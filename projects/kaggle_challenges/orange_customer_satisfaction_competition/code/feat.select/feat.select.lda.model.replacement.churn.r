#TRUE: server settings / FALSE: local settings
isServerRun = FALSE
model.name <- "RF - Feature Selection (replacement)"
model.formula <-as.formula("factor(churn)~.-appetency-upselling")      

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
    drop_na_cols,
    remove_correlated_predictors,
    convert_NAs_to_level,
    remove_linear_dependencies,
    create_replacement_columns,
    impute_data
  )
  # Need to do these up-front, otherwise we might end up with mis-matched
  # levels between training and test folds in the cross-validation loop.
  # Shouldn't introduce any bias since nothing is being imputed. 
  model.data <- apply_pre_processing(train, model.preProcessingFunctions)
  write.csv(model.data, file = "train.bin.neg.replacement.app.csv", row.names = FALSE)
} else {
  #reload from file
  model.data <- read.csv("train.bin.neg.replacement.app.csv", stringsAsFactors = FALSE)
  model.data <- convert_to_factors(model.data)
}

cutdown_data = model.data[,c("appetency","churn","upselling","V1","V101","V107","V11_new","V111","V112_new","V113","V114","V115","V116_new","V118_new","V119_new","V121","V124","V125_new","V128_new","V134","V138_new","V14","V141","V143_new","V149_new","V15","V150","V151","V154_new","V155_new","V156_new","V161","V165_new","V166","V168_new","V171","V187_new","V189_new","V190_new","V191","V192","V196_new","V197","V202","V204_new","V206","V21","V212_new","V219","V222","V224_new","V230","V29_new","V30","V37","V42","V55","V58_new","V67","V70","V71","V73_new","V75","V79_new","V81","V84","V90_new","V91","V93_new","V94","V95","V96")]

cutdown_data$V11_new=factor("V11_new")
cutdown_data$V112_new=factor("V112_new")
cutdown_data$V116_new=factor("V116_new")
cutdown_data$V118_new=factor("V118_new")
cutdown_data$V119_new=factor("V119_new")
cutdown_data$V125_new=factor("V125_new")
cutdown_data$V128_new=factor("V128_new")
cutdown_data$V138_new=factor("V138_new")
cutdown_data$V143_new=factor("V143_new")
cutdown_data$V149_new=factor("V149_new")
cutdown_data$V154_new=factor("V154_new")
cutdown_data$V155_new=factor("V155_new")
cutdown_data$V156_new=factor("V156_new")
cutdown_data$V165_new=factor("V165_new")
cutdown_data$V168_new=factor("V168_new")
cutdown_data$V187_new=factor("V187_new")
cutdown_data$V189_new=factor("V189_new")
cutdown_data$V190_new=factor("V190_new")
cutdown_data$V196_new=factor("V196_new")
cutdown_data$V204_new=factor("V204_new")
cutdown_data$V212_new=factor("V212_new")
cutdown_data$V224_new=factor("V224_new")
cutdown_data$V29_new=factor("V29_new")
cutdown_data$V58_new=factor("V58_new")
cutdown_data$V73_new=factor("V73_new")
cutdown_data$V79_new=factor("V79_new")
cutdown_data$V90_new=factor("V90_new")
cutdown_data$V93_new=factor("V93_new")

random_forest_feature_selection(model.formula, cutdown_data,500)


