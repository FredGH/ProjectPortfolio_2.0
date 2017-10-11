
#' The intention here is that this file - specifcially the evaluate_model
#' function - should be used to score all of our AUCs, so that we can 
#' compare like-for-like, at least in so far as that's practicable. 

require(caret)
source("pre_processing_functions.r")

#' This is the default callback hook for fitting a model inside
#' the evaluation loop. It just calls caret's train method, with
#' whatever parameters you've specified. But I wanted a way to 
#' decouple evaluate_model from caret, in case we need it.
call_caret_train = function(formula, data, ...) {
  train(formula, data=data, ...)
}

#' This is a helper method, used inside evaluate_model, and
#' just split into its own function for clarity (and debugging).
calculate_metrics = function(table, debug=FALSE) {
  tn <- table[1]
  fp <- table[2]
  fn <- table[3]
  tp <- table[4]
  sens <- tp/(tp+fn)
  if (tp+fn == 0) {
    sens <- 1
  }
  spec <- tn/(tn+fp)
  if (tn+fp == 0) {
    spec <- 1
  }
  auc <- sens * spec
  auc <- auc + ((0.5*(1-sens))*spec)
  auc <- auc + ((0.5*(1-spec))*sens)
  
  precision <- tp / (tp+fp)
  accuracy <- (tp+tn) / (tp+fp+fn+tn)
  f1Score <- (2*tp) / (2*tp+fp+fn)
  
  if (debug) {
    print(table)
    print(sprintf("tn: %s, fp: %s, fn: %s. tp: %s", tn, fp, fn, tp))
    print(sprintf("specificity: %s", spec))
    print(sprintf("sensitivity: %s", sens))
    print(sprintf("precision: %s", precision))
    print(sprintf("accuracy: %s", accuracy))
    print(sprintf("F1-score: %s", f1Score))
    print(sprintf("auc: %s", auc))
  }
  
  res = list("accuracy" = accuracy, "auc" = auc)
  return (res)
}

#' This is the main test harness method, and really the only one 
#' which would have public scope, were such a thing possible in R.
#' 
#' TODO - at the moment this is still nested cross-validation. Or rather,
#' just cross-validation. It's up to e.g. caret whether there's an 
#' additional level of cross-validation going on, at each iteration of
#' the outer-loop.
#' 
evaluate_model <- function(
  data, # the dataset
  formula, # the formula to use e.g. as.formula("appetency ~ foo")
  numFolds = 5, # number of folds for the outer loop cross-validation 
  trainMethod, # optional callback method to do the training (defaults to caret, per notes above)
  trainSMOTE = FALSE, 
  debug = FALSE, # optional flag to enabled/disable print statements during evaluation
  ... # pass-through arguments to e.g. caret
  ) {
  
  if (debug) {
    print("evaluate_model:")
    print(formula)
    print(sprintf("numFolds: %s", numFolds))
    print(sprintf("debug: %s", debug))
  }

  if (missing(trainMethod)) {
    trainMethod = call_caret_train # default
  }

  # Work out how many rows go in each test fold
  numRows <- NROW(data)
  foldSize <- numRows %/% numFolds
  if (debug) {
    print(sprintf("foldSize is %s, based on %s rows and %s folds", foldSize, numRows, numFolds))
  }
  
  # Work out which of e.g. appetency, upselling and churn we're predicting
  targetColumnName <- get_target_column_name(formula)
  if (debug) {
    print(sprintf("targetColumnName: %s", targetColumnName))
  }
  
  accuracy <- 0.
  auc <- 0.
  
  # Now do our cross validation
  for (i in 1:numFolds) {
    
    # Determine the start and end row indices for our test fold
    foldStart <- 1 + ((i-1)*foldSize)
    foldEnd = i * foldSize
    fold.rows <- foldStart:foldEnd
    if (debug) {
      print(sprintf("Training model, holding out rows %s to %s for evaluation", foldStart, foldEnd))
    }
    
    # Split out the training and test folds
    train.data <- data[-fold.rows, ]
    test.data <- data[fold.rows, ]

    # Fit the model using the training folds
    if (trainSMOTE) {
      # Balance data with SMOTE - Audrey
      model.fit <- SMOTE(formula, train.data, learner = trainMethod, ...)
    }
    else {
      model.fit <- trainMethod(formula, train.data, ...)
    }
    
    # Make our predictions on the test fold
    model.pred <- predict(model.fit, test.data)

    # Build a confusion matrix of predictions vs truth
    model.table <- table(
      "Prediction" = model.pred,
      "Truth" = test.data[,targetColumnName]
    )
    
    # Use the confusion matrix to score for AUC this iteration
    # and increment our running total
    metrics <- calculate_metrics(model.table, debug = debug)
    accuracy <- accuracy + metrics$accuracy
    auc <- auc + metrics$auc
  }
  
  # Work out and return our average AUC
  accuracy <- accuracy / numFolds
  auc <- auc / numFolds
  
  if (debug) {
    print(sprintf("Average AUC for model: %s", auc))
    print(sprintf("Average accuracy for model: %s", accuracy))
  }
  
  # Retrain the model on the whole training set, ready for predicting the test data
  if (debug) {
    print("Retraining final model on whole training set")
  }
  if (trainSMOTE) {
    model.fit <- SMOTE(formula, data, learner = trainMethod, ...)
  }
  else {
    model.fit <- trainMethod(formula, data, ...)
  }

  res = list("accuracy" = accuracy, "auc" = auc, "model" = model.fit)
  return (res)
}