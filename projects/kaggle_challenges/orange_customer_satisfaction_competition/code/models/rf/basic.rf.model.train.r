setwd('C:/Users/john/dev/goldsmiths/mlsdm/assignment3/submission')
set.seed(1)
source("init_data.r")
source("models/rf/basic.rf.model.r")

model.name <- "BasicRF"
model.data <- train

predictors <- c("V11",  "V14",  "V22",  "V27",  "V29",  "V42",  "V50",  "V73",  "V90",
                "V111", "V112", "V116", "V119", "V128", "V138", "V143", "V154", "V155", 
                "V165", "V168", "V182", "V190", "V204", "V212", "V224")

ordinalCharacterLevels <- c(
               "V11", "V29", "V90", "V116", "V138", "V165", "V190", "V224")

model.data <- model.data[, c(predictors, trainLabelNames)]
model.data <- convert_NAs_to_level(model.data)

model.data <- add_num_std_devs(
  data = model.data,
  colnames = ordinalCharacterLevels
)

model.data <- bin_levels_if_not_in_test_set(
  trainData = model.data, 
  testData = test, 
  binLevelName = "BIN"
) # stick in same BIN as others, at least have chance of getting some right

model.data <- scale_and_normalise(model.data)

for (targetColumnName in "appetency") {
#for (targetColumnName in trainLabelNames) {

  print(sprintf("Evaluating model for target label %s", targetColumnName))
    
  model.formula <- as.formula(
    paste(
      targetColumnName,
      " ~ ",
      paste(predictors, collapse = "+"), "+",
      paste(ordinalCharacterLevels, collapse = "_SD+"), "_SD", 
      sep = ""
    )
  )
    
  model.eval.data <- removeCols(model.data, trainLabelNames[!(targetColumnName == trainLabelNames)])
  
  model.eval.data <- bin_negative_levels(
    data = model.eval.data, 
    targetColumnName = targetColumnName, 
    binLevelName = "ALL_NEGATIVE"
  ) 
  allNegativeLevels <- attr(model.eval.data, "ALL_NEGATIVE")
  
  model.eval.data <- keep_top_X_levels(
    data = model.eval.data, 
    X = 30, 
    binLevelName = "BIN"
  )
  binnedLevels <- attr(model.eval.data, "BIN")
  
  model.eval.data <- add_bin_levels(model.eval.data, "BIN")
  model.eval.data <- add_bin_levels(model.eval.data, "ALL_NEGATIVE")
  knownLevels <- list_factor_levels(model.eval.data)
  
  res = evaluate_model(
    data = model.eval.data, 
    formula = model.formula, 
    debug = TRUE,
    trainMethod = train.BasicRF
  )
  
  auc <- res[["auc"]]
  predictor <- res[["model"]]
  
  # save the predictor model - and any state it depends on
  save(allNegativeLevels,
       auc,
       binnedLevels,
       debug.test,
       knownLevels,
       ordinalCharacterLevels,
       predictor,
       predict.BasicRF,
       predictors,
       file = sprintf("models/rf/BasicRF_%s.rda", targetColumnName)
  )
}

