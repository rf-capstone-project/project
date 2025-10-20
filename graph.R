## visualizations
## ----------------------------------------------------


# set up
library(dplyr)
library(ggplot2)
library(naniar)
library(corrplot)
library(caret)
options(scipen = 999)

train_final <- read.csv("ieee-fraud-detection/train_final.csv")


# Inspect data
summary(train_final)
str(train_final)
any(is.na(train_final)) # check missing values
miss_var_summary(train_final) %>% print(n = Inf) # summarize missing values

table(train_final$id_33)
head(train_final$id_33, 30)
train_final[train_final == ""] <- NA  #fill "" with NA


head(train_final$id_37, 30)


# id_33 missing 70944, 49.2%  
train_final <- train_final %>% select(-id_33)

head(train_final$id_30, 30)
# id_30 missing 66668, 46.2%
train_final <- train_final %>% select(-id_30)

# id_34 missing 66428, 46.1 %
train_final <- train_final %>% select(-id_34)


# convert logical to numeric
train_final[] <- lapply(train_final, function(col) {
  if (is.logical(col)) as.numeric(col) else col
})

# fill numeric missing values
train_final[] <- lapply(train_final, function(col) {
  if (is.numeric(col)) {
    col[is.na(col)] <- mean(col, na.rm = TRUE)
  }
  col
})

# fill categorical missing values
train_final[] <- lapply(train_final, function(col) {
  if (is.character(col)) {
    col[is.na(col)] <- "unknown"
  }
  col
})

names(train_final)

feature_final <- data.frame(
  Feature = names(train_final),
  Type = sapply(train_final, class)
)
feature_final

head(train_final$card4, 30)
head(train_final$card6, 30)
nrow(train_final)
unique(train_final$isFraud)
unique(train_final$P_emaildomain)
unique(train_final$DeviceType)
unique(train_final$DeviceInfo)
nrow(train_final)
ncol(train_final)

# -----------------------------------------------------------------------------
# graphs
# -----------------------------------------------------------------------------

# target variable classes count
ggplot(train_final, aes(x = factor(isFraud))) +
  geom_bar(fill = "lightblue4") +
  labs(x = "isFraud", y = "Count", title = "Fraud vs Non-Fraud Transactions")


# transaction Amount Distribution by Fraud Status
ggplot(train_final, aes(x = TransactionAmt, fill = factor(isFraud))) +
  geom_histogram(bins = 50, position = "identity", alpha = 0.6) +
  scale_x_log10() +
  labs(title = "Transaction Amount Distribution by Fraud Status",
       fill = "Fraud Status"   # legend label
       )

# Transaction Amount Distribution
ggplot(train_final, aes(x = TransactionAmt)) +
  geom_histogram(bins = 50) +
  scale_x_log10() +   # log scale if highly skewed
  labs(title = "Transaction Amount Distribution")

# ProductCD vs Fraud
ggplot(train_final, aes(x = ProductCD, fill = factor(isFraud))) +
  geom_bar(position = "dodge", alpha = 0.6) + 
  labs(y = "Count", title = "ProductCD vs Fraud", fill = "Fraud Status")
  

# card4(network) vs Fraud
ggplot(train_final, aes(x = card4, fill = factor(isFraud))) +
  geom_bar(position = "dodge", alpha = 0.6) +
  labs(y = "Count", title = "Payment Network vs Fraud", x = "Payment Network", fill = "Fraud Status")

# card6(card type) vs Fraud
ggplot(train_final, aes(x = card6, fill = factor(isFraud))) +
  geom_bar(position = "dodge", alpha = 0.6) +
  labs(y = "Count", title = "Card Type vs Fraud", x = "Card Type", fill = "Fraud Status")


# P_emaildomain vs Fraud
ggplot(train_final, aes(x = P_emaildomain, fill = factor(isFraud))) +
  geom_bar(position = "dodge", alpha = 0.6) +
  labs(y = "Count", title = "Fraud by Email Domain", x = "Domain", fill = "Fraud Status")

# top purchaser email domains
train_final %>%
  group_by(P_emaildomain) %>%
  summarise(FraudRate = mean(isFraud, na.rm = TRUE),
            Count = n()) %>%
  arrange(desc(FraudRate)) %>%
  head(10) %>%
  ggplot(aes(x = reorder(P_emaildomain, FraudRate), y = FraudRate)) +
  geom_col(fill = "lightblue4") +
  coord_flip() +
  labs(x = "Email Domain", y = "Fraud Rate", title = "Top Purchaser Email Domains by Fraud Rate")

# top recipient  email domains
train_final %>%
  group_by(R_emaildomain) %>%
  summarise(FraudRate = mean(isFraud, na.rm = TRUE),
            Count = n()) %>%
  arrange(desc(FraudRate)) %>%
  head(10) %>%
  ggplot(aes(x = reorder(R_emaildomain, FraudRate), y = FraudRate)) +
  geom_col(fill = "lightblue4") +
  coord_flip() +
  labs(x = "Email Domain", y = "Fraud Rate", title = "Top Recipient Email Domains by Fraud Rate")

# device type vs Fraud
ggplot(train_final, aes(x = DeviceType, fill = factor(isFraud))) +
  geom_bar(position = "dodge", alpha = 0.6) +
  labs(y = "Count", title = "Fraud by Device Type", x = "Device", fill = "Fraud Status")


# correlation matrix
num_cols <- names(train_final)[sapply(train_final, is.numeric)]
cmat <- cor(train_final[, num_cols], use = "pairwise.complete.obs")
cmat[is.na(cmat)] <- 0  # replace NAs
high_corr <- findCorrelation(cmat, cutoff = 0.9)
reduced_cmat <- cmat[-high_corr, -high_corr]
corrplot(reduced_cmat, method = "color", 
         type = "upper",       # upper triangle only
         tl.cex = 0.6,        # smaller text labels
         order = "hclust")






