week1
Multi-Classes Imbalanced Dataset Classification Based on Sample Information - https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7336427

Given an imbalanced dataset where the ratio between the majority and minority classes can be 10000:1 strategies need to be implemented such as undersampling or oversampling to achieve a balanced dataset. This paper explored methods for improving class balance with oversampling techniques including: SMOTE, Borderline-SMOTE (often for binary classification), ADASYN (often for binary classification), Iterative Nearest Neighborhood Oversampling (INNO). Post experimentation, it was determined that applying the INNO algorithm, which looks at k-NN to convert the data into classes based on local densities to resolve multi-class imbalance in datasets yielded improved accuracy when applying both the lgc and grf algorithms.



UCF-PKS: Unforeseen Consumer Fraud Detection With Prior Knowledge and Semantic Features - https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10475187



Fraud Detection Using Machine Learning: An Evaluation of Logistic Regression and Random Forest - https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10982680

Identifying credit card fraud by using linear regression and random forests with imbalanced datasets requires certain techniques to improve model performance. In this paper, the author applies SMOTE to handle the dataset's imbalance and looked at model performance based on confusion matrix and precision-recall curve statistics. Based on the performance of these types of models, the paper concludes that although the linear regression (LR) model showed the most balanced performance compared to the random forest (RF) but did include a high number of FPs and it is theorized that the root cause is due to how the LR model handles non-linear data with complex features compared to basic, normalized data. One interesting point the author makes is that although the FPs are lower in the RF model, the FNs are higher than in the LR model - This financial impact should be considered in deciding on a final model.



week2
Ensemble Synthesized Minority Oversampling-Based Generative Adversarial Networks and Random Forest Algorithm for Credit Card Fraud Detection - https://ieeexplore.ieee.org/document/10224552

Imbalanced class data for CC fraud is noisy and traditional over/under sampling techniques introduce bias when creating synthetic data. This paper looked to address this by first using undersampling to reduce the feature space between the two classes (90% v 10% as compared to 99.9% v 0.1%). Next, SMOTE is applied to create a more balanced dataset - this ratio was identified as ideal as the larger the minority class for SMOTE, low quality syntetic samples would be generated with more overlapping features. After this, a GAN model is applied and to check if the synthetic data is real or fake and once the synthetic data can fool the GAN model 50% of the time, the dataset is complete and ready for use in a random forest. When assessing performance, this ESMOTE-GAN modeling method had the highest performance followed closely by GAN-SMOTE and SMOTE methods (AUC > 90%) which demonstrates that this method to generate synthetic data is ideal 



Feature Engineering and Resampling Strategies for Fund Transfer Fraud With Limited Transaction Data and a Time-Inhomogeneous Modi Operandi - https://ieeexplore.ieee.org/document/9858047

When looking at fraud within finanicial transactions, there is often a lot of noise. This paper explored methods to reduce and eliminate this noise based on feature engineering around recency, frequency, monetary, and anomaly (RFMA) identification statistics as well as employing time phased partitions for both the training and test sets to capture the ever changing nature of fraud patterns over time. In addition to these feature engineering methods, they also employed over/under sampling methods to address class imbalances. After employing these techniques, model performance did improve across the board - an important finding was the impact of feature engineering to identify non-fraud events using behavior and segmentation characteristics rather than solely focusing on fraud patterns and RFMA. Additionally, an important note is that chronologically partitioning the data for random forests increased precision, recall, and the F1 score but slightly decreased accuracy. This was due to the synthetic data generated during oversampling was without time phased partitions and thus treated all the points as similar compared to unique patterns in a specific period of time.




week3


Pruning of Random Forest Classifiers: A Survey and Future Directions - https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6282329&casa_token=b6v-DeNfNgsAAAAA:t3VpEficiA1cba_U49Oc_ggXg-cstkZUbK3YKIaczMCskW6o4tFF3kXywjvel-wiGIMKMfydvw&tag=1


Trees, forests, chickens, and eggs: when and why to prune trees in a random forest - https://onlinelibrary.wiley.com/doi/pdf/10.1002/sam.11594?casa_token=DCur6BJ76DEAAAAA%3AdSFnmVV8C7KJBw9WioBox88t1NJLyw5NWMBj7onwvE40OFoJwrmKNZMOn-hSfQIrkcR4amznzWTUYQ

This paper's authors looked to clarify the reasoning behind when and why trees in random forests need pruning as well as explore interpolation in relation to defining the model parameters. The common approach to modeling is that there is a clear trade-off between variance and bias that gives a U-shaped curve of model performance where underfitting/overfitting are at each of the ends - Interpolation is an extension of these common ideologies but by averaging high variance tree models, you can overcome this initial descent location in the U-shape and reach a lower descent location (thus higher model performance). The findings of their experiments was that the amount of signal to noise ratio is directly related to the optimal tree depth - this means that the training models to full depth is not always necessary to reach the best performance and you can improve by focusing on adding more trees with high variance features.



Random forests: from early developments to recent advancements - https://www.tandfonline.com/doi/pdf/10.1080/21642583.2014.956265

This paper explored the developments of Random Forests since their inception in 2001 and how different methodologies have evolved in specific contexts relative to the problem at hand. Summarily, it mostly looked at how modifications to majority voting and hybrid sampling approaches can improve accuracy and reduce bias. In the authors' findings of reviewing the RF models, the they focused on a few specific developments that have improved performance: 1) changing how voting is conducted amongst trees and 2) weighting of how random samples are used in building trees. Although the model improvements in these methods was limited to specific domains, it highlights the impact different methodologies can have for building robuse random forests.


