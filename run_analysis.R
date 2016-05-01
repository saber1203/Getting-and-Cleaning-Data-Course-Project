setwd("C:/Users/jim.wang/Documents/R")

# 1. Merges the training and the test sets to create one data set.

## step 1: download file from website and unzip file
if(!file.exists("./data")) {dir.create("./data")}
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(Url, destfile = "./data/wearable.zip")
wearalbe <- unzip("./data/wearable.zip", exdir = "./data")

## step 2: Load data into R
train.x <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
train.y <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
train.subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
test.x <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
test.y <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
test.subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

## step 3: merge train and test data
train <- cbind(train.subject, train.y, train.x)
test <- cbind(test.subject, test.y, test.x)
mergedata <- rbind(train, test)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

features <- read.table("./data/UCI HAR Dataset/features.txt")
meanstd <- grep("mean\\(\\)|std\\(\\)",features[,2])
MSdata <- mergedata[,c(1,2,meanstd+2)]
colnames(MSdata) <- c("subject", "activity",as.character(features[,2][meanstd]))


# 3. Uses descriptive activity names to name the activities in the data set

activity <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
MSdata$activity <- factor(MSdata$activity,activity$V1,activity$V2)

# 4. Appropriately labels the data set with descriptive variable names.

names(MSdata) <- gsub("\\()", "", names(MSdata))
names(MSdata) <- gsub("-mean", "mean", names(MSdata))
names(MSdata) <- gsub("-std", "std", names(MSdata))
names(MSdata) <- gsub("^t", "time", names(MSdata))
names(MSdata) <- gsub("^f", "frequence", names(MSdata))
names(MSdata) <- tolower(names(MSdata))

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(dplyr)
group <- MSdata %>%
  group_by(subject, activity) %>%
  summarise_each(funs(mean))

write.table(group, "./data/mean.txt", row.names = FALSE)