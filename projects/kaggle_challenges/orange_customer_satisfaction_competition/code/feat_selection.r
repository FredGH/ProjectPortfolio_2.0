library(randomForest)

#Generate the importance table and MeanDecreaseGini plot 
#for a feature selection based on a randomForest
random_forest_feature_selection = function(formula, data, ntree=500) {

  training_fit = randomForest( formula,  
                               data=data,
                               ntree = ntree,
                               importance=TRUE)
  
  #Generate the importance data and order by the column "MeanDecreaseGini" (desc)
  importance_res = importance(training_fit)
  importance_res = importance_res[order(importance_res[,"MeanDecreaseGini"] , decreasing = TRUE ),]
  #Print the importance table
  print(importance_res)
  #Display the MeanDecreaseGini plot
  varImpPlot(training_fit,type=2, main = paste("Plot of the MeanDecreaseGini for each attributes for ntree:", ntree, sep=""))
}
