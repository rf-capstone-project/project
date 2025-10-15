# Exploratory data analysis
library(ggplot2)
library(FactoMineR)
library(factoextra)
library(dplyr)

# get dataset
train_trans <- read.csv("ieee-fraud-detection/train_transaction.csv")
train_id <- read.csv("ieee-fraud-detection/train_identity.csv")
test_trans <- read.csv("ieee-fraud-detection/test_transaction.csv")
test_id <- read.csv("ieee-fraud-detection/test_identity.csv")


# exploration
ncol(train_trans)
ncol(train_id)
nrow(train_trans)

# list and explore features on train_transactions
feature_info_trans <- data.frame(
  Feature = names(train_trans),
  Type = sapply(train_trans, class)
)

# View as a table
View(feature_info_trans)


# list and explore features on train_identity
feature_info_id <- data.frame(
  Feature = names(train_id),
  Type = sapply(train_id, class)
)

# View as a table
View(feature_info_id)

# exploring transactionID (matching feature)
head(train_trans$TransactionID)
head(train_id$TransactionID)

# extract missing IDs
missing_ids <- train_trans[!(train_trans$TransactionID %in% train_id$TransactionID), ]
nrow(missing_ids)
# this results in 446 307 rows present in the transaction table that do not have a corresponding TransactionID
# in the ID table, for a 75.57%

# check if all IDs have a corresponding transaction
missing_trans <- train_id[!(train_id$TransactionID %in% train_trans$TransactionID), ]
nrow(missing_trans)

# count how many transactions are flagged as fraud
table(missing_ids$isFraud)
# from the missing_ids, 9345 transactions are flagged as fraud, vs 436962,
# this is approximately 1.58% of the total number of rows in the training transactions table (590,540)

head(train_trans$TransactionID, 20)
head(train_id$TransactionID, 20)

# explore features values
# transaction table
unique(train_trans$isFraud)
unique(train_trans$ProductCD)
head(train_trans$TransactionDT)
head(train_trans$card1)
head(train_trans$addr1)
unique(train_trans$addr1)
unique(train_trans$addr2)
head(train_trans$dist1, 30)
length(unique(train_trans$dist1))
sum(is.na(train_trans$dist1))
head(train_trans$dist2, 30)
sum(is.na(train_trans$dist2))
head(train_trans$dist2, 30)
head(train_trans$P_emaildomain, 30)
sum(is.na(train_trans$V1)) # 279287 missing
sum(is.na(train_trans$V15)) # 76073 missing



# merging training sets
train_merged <- merge(train_trans, train_id, by = "TransactionID")

## working to reduce engineered columns V
## ------------------------------------------------------------------------
v_cols <- paste0("V", 1:339) # creates a vector with the names

# replaces missing values
for(col in v_cols){
train_merged[[col]][is.na(train_merged[[col]])] <- mean(train_merged[[col]], na.rm = TRUE)
}

# removes constant columns from vector
v_cols <- v_cols[sapply(train_merged[, v_cols], function(x)
  !is.na(sd(x, na.rm = TRUE)) && sd(x, na.rm = TRUE) != 0)]

# Identify columns that match V<number> and are NOT in v_cols
drop_cols <- names(train_merged)[grepl("^V[0-9]+$", names(train_merged)) & 
                                   !names(train_merged) %in% v_cols]

# Remove them from the dataset
train_merged <- train_merged[, !names(train_merged) %in% drop_cols, drop = FALSE]

## Run PCA on selected numeric columns
pca_result <- prcomp(train_merged[, v_cols], center = TRUE, scale. = TRUE)
summary(pca_result)

# keeping the first 18 PCs explaining 72.18% of the variance
train_pca <- pca_result$x[, 1:18, drop = FALSE]
# convert to dataframe
train_pca <- as.data.frame(train_pca)

# remove v colmuns from data
train_merged <- train_merged[, !grepl("^V[0-9]+$", names(train_merged)), drop = FALSE]
head(train_merged, 10)

v_cols


#----------------------------------
check_na <- function(feature) {
  n <- sum(is.na(train_merged[[feature]]))
  return(n)  
}




## checking features in merged data
## ----------------------------------------------------------------
sum(is.na(train_merged$dist1))  # 144233 missing
# dropping dist1
train_merged <- train_merged %>%
  select(-dist1)

# dist2
sum(is.na(train_merged$dist2))  # 106640 missing
# dropping dist2
train_merged <- train_merged %>%
  select(-dist2)

# addr1
sum(is.na(train_merged$addr1))  # 60447 missing

# addr2
sum(is.na(train_merged$addr2))   # 60447 missing

# addr2
sum(is.na(train_merged$addr2))   # 60447 missing


# D columns
# ------------------------------------------------
sum(is.na(train_merged$D1))  # 106640 missing
d_cols <- paste0("D", 1:15) # creates a vector with the names

# D1 218 
# D2 113117 
# D3 115174 
# D4 79465 
# D5 111158 
# D6 76860 
# D7 108093 
# D8 69307 
# D9 69307 
# D10 75001 
# D11 144233 
# D12 85324 
# D13 82297 
# D14 82068 
# D15 75916 

dcols_drop <- d_cols[-1] 

train_merged <- train_merged[, !names(train_merged) %in% dcols_drop, drop = FALSE]

 

