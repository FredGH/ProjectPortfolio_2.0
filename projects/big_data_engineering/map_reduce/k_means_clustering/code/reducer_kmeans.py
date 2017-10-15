#!/usr/bin/env python

import sys

#It is assumed cluster ids are always positive
current_cluster_id = -1
clusters = dict()

#For each line in the system input (i.e. the key/value pair) generated after shuffling/sorting and automatic shuffling.
#The key is the cluster_id, the value is a composite of the x and y point coordinates separated by a comma.
for line in sys.stdin:
	#The line is empty, skip to the next line
	if len(line) == 0:
		continue
	#Get the input data from the line
	data_mapped = line.strip().split("\t")
	#The data is not in the expected shape, then ignore and move to the next line
	if len(data_mapped) != 2:
		continue	
	#Get the cluster_id and the sum of the x/y coordinates with the points count for a cluster  
	cluster_id, count = data_mapped
	x_coord_sum, y_coord_sum, count = count.strip().split(",")

	#As the data has been shuffled/sorted, 
	#the input data may contain more than one records with the same cluster_id
	#We therefore, to reduce them here, prior to do the cluster new center calculation
	count = int(count)
	x_coord_sum = float(x_coord_sum)
	y_coord_sum = float(y_coord_sum)
	if current_cluster_id == cluster_id:
		count_total += count
		x_coord_total +=  x_coord_sum
		y_coord_total +=  y_coord_sum			
	else:
		current_cluster_id = cluster_id
		count_total = count
		x_coord_total =  x_coord_sum
		y_coord_total =  y_coord_sum
	#This time the clustes map contains the final sum of the x/y coordinates and the final point count for a given cluster
	clusters[current_cluster_id] = (x_coord_total, y_coord_total, count_total) 

#Output the cluster_id, the average of x and y coordinates (new centroid) for each cluster	
for key in clusters:
	x_coord_total, y_coord_total, count_total = clusters[key]
	print (str(key) + " " + str(x_coord_total/count_total) + " " + str(y_coord_total/count_total))	