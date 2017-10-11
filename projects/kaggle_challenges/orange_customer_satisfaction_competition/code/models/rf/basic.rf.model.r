debug.train <- TRUE
debug.test <- TRUE
train.ntree <- 50

train.BasicRF <- function(formula, data) {
  
  print("training..")
  
  targetColumnName <- get_target_column_name(formula)
  if (debug.train) {
    print(sprintf("targetColumnName is %s", targetColumnName))
  }

  levels(data[, targetColumnName]) <- c("NO", "YES")
  
  # Using sampling = "smote" in trainControl doesn't always seem to work
  if (debug.train) {
    print("applying SMOTE")
  }
  data <- SMOTE(form = formula, data = data)
  
  if (debug.train) {
    print("fitting model")
  }
  
  caretModel <- train( 
    formula,
    data,
    method = "rf",
    metric = "ROC",
    ntree = train.ntree,
    trControl = trainControl(
      method = "repeatedcv", 
      number = 5,
      classProbs = TRUE,
      summaryFunction = twoClassSummary
    )
  )

  model <- structure(list(
    model = caretModel),
    class = "BasicRF") 
  
  if (debug.train) {
    print(model)
    print("finished")
  }
  
  return(model)
}

predict.BasicRF <- function(model, data) {
  
  print("testing..")
  
  model <- model$model
  predictions <- predict(model, data) 
  levels(predictions) <- c(-1, 1)
  
  if (debug.test) {
    print(sprintf("predictions: %s", paste(predictions, collapse=",")))
    print("finished")
  }
  
  return(predictions)
}

