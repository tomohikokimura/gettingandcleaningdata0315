# This R script generates a tidy data set, meansPerSubjectActivity, from the
# input data set for Human Activity Recognition Using Smartphones as specified
# below:
#
# 1. Consists of both training and test data that are merged.
# 2. Includes only the measurements on the mean and standard deviation
#    for each measurement.
# 3. For each of the measurements selected above, summarises it by taking a mean
#    per each subject and activity.
# 4. All the selected features have descriptive column names taken from
#    "features.txt"
#
# This script assumes that the data set is located in the working directory with
# the following directory structure:
#
# ./UCI HAR Dataset/activity_labels.txt        (activity id/label table)
#                  /features.txt               (feature id/label table)
#                  /train/                     (training data directory)
#                         X_train.tx           (observations)
#                         subject_train.txt    (subjects)
#                         y_train.txt          (activities)
#                  /test/                      (test data directory)
#                        X_test.txt            (observations)
#                        subject_test.txt      (subjects)
#                        y_test.txt            (activities)
#
#
# The original data set can be downloaded the following URL:
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

library(plyr)
library(dplyr)

# Directory name constants
UCI_HAR_DIR = "./UCI HAR Dataset"
TEST_DIR = "/test"
TRAIN_DIR = "/train"

# Utility functions to create a training / test data file path from a file name.
metaDataFile <- function(filename) { paste0(UCI_HAR_DIR, "/", filename) }
testFile <- function(filename) {
    paste0(UCI_HAR_DIR, "/", TEST_DIR, "/", filename)
}
trainFile <- function(filename) {
    paste0(UCI_HAR_DIR, "/", TRAIN_DIR, "/", filename)
}

# Data files.
TEST_DATA = testFile("/X_test.txt")
TEST_SUBJ_DATA = testFile("/subject_test.txt")
TEST_ACTIVITY_DATA  = testFile("/y_test.txt")

TRAIN_DATA = trainFile("/X_train.txt")
TRAIN_SUBJ_DATA = trainFile("/subject_train.txt")
TRAIN_ACTIVITY_DATA  = trainFile("/y_train.txt")

# The feature ID / label table.
FEATURES_FILE = "features.txt"
features = read.table(metaDataFile(FEATURES_FILE), col.names=c("index", "label"))

# Extracts only the measuraments on mean and standard deviation from the give
# data frame consisting of 561 features. Each feature is labled in the file
# "UCI HAR Dataset/features.txt".
extractMeanAndStd <- function(measurements) {
    # Keeps columns with feature names containing "mean()" or "std()".
    # Needs to be careful not to match on "meanFreq()" and "gravityMean".
    measurements[, grep("mean\\(\\)|std\\(\\)", features$label)]
}

# The activity ID / label table
ACTIVITIES_FILE = "activity_labels.txt"
ACTIVITY_ID_COL = "aid"
ACTIVITY_COL = "activity"
activities <- read.table(metaDataFile(ACTIVITIES_FILE),
                         col.names=c(ACTIVITY_ID_COL, ACTIVITY_COL))
# Reads in subject ID vector from a file that corresponds to the training / test
# data, joins with the activity ID/label table, and keeps only the labels.
activityLabelsVector <- function(activityDataFile) {
    activityIds <- read.table(activityDataFile, col.names=c(ACTIVITY_ID_COL))
    select(join(activityIds, activities), activity)
}

# Reads in a subject ID vector from an input file and assigns a column name
# SUBJECT_ID_COL.
SUBJECT_ID_COL = "subject"
subjectIdsVector <- function(subjectData) {
    read.table(subjectData, col.names=c(SUBJECT_ID_COL))
}

# Given a data file of feature vectors, a subject ID table, and an activity
# table, joins each feature vector with the corresponding subject ID and
# activity label, keeping only the means and standard deviations of measurements
# with descriptive feature labels.
#
# Parameters:
#     dataFile     - A white space separated table of 561-features vectors.
#     subjectFile  - A file containing a single vector table of subject IDs
#                    corresponding to each feature vector.
#     activityFile - A file containing a single vector table of activity IDs
#                    corresponding to each feature vector.
meansAndStds <- function(dataFile, subjectFile, activityFile) {
    # Reads a table of feature vectors.
    data <- read.table(dataFile)
    # Sets the column name to the descriptive labels.
    names(data) <- features$label
    # Keeps only the means and STDs, reducing the feature size.
    meansStds <- extractMeanAndStd(data)
    # Generates a subject ID vector.
    subjects <- subjectIdsVector(subjectFile)
    # Generates an activity label vector.
    activities <- activityLabelsVector(activityFile)
    # Binds into a singe data frame.
    cbind(subjects, activities, meansStds)
}

# Extracts the means and standard deviations from the feature vectors first
# to reduce the data size before merging the training and test data sets.
testData <- meansAndStds(TEST_DATA, TEST_SUBJ_DATA, TEST_ACTIVITY_DATA)
trainData <- meansAndStds(TRAIN_DATA, TRAIN_SUBJ_DATA, TRAIN_ACTIVITY_DATA)
allData <- rbind(testData, trainData)
meansPerSubjectActivity <- summarise_each(group_by(allData, subject, activity),
                                          funs(mean))
