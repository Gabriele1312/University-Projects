library(psych)
library(corrplot)
library(caret)
library(randomForest)
library(e1071)
library(pROC)
library(ggplot2)
library(car)
library(gridExtra)

#upload dataset
diabetes_dataset <- read.csv(file="/Users/lele1312/IntelligentSystems/Assignment/Data/diabetes.csv",head=TRUE,sep=",")
diabetes_dataset
#descriptive info
describe(diabetes_dataset)

#CHECK NORMAL DISTRIBUTION
#Shapiro-Wilk
shapiro_tests <- lapply(diabetes_dataset[sapply(diabetes_dataset, is.numeric)], shapiro.test)
print(shapiro_tests)

# Function to create QQ plot for each column
create_qqplot <- function(data, col) {
  ggplot(data, aes(sample = .data[[col]])) +
    stat_qq(shape = 1, colour = "blue") +
    stat_qq_line(colour = "red") +
    ggtitle(paste("QQ Plot -", col)) +
    theme_minimal()
}

#List for plots
qqplots <- list()
cols_to_exclude <- c("Outcome")

#Make plots for each columns 
for (col in setdiff(names(diabetes_dataset), cols_to_exclude)) {
  if (is.numeric(diabetes_dataset[[col]])) {
    qqplots[[col]] <- create_qqplot(diabetes_dataset, col)
  }
}
#Bind plots in one single plot
combined_qqplot <- do.call("grid.arrange", c(qqplots, ncol = 3))

#CHECK BALANCE OF THE DATA
# Check the distribution of 'Outcome' variable
outcome_distribution <- table(diabetes_dataset$Outcome)
# Print the counts for each outcome
print(outcome_distribution)
# Plot the distribution of dependent variable
barplot(outcome_distribution, main = "Distribution of Outcome", xlab = "Outcome", ylab = "Count", col = "skyblue")

#----------------

#NOISE DETECTION AND TREATMENT
# Count missing values for each column
missing_values <- colSums(is.na(diabetes_dataset))
missing_values

# Create a bar plot for display the missing values
missing_values_plot <-- barplot(missing_values, col = ifelse(missing_values > 0, "red", "green"),
        main = "Missing Values by Feature",
        xlab = "Features",
        ylab = "Count",
        names.arg = colnames(diabetes_dataset),
        cex.names = 0.7,
        las = 2)

# Count nullify values for each column
columns_to_exclude <- c("Pregnancies", "Outcome")
filtered_data <- diabetes_dataset[, !colnames(diabetes_dataset) %in% columns_to_exclude]
nullify_values <- colSums(filtered_data== 0, na.rm = TRUE)
nullify_values

# Create a bar plot for display nullify values
barplot(nullify_values, col = ifelse(nullify_values > 0, "blue", "green"),
        main = "Zero Values by Feature",
        xlab = "Features",
        ylab = "Count",
        names.arg = colnames(filtered_data),
        cex.names = 0.7,
        las = 2)

cols <- c('Glucose', 'BloodPressure', 'SkinThickness', 'Insulin', 'BMI')
# Replace zero values with NA
diabetes_dataset[, cols][diabetes_dataset[, cols] == 0] <- NA
# Print the structure of the data frame
str(diabetes_dataset)

#----------------

#OUTLIERS DETECTION AND TREATMENT
# Set up the layout for subplots
par(mfrow = c(2, 4), mar = c(4, 4, 2, 2))
# Select columns for boxplots
cols <- names(diabetes_dataset)[1:(length(names(diabetes_dataset)) - 1)]
# Loop through columns and create boxplots
for (col in cols) {
  boxplot(diabetes_dataset[[col]], main = col, ylab = col, col = "lightblue", border = "black")
}
# Reset the layout
par(mfrow = c(1, 1))

# IQR function to detect outliers
detect_outliers_iqr <- function(data) {
  bool_series <- !is.na(data)
  data <- data[bool_series]
  data <- sort(data)
  
  q1 <- quantile(data, 0.25)
  q3 <- quantile(data, 0.75)
  
  IQR <- q3 - q1
  lwr_bound <- q1 - 1.5 * IQR
  upr_bound <- q3 + 1.5 * IQR
  
  outliers_down <- data[data < lwr_bound]
  outliers_up <- data[data > upr_bound]
  
  return(list(outliers_up = outliers_up, outliers_down = outliers_down))
}

#function to print outliers
print_outliers_iqr <- function(data, column_name) {
  outliers <- detect_outliers_iqr(data)
  
  cat("IQR outliers:", column_name, "\n")
  cat("Outliers (Upper):", outliers$outliers_up, "\n")
  cat("Outliers (Lower):", outliers$outliers_down, "\n")
  
}

# Columns to check for outliers
col_names <- c('Pregnancies', 'Glucose', 'BloodPressure', 'SkinThickness', 'Insulin', 'BMI', 'DiabetesPedigreeFunction', 'Age')

# Loop through columns and print outliers
for (col in col_names) {
  x <- print_outliers_iqr(diabetes_dataset[[col]], col)
}

# Treat outliers using IQR: this code replaces outliers with the lower and upper bounds within each specified column
# Specify the columns to analyze
col_names <- c('Pregnancies', 'Glucose', 'BloodPressure', 'SkinThickness', 'Insulin', 'BMI', 'DiabetesPedigreeFunction', 'Age')

# Loop through each specified column
for (col in col_names) {
  # Detect outliers using the IQR method
  outliers_info <- detect_outliers_iqr(diabetes_dataset[[col]])
  
  # Calculate quartiles and IQR
  q1 <- quantile(diabetes_dataset[[col]], 0.25, na.rm = TRUE)
  q3 <- quantile(diabetes_dataset[[col]], 0.75, na.rm = TRUE)
  IQR <- q3 - q1
  
  # Define lower and upper bounds
  lwr_bound <- q1 - 1.5 * IQR
  upr_bound <- q3 + 1.5 * IQR
  
  # Replace outliers with lower and upper bounds
  diabetes_dataset[[col]][diabetes_dataset[[col]] %in% outliers_info$outliers_down] <- lwr_bound
  diabetes_dataset[[col]][diabetes_dataset[[col]] %in% outliers_info$outliers_up] <- upr_bound
  
  # Clear the lists of outliers
  outliers_up <- c()
  outliers_down <- c()
}

#----------------

#IMPUTE MISSING VALUE 
# Fill 3 features having few NAs using median method.
features_to_fill <- c('Glucose', 'BloodPressure', 'BMI')

# Loop through each specified feature
for (feature in features_to_fill) {
  # Replace missing values with the median of the observed values in that feature
  diabetes_dataset[[feature]][is.na(diabetes_dataset[[feature]])] <- median(diabetes_dataset[[feature]], na.rm = TRUE)
}

# Correlation of features
correlation_matrix <- cor(diabetes_dataset)
corrplot(correlation_matrix, method = "color", type = "upper", order = "hclust", tl.col = "black", tl.srt = 45)

# Treat missing values in Insulin highly correlated with Glucose
# Sort the dataframe by Glucose
diabetes_dataset <- diabetes_dataset[order(diabetes_dataset$Glucose), ]

# Forward fill missing values in Insulin
for (i in 2:nrow(diabetes_dataset)) {
  if (is.na(diabetes_dataset$Insulin[i])) {
    diabetes_dataset$Insulin[i] <- diabetes_dataset$Insulin[i - 1]
  }
}

# Treat missing values in SkinThickness highly correlated with BMI
# Sort the dataframe by BMI
diabetes_dataset <- diabetes_dataset[order(diabetes_dataset$BMI), ]

# Forward fill missing values in Insulin
for (i in 2:nrow(diabetes_dataset)) {
  if (is.na(diabetes_dataset$SkinThickness[i])) {
    diabetes_dataset$SkinThickness[i] <- diabetes_dataset$SkinThickness[i - 1]
  }
}

# Fill NAs features due to error in training model.
features_to_fill <- c('SkinThickness', 'Insulin')

# Loop through each specified feature
for (feature in features_to_fill) {
  # Replace missing values with the median of the observed values in that feature
  diabetes_dataset[[feature]][is.na(diabetes_dataset[[feature]])] <- median(diabetes_dataset[[feature]], na.rm = TRUE)
}

#sort back by index
diabetes_dataset <- diabetes_dataset[order(rownames(diabetes_dataset)),]
diabetes_dataset

#----------------

#TRAIN-TEST SPLIT
# Extract predictor variables (X) excluding 'Outcome'
X <- diabetes_dataset[, !names(diabetes_dataset) %in% c('Outcome')]
# Extract the response variable (y)
y <- diabetes_dataset$Outcome
# Set the seed for reproducibility
set.seed(42)
# Specify the proportion for the test set
test_proportion <- 0.25
# Generate random indices for the test set
test_indices <- sample(1:length(y), size = test_proportion * length(y))
# Split the data into training and test sets
X_train <- X[-test_indices, ]
X_test <- X[test_indices, ]
y_train <- y[-test_indices]
y_test <- y[test_indices]

#DATA SCALING
# Combine X_train and X_test for scaling
combined_data <- rbind(X_train, X_test)
# Specify the method for scaling (in this case, "range" for Min-Max scaling)
scaling_method <- c("range")
# Use preProcess to scale the data
scaling_model <- preProcess(combined_data, method = scaling_method)
# Transform X_train and X_test using the scaling model
scaled_X_train <- predict(scaling_model, newdata = X_train)
scaled_X_test <- predict(scaling_model, newdata = X_test)
# Print the shapes
cat("Scaled X_train shape:", dim(scaled_X_train), "\n")
cat("Scaled X_test shape:", dim(scaled_X_test), "\n")

#----------------

#RANDOM FOREST CLASSIFIER
# Set the seed for reproducibility
set.seed(42)

# Create the random forest model
model <- randomForest(
  x = scaled_X_train,
  y = as.factor(y_train),  # Ensure y_train is a factor for classification
  classwt = c(1, 2),  # Class weights {0: 1, 1: 2}
  ntree = 25,
  mtry = sqrt(ncol(scaled_X_train)),  # Number of features to consider at each split
  minsplit = 5,
  maxdepth = 15,
  nodesize = 15
)

# Make predictions on the training and test sets
train_predictions <- predict(model, newdata = scaled_X_train)
test_predictions <- predict(model, newdata = scaled_X_test)


#MODEL CLASSIFICATION REPORT
# Create a classification report for training and test sets
classification_report_train <- confusionMatrix(as.factor(train_predictions), as.factor(y_train))
classification_report_test <- confusionMatrix(as.factor(test_predictions), as.factor(y_test))
# Print the classification reports
print("Classification Report Random Forest - Training Set:")
print(classification_report_train)
print("\nClassification Report Random Forest - Test Set:")
print(classification_report_test)

# Extract scores
accuracy_score_train <- classification_report_train$overall["Accuracy"]
precision_train <- classification_report_train$byClass["Precision"]
recall_train <- classification_report_train$byClass["Recall"]
f1_train <- classification_report_train$byClass["F1"]

accuracy_score_test <- classification_report_test$overall["Accuracy"]
precision_test <- classification_report_test$byClass["Precision"]
recall_test <- classification_report_test$byClass["Recall"]
f1_test <- classification_report_test$byClass["F1"]

# Print precision, recall, and F1 score
print("Metrics Random Forest - Training Set:")
print(paste("Accuracy Score - Training Set:", accuracy_score_train))
print(paste("Precision:", precision_train))
print(paste("Recall:", recall_train))
print(paste("F1 Score:", f1_train))

print("\nMetrics Random Forest - Test Set:")
print(paste("Accuracy Score - Test Set:", accuracy_score_test))
print(paste("Precision:", precision_test))
print(paste("Recall:", recall_test))
print(paste("F1 Score:", f1_test))

#ROC CURVE
test_prob <- predict(model, newdata = scaled_X_test, type = "prob")[,2]
roc_obj <- roc(as.factor(y_test), test_prob)
plot(roc_obj, main="ROC curve Random Forest", col="#1c61b6")
auc(roc_obj)
#----------------

# SUPPORT VECTOR MACHINE
model2 <- svm(as.factor(y_train) ~ ., data = scaled_X_train, kernel = "radial", cost = 1, probability = TRUE, class.weights = c("0" = 1, "1" = 2))
# Print the model details
print(model2)

# Make predictions on the training and test sets
train_predictionsSVM <- predict(model2, newdata = scaled_X_train)
test_predictionsSVM <- predict(model2, newdata = scaled_X_test)

#MODEL CLASSIFICATION REPORT
# Create a classification report for training and test sets
classification_report_trainSVM <- confusionMatrix(as.factor(train_predictionsSVM), as.factor(y_train))
classification_report_testSVM <- confusionMatrix(as.factor(test_predictionsSVM), as.factor(y_test))
# Print the classification reports
print("Classification Report SVM - Training Set:")
print(classification_report_trainSVM)
print("\nClassification Report SVM - Test Set:")
print(classification_report_testSVM)

# Extract scores
accuracy_score_trainSVM <- classification_report_trainSVM$overall["Accuracy"]
precision_trainSVM <- classification_report_trainSVM$byClass["Precision"]
recall_trainSVM <- classification_report_trainSVM$byClass["Recall"]
f1_trainSVM <- classification_report_trainSVM$byClass["F1"]

accuracy_score_testSVM <- classification_report_testSVM$overall["Accuracy"]
precision_testSVM <- classification_report_testSVM$byClass["Precision"]
recall_testSVM <- classification_report_testSVM$byClass["Recall"]
f1_testSVM <- classification_report_testSVM$byClass["F1"]

# Print precision, recall, and F1 score
print("Metrics SVM - Training Set:")
print(paste("Accuracy Score - Training Set:", accuracy_score_trainSVM))
print(paste("Precision:", precision_trainSVM))
print(paste("Recall:", recall_trainSVM))
print(paste("F1 Score:", f1_trainSVM))

print("\nMetrics SVM - Test Set:")
print(paste("Accuracy Score - Test Set:", accuracy_score_testSVM))
print(paste("Precision:", precision_testSVM))
print(paste("Recall:", recall_testSVM))
print(paste("F1 Score:", f1_testSVM))

#ROC CURVE
test_probSVM <- predict(model2, newdata = scaled_X_test, probability = TRUE)
test_probSVM <- attr(test_probSVM, "probabilities")[,2]
roc_objSVM <- roc(as.factor(y_test), test_probSVM)
plot(roc_objSVM, main="ROC curve SVM", col="#1c61b6")
auc(roc_objSVM)
#----------------
