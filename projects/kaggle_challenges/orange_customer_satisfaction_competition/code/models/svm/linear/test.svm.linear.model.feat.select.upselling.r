#TRUE: server settings / FALSE: local settings
isServerRun = TRUE
model.kernel = "linear"
model.name <- paste("SVM -", model.kernel, sep="")
model.formula <- as.formula("upselling~V84+V101+V14")
targetColumnName <- all.vars(model.formula)[[1]]

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


#########################################
########### Data Preprocessing ##########
#########################################
#The training and test size needs to be same to generate the confusion matrix,
#so the number of folds are set to 2 to ensure a the nested-cv fold size have an equal length
#SMOTE cannot be used on the taining fold as it changes its size, so it is set to FALSE.
#In the same vein, the last record of the dataset is removed if the dataset contains an odd number of rows

forceReloadPreCanned1 = FALSE
if (forceReloadPreCanned1) {
  print ("Force re-regen dataset")
  #List the pre-processing functions
  model.preProcessingFunctions <- c(
    drop_na_cols,
    convert_NAs_to_level,
    convert_non_num_to_factors,
    remove_correlated_predictors,
    remove_linear_dependencies,
    #bin_negative_levels_churn,
    #keep_top_10_levels,
    impute_data
  )
  # Need to do these up-front, otherwise we might end up with mis-matched
  # levels between training and test folds in the cross-validation loop.
  # Shouldn't introduce any bias since nothing is being imputed. 
  model.data <- apply_pre_processing(train, model.preProcessingFunctions)
  write.csv(model.data, file = "train.precanned.svm.csv", row.names = FALSE)
} else {
  #reload from file
  print ("Loading canned dataset")
  model.data <- read.csv("train.precanned.svm.csv", stringsAsFactors = FALSE)
  model.data <-convert_non_num_to_factors(model.data)
}

levels(model.data$appetency) <- make.names(levels(factor(model.data$appetency)))
levels(model.data$churn) <- make.names(levels(factor(model.data$churn)))
levels(model.data$upselling) <- make.names(levels(factor(model.data$upselling)))

#Have a look to ensure there is no missing data
lookAtMissingValues = FALSE
if (lookAtMissingValues){
  ggplot_missing(model.data)
}
#########################################
########### Train/Test Model ###########
#########################################
if (targetColumnName == "appetency"){
  removeUnwantedLabelCols = c(-2, -3)
} else if (targetColumnName == "churn"){
  removeUnwantedLabelCols = c(-1, -3)
} else {
  removeUnwantedLabelCols = c(-1, -2)
}

if (isServerRun) {
  train = model.data[,removeUnwantedLabelCols]
  cost=c(0.0001,0.0005, 0.001, 0.1, 1 ,5 ,10 ,100 )
  if (model.kernel == "linear"){
    hyperParams = list (cost= cost)
  } else if (model.kernel == "radial"){
      gamma=c(0.0001,0.0005, 0.001, 0.1, 0.5, 0.7, 1)
      hyperParams = list (cost= cost, gamma=gamma)
  }
  print(sprintf("hyperParams: %s", hyperParams))

} else {
  train = model.data[1:1000,removeUnwantedLabelCols]
  cost=c(0.001)
  if (model.kernel == "linear"){
    hyperParams = list (cost= cost)
  } else if (model.kernel == "radial"){
    gamma=c(0.1)
    hyperParams = list (cost= cost, gamma=gamma)
  }
  print(sprintf("hyperParams: %s", hyperParams))
}

#remove the last row if the dataset contains an odd number of rows
res = (dim(train)[1]) %% 2 
if (res !=0){
  print ("deleting the last row to ensure # rows are even")
  n<-dim(train)[1]
  train <- train[1:(n-1),]
}

train = train[,c("upselling","V84","V101","V14")]

trainMethod <- function(formula, data, ...) {
  #tune() performs a  ten fold cross validation on a set of models of interest.  
  svm.tune = tune(svm, model.formula, data=data, kernel = model.kernel, ranges = hyperParams,scale =TRUE)
  model = structure(list(svm.tune = svm.tune), class = "SvmLinearModelFeatSelectUpselling") 
  return(model)
}

predict.SvmLinearModelFeatSelectUpselling <- function(model, test.data) {
  svm.tune <- model$svm.tune
  svm.pred  <- predict(svm.tune$best.model,newx=test.data)
  return(svm.pred)
}

res = evaluate_model(
  data = train,
  formula = model.formula, 
  numFolds = 2, 
  trainMethod = trainMethod,
  trainSMOTE = FALSE, 
  debug = TRUE
)
print ("complete")