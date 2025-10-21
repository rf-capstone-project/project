library(dplyr)

train_final %>%
  summarise(
    count = n(),
    mean = mean(TransactionAmt, na.rm = TRUE),
    median = median(TransactionAmt, na.rm = TRUE),
    p10 = quantile(TransactionAmt, 0.10, na.rm = TRUE),
    p25 = quantile(TransactionAmt, 0.25, na.rm = TRUE),
    p75 = quantile(TransactionAmt, 0.75, na.rm = TRUE),
    p90 = quantile(TransactionAmt, 0.90, na.rm = TRUE),
    max = max(TransactionAmt, na.rm = TRUE)
  )

train_final %>%
  group_by(isFraud) %>%
  summarise(
    n = n(),
    mean = mean(TransactionAmt, na.rm = TRUE),
    median = median(TransactionAmt, na.rm = TRUE),
    p10 = quantile(TransactionAmt, 0.10, na.rm = TRUE),
    p25 = quantile(TransactionAmt, 0.25, na.rm = TRUE),
    p75 = quantile(TransactionAmt, 0.75, na.rm = TRUE),
    p90 = quantile(TransactionAmt, 0.90, na.rm = TRUE),
    max = max(TransactionAmt, na.rm = TRUE)
  )