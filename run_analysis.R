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

# Data files.
TEST_DATA = uciTestFile("/X_test.txt")
TEST_SUBJ_DATA = uciTestFile("/subject_test.txt")
TEST_ACTIVITY_DATA  = uciTestFile("/y_test.txt")

TRAIN_DATA = uciTrainFile("/X_train.txt")
TRAIN_SUBJ_DATA = uciTrainFile("/subject_train.txt")
TRAIN_ACTIVITY_DATA  = uciTrainFile("/y_train.txt")

# Load the feature labels.
FEATURES_FILE = "features.txt"
features = read.table(uciDataFile(FEATURES_FILE), col.names=c("index", "label"))

# Extracts only the measuraments of means and standard deviations from
# the give data frame of measuraments consisting of 561 features.
# Each feature is labled in the file "UCI HAR Dataset/features.txt".
extractMeanAndStd <- function(measurements) {
    measurements[, grep("mean\\(\\)|std\\(\\)", features$label)]
}

# Activities labels
ACTIVITIES_FILE = "activity_labels.txt"
ACTIVITY_ID_COL = "aid"
activities <- read.table(uciDataFile(ACTIVITIES_FILE),
                         col.names=c(ACTIVITY_ID_COL, "activity"))
activityLabelsVector <- function(activityDataFile) {
    activityIds <- read.table(activityDataFile, col.names=c(ACTIVITY_ID_COL))
    select(merge(activityIds, activities), activity)
}

# Subject ids
SUBJECT_ID_COL = "subject"
subjectIdsVector <- function(subjectData) {
    read.table(subjectData, col.names=c(SUBJECT_ID_COL))
}

# Reads the feature vector table and extract only the measurements on means and
# starndard deviations, and joins the subsetted feature vectors with
# corresponding subject IDs and activity labels, with all columns given
# descriptive names.
meansAndStds <- function(dataFile, subjectFile, activityFile) {
    data <- read.table(dataFile)
    names(data) <- features$label
    meansStds <- extractMeanAndStd(data)
    subjects <- subjectIdsVector(subjectFile)
    activities <- activityLabelsVector(activityFile)
    cbind(subjects, activities, meansStds)
}

testData <- meansAndStds(TEST_DATA, TEST_SUBJ_DATA, TEST_ACTIVITY_DATA)
trainData <- meansAndStds(TRAIN_DATA, TRAIN_SUBJ_DATA, TRAIN_ACTIVITY_DATA)
mergedData <- rbind(testData, trainData)
