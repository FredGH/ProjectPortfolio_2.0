#' Some helper methods for visualising/summarising the data

require(dplyr)

plot_distributions = function(data) {
  colnames <- colnames_without_training_label_cols(data)
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- data[, colname]
    # Could switch on is.factor(coldata), here - however the discrete 
    # vars seem to display better using barplot. 
    png(filename=paste("images/levels_distib/",colname,".png",sep=""))
    if (colname %in% continuousVarNames) {
      hist(data[,colname], main = sprintf("%s", colname))
    }
    else {
      barplot(table(data[,colname]), main = sprintf("%s", colname))
    }
    dev.off()
  }
}

plot_distributions <- function(data1, data2, data1label="train", data2label="test") { 
  colnames <- colnames_without_training_label_cols(data1)
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    if (colname %in% continuousVarNames) {
      hist(data1[,colname], xlab = "value", main = sprintf("%s - %s", colname, data1label))
      hist(data2[,colname], xlab = "value", main = sprintf("%s - %s", colname, data2label))
    }
    else {
      barplot(table(data1[,colname]), main = sprintf("%s - %s", colname, data1label))
      barplot(table(data2[,colname]), main = sprintf("%s - %s", colname, data2label))
    }
  }
}

summarise_levels <- function(data, targetColumnName) {
  
  positiveForTarget <- data[data[, targetColumnName] == 1,]
  negativeForTarget <- data[data[, targetColumnName] == -1,]
  
  colnames <- colnames_without_training_label_cols(data)
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- data[, colname]
    if (is.factor(coldata)) {
      numLevels <- length(unique(data[, colname]))
      print(sprintf("%s has %s levels for %s", colname, numLevels, targetColumnName))
      numPositiveForTarget <- length(na.omit(positiveForTarget[, colname]))
      numNegativeForTarget <- length(na.omit(negativeForTarget[, colname]))
      numPositiveForTargetLevels <- length(unique(positiveForTarget[, colname]))
      print(sprintf(".. of which %s include +1s (with %s rows == +1 and %s == -1", 
                    numPositiveForTargetLevels, numPositiveForTarget, numNegativeForTarget))
      if (numPositiveForTargetLevels < 50) {
        print(table(coldata, data[, targetColumnName]))
      }
      cat("\n")
    }
  }
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata <- data[, colname]
    if (is.factor(coldata)) {
      numPositiveForTargetLevels <- length(unique(positiveForTarget[, colname]))
      if (numPositiveForTargetLevels > 35) {
        print(sprintf("**** %s may need aggregation to be treated as a factor ****", colname))
      }
    }
  }
}

check_for_common_levels <- function(data) {
  colnames <- colnames_without_training_label_cols(data)
  for (i in 1:length(colnames)) {
    colname1 <- colnames[i]
    coldata1 <- data[, colname1]
    if (is.factor(coldata1)) {
      for (j in 1:length(colnames)) {
        if (j != i) {
          colname2 <- colnames[j]
          coldata2 <- data[, colname2]
          if (is.factor(coldata2)) {
            levels1 <- levels(coldata1)
            levels2 <- levels(coldata2)
            same <- inner_join(data.frame(x = levels1), data.frame(x = levels2))
            if (NROW(same) > 0) {
              print(sprintf("the following levels are in %s and %s:", colname1, colname2))
              print(same$x)
            }
          }
        }
      }
    }
  } 
}

compare_factors<- function(data1, data2) {
  colnames <- colnames_without_training_label_cols(data1)
  for (i in 1:length(colnames)) {
    colname <- colnames[i]
    coldata1 <- data1[, colname]
    if (is.factor(coldata1)) {
      coldata2 <- data2[, colname]
      levels1 <- levels(coldata1)
      levels2 <- levels(coldata2)
      diff1 <- anti_join(data.frame(x = levels1), data.frame(x = levels2))
      if (NROW(diff1) > 0) {
        if (NROW(diff1) < 10) {
          print(sprintf("%s: the following %s levels (out of %s) are in data1 but not data2:", colname, NROW(diff1), NROW(levels1)))
          print(diff1$x)
        } else {
          print(sprintf("%s: there are %s (out of %s) which are in data1 but not data2:", colname, NROW(diff1), NROW(levels1)))
        }
      }
      else {
        print(sprintf("%s: there are no levels data1 which are not in data2:", colname, NROW(diff1)))
      }
      diff2 <- anti_join(data.frame(x = levels2), data.frame(x = levels1))
      if (NROW(diff2) > 0) {
        if (NROW(diff2) < 10) {
          print(sprintf("%s: the following %s levels (out of %s) are in data2 but not data1:", colname, NROW(diff2), NROW(levels2)))
          print(diff2$x)
        } else {
          print(sprintf("%s: there are %s (out of %s) which are in data2 but not data1:", colname, NROW(diff2), NROW(levels2)))
        }
      }
      else {
        print(sprintf("%s: there are no levels data2 which are not in data1:", colname, NROW(diff2)))
      }
    }
  }   
}

require(ggplot2)
require(dplyr)
require(reshape2)
ggplot_missing <- function(x){   
    x %>%      
    is.na %>%     
    melt %>%     
    ggplot(data = ., aes(x = Var2,y = Var1)) + 
    geom_raster(aes(fill = value)) + 
    scale_fill_grey(name = "", labels = c("Present","Missing")) +     
    theme_minimal() +      
    theme(axis.text.x = element_text(angle=45, vjust=0.5)) +
    labs(x = "Variables in Dataset", y = "Rows / observations") 
}
