# Exploratory data analysis
library(ggplot2)
library(FactoMineR)
library(factoextra)

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

# Run PCA on selected numeric columns
v_cols <- paste0("V", 1:339)
#pca_result <- PCA(train_trans[, v_cols], scale.unit = TRUE, graph = FALSE)

#subset_scaled <- scale(train_trans[, v_cols])
pca_result <- prcomp(train_trans, center = TRUE, scale. = TRUE)

# Visualize variance explained
fviz_eig(pca_result, 10)

# Visualize individuals and variables
fviz_pca_biplot(pca_result)





# merge training data

