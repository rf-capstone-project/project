# Credit Card Fraud Detection Using Enhanced Random Forest Classifier for Imbalanced Data

The study focuses on overcoming the problem of imbalanced datasets in the context of credit card fraud detection. Given the fact that fraudulent transactions are significantly outnumbered by legitimate ones. To tackle this, the authors implemented an enhanced Random Forest (RF) classifier, referring to the incorporation of the Synthetic Minority Over-sampling Technique (SMOTE) to balance the dataset and hyperparameter tuning to optimize model performance.

**Methodology**

The dataset used in the study consists of 284,807 credit card transactions carried out by European cardholders over two days in September 2013\. Out of these, only 492 transactions were fraudulent, which corresponds to about 0.172% of the data, making it a highly imbalanced dataset. Each transaction is described by 30 features: 28 anonymized numerical variables obtained through principal component analysis (PCA) (labeled V1–V28), along with Time, which records the seconds elapsed since the first transaction, and Amount, which is the transaction value. The target variable is Class, where 0 represents a legitimate transaction and 1 indicates fraud. Importantly, the dataset contains no missing values, making it well suited for machine learning applications. To address the challenge of class imbalance, where fraudulent transactions are much fewer than legitimate ones, the authors applied the Synthetic Minority Over-sampling Technique (SMOTE) to generate synthetic samples for the minority class. This ensured the Random Forest classifier was trained on a more balanced dataset. Additionally, hyperparameter tuning was performed on the Random Forest model to optimize its performance, adjusting parameters such as the number of trees and maximum depth. The model’s predictive ability was then evaluated using accuracy and F1-score, which are especially important metrics in imbalanced classification scenarios.

### **Results**

The enhanced RF classifier achieved an impressive accuracy of 98% and an F1-score of approximately 98%. These results underscore the model's effectiveness in identifying fraudulent transactions, even in the presence of significant class imbalance. The study also highlights the practicality of the proposed model, suggesting that it can be readily applied to real-world fraud detection scenarios.

**Conclusion**

The paper demonstrates that by integrating SMOTE for data balancing and optimizing RF hyperparameters, it's possible to develop a robust and efficient model for credit card fraud detection. This approach not only improves detection accuracy but also offers a practical solution to the prevalent issue of class imbalance in fraud detection tasks.

