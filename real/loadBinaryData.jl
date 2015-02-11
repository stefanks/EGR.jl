# CHANGE THIS TO USE DIFFERENT DATASET!!!
datasetHT = datasetArray[1]

(features,labels) = readBin(datasetHT["path"]*datasetHT["name"]*".bin",int(datasetHT["nDatapoints"]),int(datasetHT["nFeatures"]))