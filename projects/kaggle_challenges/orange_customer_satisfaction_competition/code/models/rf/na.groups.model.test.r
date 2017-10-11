setwd('C:/Users/john/dev/goldsmiths/mlsdm/assignment3/submission')
source("init_data.r")

test.data <- test

# Re-apply pre-processing steps where relevant
test.data$V22 <- fillna(test.data$V22, "NA")
test.data$V27 <- fillna(test.data$V27, "NA")
test.data$V50 <- fillna(test.data$V50, "NA")
test.data$V138 <- fillna(test.data$V138, "NA")
test.data$V143 <- fillna(test.data$V143, "NA")
test.data$V165 <- fillna(test.data$V165, "NA")
test.data$V182 <- fillna(test.data$V182, "NA")

# Discrete/continuous numeric values - replace with mode. Strictly speaking, 
# this imputation should be done on training and validation folds separately, 
# however the frequency of the modal values is overwhelmingly high compared 
# to other values, so I'm assuming that the end result would be the same.
test.data$V36 <- fillna(test.data$V36, 552)
test.data$V61 <- fillna(test.data$V61, 0)
test.data$V84 <- fillna(test.data$V84, 8)
test.data$V101 <- fillna(test.data$V101, 0)
test.data$V120 <- fillna(test.data$V120, 0)
test.data$V176 <- fillna(test.data$V176, 0)
test.data$V183 <- fillna(test.data$V183, 0)
test.data$V185 <- fillna(test.data$V185, 0)

test.data <- add_num_std_devs(
  data = test.data
)

test.data <- scale_and_normalise(test.data)

#for (targetColumnName in trainLabelNames) {
#for (targetColumnName in c("churn")) {
#for (targetColumnName in c("upselling")) {
for (targetColumnName in c("appetency")) {

  print(sprintf("Making predictions on test data for target label %s", targetColumnName))
  
  load(sprintf("models/rf/NaGroups_%s.rda", targetColumnName))
  
  test.eval.data <- test.data
  
  test.eval.data <- bin_levels(
    data = test.eval.data, 
    levelNamesList = allNegativeLevels, 
    binLevelName = "ALL_NEGATIVE"
  )
  
  test.eval.data <- bin_levels(
    data = test.eval.data, 
    levelNamesList = binnedLevels,
    binLevelName = "BIN"
  )
  
  test.eval.data <- bin_levels(
    data = test.eval.data, 
    levelNamesList = knownLevels, 
    binLevelName = "BIN", 
    binLevelsInList = FALSE
  )
    
  predictions <- predict(predictor, test.eval.data)

  # write them to a csv file
  con <- file(sprintf("models/rf/BasicRF_%s.csv", targetColumnName), encoding="UTF-8")
  write.table(predictions, file=con, row.names=FALSE, col.names=FALSE, sep=",")

}