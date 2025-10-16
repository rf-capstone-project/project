# Exploratory data analysis
library(ggplot2)
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

## working to reduce columns V
## ------------------------------------------------------------------------
v_cols <- paste0("V", 1:339) # creates a vector with the names


for (col in v_cols) {
  sum <- check_na(col)
  cat(col, sum, "\n")
}

# remove V columns with excessive missing values
v_cols <- v_cols[-c(1:94, 138:166, 322:339)]

v_cols

# replaces missing values
for(col in v_cols){
train_merged[[col]][is.na(train_merged[[col]])] <- mean(train_merged[[col]], na.rm = TRUE)
}

# checking for constant colmuns
for (col in v_cols) {
  if (is.na(sd(train_merged[[col]])))
    print(col)
  }


## Run PCA
pca_result <- prcomp(train_merged[, v_cols], center = TRUE, scale. = TRUE)
summary(pca_result)

# keeping the first 10 PCs explaining 72.10% of the variance
train_pca_df <- as.data.frame(pca_result$x)
train_pca <- select(train_pca_df, 1:10)


# remove v colmuns from data
train_merged <- train_merged[, !grepl("^V[0-9]+$", names(train_merged)), drop = FALSE]
head(train_merged, 10)


# functions
#------------------------------------------
check_na <- function(feature) {
  n <- sum(is.na(train_merged[[feature]]))
  return(n)  
}


drop_f <- function(feature) {
  train_merged[, !(names(train_merged) %in% feature)]
}
# end functions



## check features cont
## ----------------------------------------------------------------
sum(is.na(train_merged$dist1))  # 144233 missing
# dropping dist1
train_merged <- drop_f("dist1")

# dist2
sum(is.na(train_merged$dist2))  # 106640 missing
# dropping dist2
train_merged <- drop_f("dist2")

# addr1
sum(is.na(train_merged$addr1))  # 60447 missing
# dropping addr1
train_merged <- drop_f("addr1")

# addr2
sum(is.na(train_merged$addr2))   # 60447 missing
# dropping addr2
train_merged <- drop_f("addr2")

# D columns
# ------------------------------------------------
sum(is.na(train_merged$D1))  # 106640 missing
d_cols <- paste0("D", 1:15) # creates a vector with the names

for (col in d_cols) {
  sum <- check_na(col)
  cat(col, sum, "\n")
}

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

 

