
## Download the data and unzip it
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./Dataset.zip")
unzip("./Dataset.zip", exdir = "./Dataset")

## Read the necessary files into R

y_test <- read.table("./Dataset/UCI HAR Dataset/test/y_test.txt")
x_test <- read.table("./Dataset/UCI HAR Dataset/test/X_test.txt")
subject_test <- read.table("./Dataset/UCI HAR Dataset/test/subject_test.txt")
y_train <- read.table("./Dataset/UCI HAR Dataset/train/y_train.txt")
x_train <- read.table("./Dataset/UCI HAR Dataset/train/X_train.txt")
subject_train <- read.table("./Dataset/UCI HAR Dataset/train/subject_train.txt")
labels <- read.table("./Dataset/UCI HAR Dataset/features.txt", stringsAsFactors=FALSE)


## merge the test and train datasets
x_total <- rbind(x_test, x_train)
y_total <- rbind(y_test, y_train)
subjects <- rbind(subject_test, subject_train)


## identify the columns containing mean or std and subset the labels
ChooseColumns <- grepl("-mean|-std", labels[,2])
labels <- subset(labels[,2], ChooseColumns)

## subset the x data for the columns containing mean or std
x_subset <- subset(x_total, select = ChooseColumns)


## further remove columns containing meanFreq
ChooseColumns <- !grepl("meanFreq", labels)
labels <- subset(labels, ChooseColumns)
x_subset <- subset(x_subset, select = ChooseColumns)


## Tidy the label names with changes to another file
labels2 <- labels <- read.table("./LabelNames.txt", stringsAsFactors = FALSE)
labels2 <- labels2[,2]


## name the columns
colnames(y_total) <- ("Activity")
colnames(x_subset) <- (labels2)
colnames(subjects) <- ("Subject")


## Replace the activity values with descriptive names
y_total$Activity[which(y_total$Activity==1)] <- "Walking"
y_total$Activity[which(y_total$Activity==2)] <- "Walking_Upstairs"
y_total$Activity[which(y_total$Activity==3)] <- "Walking_Downstairs"
y_total$Activity[which(y_total$Activity==4)] <- "Sitting"
y_total$Activity[which(y_total$Activity==5)] <- "Standing"
y_total$Activity[which(y_total$Activity==6)] <- "Laying"


## merge the activity labels in the y data with the x data
Data <- cbind(y_total, subjects, x_subset)

## Create an independent tidy data set with the average of each variable for each activity and each subject
Summary <- aggregate(Data[3:68], list(Activity = Data$Activity, Subject = Data$Subject), mean)

## Write the Summary data to a text file
write.table(Summary, file = "./TidyData.txt", row.names = FALSE)
