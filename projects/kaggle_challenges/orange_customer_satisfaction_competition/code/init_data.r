train <- read.table(file="train_X.csv", header=FALSE, sep="\t", na.strings = "")
test <- read.table(file="test_X.csv", header=FALSE, sep="\t", na.strings = "")

trainLabels <- read.table(file="train_Y.csv", header=TRUE, sep="\t", na.strings = "")
trainLabelNames <- colnames(trainLabels)
train$appetency <- as.factor(trainLabels$appetency)
train$churn <- as.factor(trainLabels$churn)
train$upselling <- as.factor(trainLabels$upselling)

# For most of the numeric vars we can choose whether to treat them
# as ordinal or factors - however these (below) are definitely 
# continuous since they have fractional parts.
continuousVarNames <- c(
  "V14", 
  "V31", 
  "V51", 
  "V61", 
  "V65", 
  "V101", 
  "V110", 
  "V111", 
  "V120", 
  "V147", 
  "V170", 
  "V176",
  "V180",
  "V183",
  "V185",
  "V192")

# And these are character factors
characterVarNames <- c(
  "V4",
  "V11",
  "V22",
  "V27",
  "V29",
  "V38",
  "V50",
  "V58",
  "V73",
  "V76",
  "V77",
  "V79",
  "V90",
  "V93",
  "V112",
  "V116",
  "V118",
  "V119",
  "V125",
  "V126",
  "V128",
  "V138",
  "V143",
  "V149",
  "V154",
  "V155",
  "V156",
  "V158",
  "V165",
  "V168",
  "V182",
  "V187",
  "V189",
  "V190",
  "V196",
  "V204",
  "V212",
  "V224"
)

source("util_functions.r")
source("pre_processing_functions.r")
source("test_harness.r")

# Drop any columns that are all NA - in test and train data
train <- drop_na_cols(train, 1)
test <- drop_na_cols(test, 1)

discreteNumericVarNames <- names(train)[!(names(train) %in% c(characterVarNames, continuousVarNames, trainLabelNames))]
positive.appetency = train[train$appetency == 1, ]
positive.churn = train[train$churn == 1, ]
positive.upselling = train[train$upselling == 1, ]
negative.appetency = train[train$appetency == -1, ]
negative.churn = train[train$churn == -1, ]
negative.upselling = train[train$upselling == -1, ]
