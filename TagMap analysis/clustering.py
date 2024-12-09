import pysam
import pandas as pd
import sys

#The sam file should contain the header.

sam_path = sys.argv[1] 
samfile = pysam.AlignmentFile(sam_path, mode="r")
coordinate_p = []
coordinate_n = []
for read in samfile:
    #Get chromosome name.
    chromosome_name = read.reference_name
    if chromosome_name[3:] == "X":
        chromosome_number = 23
    else:
        chromosome_number = int(chromosome_name[3:])
    #Get alignment coordinate. 
    position = read.reference_start
    #Get mapping strand. 
    if read.is_reverse == True: 
        strand = "-"
        coordinate_n.append((chromosome_number,strand,position))
    else:
        strand = "+"
        coordinate_p.append((chromosome_number,strand,position))

coordinate_n_sorted = sorted(coordinate_n)
coordinate_p_sorted = sorted(coordinate_p)
'''
print(coordinate_n_sorted)
print(coordinate_p_sorted)
'''

integration_n = []
integration_p = []
#Initial a varibale that make sure the first read of negative strand is included.
integ_first_read_coord_n = [1,1,-1000]
#Initial a varibale that make sure the first read of positive strand is not included.
integ_first_read_coord_p = coordinate_p_sorted[0]

#For negative strand, take the smallest coordinate as the one that is closest to the intregration.
for coord_n in coordinate_n_sorted:
    if coord_n[0] == integ_first_read_coord_n[0]:
        if coord_n[2] - integ_first_read_coord_n[2] > 500:
                integration_n.append(coord_n)
                integ_first_read_coord_n = coord_n
    else:
        integration_n.append(coord_n)
        integ_first_read_coord_n = coord_n
    
#For positive strand, take the largest coordinate as the one that is closest to the intregration.
for coord_p in coordinate_p_sorted:
    if coord_p[0] == integ_first_read_coord_p[0]:
        if coord_p[2] - integ_first_read_coord_p[2] >500:
                integration_p.append(coord_last)
                integ_first_read_coord_p = coord_p
    else:
        integration_p.append(coord_last)
        integ_first_read_coord_p = coord_p
    coord_last = coord_p

integration_final =[]

for integ_p in integration_p:
    if integ_p[0] == 23:
        integ_p_list = list(integ_p)
        integ_p_list[0] = "chrX"
        integ_p_tuple = tuple(integ_p_list)
    else:
        integ_p_list = list(integ_p)
        integ_p_list[0] = "chr" + str(integ_p[0])
        integ_p_tuple = tuple(integ_p_list)
    integration_final.append(integ_p_tuple)
for integ_n in integration_n:
    if integ_n[0] == 23:
        integ_n_list = list(integ_n)
        integ_n_list[0] = "chrX"
        integ_n_tuple = tuple(integ_n_list)
    else:
        integ_n_list = list(integ_n)
        integ_n_list[0] = "chr" + str(integ_n[0])
        integ_n_tuple = tuple(integ_n_list)
    integration_final.append(integ_n_tuple)

number_of_integ = len(integration_final)

integ_list_for_df = []
counter = 0
for i in integration_final:
    counter += 1
    integ_list_for_df.append((i[0],i[2],i[2]+1,str(counter),".",i[1]))


integ_df = pd.DataFrame(integ_list_for_df)
file_name = sys.argv[2]
integ_df.to_csv(file_name,sep='\t',header=None,index=False)


