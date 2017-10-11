#TRUE: server settings / FALSE: local settings
isServerRun = FALSE
model.name <- "LDA"
model.formula <-as.formula("churn ~ V118+V224+V165+V84+V155+V14+V116+V149+V111+V156+V149")

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
      bin_negative_levels_churn,
      keep_top_10_levels,
      impute_data
  )
  model.data <- apply_pre_processing(train, model.preProcessingFunctions)
  write.csv(model.data, file = "train.bin.neg.top10.churn.csv", row.names = FALSE)
} else {
  #reload from file
  model.data <- read.csv("train.bin.neg.top10.app.churn.csv", stringsAsFactors = FALSE)
  model.data <- convert_to_factors(model.data)
}

#Have a look to ensure there is no missing data
lookAtMissingValues = FALSE
if (lookAtMissingValues){
  ggplot_missing(model.data)
}

#Run a Kolmogorov Smirnov test on numerical data
par( mfrow = c( 2, 2 ) )
df =  subset(subset(model.data, select=c("churn","V84")), model.data$churn == 1)
kolmogorov_smirnov_normal_distribution_test(df$V84, paste("'V84/churn == 1' is normally distributed", sep=""))
plot_qqplot (df$V84, "V84/churn == 1")
df =  subset(subset(model.data, select=c("churn","V84")), model.data$churn == -1)
kolmogorov_smirnov_normal_distribution_test(df$V84, paste("'V84/churn == -1' is normally distributed", sep=""))
plot_qqplot (df$V84, "V84/churn == -1")

df =  subset(subset(model.data, select=c("churn","V14")), model.data$churn == 1)
kolmogorov_smirnov_normal_distribution_test(df$V14, paste("'V14/churn == 1' is normally distributed", sep=""))
plot_qqplot (df$V14, "V14/churn == 1")
df =  subset(subset(model.data, select=c("churn","V14")), model.data$churn == -1)
kolmogorov_smirnov_normal_distribution_test(df$V14, paste("'V14/churn == -1' is normally distributed", sep=""))
plot_qqplot (df$V14, "V14/churn == -1")

df =  subset(subset(model.data, select=c("churn","V111")), model.data$churn == 1)
kolmogorov_smirnov_normal_distribution_test(df$V111, paste("'V111/churn == 1' is normally distributed", sep=""))
plot_qqplot (df$V111, "V111/churn == 1")
df =  subset(subset(model.data, select=c("churn","V111")), model.data$churn == -1)
kolmogorov_smirnov_normal_distribution_test(df$V111, paste("'V111/churn == -1' is normally distributed", sep=""))
plot_qqplot (df$V111, "V111/churn == -1")

par( mfrow = c( 1, 1 ) ) 

#Get the AUC
res = evaluate_model(
  # args to model.evaluate
  data = model.data,
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

