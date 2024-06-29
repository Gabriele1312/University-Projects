library(psych)
library(corrplot)
library(caret)
library(tidyverse)
library(ggplot2)
library(randomForest)
library(kknn)
library(dplyr)
library(reshape2)

#upload dataset
wine_dataset <- read.csv(file="/Users/lele1312/IntelligentSystems/Assignment/Data/winequality-red.csv",head=TRUE,sep=",")
wine_dataset

#DATA EXPLORATION
#Histogram for quality (target variable)
hist(wine_dataset$quality, breaks = seq(0, 11, by = 1), col = 'lightblue', border = 'black', main = 'Histogram of quality', xlab = 'quality', ylab = 'Frequency')
xlim <- c(1, 10)
axis(side = 1, at = seq(xlim[1], xlim[2], by = 1))
table(wine_dataset$quality) #number of value for each outcome
#descriptive info
describe(wine_dataset)

#CHECK NORMAL DISTRIBUTION
#Shapiro-Wilk
shapiro_tests <- lapply(wine_dataset[sapply(wine_dataset, is.numeric)], shapiro.test)
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
cols_to_exclude <- c("quality")

#Make plots for each columns 
for (col in setdiff(names(wine_dataset), cols_to_exclude)) {
  if (is.numeric(wine_dataset[[col]])) {
    qqplots[[col]] <- create_qqplot(wine_dataset, col)
  }
}
#Bind plots in one single plot
combined_qqplot <- do.call("grid.arrange", c(qqplots, ncol = 3))

#----------------

#CORRELATION OF FEATURES
# SCATTER PLOT OF FEATURES VS QUALITY
# Create a list of all features to consider
features <- c('fixed.acidity', 'volatile.acidity', 'citric.acid', 'residual.sugar', 'chlorides', 'free.sulfur.dioxide', 'total.sulfur.dioxide', 'density', 'pH', 'sulphates', 'alcohol')
# Create a new figure with the specified size
par(mfrow = c(3, 4), mar = c(4, 4, 2, 1))
# Iterate through each feature and create a scatter plot
for (feature in features) {
  # Extract the feature values and quality values
  feature_values <- wine_dataset[[feature]]
  quality_values <- wine_dataset[['quality']]
  # Check if lengths match
  if (length(feature_values) == length(quality_values)) {
    # Create a scatter plot of the feature values versus quality values
    plot(feature_values, quality_values, pch = 19, col = adjustcolor('skyblue', alpha = 0.7),
         xlab = feature, ylab = 'Quality')
    # Add a title to the scatter plot
    title(paste0(feature, ' vs. Quality'))
  } else {
    cat("Lengths of", feature, "and quality differ.\n")
  }
}

#CORRELATION MATRIX
correlation_matrix <- cor(wine_dataset)
correlation_matrix
corrplot(correlation_matrix, method = "color", type = "upper", order = "hclust", tl.col = "black", tl.srt = 45)

#heatmap correlation
ggplot(melt(correlation_matrix), aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile() +
  scale_fill_gradient2(low = "red", high = "blue", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(x='', y='', title='Heat-Map correlation')

#----------------

#DETECTING AND REMOVE OUTLIERS (2 METHODS)
# Set up the layout for subplots
par(mfrow = c(3, 4), mar = c(4, 4, 2, 2))  # Adjust the layout for 11 features
# Select columns for boxplots
cols <- names(wine_dataset)[1:11]
# Loop through columns and create boxplots
for (i in 1:11) {
  boxplot(wine_dataset[[cols[i]]], main = cols[i], ylab = cols[i], col = "lightblue", border = "black")
}
# Reset the layout
par(mfrow = c(1, 1))

#Z-score based
# Calculate Z-scores
z_scores <- as.data.frame(scale(wine_dataset[, cols]))

# Identify outliers
outliers <- apply(z_scores, 1, function(x) any(x > 3 | x < -3))

# Count and percentage of outliers
total_outliers <- sum(outliers)
percentage_outliers <- (total_outliers / nrow(wine_dataset)) * 100

# Print total number and percentage of outliers
cat("Total number of rows with outliers:", total_outliers, "\n")
cat("Percentage of rows with outliers:", percentage_outliers, "%\n")
# Remove outliers
wine_dataset_clean <- wine_dataset[!outliers, ]

#IQR-based
#IQR for each columns
outlier_rows <- rep(FALSE, nrow(wine_dataset))

for (col in names(wine_dataset[, cols])) {
  Q1 <- quantile(wine_dataset[[col]], 0.25, na.rm = TRUE)
  Q3 <- quantile(wine_dataset[[col]], 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  
  outliers <- wine_dataset[[col]] < lower_bound | wine_dataset[[col]] > upper_bound
  outlier_rows <- outlier_rows | outliers
}

total_outliers_iqr <- sum(outlier_rows)
percentage_outliers_iqr <- (total_outliers_iqr / nrow(wine_dataset)) * 100

cat("Total rows with outlier (IQR):", total_outliers_iqr, "\n")
cat("Percentage of rows with outlier (IQR):", percentage_outliers_iqr, "%\n")
# Remove outliers 
wine_dataset_clean <- wine_dataset[!outlier_rows, ]

#check the quality values, Histogram for quality (target variable)
hist(wine_dataset_clean$quality, breaks = seq(0, 11, by = 1), col = 'lightblue', border = 'black', main = 'Histogram of quality', xlab = 'quality', ylab = 'Frequency')
xlim <- c(1, 10)
axis(side = 1, at = seq(xlim[1], xlim[2], by = 1))
table(wine_dataset_clean$quality) #number of value for each outcome

#----------------

#FEATURE SELECTION 
#preparing variables
target_variable <- 'quality'
features <- setdiff(names(wine_dataset_clean), target_variable)

#train random forest model
rf_model <- randomForest(x = wine_dataset_clean[features], 
                         y = wine_dataset_clean[[target_variable]], 
                         importance = TRUE, 
                         ntree = 500)

#Feature importance >MSE >importance
feature_importance <- rf_model$importance[, '%IncMSE']

#Data fram for feature importance
importance_df <- data.frame(Feature = names(feature_importance), Importance = feature_importance)

#Bar plot feature importance
ggplot(importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = 'identity') +
  coord_flip() +
  xlab('Feature') +
  ylab('Importance') +
  ggtitle('Features Importance based on %IncMSE using random forest')

#selecting features
features_number <- 8
selected_features <- names(sort(feature_importance, decreasing = TRUE)[1:features_number])
# Dataset with no outliers and selected features
wine_dataset_noOutliers_selected <- wine_dataset_clean[c(selected_features, target_variable)]
wine_dataset_noOutliers_selected

#----------------

#DATA SPLITTING
#seed for reproducibility
set.seed(123)

#Dataset Splitting
index <- createDataPartition(y = wine_dataset_noOutliers_selected$quality, p = 0.8, list = FALSE)
train_data <- wine_dataset_noOutliers_selected[index,]
test_data <- wine_dataset_noOutliers_selected[-index,]

#Data preparing 
preproc <- preProcess(train_data[, -ncol(train_data)], method = c("center", "scale"))
train_norm <- predict(preproc, train_data[, -ncol(train_data)])
test_norm <- predict(preproc, test_data[, -ncol(test_data)])
train_norm$quality <- train_data$quality
test_norm$quality <- test_data$quality

#----------------

#BASELINE MODEL to compare my models
mean_training_target <- mean(train_norm$quality)
baseline_predictions <- rep(mean_training_target, nrow(test_norm))

mae_baseline <- mean(abs(test_norm$quality - baseline_predictions))
mse_baseline <- mean((test_norm$quality - baseline_predictions)^2)
rmse_baseline <- sqrt(mse_baseline)

ss_total <- sum((test_norm$quality - mean(test_norm$quality))^2)
ss_res <- sum((test_norm$quality - baseline_predictions)^2)
r_squared_baseline <- 1 - (ss_res / ss_total)

cat("Baseline MAE:", mae_baseline, "\n")
cat("Baseline MSE:", mse_baseline, "\n")
cat("Baseline RMSE:", rmse_baseline, "\n")
cat("Baseline R^2:", r_squared_baseline, "\n")

#Residuals
baseline_predictions <- as.vector(baseline_predictions)
residuals <- test_data$quality - baseline_predictions

#Residuals plot
residual_plot <- ggplot() +
  geom_histogram(aes(x=residuals), bins=30, fill="blue", color="black") +
  ggtitle("Baseline model: Residuals Distribution") +
  xlab("Residuals") +
  ylab("Frequency")
print(residual_plot)

#Actual vs Predicted plot
actual_vs_predicted_plot <- ggplot() +
  geom_point(aes(x=baseline_predictions, y=test_data$quality), color="blue") +
  ggtitle("Baseline model: Actual vs Predicted") +
  xlab("Predicted Quality") +
  ylab("Actual Quality") +
  geom_abline(intercept=0, slope=1, linetype="dashed", color="red")
print(actual_vs_predicted_plot)


#----------------

#KNN Regression with Hyperparameter Tuning (k)
train_control <- trainControl(method = "repeatedcv", number = 10, repeats = 10)
set.seed(123)
knn_fit <- train(
  quality ~ .,
  data = train_norm,
  method = 'knn',
  tuneLength = 10,
  trControl = train_control
)
#Print results
print(knn_fit)

#Plot comparision between K and RMSE
ggplot(knn_fit$results, aes(x = k, y = RMSE)) +
  geom_line() +
  geom_point() +
  ggtitle("RMSE vs k for KNN Regression") +
  xlab("k (Number of Neighbors)") +
  ylab("RMSE")

#Predictions with best model
knn_predictions <- predict(knn_fit, test_norm)
#Results on test set
knn_results <- postResample(pred = knn_predictions, obs = test_norm$quality)
print(knn_results)


#Residuals
knn_predictions <- as.vector(knn_predictions)
residuals <- test_data$quality - knn_predictions

#Residuals plot
residual_plot <- ggplot() +
  geom_histogram(aes(x=residuals), bins=30, fill="blue", color="black") +
  ggtitle("KNN Regression: Residuals Distribution") +
  xlab("Residuals") +
  ylab("Frequency")
print(residual_plot)

#Actual vs Predicted plot
actual_vs_predicted_plot <- ggplot() +
  geom_point(aes(x=knn_predictions, y=test_data$quality), color="blue") +
  ggtitle("KNN Regression: Actual vs Predicted") +
  xlab("Predicted Quality") +
  ylab("Actual Quality") +
  geom_abline(intercept=0, slope=1, linetype="dashed", color="red")
print(actual_vs_predicted_plot)

#----------------

#RIDGE Regression with Hyperparameter Tuning (lambda)
ridge_fit <- train(
  quality ~ .,
  data = train_norm,
  method = 'ridge',
  tuneLength = 10,
  trControl = train_control
)

#Print results
print(ridge_fit)

#Plot comparision between λ and RMSE
ggplot(ridge_fit$results, aes(x = lambda, y = RMSE)) +
  geom_line() +
  geom_point() +
  ggtitle("RMSE vs λ for Ridge Regression") +
  xlab("λ (lambda)") +
  ylab("RMSE")

#Predictions with best model
ridge_predictions <- predict(ridge_fit, test_norm)
#Results on test set
ridge_results <- postResample(pred = ridge_predictions, obs = test_norm$quality)
print(ridge_results)

#Residuals
ridge_predictions <- as.vector(ridge_predictions)
residuals <- test_data$quality - ridge_predictions

#Residuals plot
residual_plot <- ggplot() +
  geom_histogram(aes(x=residuals), bins=30, fill="blue", color="black") +
  ggtitle("Ridge Regression: Residuals Distribution") +
  xlab("Residuals") +
  ylab("Frequency")
print(residual_plot)

#Actual vs Predicted plot
actual_vs_predicted_plot <- ggplot() +
  geom_point(aes(x=ridge_predictions, y=test_data$quality), color="blue") +
  ggtitle("Ridge Regression: Actual vs Predicted") +
  xlab("Predicted Quality") +
  ylab("Actual Quality") +
  geom_abline(intercept=0, slope=1, linetype="dashed", color="red")
print(actual_vs_predicted_plot)