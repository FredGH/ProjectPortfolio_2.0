#TRUE: server settings / FALSE: local settings
isServerRun = FALSE
model.name <- "LDA"
model.formula <-as.formula("churn~.")

print(sprintf("model: %s formula: %s", model.name, deparse(model.formula)))

#########################################
############## Drive Config #############
#########################################
if(isServerRun){
  setwd('/host/dsm1/fmare001/stats/svm/deliverables')
}else{
  #setwd('C:/Users/audrey.ekuban/dev/goldsmiths/mlsdm/assignment3')
  #setwd('C:/Users/john/dev/goldsmiths/mlsdm/assignment3/submission')
  setwd('C:/Users/Fred/Desktop/Studies/MSc-DataScience/Statistical Learning/Assignments/Assignment3/deliverables')
}

#########################################
########### Load Dependencies ###########
#########################################
source("init_data.r")
source("exploratory_functions.r")
source("pre_processing_functions.r")
source("feat_selection.r")
require(e1071)

forceReloadPreCanned1 = TRUE
if (forceReloadPreCanned1) {
  #List the pre-processing functions
  model.preProcessingFunctions <- c(
      convert_to_factors, 
      drop_na_cols,
      remove_correlated_predictors,
      convert_NAs_to_level,
      remove_linear_dependencies,
      create_replacement_columns,
      impute_data
  )
  model.data <- apply_pre_processing(train, model.preProcessingFunctions)
  write.csv(model.data, file = "train.replacement.churn.csv", row.names = FALSE)
} else {
  #reload from file
  model.data <- read.csv("train.replacement.churn.csv", stringsAsFactors = FALSE)
  model.data <- convert_to_factors(model.data)
}

#Have a look to ensure there is no missing data
lookAtMissingValues = FALSE
if (lookAtMissingValues){
  ggplot_missing(model.data)
}


sub <- model.data[,c("churn","V14","V84","V111","V70","V192","V222","V161","V55","V141","V101","V191","V134")]

res = evaluate_model(
  # args to model.evaluate
  data = sub,
  formula = model.formula,
  trainSMOTE = TRUE,
  debug = TRUE,
  # args passed through to other functions e.g. caret
  method = "lda", 
  metric = "Kappa", 
  #preProcess=c("knnImpute"), 
  trControl = trainControl(
    method = "repeatedcv", 
    number = 10, 
    repeats = 5,
    selectionFunction = "oneSE"
  )
)

print(sprintf("Model %s AUC score = %s", model.name, res$auc)) 

