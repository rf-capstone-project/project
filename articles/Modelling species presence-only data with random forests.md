Modelling species presence-only data with random forests

This paper explores improvement opportunities of the random forest algorithm in its application to species distribution modeling (SDM).  The author highlights the popularity of random forest for species modeling applications, due to its tendency to accurately predict with minimal parameter tuning, while also capturing complex relationships between species and the environment, including interactions natively. The study supports this point by referencing Freeman et al.( 2016\) and Elith ( 2019).

The study addresses the challenges that arise when using presence-background data, such as class imbalance and overlapping environmental conditions, which can reduce the predictive accuracy of default Random Forest implementations. The study investigates how adjustments to sampling strategies and tree complexity can improve model performance, offering practical guidance for more accurate species distribution predictions.

**Solutions suggested for the class imbalance problem.**

Applying weights  
The method tackles class imbalance by assigning higher weights (misclassification costs) to the minority class. These weights are incorporated into the Gini index in the randomForest package, affecting both the choice of splits and the weighting of terminal nodes in each tree. Different implementations of Random Forest may estimate weights differently, but the core idea is to make the model more sensitive to underrepresented classes.

Equal sampling  
Equal-sampling involves creating multiple datasets (from the original data), each containing all presence records and a randomly sampled subset of background records equal in size to the presence set. Separate Random Forest models are trained on each dataset, and the final prediction is obtained by averaging the predictions of all models. This approach, derived from repeated random sub-sampling in machine learning, reduces class overlap by limiting the dominance of the majority class. However, when the number of presences is small, the method uses relatively few background samples per model, which can be a limitation.

Down sampling  
Down-sampling, also called balanced Random Forest, addresses class imbalance by creating a balanced training set for each individual tree. Each tree uses all minority-class samples and a randomly selected subset of majority-class samples equal in size to the minority. Because different trees may use different subsets, the method effectively incorporates many majority samples across the forest. This reduces class overlap and imbalance for each tree, improving model performance in species presence-background studies and other imbalanced classification tasks. This technique can be performed by adjusting parameter values in the RF implementation.

Using random forest regression  
The author proposes the use of random forest regression instead of the random forest classifier, following Malley et al. (2012). In this line, the classes would be modeled as 0 and 1, and the results interpreted as probabilities in the range {0,1}. The author argues that studies have shown it is possible to obtain a smoother response in this way.

Shallow probability trees  
The study lists one additional method: limiting the depth of the trees in the presence of class imbalance and overlapping, and using the Hellinger distance as a splitting criterion.

All the above strategies were tested together with a random forest implementation with default parameters. All implementations were done in R with the randomForest v4.6-14 and ranger v0.12.1 packages (for the shallow probability trees). For the ranger package, a maximum depth of 2 was chosen, leading to a maximum of 4 terminal nodes. The used dataset is called NCEAS. It consists of 225 species from six regions worldwide. 

**Model evaluation**

The models were compared using two threshold-independent evaluation metrics to assess their predictive performance: Area under the ROC curve (AUC) and Pearson correlation (COR). AUC, according to the authors, is widely used in this particular application domain.  The models' difference in performance was assessed via non-parametric hypothesis tests. The Friedman’s Aligned Rank test (García & Herrera, 2008\) was calculated for AUC (and COR) and the p-values were adjusted by Bergmann-Hommel correction (Bergmann & Hommel, 1988). All pairwise comparisons were assessed to check whether the differences between different approaches and default models were statistically significant. The authors applied Friedman’s Aligned Rank test (García & Herrera, 2008\) to both AUC and COR metrics, with p-values adjusted using the Bergmann-Hommel correction (Bergmann & Hommel, 1988). Pairwise comparisons were conducted to determine whether differences between the various approaches and the default models were statistically significant.

**Conclusions**

The study addressed an intrinsic problem of the random forest methodology in its default form when handling data with class imbalance and class overlap. The paper proposes several methods to solve the highlighted barrier. The authors concluded that all the approaches listed effectively handled the problem of class imbalance and class overlap in the SDM application domain, performing significantly better than the default implementation of random forest.

