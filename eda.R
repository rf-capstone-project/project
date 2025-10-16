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
  if (sd(train_merged[[col]]) == 0)
    print(col)
  }

# remove constant columns
v_cols <- v_cols[v_cols != c("V107", "V305")]
v_cols

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


# replaces missing values

na_fill <- function(col) {
  train_merged[[col]][is.na(train_merged[[col]])] <- mean(train_merged[[col]], na.rm = TRUE)
  return(train_merged)
}  

# end functions
# -------------------------------------------



## check features cont
## ----------------------------------------------------------------

# dist1
sum(is.na(train_merged$dist1))  # 144233 missing
# dist2
sum(is.na(train_merged$dist2))  # 106640 missing
# addr1
sum(is.na(train_merged$addr1))  # 60447 missing
# addr2
sum(is.na(train_merged$addr2))   # 60447 missing

# dropping dist1
train_merged <- drop_f("dist1")
# dropping dist2
train_merged <- drop_f("dist2")
# dropping addr1
train_merged <- drop_f("addr1")
# dropping addr2
train_merged <- drop_f("addr2")

# D columns
# ------------------------------------------------
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

# emails
sum((train_merged$P_emaildomain) == "")
sum((train_merged$R_emaildomain) == "")
d_cols

# M columns
# ------------------------------------------------
m_cols <- paste0("M", 1:9) # creates a vector with the names

for (col in m_cols) {
  sum <- check_na(col)
  cat(col, sum, "\n")
}

# M1 144233 
# M2 144233 
# M3 144233 
# M4 0 
# M5 144233 
# M6 144233 
# M7 144233 
# M8 144233 
# M9 144233

mcols_drop <- m_cols[-4]
train_merged <- train_merged[, !names(train_merged) %in% mcols_drop, drop = FALSE]


# id columns
# ------------------------------------------------

id_cols <- paste0("id_", sprintf("%02d", 1:38)) # creates a vector with the names
id_cols

for (col in id_cols) {
  sum <- check_na(col)
  cat(col, sum, "\n")
}

# id_01 0 
# id_02 3361 
# id_03 77909 
# id_04 77909 
# id_05 7368 
# id_06 7368 
# id_07 139078 
# id_08 139078 
# id_09 69307 
# id_10 69307 
# id_11 3255 
# id_12 0 
# id_13 16913 
# id_14 64189 
# id_15 0 
# id_16 0 
# id_17 4864 
# id_18 99120 
# id_19 4915 
# id_20 4972 
# id_21 139074 
# id_22 139064 
# id_23 0 
# id_24 139486 
# id_25 139101 
# id_26 139070 
# id_27 0 
# id_28 0 
# id_29 0 
# id_30 0 
# id_31 0 
# id_32 66647 
# id_33 0 
# id_34 0 
# id_35 3248 
# id_36 3248 
# id_37 3248 
# id_38 3248 

idcols_drop <- id_cols[-c(1,2,5,6,11,12,15,16,23,c(27:31),c(33:38))]
train_merged <- train_merged[, !names(train_merged) %in% idcols_drop, drop = FALSE]

train_merged <- na_fill("id_05")
train_merged <- na_fill("id_06")

head(train_merged,20)
unique(train_merged$id_23)
sum((train_merged$id_23)=="") # 139064 blank values
train_merged <- drop_f("id_23")

unique(train_merged$id_30)
unique(train_merged$M4)
sum((train_merged$M4)=="")

train_merged <- drop_f("M4")

sum((train_merged$id_27)=="")
train_merged <- drop_f("id_27")

train_merged <- na_fill("id_02")
train_merged <- na_fill("id_11")

ncol(train_merged)


# Combine train_merged (other columns) with the selected PCs
train_final <- cbind(train_merged, train_pca)

final_features <- colnames(train_final)

final_features

# test set
# -----------------------------------------------------------------------
test_merged <- merge(test_trans, test_id, by = "TransactionID")
test_cols <- colnames(test_merged)
test_cols

# removes unusable v cols
test_merged <- test_merged[, !(grepl("^V[0-9]+$", names(test_merged)) & !names(test_merged) %in% v_cols)]

# replaces missing values
for(col in v_cols){
  test_merged[[col]][is.na(test_merged[[col]])] <- mean(test_merged[[col]], na.rm = TRUE)
}

# pca
test_pca <- predict(pca_result, newdata = test_merged[, v_cols])
test_pca <- as.data.frame(test_pca[, 1:10, drop = FALSE])

# Keep only the columns that exist in the training data
test_merged <- test_merged[, intersect(names(test_merged), names(train_merged)), drop = FALSE]

head(test_merged)

test_pca

# Combine original test data with PCA results
test_final <- cbind(test_merged, test_pca)

# exporting data
write.csv(train_final, "train_final.csv", row.names = FALSE)
write.csv(test_final, "test_final.csv", row.names = FALSE)
nrow(test_final)
