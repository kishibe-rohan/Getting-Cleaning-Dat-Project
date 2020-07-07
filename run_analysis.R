# Getting and Cleaning Data Project John Hopkins Coursera
# Author: Kishibe Rohan

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(reshape2)    #load lib required to melt and cast 

#1. get dataset from web and store in working directory

rawDataDir <- "./rawData"
rawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataFile <- "rawData.zip"
rawDataDest <- paste(rawDataDir,"/","rawData.zip",sep = "")
dataDir <- "./data"

if(!file.exists(rawDataDir))
{
  dir.create(rawDataDir)
  download.file(url = rawDataUrl,destfile = rawDataDest)
}

if(!file.exists(dataDir))
{
  dir.create(dataDir)
  unzip(zipfile = rawDataDest, exdir = dataDir)
}

#2. Merge train and test data

# train data
x_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/Y_train.txt"))
s_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/subject_train.txt"))

# test data
x_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/Y_test.txt"))
s_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/subject_test.txt"))

# merge 
x_data <- rbind(x_train,x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)

#3. Extract feature & activity info

feature <- read.table(paste(sep="",dataDir,"/UCI HAR Dataset/features.txt"))

a_label <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/activity_labels.txt"))
a_label[,2] <- as.character(a_label[,2])

# Extract mean & standard deviation info

targetCols <- grep("-(mean|std).*",as.character(feature[,2]))
targetColNames <- feature[targetCols,2]
targetColNames <- gsub("-mean","Mean",targetColNames)
targetColNames <- gsub("-std","Std",targetColNames)
targetColNames <- gsub("[-()]", "", targetColNames)

#4. Label the data set with descriptive variable names.

x_data <- x_data[targetCols]
reqData <- cbind(s_data,y_data,x_data)
colnames(reqData) <- c("Subject","Activity",targetColNames)

reqData$Activity <- factor(reqData$Activity,levels = a_label[,1],labels = a_label[,2])
reqData$Subject <- as.factor(reqData$Subject)

#5. Melt and cast to generate tidy dataset

meltedData <- melt(reqData,id=c("Subject","Activity"))
tidyData <- dcast(meltedData,Subject + Activity ~ variable,mean)

write.table(tidyData,"./tidy_dataset.txt",row.names = FALSE,quote = FALSE)

