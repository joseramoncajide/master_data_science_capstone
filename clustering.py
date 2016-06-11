## Spark Application - execute with spark-submit

## Imports
import pyspark
from pyspark.mllib.clustering import KMeans, KMeansModel
from math import sqrt
from numpy import array
import pandas as pd
import numpy as np
from pyspark import SparkConf, SparkContext


## Module Constants
APP_NAME = "Clustering App"

## Closure Functions
def flatten_cluster_data(r):
    return {"PER_ID_PERSONA": r[0], "cluster" : r[1][0], "F1": r[1][1][0], "F2": r[1][1][1], "F3": r[1][1][2], "F4": r[1][1][3], "F5": r[1][1][4], "F6": r[1][1][5]}

## Main functionality
def main(sc):
	data = sc.newAPIHadoopFile('clustering/data_scaled.csv', "org.apache.hadoop.mapreduce.lib.input.TextInputFormat",
    "org.apache.hadoop.io.LongWritable", "org.apache.hadoop.io.Text",
    conf={"textinputformat.record.delimiter": '\n'}).map(lambda x: x[1].strip().split(","))
	
	clustering_input_pairs = data.map(lambda x: (x[0], array([float(x[1]), float(x[2]), float(x[3]), float(x[4]), float(x[5]), float(x[6])])))
	
	clustering_input = data.map(lambda x: array([float(x[1]), float(x[2]), float(x[3]), float(x[4]), float(x[5]), float(x[6])]))

	final_clusters = KMeans.train(clustering_input, 4, maxIterations=10, runs=10, initializationMode="random")
	
	cluster_membership = clustering_input_pairs.mapValues(lambda x: final_clusters.predict(x))
	
	complete_cluster_data = cluster_membership.join(clustering_input_pairs).map(flatten_cluster_data)

	# Save de RDD on HFDS 
	# complete_cluster_data.saveAsTextFile('clustering/results')

	# Convert the RDD to a Pandas DataFrame
	cluster_df = pd.DataFrame(complete_cluster_data.collect())
	
	# Save results to a csv file on local file system
	cluster_df.to_csv('results.csv', sep=',', encoding='utf-8')


if __name__ == "__main__":
    # Configure Spark
    conf = SparkConf().setMaster("local[*]")
    conf = conf.setAppName(APP_NAME)
    # Increased kryoserializer buffer was necessary to succesfull run this app
    conf = conf.set("spark.kryoserializer.buffer.max", "2047")
    sc   = SparkContext(conf=conf)
    
    # Execute main functionality
    main(sc)

    
