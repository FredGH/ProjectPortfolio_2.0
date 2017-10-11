#'
#' Functions in this file are designed to take a data.frame as 
#' an argument and return a modified data.frame as the response.
#' This allows them to be chained together as a series of 
#' pre-processing steps, either up-front (to the entire dataset,
#' where applicable) or else inside the evaluate_model function -
#' where they can be applied separately to training and test
#' folds. 
#' 
#' Similar in concept (sort of) to Caret's way of letting us
#' tell it to e.g. centre, scale, and impute, before training
#' a model.
#' 
#' Note that some processing we can only really do up-front. I've 
#' found out that bin_negative_levels, for example, gets in a pickle
#' if the BIN level gets added to the training folds and not 
#' the test fold (or vice versa). Presumaly something similar
#' could happen with convert_NAs_to_level and convert_to_factors,
#' in terms of mismatching levels between training and test data.
#' That's not to say that these functions are not useful, so long
#' as they can be applied to the whole data set without introducing
#' unnecessary bias.
#'
#' Note also that I haven't quite figured out how to handle optional 
#' arguments yet in calls to these methods. Unless or until 
#' this gets fixed, the workaround is to wrap a function with 
#' optional arguments inside one which hard codes those 
#' arguments - e.g. convert_to_factors50 would invoke 
#' convert_to_factors(data, maxLevels=50). This wrapper
#' method could then be passed in, as a function to be called
#' with a single "data" argument, to the model evaluation method.
#'

source("util_functions.r")
require(caret)
require(DMwR)
require(dplyr)

#' Helper method to apply a chain of functions to a dataframe
apply_pre_processing = function(data, preProcessingFunctions) {
  modified <- data.frame(data)
  for (preProcessingFunction in preProcessingFunctions) {
    modified <- preProcessingFunction(modified)
  }
  return(modified)
}

#' Convert any columns (that aren't already factors) to factors.
#' By default, ignore any columns where doing this would result
#' in a factor with more than 10 levels. But this threshold can 
#' be changed by specifying a value using the maxLevels argument. 
convert_to_factors = function(data, maxLevels=10, debug=FALSE, colnames) {
  
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[, colname]
    asFactor <- as.factor(coldata)
    levelsAsFactor <- levels(asFactor)
    if (!is.factor(coldata) & (length(levelsAsFactor) <= maxLevels)) {
      if (debug) {
        print(sprintf("Converting %s to factor as has <= %s discrete values", colname, maxLevels))
      }
      newdata[colname] <- asFactor
    }
  }
  return(newdata)
}

#Convert all non nnumerical cols to factor
convert_non_num_to_factors = function(data) {
  isNumeric <- sapply(data, is.numeric)
  numData <- data[isNumeric]
  nonNumData <- data[!isNumeric]
  colnames <- colnames(nonNumData)
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- nonNumData[, colname]
    nonNumData[colname] <- as.factor(coldata)
  }
  return(cbind(numData,nonNumData))
}

#Make syntactically valid names out of character vectors.
make_valid_column_name = function(data){
  colnames = colnames(data)
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    newName = make.names(c(colname), unique = TRUE)
    colnames(data)[colnames(data)==colname] <- newName
  }
  return(data)
}

#' Assign any missing values inside factor columns to an explicit
#' "NA" level. This gives e.g. classification trees something to 
#' branch on.
convert_NAs_to_level = function(data, naLevelName="NA", debug=FALSE, colnames) {
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[, colname]
    if (is.factor(coldata)) {
      if (debug) {
        print(sprintf("Converting NAs to level [%s] for %s", naLevelName, colname))
      }
      newdata[colname] <- fillna(coldata, naLevelName)
    }
  }
  return(newdata)
}

#' This one drops any levels where the target response value is
#' always -1. Which are effectively useless to us, since we're
#' interested in predicting +1 responses. This can help bring 
#' the number of levels in a factor down under the RF limit of
#' 35, without (so far as I can see) alterting the distribution
#' of the data. In effect, it's kind of up-front pruning of a 
#' decision tree - since any branches through these levels will
#' always end up with a classification of -1.  
#' 
#' Note that this method is called with respect to a specific
#' target column, since there may be levels which "test positive"
#' for appetency, but negative for upselling, etc.
#' 
#' Note also that this one doesn't always place nicely if applied
#' to training and test folds separately, since there may be 
#' cases where a test fold ends up with a BIN level, but the
#' corresponding training folds do not. Or vice versa.
bin_negative_levels = function(data, targetColumnName, binLevelName = "ALLNEGATIVE", colnames) {
  newdata <- data.frame(data)
  positiveForTarget <- newdata[newdata[, targetColumnName] == 1,]
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  binned <- list()
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[, colname]
    # We only care about factor columns
    if (is.factor(coldata)) {
      # Which levels only ever result in a negative? 
      positiveLevels <- unique(positiveForTarget[, colname])
      levels(coldata) <- c(levels(coldata), binLevelName)
      # Keep a record of which ones we're about to bin so that we can return these to
      # the caller. Useful if for example we want to bin them during a training phase,
      # and then re-apply them to unseen data during a test phase
      binnedLevels <- unique(as.character(coldata[!coldata %in% positiveLevels]))
      if (length(binnedLevels) > 0) {
        binned[[colname]] <- binnedLevels
      }
      # Now we've stored them, we can bin them
      coldata[!coldata %in% positiveLevels] <- binLevelName
      coldata <- droplevels(coldata)
      newdata[colname] <- coldata
    }
  }
  attr(newdata, binLevelName) <- binned
  return(newdata)
}

#' These just wrap bin_negative_levels, to supply the additional 
#' targetColumnName parameter. We can then pass in a list of
#' pre-processing steps to the model evaluation call, e.g.
#' c(convert_NAs_to_level, bin_negative_levels_appetency) - so
#' that these get invoked inside the evaluation loop rather than
#' when we call it.
bin_negative_levels_appetency <- function(data) {
  bin_negative_levels(data, "appetency")
}

bin_negative_levels_upselling <- function(data) {
  bin_negative_levels(data, "upselling")
}

bin_negative_levels_churn <- function(data) {
  bin_negative_levels(data, "churn")
}

#' This is a quick'n'dirty level aggregation method, which just sorts the levels
#' by exposure, keeps the X most exposed (e.g. the top 10), and puts the rest
#' in a new level called BIN. Not suggesting this is an especially good approach
#' to aggregation; just something simple to get started with.
keep_top_X_levels = function(data, X, binLevelName = "BIN", colnames, ignoreList) {
  
  binned <- list()
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[, colname]
    if (is.factor(coldata)) {
      levels <- levels(coldata)
      numLevels <- length(levels)
      asFrame <- data.frame(table(coldata))
      asFrame <- asFrame[rev(order(asFrame$Freq)),]
      topLevels <- asFrame[1:X, 1]
      if (!missing(ignoreList)) {
        topLevels <- as.vector(topLevels)
        topLevels <- c(topLevels, ignoreList)
      }
      if (!(binLevelName %in% levels(coldata))) {
        levels(coldata) <- c(levels(coldata), binLevelName)
      }
      # Keep a record of which ones we're about to bin so that we can return these to
      # the caller. Useful if for example we want to bin them during a training phase,
      # and then re-apply them to unseen data during a test phase
      binnedLevels <- unique(as.character(coldata[!coldata %in% topLevels]))
      if (length(binnedLevels) > 0) {
        binned[[colname]] <- binnedLevels
      }
      # Now we've stored them, we can bin them
      coldata[!coldata %in% topLevels] <- binLevelName
      coldata <- droplevels(coldata)
      newdata[colname] <- coldata
    }
  }
  attr(newdata, binLevelName) <- binned
  return(newdata)
}

#' This just wraps keep_top_X_levels
keep_top_10_levels <- function(data) {
  keep_top_X_levels(data, 10)
}

keep_top_20_levels <- function(data) {
  keep_top_X_levels(data, 20)
}

keep_top_30_levels <- function(data) {
  keep_top_X_levels(data, 30)
}

#' Added a "bin" level to all factors in specified dataset
add_bin_levels <- function(data, binLevelName, colnames) {
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[, colname]
    if (!(binLevelName %in% levels(coldata))) {
      levels(coldata) <- c(levels(coldata), binLevelName)
      newdata[colname] <- coldata
    }
  }
  return(newdata)
}

# This can be used to re-apply the "binned" mappings from one of the
# methods above, e.g. perform the same level -> BIN, or level -> ALLNEGATIVE
# mapping on unseen test data (assuming we already saw the raw level during
# the training phase). Alternatively it can be used to bin any levels that
# have not been seen in the training phase, by passing in a list of known
# levels and setting binLevelsInList = FALSE
bin_levels <- function(data, levelNamesList, binLevelName, binLevelsInList = TRUE) {
  binned <- list()
  newdata <- data.frame(data)
  for (i in 1:length(levelNamesList)) {
    levelNames <- unlist(levelNamesList[i])
    colname <- names(levelNamesList)[i]
    coldata <- newdata[, colname]
    if (!(binLevelName %in% levels(coldata))) {
      levels(coldata) <- c(levels(coldata), binLevelName)
    }
    if (binLevelsInList) {
      # Keep a record of which ones we're about to bin so that we can return these to
      # the caller. Useful if for example we want to bin them during a training phase,
      # and then re-apply them to unseen data during a test phase
      binnedLevels <- unique(coldata[as.character(coldata) %in% levelNames])
      if (length(binnedLevels) > 0) {
        binned[[colname]] <- binnedLevels
      }
      # Now we've stored them, we can bin them
      coldata[as.character(coldata) %in% levelNames] <- binLevelName
    } else {
      # Keep a record of which ones we're about to bin so that we can return these to
      # the caller. Useful if for example we want to bin them during a training phase,
      # and then re-apply them to unseen data during a test phase
      binnedLevels <- unique(coldata[!(as.character(coldata) %in% levelNames)])
      if (length(binnedLevels) > 0) {
        binned[[colname]] <- binnedLevels
      }
      # Now we've stored them, we can bin them
      coldata[!(as.character(coldata) %in% levelNames)] <- binLevelName
    }
    coldata <- droplevels(coldata)
    newdata[colname] <- coldata
  }
  attr(newdata, binLevelName) <- binned
  return(newdata)
}

rename_factor_level = function(data, value, replacement, colnames) {
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[, colname]
    if (is.factor(coldata)) {
      if (!(replacement %in% levels(coldata))) {
        levels(coldata) <- c(levels(coldata), replacement)
      }
      coldata[coldata == value] <- replacement
      coldata <- droplevels(coldata)
      newdata[colname] <- coldata
    }
  }
  return(newdata)
}

drop_factors_with_less_than_X_levels = function(data, X, colnames) {
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  colsToDrop <- vector()
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[, colname]
    if (is.factor(coldata)) {
      numLevels = length(levels(coldata))
      if (numLevels < X) {
        colsToDrop[length(colsToDrop)+1] <- colname
      }
    }
  }
  if (length(colsToDrop) > 0) {
    newdata <- removeCols(newdata, colsToDrop)
  }
  return(newdata)
}

drop_factors_with_only_one_level = function(data) {
  return (drop_factors_with_less_than_X_levels(data, 2))
}

#Imput data for numeric cols.
impute_data = function(data, method = "knnImpute"){
  isNumeric = sapply(data, is.numeric)
  numData = data[isNumeric]
  nonNumData = data[!isNumeric]
  impu <- preProcess(numData, method = method)
  impuData <- predict(impu, numData)
  newData <- cbind(impuData, nonNumData)
  newData <- newData[, order(colnames(newData))]
  return(newData)
}

#Set-up and return a df that list the replacement level. Each replacement level has a name and a category frequency range
get_replacement_levels = function(){
  replacementLevels <- NULL
  replacementLevels <- data.frame( minFreq = 1, maxFreq=250, levelName ="LEV_1_250",stringsAsFactors=FALSE)   
  replacementLevels[nrow(replacementLevels)+1, ] <- c(251,500, "LEV_251_500")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(501,1000, "LEV_501_1000")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(1001,100000, "LEV_1001_Above")
  return (replacementLevels)
}

#Set-up and return a df that list the replacement level. Each replacement level has a name and a category frequency range
get_replacement_levels_1 = function(){
  replacementLevels <- NULL
  replacementLevels <- data.frame( minFreq = 1, maxFreq=500, levelName ="LEV_1_500",stringsAsFactors=FALSE)   
  replacementLevels[nrow(replacementLevels)+1, ] <- c(501,1000, "LEV_501_1000")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(1001,100000, "LEV_1001_Above")
  return (replacementLevels)
}

#Set-up and return a df that list the replacement level. Each replacement level has a name and a category frequency range
get_replacement_levels_2 = function(){
  replacementLevels <- NULL
  replacementLevels <- data.frame( minFreq = 1, maxFreq=10, levelName ="LEV_1_10",stringsAsFactors=FALSE)   
  replacementLevels[nrow(replacementLevels)+1, ] <- c(11,25, "LEV_11_25")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(26,50, "LEV_26_50")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(51,100, "LEV_51_100")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(101,150, "LEV_101_150")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(151,250, "LEV_151_250")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(251,500, "LEV_251_500")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(501,750, "LEV_501_750")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(751,1000, "LEV_751_1000")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(1001,3000, "LEV_1001_3000")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(3001,5000, "LEV_3001_5000")
  replacementLevels[nrow(replacementLevels)+1, ] <- c(5001,1000000, "LEV_5001_Above")
  return (replacementLevels)
}

#It generate a an extra col for each char col, name [colName]_new,
#and set each cell value of the new col to one of the replacement level, 
#based on the orginal col category level row occurrence frequency
create_replacement_columns = function(data) {
  
  replacementLevels <- get_replacement_levels_2()
  
  isNumeric = sapply(data, is.numeric)
  numData = data[isNumeric]
  nonNumData = data[!isNumeric]
  
  #Create a "_new" col for each char col and default to DUMMY
  for (colName in names(nonNumData)){
    newColName <- paste(colName, "_new", sep="")
    newLevel <- "DUMMY"
    #Create colName_new and default to "DUMMY"
    nonNumData[newColName] <- newLevel
    rowNb = NROW(nonNumData[newColName])
    #Find the occurrence of each category in the dataset
    rowsPerCat = data.frame(table(nonNumData[colName]))
    #For each row...
    for (rowIdx in 1:rowNb){
      #Get the current category
      currCat = nonNumData[rowIdx,colName]
      if (!is.na(currCat)) {
        #Get the current Frequency for the category
        currFreq = subset(rowsPerCat, rowsPerCat$Var1==currCat)$Freq
        #Get the new level from the replacementLevels table, 
        #comparing the current Freq of a category occurence Vs the ranges defined in replacementLevels
        rplRowNb = NROW(replacementLevels)
        for (rplIdx in 1:rplRowNb) {
          minFreq = as.integer(replacementLevels$minFreq[rplIdx])
          maxFreq = as.integer(replacementLevels$maxFreq[rplIdx])
          if (currFreq > minFreq & currFreq < maxFreq) {
            newLevel =  replacementLevels$levelName[rplIdx]
            break;
          }  
        }
      }
      nonNumData[rowIdx,newColName] <- newLevel
    }
  }
  newData <- cbind(numData, nonNumData)
  newData <- newData[, order(colnames(newData))]
  return(newData)
}

#Scale and normalise data
scale_and_normalise = function(data, center = TRUE, scale = TRUE ) {
  isNumeric = sapply(data, is.numeric)
  numData = data[isNumeric]
  nonNumData = data[!isNumeric]
  numData = scale(numData, center = center, scale = scale)
  return (cbind(numData, nonNumData))
}

# Identify and remove Correlated Predictors -> The collinearity issue
# Only to be applied to numerica columns
remove_correlated_predictors = function(data, correlationCutOff= 0.9){
  isNumeric = sapply(data, is.numeric)
  numData = data[isNumeric]
  nonNumData = data[!isNumeric]
  # Get the correlation
  corr <- cor(numData)
  # This function searches through a correlation matrix and returns a vector of integers corresponding
  # to columns to remove to reduce pair-wise correlations.
  cols_index_to_delete <- findCorrelation(corr, cutoff = correlationCutOff)
  removeCount <- 0
  count_col_to_delete <-0
  if (length(cols_index_to_delete) > 0){
    res <- numData[, -cols_index_to_delete]
    removeCount <- length(count_col_to_delete$remove)
    newData <- cbind(res, nonNumData)
    newData <- newData[, order(colnames(newData))]
    print(paste("Number of removed correlated predictors: ", removeCount, sep=""))
    return(newData)
  }
  return (data)
}

#The function findLinearCombos uses the QR decomposition of a matrix 
#to enumerate sets of linear combinations (if they exist).
#For each linear combination, it will incrementally remove columns 
#from the matrix and test to see if the dependencies have been resolved.
remove_linear_dependencies = function(data) {
  isNumeric = sapply(data, is.numeric)
  numData = data[isNumeric]
  nonNumData = data[!isNumeric]
  comboInfo <- findLinearCombos(data.matrix(nonNumData))
  removeCount <- 0
  # The dataset minus the identified col(s)
  if (is.null(comboInfo$remove) == FALSE) {
    res <- numData[, -comboInfo$remove]
    newData <- cbind(res, nonNumData)
    newData <- newData[, order(colnames(newData))]
    removeCount <-length(comboInfo$remove)
    return(newData)
  }
  print(paste("Number of removed linearly dependent col(s): ", removeCount, sep=""))
  return (data) 
}

#The threshold is a number between 0 and 1
drop_na_cols = function(data, threshold=0.5){
  naDf = get_naCount_perc(data)
  data <- data[naDf$perc < 100*threshold]
  return(data)
}

remove_near_zero_variance_columns = function(data) {
  colnames <- names(data)
  nzv <- nearZeroVar(data)
  nzv <- colnames(data[nzv])
  nzv <- nzv[!nzv %in% trainLabelNames]
  res <- data[, colnames[!colnames %in% nzv]]
  return(res)
}

bin_levels_if_not_in_test_set = function(trainData, testData, binLevelName, colnames) {
  binned <- list()
  newdata <- data.frame(trainData)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(trainData)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata1 <- trainData[, colname]
    if (is.factor(coldata1)) {
      if (colname %in% names(testData)) {
        coldata2 <- testData[, colname]
        levels1 <- levels(coldata1)
        levels2 <- levels(coldata2)
        diff <- levels1[!levels1%in%levels2]
        if (NROW(diff) > 0) {
          # Keep a record of which ones we're about to bin so that we can return these to
          # the caller. Useful if for example we want to bin them during a training phase,
          # and then re-apply them to unseen data during a test phase
          binnedLevels <- diff
          binned[[colname]] <- binnedLevels
          # Now we've stored them, we can bin them
          if (!(binLevelName %in% levels1)) {
            levels(coldata1) <- c(levels(coldata1), binLevelName)
          }
          coldata1[as.character(coldata1) %in% diff] <- binLevelName
          coldata1 <- droplevels(coldata1)
          newdata[colname] <- coldata1
        }
      }
    }
  }
  attr(newdata, binLevelName) <- binned
  return(newdata)
}

add_num_std_devs = function(data, debug=FALSE, colnames) {
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[[colname]]
    if (is.factor(coldata)) {
      frequencyTable <- data.frame(table(coldata))
      numFrequencies <- NROW(frequencyTable)
      if (numFrequencies > 1) {
        newcolname <- paste(colname,"_SD", sep = "")
        if (debug) {
          print(sprintf("Adding predictor %s", newcolname))
        }
        stdDev <- sd(frequencyTable$Freq)
        joined <- left_join(data.frame(coldata = coldata), frequencyTable)
        numRows <- NROW(joined)
        newcoldata <- matrix(NA, numRows, 1)
        for (j in 1:numRows) {
          if(!is.na(coldata[j])) {
            frequency <- joined[j,2]
            numStdDev <- frequency / stdDev
            newcoldata[j,1] <- numStdDev
          }
        }
        newdata[newcolname] <- as.vector(newcoldata)
      }
    }
  }
  return(newdata)
}

add_levels_for_num_std_devs = function(data, maxLevels = 10, debug=FALSE, colnames) {
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[[colname]]
    if (is.factor(coldata)) {
      frequencyTable <- data.frame(table(coldata))
      numFrequencies <- NROW(frequencyTable)
      if (numFrequencies > 1) {
        newcolname <- paste(colname,"_SDL", sep = "")
        if (debug) {
          print(sprintf("Adding predictor for %s with levels up to %s std deviations", colname, maxLevels))
        }
        stdDev <- sd(frequencyTable$Freq)
        joined <- left_join(data.frame(coldata = coldata), frequencyTable)
        numRows <- NROW(joined)
        newcoldata <- matrix(NA, numRows, 1)
        for (j in 1:numRows) {
          if(!is.na(coldata[j])) {
            frequency <- joined[j,2]
            newcoldata[j,1] <- 0
            for (k in maxLevels : 1) {
              if (frequency > (k * stdDev)) {
                newcoldata[j,1] <- k
                break;
              }
            }
          }
        }
        newdata[newcolname] <- as.factor(as.vector(newcoldata))
      }
    }
  }
  return(newdata)
}

add_level_frequencies_percent = function(data, debug=FALSE, colnames) {
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[[colname]]
    if (is.factor(coldata)) {
      frequencyTable <- data.frame(table(coldata))
      newcolname <- paste(colname,"_PC", sep = "")
      if (debug) {
        print(sprintf("Adding predictor %s", newcolname))
      }
      joined <- left_join(data.frame(coldata = coldata), frequencyTable)
      sumFrequencies <- sum(frequencyTable$Freq)
      numRows <- NROW(joined)
      newcoldata <- matrix(NA, numRows, 1)
      for (j in 1:numRows) {
        if(!is.na(coldata[j])) {
          frequency <- joined[j,2]
          percent <- frequency / sumFrequencies
          newcoldata[j,1] <- percent
        }
      }
      newdata[newcolname] <- as.vector(newcoldata)
    }
  }
  return(newdata)
}

#' Convert any character factor levels to integer representations.
#' I'm thinking here that levels for variables such as V4 are actually
#' alphabetically ordered, and so there may be some value (albeit unlikely)
#' in treating them as numbers so that e.g. a tree based model can split
#' on values that don't necessarily have to exist as a factor level, and
#' so give a different level of abstraction over the data.
#' 
convert_character_factors_to_int = function(data, colnames, debug=FALSE) {
  
  require(digest)
  
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[[colname]]
    # adapted from http://stackoverflow.com/questions/27442991/how-to-get-a-hash-code-as-integer-in-r
    newdata[colname] <- sapply(coldata, function(x) {
      x <- digest(as.character(x), algo='xxhash32')
      xx = strsplit(tolower(x), "")[[1L]]
      pos = match(xx, c(0L:9L, letters[1L:6L]))
      sum((pos - 1L) * 16^(rev(seq_along(xx) - 1)))
    })
  }
  return(newdata)
}

add_alphanumeric_sort_value = function(data, colnames, debug=FALSE) {
  
  newdata <- data.frame(data)
  if (missing(colnames)) {
    colnames <- colnames_without_training_label_cols(data)
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- newdata[[colname]]
    if (is.factor(coldata)) {
      values <- unique(as.character(coldata))
      values <- values[order(values)]
      newcolname <- paste(colname,"_SORT", sep = "")
      newcoldata <- sapply(coldata, function(x) {
        if(!is.na(x)) {
          return(which(values == x))
        }      
      })
      newdata[newcolname] <- newcoldata
    }
  }
  return(newdata)
}

