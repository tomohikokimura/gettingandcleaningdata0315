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

UCI_HAR_DATA_DIR = "./UCI HAR Dataset"
TEST_DATA_DIR = paste0(UCI_HAR_DATA_DIR, "/test")
TRAIN_DATA_DIR = paste0(UCI_HAR_DATA_DIR, "/train")

TEST_DATA = paste0(TEST_DATA_DIR, "/X_test.txt")
TEST_SUBJ_DATA = paste0(TEST_DATA_DIR, "/subject_test.txt")
TEST_ACTIVITY_DATA  = paste0(TEST_DATA_DIR, "/y_test.txt")

TRAIN_DATA = paste0(TRAIN_DATA_DIR, "/X_train.txt")
TRAIN_SUBJ_DATA = paste0(TRAIN_DATA_DIR, "/subject_train.txt")
TRAIN_ACTIVITY_DATA  = paste0(TRAIN_DATA_DIR, "/y_train.txt")

testVars <- read.table(TEST_DATA, sep = "", header = FALSE)
testSubject <- read.table(TEST_SUBJ_DATA, sep = "", header = FALSE)
testActivity <- read.table(TEST_ACTIVITY_DATA, sep = "", header = FALSE)
testData <- cbind(testSubject, testActivity, testVars)

trainVars <- read.table(TRAIN_DATA, sep = "", header = FALSE)
trainSubject <- read.table(TRAIN_SUBJ_DATA, sep = "", header = FALSE)
trainActivity <- read.table(TRAIN_ACTIVITY_DATA, sep = "", header = FALSE)
trainData <- cbind(trainSubject, trainActivity, trainVars)

mergedData <- rbind(testData, trainData)
