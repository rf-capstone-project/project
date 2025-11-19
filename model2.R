library(themis)
library(recipes)
library(randomForest)
library(rsample)
library(caret)
library(pROC)
library(ggplot2)
library(dplyr)
library(iml)

#######################
#init dataset
df <- read.csv("ieee-fraud-detection/train_final_2.csv")



#######################
#final cleaning/adhoc stuff

# Define the start date
start_date <- as.Date("2017-12-01", format = "%Y-%m-%d", tz = "UTC")

# Convert 'TransactionDT' using predefined logic for date
df$TransactionDT <- start_date + as.difftime(df$TransactionDT, units = "secs")

#convert to factor for model
df$isFraud <- as.factor(df$isFraud)

#convert target to categorical - this determines if the model will do regression or classification
#omitted conversions since function can only handle 53 max catagories
df$card4 <- as.factor(df$card4)
df$card6 <- as.factor(df$card6)
#df$P_emaildomain <- as.factor(df$P_emaildomain) #60 levels
#df$S_emaildomain <- as.factor(df$S_emaildomain) #issue converting ...
df$id_12 <- as.factor(df$id_12)
df$id_15 <- as.factor(df$id_15)
df$id_16 <- as.factor(df$id_16)
df$id_28 <- as.factor(df$id_28)
df$id_29 <- as.factor(df$id_29)
#df$id_31 <- as.factor(df$id_31) #131 levels
df$DeviceType <- as.factor(df$DeviceType)
df$ProductCD <- as.factor(df$ProductCD)
#df$DeviceInfo <- as.factor(df$DeviceInfo) #1787 levels


#fix factor naming for model 
df$isFraud <- factor(make.names(df$isFraud))
df$card4 <- factor(make.names(df$card4))
df$card6 <- factor(make.names(df$card6))
df$DeviceType <- factor(make.names(df$DeviceType))


#######################
#train/test split 80-20
set.seed(1)

split <- initial_split(df, prop = 0.8)
train_df <- training(split)
test_df  <- testing(split)




#######################
#SMOTE Upsampling methodss:

#upsampling 50%
df_upsample_50 <- recipe(isFraud ~ ., data = train_df) %>%
  update_role(DeviceInfo,id_31,R_emaildomain,P_emaildomain, new_role = "ID") %>%
  step_upsample(isFraud, over_ratio = 0.5) #over ration = size of majority

balanced_train_50 <- df_upsample_50 %>%
  prep() %>%
  juice()




#upsampling 100%
df_upsample_100 <- recipe(isFraud ~ ., data = train_df) %>%
  update_role(DeviceInfo,id_31,R_emaildomain,P_emaildomain, new_role = "ID") %>%
  step_upsample(isFraud, over_ratio = 1) #over ratio = size of majority

balanced_train_100 <- df_upsample_100 %>%
  prep() %>%
  juice()


#######################
#Grid Search testing

rf_grid_optimize <- function(data, target,
                             ntree_values = c(5, 10),
                             mtry_values = NULL,
                             importance_values = c(TRUE, FALSE),
                             test_ratio = 0.2,
                             seed = 1) {
  
  set.seed(seed)
  
  # Ensure target is a factor
  data[[target]] <- factor(make.names(data[[target]]))  # sanitize labels
  if (is.null(mtry_values)) {
    mtry_values <- seq(1, floor(sqrt(ncol(data) - 1)), by = 1)
  }
  
  # Split data into training and test sets
  train_index <- createDataPartition(data[[target]], p = 1 - test_ratio, list = FALSE)
  train <- data[train_index, ]
  test  <- data[-train_index, ]
  
  # Parameter grid
  param_grid <- expand.grid(
    ntree = ntree_values,
    mtry = mtry_values,
    importance = importance_values
  )
  
  results <- data.frame()
  
  cat("\n Starting grid search with", nrow(param_grid), "combinations...\n")
  
  # Iterate through combinations
  for (i in 1:nrow(param_grid)) {
    params <- param_grid[i, ]
    cat("\nRunning model", i, "of", nrow(param_grid),
        "-> ntree:", params$ntree, ", mtry:", params$mtry, ", importance:", params$importance, "\n")
    
    # Train model
    model <- randomForest(
      formula = as.formula(paste(target, "~ .")),
      data = train,
      ntree = params$ntree,
      mtry = params$mtry,
      importance = params$importance
    )
    
    # Predict on test set
    preds <- predict(model, newdata = test)
    
    # Confusion matrix
    cm <- confusionMatrix(preds, test[[target]])
    
    # Extract metrics
    acc <- cm$overall["Accuracy"]
    cm_table <- cm$table
    tn <- cm_table[1, 1]
    fp <- cm_table[1, 2]
    fn <- cm_table[2, 1]
    tp <- cm_table[2, 2]
    fpr <- fp / (fp + tn)
    
    # Store results
    results <- rbind(results, data.frame(
      ntree = params$ntree,
      mtry = params$mtry,
      importance = params$importance,
      Accuracy = as.numeric(acc),
      False_Positive_Rate = as.numeric(fpr)
    ))
  }
  
  # Select best model: max Accuracy, then min FPR
  best_row <- results[order(-results$Accuracy, results$False_Positive_Rate), ][1, ]
  
  cat("\n Best parameters found:\n")
  print(best_row)
  
  # Retrain best model on full dataset
  best_model <- randomForest(
    formula = as.formula(paste(target, "~ .")),
    data = data,
    ntree = best_row$ntree,
    mtry = best_row$mtry,
    importance = best_row$importance
  )
  
  return(list(
    best_params = best_row,
    all_results = results,
    best_model = best_model
  ))
}



#######################
# ***FINAL***

# Train model
best_model <- randomForest(isFraud ~ ., 
                           data = balanced_train_100,     # data
                           ntree = 50,        # number of trees (default = 500)
                           mtry = 5,           # number of variables tried at each split (default is n vars / 3)
                           importance = TRUE   # store variable importance
)


# Predict on test set
preds <- predict(best_model, newdata = test_df)

# Probabilies
probs <- predict(best_model, newdata = test_df, type = "prob")

#probs
imp <- importance(best_model)
imp_sorted <- imp[order(imp[, "MeanDecreaseGini"], decreasing = TRUE), ]
head(imp_sorted, 20)



# Confusion matrix
cm <- confusionMatrix(preds, test_df$isFraud)

acc <- cm$overall["Accuracy"]
pre <- cm$byClass["Precision"]
rec <- cm$byClass["Recall"]
spe <- cm$byClass["Specificity"]
f1  <- cm$byClass["F1"]

acc
pre
rec
spe
f1




#####################
#Model Performance AUC ROC

roc_obj <- roc(
  response = test_df$isFraud,       # actual labels
  predictor = probs[, "X1"],        # probability of fraud
  levels = c("X0", "X1"),           # specify negative/positive order
  direction = "<"                   # higher prob(X1) = more likely fraud
)

roc_df <- data.frame(
  fpr = 1 - roc_obj$specificities,
  tpr = roc_obj$sensitivities
)

ggplot(roc_df, aes(x = fpr, y = tpr)) +
  geom_line(color = "#1f77b4", size = 1.2) +
  geom_abline(linetype = "dashed", color = "gray") +
  labs(
    title = sprintf("ROC Curve (AUC = %.3f)", auc(roc_obj)),
    x = "False Positive Rate",
    y = "True Positive Rate"
  ) +
  theme_minimal(base_size = 14)

##############################
# Threshold tuning curve


# true labels from your test set
true <- test_df$isFraud

# probability of fraud (class "X1")
fraud_prob <- probs[, "X1"]

# thresholds to evaluate
thresholds <- seq(0, 1, by = 0.01)

# storage
metrics <- data.frame(
  threshold = thresholds,
  precision = NA,
  recall = NA,
  F1 = NA
)

# compute metrics at each threshold
for (i in seq_along(thresholds)) {
  
  t <- thresholds[i]
  
  # classify based on threshold
  preds_t <- ifelse(fraud_prob >= t, "X1", "X0")
  preds_t <- factor(preds_t, levels = c("X0", "X1"))
  
  # confusion matrix
  cm1 <- confusionMatrix(preds_t, true, positive = "X1")
  
  # store metrics
  metrics$precision[i] <- cm1$byClass["Precision"]
  metrics$recall[i]    <- cm1$byClass["Recall"]
  metrics$F1[i]        <- cm1$byClass["F1"]
}

# long format for ggplot
metrics_long <- metrics %>%
  tidyr::pivot_longer(cols = c("precision", "recall", "F1"),
                      names_to = "metric",
                      values_to = "value")

# plot
ggplot(metrics_long, aes(x = threshold, y = value, color = metric)) +
  geom_line(size = 1.2) +
  labs(
    title = "Threshold Tuning Curve",
    x = "Threshold",
    y = "Metric Value",
    color = "Metric"
  ) +
  theme_minimal(base_size = 14)
