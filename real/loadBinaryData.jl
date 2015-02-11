# CHANGE THIS TO USE DIFFERENT DATASET!!!
datasetHT = datasetArray[1]

println("Reading binary file "*datasetHT["path"]*datasetHT["name"]*".bin")

@time (features,labels) = readBin(datasetHT["path"]*datasetHT["name"]*".bin",int(datasetHT["nDatapoints"]),int(datasetHT["nFeatures"]))