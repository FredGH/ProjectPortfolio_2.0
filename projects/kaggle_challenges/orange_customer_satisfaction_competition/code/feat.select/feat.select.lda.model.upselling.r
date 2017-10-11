#TRUE: server settings / FALSE: local settings
isServerRun = FALSE
model.name <- "RF - Feature Selection"
model.formula <-as.formula("factor(upselling)~.")

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
require(randomForest)

forceReloadPreCanned1 = TRUE
if (forceReloadPreCanned1) {
  #List the pre-processing functions
  model.preProcessingFunctions <- c(
    convert_to_factors, 
    drop_na_cols,
    remove_correlated_predictors,
    convert_NAs_to_level,
    remove_linear_dependencies,
    bin_negative_levels_churn,
    keep_top_10_levels,
    impute_data
  )
  # Need to do these up-front, otherwise we might end up with mis-matched
  # levels between training and test folds in the cross-validation loop.
  # Shouldn't introduce any bias since nothing is being imputed. 
  model.data <- apply_pre_processing(train, model.preProcessingFunctions)
  write.csv(model.data, file = "train.bin.neg.top10.upselling.csv", row.names = FALSE)
} else {
  #reload from file
  model.data <- read.csv("train.bin.neg.top10.upselling.csv", stringsAsFactors = FALSE)
  model.data <- convert_to_factors(model.data)
}

random_forest_feature_selection(model.formula, model.data,500)


