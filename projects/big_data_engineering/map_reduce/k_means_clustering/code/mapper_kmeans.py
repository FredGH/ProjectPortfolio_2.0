#!/usr/bin/env python

import sys
import math

CLUSTERS_FILENAME = 'clusters.txt'

clusters = []

#Read the initial cluster data from a file 
#and return a data object
def read_from_clusters(clusters_file):
	f = open(clusters_file, 'r')
	data = f.read()
	f.close()
	del f
	return data

#Read the cluster data object and insert each data row into a list
def read_clusters():
	#Get the clusters from the txt file
	cluster_data = read_from_clusters(CLUSTERS_FILENAME)
	#For each line in the cluster_data object
	for line in cluster_data.strip().split("\n"):
		#The centroid id and the centroid coordinates are extracted.
		centroid_id, x_coord, y_coord = line.split(" ")
		#The clusters list is appended with the centroid_id and the x/y coordinates  
		clusters.append((int(centroid_id), float(x_coord), float(y_coord)))
	
#Calculate euclidian distance between two coordinates and return the distance
def get_distance_coords(x_coord, y_coord, center_x_coord, center_y_coord):
	dist = math.sqrt(math.pow(x_coord - center_x_coord,2) + math.pow(y_coord - center_y_coord,2))
	return dist

def get_nearest_cluster(x_coord, y_coord):
	#The cluster id is unknown originally, it is discovered by the code below and returned
	nearest_cluster_id = None  	
	#The closest_distance is set as a very far initial point on the grid
    #An initial distance of 1000 is more than enough in this case, as the points coordinates
	#are all between 0 and 1 in the current datasest.
	#This assumption may need to be reviewed with other datasets.
	#This could even be passed as a parameter...
	nearest_distance = 1000	
	#For each cluster in the cluster list...
	for cluster in clusters:
		#Get the distance between the point coordinates and the cluster coordinates
		dist = get_distance_coords(x_coord, y_coord, cluster[1], cluster[2])
		#When the distance is less than the closest_distance, then
		#the closest_distance is reset to the current distance.
		#Else the process continues until a closer cluster is found.
		if dist < nearest_distance:
			nearest_cluster_id = cluster[0]
			nearest_distance = dist
	#Return the closest_cluster_id for point coordinates 
	return nearest_cluster_id
	
#Read the clusters information from a file and store the data into an in-memory list 	
read_clusters()

#For each line in the standard input, the mapper produces a key/value pair output.
#It serves as input for the reducer. The key is the cluster_id. 
#the value is a composite of the x and y point coordinates separated by a comma
for line in sys.stdin:
	#The line is empty, skip to the next line
	if len(line) == 0:
		continue
	#Get the point coordinates (x and y)
	coords = line.strip().split(" ")
	x_coord,y_coord = coords
	#Compute the nearest_cluster_id based on the point coordinates and
	#the in-memory cluster list (read from the CLUSTERS_FILENAME file)
	nearest_cluster_id = get_nearest_cluster(float(x_coord), float(y_coord))
	#Fabricate a key/value pair object ouput that serves as input for the reducer task.	
	#Also add one at the end of the string in order to facilitate the counting of points
	#for a given cluster_id in the reducer.  
	print ("%s\t%s" % (str(nearest_cluster_id),str(x_coord) + "," + str(y_coord) + "," + str(1) ))