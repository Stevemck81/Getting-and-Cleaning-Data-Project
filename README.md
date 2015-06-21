# Getting-and-Cleaning-Data-Project

This ReadMe documents the submission for the Coursera 'Getting and Cleaning Data' course project.

There is also:

CodeBook.MD that describes the variables and data. 

Labels.txt with the tidy column names applied to the x data

run_analysis.R script file with code used to produce the data

TidyData.txt with the independent tidy data set with the average of each variable for each subject and activity


##Description of the R script

### Download the data and unzip it
This part isn't in the R file itself but can be used to downloaded the data into the working directory

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./Dataset.zip")


unzip("./Dataset.zip", exdir = "./Dataset")

### Read the necessary files into R
The following code reads the files contained in the zip files that are needed into R


y_test <- read.table("./Dataset/UCI HAR Dataset/test/y_test.txt")

x_test <- read.table("./Dataset/UCI HAR Dataset/test/X_test.txt")

subject_test <- read.table("./Dataset/UCI HAR Dataset/test/subject_test.txt")

y_train <- read.table("./Dataset/UCI HAR Dataset/train/y_train.txt")

x_train <- read.table("./Dataset/UCI HAR Dataset/train/X_train.txt")

subject_train <- read.table("./Dataset/UCI HAR Dataset/train/subject_train.txt")

labels <- read.table("./Dataset/UCI HAR Dataset/features.txt", stringsAsFactors=FALSE)


### merge the test and train datasets
Next the test and train datasets are joined using the rbind function for the 'x data', 'y data' and subject list.

x_total <- rbind(x_test, x_train)

y_total <- rbind(y_test, y_train)

subjects <- rbind(subject_test, subject_train)


### identify the columns containing mean or std and subset the labels
The columns needed for the submission are those for the mean and standard deviation. These are identified by created a logical vector with the grepl command searching for the terms mean or std.
The subset of columns meeting this criteria are stored in a dataframe called 'labels' using the subset function. At this stage this contains some variables that could or could not be included 
named with 'FrequencyMean' making 79 variables in total.

ChooseColumns <- grepl("-mean|-std", labels[,2])

labels <- subset(labels[,2], ChooseColumns)

### subset the x data for the columns containing mean or std
The x data are subset on the same basis as the column labels so only those columsn are included.

x_subset <- subset(x_total, select = ChooseColumns)


### further remove columns containing meanFreq
This step removes the additional columns named 'meanFreq' which it has been chosen not to include in this submission. This step could be removed if it was preferred to include them.

ChooseColumns <- !grepl("meanFreq", labels)

labels <- subset(labels, ChooseColumns)

x_subset <- subset(x_subset, select = ChooseColumns)


### Tidy the label names with changes to another file
The tidy version of the column names from the original data were created in a separate txt file included in the repository called LableNames. These replace the original names in the following code.


labels2 <- labels <- read.table("./LabelNames.txt", stringsAsFactors = FALSE)

labels2 <- labels2[,2]


### name the columns
The columns in the x data are named with the tidy names here and names are also given to the activity and subject data

colnames(y_total) <- ("Activity")

colnames(x_subset) <- (labels2)

colnames(subjects) <- ("Subject")


### Replace the activity values with descriptive names
The numerical activity codes are replaced with the actual activity names here

y_total$Activity[which(y_total$Activity==1)] <- "Walking"

y_total$Activity[which(y_total$Activity==2)] <- "Walking_Upstairs"

y_total$Activity[which(y_total$Activity==3)] <- "Walking_Downstairs"

y_total$Activity[which(y_total$Activity==4)] <- "Sitting"

y_total$Activity[which(y_total$Activity==5)] <- "Standing"

y_total$Activity[which(y_total$Activity==6)] <- "Laying"


### merge the activity labels in the y data with the x data
The x data, subjects and activity data are now merged using cbind

Data <- cbind(y_total, subjects, x_subset)

### Create an independent tidy data set with the average of each variable for each activity and each subject
A tidy data file of the means of each columns grouped by the activity and subject are created using the aggregate function

Summary <- aggregate(Data, list(Activity = Data$Activity, Subject = Data$Subject), mean)

### Write the Summary data to a text file
Finally the summary data is written to a txt file

write.table(Summary, file = "./TidyData.txt", row.names = FALSE)
