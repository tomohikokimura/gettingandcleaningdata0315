# This is an R script that does the following:
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation
#    for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set.
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data
#    set with the average of each variable for each activity and each subject.

library(dplyr)

UCI_HAR_DIR = "./UCI HAR Dataset"
TEST_DIR = "/test"
TRAIN_DIR = "/train"

uciDataFile <- function(filename) { paste0(UCI_HAR_DIR, "/", filename) }
uciTestFile <- function(filename) {
    paste0(UCI_HAR_DIR, "/", TEST_DIR, "/", filename)
}
uciTrainFile <- function(filename) {
    paste0(UCI_HAR_DIR, "/", TRAIN_DIR, "/", filename)
}

# Load the feature labels.
FEATURES_FILE = "features.txt"
features = read.table(uciDataFile(FEATURES_FILE), col.names=c("index", "label"))

# Extracts only the measuraments of means and standard deviations from
# the give data frame of measuraments consisting of 561 features.
# Each feature is labled in the file "UCI HAR Dataset/features.txt".
extractMeanAndSdv <- function(measurements) {
    measurements[, grep("mean\\(\\)|std\\(\\)", features$label)]
}

TEST_DATA = uciTestFile("/X_test.txt")
TEST_SUBJ_DATA = uciTestFile("/subject_test.txt")
TEST_ACTIVITY_DATA  = uciTestFile("/y_test.txt")

TRAIN_DATA = uciTrainFile("/X_train.txt")
TRAIN_SUBJ_DATA = uciTrainFile("/subject_train.txt")
TRAIN_ACTIVITY_DATA  = uciTrainFile("/y_train.txt")

testMeasurements <- read.table(TEST_DATA)
testMeansStds <- extractMeanAndSdv(testMeasurements)
testSubject <- read.table(TEST_SUBJ_DATA)
testActivity <- read.table(TEST_ACTIVITY_DATA)
testData <- cbind(testSubject, testActivity, testMeansStds)

trainMeasuraments <- read.table(TRAIN_DATA)
trainMeansStds <- extractMeanAndSdv(trainMeasuraments)
trainSubject <- read.table(TRAIN_SUBJ_DATA)
trainActivity <- read.table(TRAIN_ACTIVITY_DATA)
trainData <- cbind(trainSubject, trainActivity, trainMeansStds)

mergedData <- rbind(testData, trainData)
