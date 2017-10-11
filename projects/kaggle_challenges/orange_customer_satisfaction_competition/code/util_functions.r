#' Some common util methods

#' replaces all instances of NA in a column with whatever you tell it to
fillna <- function(col, replacement) {
  if (is.factor(col)) {
    levels <- levels(col)
    return (as.factor(ifelse(is.na(col),replacement,levels[col])))
  }
  else {
    return (ifelse(is.na(col),replacement,col))
  }
}

#' replaces all instances of a specified value in a column, with 
#' whatever you tell it to
replace <- function(col, value, replacement) {
  if (is.factor(col)) {
    levels(col) <- c(levels(col), replacement)
    col[col == value] <- replacement
    col <- droplevels(col)
    return(col)
  }
  else {
    return (ifelse(col == value, replacement, col))
  }
}

#' drops specified columns (by name) from a dataframe
removeCols <- function(data, colNamesToRemove) {
  newdata <- data[, !(names(data) %in% colNamesToRemove)]
  if (!is.data.frame(newdata)) {
    newdata <- data.frame(newdata)
    colnames(newdata)[1] = names(data)[1]
  }
  return (newdata)
}

#' returns the column names from a data.frame, excluding 
#' appetency, churn and upselling
colnames_without_training_label_cols = function(data) {
  return(colnames(removeCols(data, trainLabelNames)))
}

get_naCount_perc = function (dfParam){
  naCount <-sapply(dfParam, function(y) sum(length(which(is.na(y)))))
  naDf <- data.frame(naCount, 100 * naCount/dim(dfParam)[1])
  colnames(naDf) <- c("count", "perc")
  sort(naDf$perc, decreasing=TRUE)
  return(naDf)
}

#input a 0<=value<=1 and mult * 100
to_perc = function(value, dp =2){
  return (round(100 * value, digits=dp))    
}

get_target_column_name = function(formula) {
  targetColumnName <- all.vars(formula)[[1]]
  return(targetColumnName)
}

all_vars_numeric <- function(var_names) {
  res <- TRUE
  for (var_name in var_names) {
    if (var_name %in% characterVarNames) {
      res <- FALSE
      break
    } 
  }
  return(res)
}

list_factor_levels <- function(data) {
  levelNamesList <- list()
  colnames <- colnames_without_training_label_cols(data)
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- data[, colname]
    if (is.factor(coldata)) {
      levelNames = unique(as.character(levels(coldata)))
      if (length(levelNames > 0)) {
        levelNamesList[[colname]] <- levelNames
      }
    }
  }
  return(levelNamesList)
}

#Produce the results of the KS test
kolmogorov_smirnov_normal_distribution_test = function(data,msg) {
  #This is the z-score scaling: (x-avg)/std as default
  scaled_data = scale(data)
  #Ensure all data is unique, else it breaks the ks test
  res = ks.test(unique(scaled_data), pnorm)
  cat(msg,"\n", sep =" ")
  cat("H0 = the data is normally distributed.\n", sep="")
  if(res$p.value > 0.05){
    cat("The ks p_value: ", res$p.value, " > 0.05 -> H0 (the null hypothetsis) is NOT rejected. There is not enough evidence to reject the hypothesis that the distribution is normal. Therefore, the data seems to follow normal distribution\n",  sep="")
  } else
  {
    cat("The ks p_value: ", res$p.value, " < 0.05 -> H0 (the null hypothesis) is rejected. The data distribution does not seem to follow a normal distribution.\n",  sep="")
  }
}

#Produce the QQ plot
plot_qqplot = function (data, ylab_param) {
  title = ylab_param
  qqnorm(data, main=paste(title, " \n (centered & scaled) - QQplot", sep=""), ylab=paste(ylab_param, paste=""))
  qqline(data, col="gold", lwd=2)
}