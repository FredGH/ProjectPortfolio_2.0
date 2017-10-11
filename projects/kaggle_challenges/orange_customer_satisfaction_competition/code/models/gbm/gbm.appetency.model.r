setwd('C:/Users/audrey.ekuban/dev/goldsmiths/mlsdm/assignment3/merged')

library(caret)
library(gbm)				  # GBM Models
require(plyr)
require(dplyr)

ptm <- proc.time()

set.seed(1)
source("init_data.r")
source("test_harness.r")

model.name <- "xgbTrain#appetency"

model.data.discrete = train[discreteNumericVarNames]
model.data.continuous = train[continuousVarNames]
model.data.character = train[characterVarNames]

# ----------------DISCRETE VALUES-----------------------------------
# This is just for figuring out if the model is the best.
# If it does turn out to be the best then we would need to figure out
# which value goes into which bin. But no different to the "keep levels"
# method
model.data.discrete[] = lapply(model.data.discrete, function(x)  
  x = percent_rank(x))

model.data.discrete[] = lapply(model.data.discrete, function(x)
  ifelse(is.na(x), x, 
  ifelse(x == 0, "N", 
  ifelse(x < 0.25, "L",
  ifelse(x < 0.5, "LM",
  ifelse(x < 0.75, "MH", "H"))))))

model.data.discrete[] = lapply(model.data.discrete, function(x) 
  factor(x))

model.data.discrete[] = lapply(model.data.discrete, function(x) 
  if(is.factor(x)) fillna(x, "NA") else x)



# ------------- CHARACTER DATA ---------------------------------
# GBM cannot handle levels greater than 1024 
# Bin character data based on the 1st 3 characters
model.data.character[] = lapply(model.data.character, function(x) 
  fillna(x, "NA"))

model.data.character[] = lapply(model.data.character, function(x) 
  factor(substr(x, 1, 3)))

model.data.character = keep_top_X_levels(model.data.character, 100, "BIN")

# ------------- preProcessing function -------------------------------
model.preProcessingFunctions <- c(
  drop_na_cols
)


model.data = cbind(model.data.discrete, model.data.continuous, model.data.character)
model.data <- apply_pre_processing(model.data, model.preProcessingFunctions)

model.data = model.data %>% 
  mutate(appetency = factor(trainLabels$appetency))
model.data$appetency = factor((ifelse(model.data$appetency == 1, "P", "N")))

# Split Data - Only for development
#model.data.training <-
# createDataPartition(model.data$appetency, p=0.75, list=FALSE)
#model.data.train <- model.data[model.data.training,]
#model.data.test <- model.data[-model.data.training,]


model.formula = as.formula("appetency~.")

gbm.train <- function(formula, data) {
#  data = model.data.train  
  # ------------- preProcessing for Train data -------------------------------
  model.preProcessingFunctions <- c(
    impute_data
  )
  data <- apply_pre_processing(data, model.preProcessingFunctions)
  
  ctrl <- trainControl(method = "cv",   # 10fold cross validation
                     number = 5,							# do 5 repititions of cv
                     summaryFunction=twoClassSummary,	# Use AUC to pick the best model
                     classProbs=TRUE,
                     sampling = "smote")

  # Use the expand.grid to specify the search space	
  grid <- expand.grid(interaction.depth=5,
                    n.trees=100,	 
                    shrinkage=0.01,	
                    n.minobsinnode = 20)

  set.seed(2017)
  data.train = data %>% select(-c(appetency))
  gbm.tune <- train(x=data.train, y=data$appetency,
                  method = "gbm",
                  metric = "ROC",
                  trControl = ctrl,
                  tuneGrid=grid,
                  verbose=TRUE)

}


#data = model.data.test  

boosting.predict <- function(fitted.model, data) {
    # ------------- preProcessing for Train data -------------------------------
   model.preProcessingFunctions <- c(
      impute_data
    )
   data <- apply_pre_processing(data, model.preProcessingFunctions)
   data.test = data %>% select(-c(appetency))
   model.pred = predict(fitted.model, data.test)
}

model.table <- table(
  "Prediction" = model.pred,
  "Truth" = model.data.test$appetency
)


res = evaluate_model(
  data = model.data,
  formula = model.formula, 
  trainMethod = gbm.train,
  boosting = TRUE,
  trainSMOTE = FALSE,
  debug = TRUE
)

proc.time() - ptm

#model.table

#varImp(gbm.tune)
#calculate_metrics(model.table)
#gbm.perf(gbm.tune) 