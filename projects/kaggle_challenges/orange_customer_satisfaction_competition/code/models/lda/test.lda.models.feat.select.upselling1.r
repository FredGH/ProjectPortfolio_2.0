#TRUE: server settings / FALSE: local settings
isServerRun = FALSE
model.name <- "LDA"
model.formula <-as.formula("upselling ~V84+V101+V14+V155+V111+V70+V222+V192+V141+V161+V191+V55+V156+V91+V37+V116+V42+V134+V189+V96+V1+V121+V166+V124+V81+V151+V75+V206+V197+V165")

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
  
  model.data <- bin_negative_levels(data = model.data, targetColumnName = "upselling", binLevelName = "ALL_NEGATIVE") 
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
df =  subset(subset(model.data, select=c("upselling","V84")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V84, paste("'V84/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V84, "V84/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V84")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V84, paste("'V84/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V84, "V84/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V14")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V14, paste("'V14/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V14, "V14/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V14")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V14, paste("'V14/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V14, "V14/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V101")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V101, paste("'V101/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V101, "V101/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V101")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V101, paste("'V101/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V101, "V101/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V111")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V111, paste("'V111/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V111, "V111/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V111")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V111, paste("'V111/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V111, "V111/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V70")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V70, paste("'V70/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V70, "V70/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V70")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V70, paste("'V70/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V70, "V70/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V222")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V222, paste("'V222/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V222, "V222/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V222")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V222, paste("'V222/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V222, "V222/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V192")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V192, paste("'V192/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V192, "V192/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V192")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V192, paste("'V192/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V192, "V192/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V141")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V141, paste("'V141/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V141, "V141/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V141")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V141, paste("'V141/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V141, "V141/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V161")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V161, paste("'V161/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V161, "V161/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V161")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V161, paste("'V161/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V161, "V161/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V191")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V191, paste("'V191/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V191, "V191/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V191")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V191, paste("'V191/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V191, "V191/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V55")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V55, paste("'V55/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V55, "V55/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V55")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V55, paste("'V55/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V55, "V55/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V91")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V91, paste("'V91/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V91, "V91/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V91")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V91, paste("'V91/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V91, "V91/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V37")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V37, paste("'V37/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V37, "V37/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V37")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V37, paste("'V37/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V37, "V37/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V42")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V42, paste("'V42/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V42, "V42/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V42")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V42, paste("'V42/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V42, "V42/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V134")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V134, paste("'V134/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V134, "V134/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V134")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V134, paste("'V134/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V134, "V134/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V96")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V96, paste("'V96/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V96, "V96/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V96")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V96, paste("'V96/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V96, "V96/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V1")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V1, paste("'V1/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V1, "V1/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V1")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V1, paste("'V1/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V1, "V1/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V121")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V121, paste("'V121/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V121, "V121/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V121")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V121, paste("'V121/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V121, "V121/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V166")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V166, paste("'V166/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V166, "V166/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V166")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V166, paste("'V166/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V166, "V166/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V124")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V124, paste("'V124/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V124, "V124/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V124")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V124, paste("'V124/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V124, "V124/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V81")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V81, paste("'V81/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V81, "V81/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V81")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V81, paste("'V81/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V81, "V81/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V151")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V151, paste("'V151/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V151, "V151/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V151")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V151, paste("'V151/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V151, "V151/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V75")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V75, paste("'V75/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V75, "V75/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V75")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V75, paste("'V75/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V75, "V75/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V206")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V206, paste("'V206/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V206, "V206/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V206")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V206, paste("'V206/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V206, "V206/upselling == -1")

df =  subset(subset(model.data, select=c("upselling","V197")), model.data$upselling == 1)
kolmogorov_smirnov_normal_distribution_test(df$V197, paste("'V197/upselling == 1' is normally distributed", sep=""))
plot_qqplot (df$V197, "V197/upselling == 1")
df =  subset(subset(model.data, select=c("upselling","V197")), model.data$upselling == -1)
kolmogorov_smirnov_normal_distribution_test(df$V197, paste("'V197/upselling == -1' is normally distributed", sep=""))
plot_qqplot (df$V197, "V197/upselling == -1")

par( mfrow = c( 1, 1 ) ) 



train.LDAupselling <- function(formula, data) {
  
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
    class = "LDAupselling"
  ) 
  
  return(model)
}

predict.LDAupselling <- function(model, data) {
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
  trainMethod = train.LDAupselling,
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
     predict.LDAupselling,
     file = "models/lda/LDAupselling.rda"
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
con <- file("models/lda/LDA_upselling.csv", encoding="UTF-8")
write.table(predictions, file=con, row.names=FALSE, col.names=FALSE, sep=",")



