setwd('C:/Users/john/dev/goldsmiths/mlsdm/assignment3/submission')
source("init_data.r")

for (targetColumnName in "appetency") {
  #for (targetColumnName in trainLabelNames) {

  print(sprintf("Loading model BasicRF_%s.rda", targetColumnName))
  
  load(sprintf("models/rf/BasicRF_%s.rda", targetColumnName))
  
  print("Applying pre-processing to test data")
  
  test.data <- test[, predictors]
  
  # Re-apply pre-processing steps where relevant
  test.data <- convert_NAs_to_level(test.data)
  
  test.data <- add_num_std_devs(
    data = test.data,
    colnames = ordinalCharacterLevels
  )
    
  test.data <- scale_and_normalise(test.data)
      
  test.data <- bin_levels(
    data = test.data, 
    levelNamesList = allNegativeLevels, 
    binLevelName = "ALL_NEGATIVE"
  )
  
  test.data <- bin_levels(
    data = test.data, 
    levelNamesList = binnedLevels,
    binLevelName = "BIN"
  )
  
  test.data <- bin_levels(
    data = test.data, 
    levelNamesList = knownLevels, 
    binLevelName = "BIN", 
    binLevelsInList = FALSE
  )
  
  print("Making predictions on test data")
  predictions <- predict(predictor, test.data)
    
  # write them to a csv file
  con <- file(sprintf("models/rf/BasicRF_%s.csv", targetColumnName), encoding="UTF-8")
  write.table(predictions, file=con, row.names=FALSE, col.names=FALSE, sep=",")
   
}