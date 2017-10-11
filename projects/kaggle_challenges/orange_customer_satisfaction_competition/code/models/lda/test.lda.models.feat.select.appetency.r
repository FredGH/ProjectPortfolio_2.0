#TRUE: server settings / FALSE: local settings
isServerRun = FALSE
model.name <- "LDA"
model.formula <-as.formula("appetency ~ V84+V118+V165+V224+V116+V155+V14+V90")

print(sprintf("model: %s formula: %s", model.name, deparse(model.formula)))

#########################################
############## Drive Config #############
#########################################
if(isServerRun){
  setwd('/host/dsm1/fmare001/stats/svm/deliverables')
}else{
  #setwd('C:/Users/audrey.ekuban/dev/goldsmiths/mlsdm/assignment3')
  setwd('C:/Users/john/dev/goldsmiths/mlsdm/assignment3/submission')
  #setwd('C:/Users/Fred/Desktop/Studies/MSc-DataScience/Statistical Learning/Assignments/Assignment3/deliverables')
}

#########################################
########### Load Dependencies ###########
#########################################
source("init_data.r")
source("exploratory_functions.r")
source("pre_processing_functions.r")
source("feat_selection.r")
source("util_functions.r")
require(e1071)

#List the pre-processing functions
model.preProcessingFunctions <- c(
  drop_na_cols,
  remove_correlated_predictors,
  convert_NAs_to_level,
  remove_linear_dependencies
)

forceReloadPreCanned1 = TRUE
if (forceReloadPreCanned1) {
  
  model.data <- bin_levels_if_not_in_test_set(train, test, "BIN")
  model.data <- apply_pre_processing(model.data, model.preProcessingFunctions)
  
  model.data <- bin_negative_levels(data = model.data, targetColumnName = "appetency", binLevelName = "ALL_NEGATIVE") 
  allNegativeLevels <- attr(model.data, "ALL_NEGATIVE")
  
  model.data <- keep_top_X_levels(data = model.data, X = 10, binLevelName = "BIN")
  binnedLevels <- attr(model.data, "BIN")
  
  write.csv(model.data, file = "train.bin.neg.top10.app.csv", row.names = FALSE)
} else {
  #reload from file
  model.data <- read.csv("train.bin.neg.top10.app.csv", stringsAsFactors = FALSE)
  model.data <- convert_to_factors(model.data)
}

#Have a look to ensure there is no missing data
lookAtMissingValues = FALSE
if (lookAtMissingValues){
  ggplot_missing(model.data)
}

#Run a Kolmogorov Smirnov test on numerical data
par( mfrow = c( 2, 2 ) )
df =  subset(subset(model.data, select=c("appetency","V84")), model.data$appetency == 1)
kolmogorov_smirnov_normal_distribution_test(df$V84, paste("'V84/appetency == 1' is normally distributed", sep=""))
plot_qqplot (df$V84, "V84/appetency == 1")
df =  subset(subset(model.data, select=c("appetency","V84")), model.data$appetency == -1)
kolmogorov_smirnov_normal_distribution_test(df$V84, paste("'V84/appetency == -1' is normally distributed", sep=""))
plot_qqplot (df$V84, "V84/appetency == -1")

df =  subset(subset(model.data, select=c("appetency","V14")), model.data$appetency == 1)
kolmogorov_smirnov_normal_distribution_test(df$V14, paste("'V14/appetency == 1' is normally distributed", sep=""))
plot_qqplot (df$V14, "V14/appetency == 1")
df =  subset(subset(model.data, select=c("appetency","V14")), model.data$appetency == -1)
kolmogorov_smirnov_normal_distribution_test(df$V14, paste("'V14/appetency == -1' is normally distributed", sep=""))
plot_qqplot (df$V14, "V14/appetency == -1")
par( mfrow = c( 1, 1 ) ) 

train.LDAappetency <- function(formula, data) {

  data <- impute_data(data)
  data <- SMOTE(form = formula, data = data)

  caretModel <- train (
    formula, 
    data,
    method = "lda", 
    metric = "Kappa",
    trControl = trainControl(
      method = "repeatedcv", 
      number = 10, 
      repeats = 5, 
      selectionFunction = "oneSE"
    )
  )
  
  model <- structure(
    list(
      model = caretModel
    ),
    class = "LDAappetency"
  ) 
  
  return(model)
}
  
predict.LDAappetency <- function(model, data) {
  model <- model$model
  data <- impute_data(data)
  predictions <- predict(model, data)
  return(predictions)
}
  
knownLevels <- list_factor_levels(model.data)

#Get the AUC
res = evaluate_model(
  data = model.data,
  formula = model.formula,
  trainMethod = train.LDAappetency,
  debug = TRUE
)

auc <- res[["auc"]]
predictor <- res[["model"]]

print(sprintf("Model %s AUC score = %s", model.name, res$auc)) 

# save the predictor model - and any state it depends on
save(allNegativeLevels,
     auc,
     binnedLevels,
     knownLevels,
     predictor,
     predict.LDAappetency,
     file = "models/lda/LDAappetency.rda"
)

print("Applying pre-processing to test data")
test.data <- apply_pre_processing(test, model.preProcessingFunctions)

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
con <- file("models/lda/LDA_appetency.csv", encoding="UTF-8")
write.table(predictions, file=con, row.names=FALSE, col.names=FALSE, sep=",")



