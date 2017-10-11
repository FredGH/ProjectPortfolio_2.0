#' "NA GROUPS" model.
#' 
#' This model makes use of what look like structural patterns in missing data.
#' If you count the number of NAs for each column in the data set, then there
#' are multiple groups of columns who have the exact same number of NA values,
#' which seems unlikely to be the result of randomly missing data. 
#' 
#' Rather than try and impute any values - which tacitly assumes that all rows
#' in the dataset represent the same category of thing, the approach below 
#' presumes that these different patterns of NA represent different types of
#' data. So if a row has values for V1,V13,V27 and V180, for example, and 
#' another row has is missing these - but has values for V8, V30, and V100,
#' then it's because one row is an apple and another row is a banana. Not
#' because they're just randomly missing values in different columns.
#' 
#' The model works by first identifying which vars group together, up-front
#' of any training or testing (to avoid mismatches due to the contents of a 
#' particular sample of test or training fold inside the cross-validation), 
#' and then builds a data frame containing the data for each of these groups. 
#' Each of these data frames then gets its own random forest model during the 
#' training' phase, and then we fit an "over-arching" model to their predictions
#' for the training set. This basically treats each random forest as a predictor
#' in its own right, and comes up with the best combination of co-efficients to
#' fit the training data. In the test phase, each random forest again gets to
#' vote on whether a row should be +1 or -1, with respect to a given label; but
#' the over-arching model weights these individual predictions accordingly.

# TODO, probably need to split this file into the predictor functions / state
# and the runner - so that we can (if needs be) source the predictor functions.
# Maybe we'll need to within the predict method, if we've loaded our model from disk.

set.seed(1)
setwd('C:/Users/john/dev/goldsmiths/mlsdm/assignment3/submission')
source("init_data.r")

model.name <- "NA GROUPS"
model.data <- train
# These (below) are some manual corrections, based on eyeballing 
# the NA groups and removing any which only had one var in them. 
# Or rather, the columns below did not group together with any 
# other columns, in terms of their number of NAs. 

# Factors - just replace missing values with explicit "NA" level.
model.data$V22 <- fillna(model.data$V22, "NA")
model.data$V27 <- fillna(model.data$V27, "NA")
model.data$V50 <- fillna(model.data$V50, "NA")
model.data$V138 <- fillna(model.data$V138, "NA")
model.data$V143 <- fillna(model.data$V143, "NA")
model.data$V165 <- fillna(model.data$V165, "NA")
model.data$V182 <- fillna(model.data$V182, "NA")

# Discrete/continuous numeric values - replace with mode. Strictly speaking, 
# this imputation should be done on training and validation folds separately, 
# however the frequency of the modal values is overwhelmingly high compared 
# to other values, so I'm assuming that the end result would be the same.
model.data$V36 <- fillna(model.data$V36, 564)
model.data$V61 <- fillna(model.data$V61, 0)
model.data$V84 <- fillna(model.data$V84, 8)
model.data$V101 <- fillna(model.data$V101, 0)
model.data$V120 <- fillna(model.data$V120, 0)
model.data$V176 <- fillna(model.data$V176, 0)
model.data$V183 <- fillna(model.data$V183, 0)
model.data$V185 <- fillna(model.data$V185, 0)

model.data <- removeCols(model.data, c("V93", "V187"))# these just group with V90 so don't add anything
model.data <- removeCols(model.data, "V175") # V175 is always 9 in both train and test set

model.data <- add_num_std_devs(
  data = model.data
)

# Look at how many n/a values we have for each variable, in case there 
# are structural patterns to missing data. 
na_count <- sapply(model.data, function(y) sum(length(which(is.na(y)))))
na_count <- data.frame(na_count)

# Let's aggregate these so we have the NA counts, and see how many
# variables have each of these numbers of NAs
na_groups <- aggregate(na_count$na_count, by = na_count, FUN = NROW)
colnames(na_groups)[2] <- "num_vars"
na_count$var <- row.names(na_count)
na_groups$var_names <- sapply(na_groups$na_count,function(x) na_count[na_count$na_count == x, ]$var)
na_groups <- na_groups[order(-na_groups$num_vars),]

model.data <- bin_levels_if_not_in_test_set(
  trainData = model.data, 
  testData = test, 
  binLevelName = "BIN"
) # stick in same BIN as others, at least have chance of getting some right

model.data <- scale_and_normalise(model.data)

# Now on with the training/test phase..
debug.train <- TRUE
debug.test <- TRUE

train.ntree <- 50
num_na_groups <- NROW(na_groups)

ctrl <- trainControl(
  method = "repeatedcv", 
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)

train.NaGroups <- function(formula, data) {
  
  print("training..")

  models <- list()

  targetColumnName <- get_target_column_name(formula)
  if (debug.train) {
    print(sprintf("targetColumnName is %s", targetColumnName))
  }

  if (debug.train) {
    print("ensuring other two training label columns are not in dataset")
  }
  
  data <- removeCols(data, trainLabelNames[!(targetColumnName == trainLabelNames)])

  if (debug.train) {
    print("removing near zero variance columns")
  }
  
  data <- remove_near_zero_variance_columns(data)
  
  if (debug.train) {
    print("replacing -1 and 1 with NO and YES to allow twoClassSummary and ROC metric in caret")
  }
  
  levels(data[, targetColumnName]) <- c("NO", "YES")

  # Using sampling = "smote" in trainControl doesn't work, as it introduces NAs
  # for some samples, which then cause errors in the training model. 
  if (debug.train) {
    print("applying SMOTE")
  }
  data <- SMOTE(form = formula, data = data)

  for (i in 1:num_na_groups) {
    
    var_names = unlist(na_groups$var_names[i])

    if (debug.train) {
      print(sprintf("processing var_names %s", paste(var_names, collapse = "+")))
    }
    
    data_group <- na.omit(data[, (names(data) %in% c(targetColumnName, var_names))])
    data_group <- remove_near_zero_variance_columns(data_group)
    data_group <- add_bin_levels(data_group, "BIN")
    data_group <- add_bin_levels(data_group, "ALLNEGATIVE")
    
    num_data_group_rows <- NROW(data_group)
    num_data_group_cols <- NCOL(data_group)
    
    if (num_data_group_cols == 1) {
      print(sprintf("skipping %s as all empty, presume all cols had e.g. zero variance", paste(var_names, collapse = "+")))
    }
    else {
    
      if (num_data_group_rows > 10) {
        
        numPositiveResponses <- length(data_group[data_group[targetColumnName] == "YES", targetColumnName])
        if (debug.train) {
          print(sprintf("found %s matching rows in %s columns with %s positive responses", 
            num_data_group_rows, num_data_group_cols, numPositiveResponses))
        }
        
        if (numPositiveResponses > 0) {

          model <- train(
            formula,  
            data = data_group,
            method = "rf",
            ntree  = train.ntree,
            trControl = ctrl,
            metric = "ROC"
          )

          modelKey <- paste(colnames_without_training_label_cols(data_group), collapse = "+")
          models[[modelKey]] <- model
          if (debug.train) {
            print(sprintf("added to list with key %s", modelKey))
            cat("\n")
          }
        }
      }
    }
  }
 
  # Let's treat the rf models as predictors in a classifier,
  # and get that classifier to try and "weight" them accordingly. 
  if (debug.train) {
    print("generating predictions matrix from model ensemble")
  }
  
  predictionsMatrix <- create_predictions_matrix(models, data)
  predictionsMatrix <- data.frame(predictionsMatrix)
  predictionsMatrix <- cbind(predictionsMatrix, data[targetColumnName])

  if (debug.train) {
    print("training predictor on predictions matrix") 
  }
  
  predictor <- train(
    as.formula(paste(targetColumnName, " ~ .", sep="")),  
    data = predictionsMatrix,
    # rda does well for appetency, ok for upselling
    # adaboost does ok for upselling (~83-86%), haven't tried others
    method = "rda" # not using vanilla lda, as all weights load on first na_group
  )

  model <- structure(list(
    formula = formula, 
    models = models, 
    predictor = predictor),
    class = "NaGroups") 
  
  return(model)
}

predict.NaGroups <- function(model, data) {
  
  print("testing..")
 
  models <- model$models
  predictor <- model$predictor

  if (debug.test) {
    print("generating predictions matrix from model ensemble")
  }
  
  predictionsMatrix <- create_predictions_matrix(models, data) 
  
  if (debug.test) {
    print("making predictions on test data")
  }
  
  predictions <- predict(predictor, data.frame(predictionsMatrix))
  levels(predictions) <- c(-1, 1)
  
  if (debug.test) {
    print(sprintf("predictions: %s", paste(predictions, collapse=",")))
  }
  
  return(predictions)
   
}

create_predictions_matrix <- function(models, data, debug=FALSE) {

  numMatrixCols <- length(models)
  numMatrixRows <- NROW(data)
  predictionsMatrix <- matrix(0, numMatrixRows, numMatrixCols)
  
  for (i in 1:numMatrixRows) {
    row <- data[i, ]
    rowPredictions <- get_row_predictions(models, row)
    # TODO, must shirley be possible to just add a row at a time ?
    for (j in 1:length(rowPredictions)) {
      predictionsMatrix[i, j] <- rowPredictions[j]
    }
  }
  
  return(predictionsMatrix)
}

get_row_predictions <- function(models, row, debug=FALSE) {
  
  row.cols <- colnames(row[1, !is.na(row)])
  if (debug) {
    print(sprintf("row.cols = %s", paste(row.cols, collapse = "+")))
  }
  
  numModels <- length(models)
  predictions <- matrix(0, 1, numModels)
  if (numModels > 0) {
    for (i in 1:numModels) {
      
      var_names <- names(models)[i]
      if (debug) {
        print(sprintf("processing model %s, var_names = %s", i, var_names))
      }
      
      model.cols <- unlist(strsplit(var_names, split="\\+"))
      if (all(model.cols %in% row.cols)) {
        
        model <- models[i]  
        voteLevel <- as.integer(predict(model, newdata = row))
        predictions[1, i] <- ifelse(voteLevel == 1, -1, 1)

        if (debug) {
          print(sprintf("found match, vote was %s", voteLevel))
        }
        
      } else {
        if (debug) {
          print("no match")
        }
      }
    }
  }
  
  predictions <- as.vector(predictions)
  if (debug) {
    print(sprintf("returning predictions %s", paste(predictions, collapse = " ")))
  }
  
  return (predictions)
}

#for (targetColumnName in trainLabelNames) {
#for (targetColumnName in c("churn")) {
for (targetColumnName in c("upselling")) {
#for (targetColumnName in c("appetency")) {
  
  print(sprintf("Evaluating model for target label %s", targetColumnName))

  model.eval.data <- removeCols(model.data, trainLabelNames[!(targetColumnName == trainLabelNames)])
    
  binLevelName <- "ALLNEGATIVE"
  model.eval.data <- bin_negative_levels(
    data = model.eval.data, 
    targetColumnName = targetColumnName,
    binLevelName = binLevelName
  )
  allNegativeLevels <- attr(model.eval.data, binLevelName)
  
  binLevelName <- "BIN"
  model.eval.data <- keep_top_X_levels(
    data = model.eval.data, 
    X = 30,
    binLevelName = binLevelName
  )

  binnedLevels <- attr(model.eval.data, binLevelName)
    
  model.eval.data <- add_bin_levels(model.eval.data, "BIN")
  model.eval.data <- add_bin_levels(model.eval.data, "ALL_NEGATIVE")
  knownLevels <- list_factor_levels(model.eval.data)
  
  model.formula <- as.formula(paste(targetColumnName, " ~ ."))
  
  res = evaluate_model(
    data = model.eval.data,
    formula = model.formula, 
    trainMethod = train.NaGroups,
    debug = TRUE
  )
  
  auc <- res[["auc"]]
  predictor <- res[["model"]]
  
  print(sprintf("Saving model state asl NaGroups_%s", targetColumnName))
  
  # save the predictor model - and any state it depends on
  save(allNegativeLevels,
       auc,
       binnedLevels,
       create_predictions_matrix,
       debug.test,
       get_row_predictions,
       knownLevels,
       predictor,
       predict.NaGroups,
       file = sprintf("models/rf/NaGroups_%s.rda", targetColumnName)
  )
}

