setwd("C:\\Users\\Scott\\Documents\\Coursera\\Getting_and_Cleaning_Data\\Week4")
library(dplyr)
library(reshape2)

address <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
root <- "./Samsung_activity_data/UCI HAR Dataset/"
if (!file.exists(address)){
    download.file(address, "./Samsung_activity_data.zip", method = "curl")
    unzip("./Samsung_activity_data.zip", exdir = "./Samsung_activity_data")
}
train_x <- read.table(paste(root, "train/X_train.txt", sep=""))
train_y <- read.table(paste(root, "train/y_train.txt", sep=""))
test_x <- read.table(paste(root, "test/X_test.txt", sep=""))
test_y <- read.table(paste(root, "test/y_test.txt", sep=""))
features <- read.table(paste(root, "features.txt", sep=""))
train_subj <- read.table(paste(root, "train/subject_train.txt", sep=""))
test_subj <- read.table(paste(root, "test/subject_test.txt", sep=""))
labels <- read.table(paste(root, "activity_labels.txt", sep=""))

#Add columns to test and train datasets
test <- setNames(cbind(test_subj, test_y, test_x), c("Subject", "Activity", as.character(features[,2])))
train <- setNames(cbind(train_subj, train_y, train_x), c("Subject", "Activity", as.character(features[,2])))
combined <- rbind(test, train)

#Match the Activity column to a label
labeled <- merge(combined, labels, by.x = "Activity", by.y = "V1", all=TRUE)
labeled$Activity <- as.character(labeled$V2)
labeled <- labeled[, 1:563]
to_keep <- c(grep("mean()", names(labeled)), grep("std()", names(labeled)))
finalData <- select(labeled, Activity, Subject, to_keep)

#Create a second, independent tidy data set with the average of each variable for each activity
#and each subject
tidied_melted <- melt(finalData, id=c("Activity", "Subject"))
tidied <- dcast(tidied_melted, Activity + Subject ~ variable, mean)

#Write out a text file
write.table(tidied, file = "./Week4/tidiedMean.txt", row.names = FALSE)