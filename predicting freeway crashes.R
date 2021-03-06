#Loading the required packages
if (!require(readxl)) install.packages("readxl"); library(readxl)
if (!require(prediction)) install.packages("prediction"); library(prediction)
if (!require(kernlab)) install.packages("kernlab"); library(kernlab)
if (!require(rattle)) install.packages("rattle"); library(rattle)
if (!require(class)) install.packages("class"); library(class)
if (!require(corrplot)) install.packages("corrplot"); library(corrplot)
if (!require(plyr)) install.packages("plyr"); library(plyr)
if (!require(randomForest)) install.packages("randomForest"); library(randomForest)
if (!require(ggplot2)) install.packages("ggplot2"); library(ggplot2)
if (!require(pROC)) install.packages("pROC"); library(pROC)
if (!require(e1071)) install.packages("e1071"); library(e1071)
if (!require(caret)) install.packages("caret"); library(caret)
if (!require(plyr)) install.packages("plyr"); library(plyr)
if (!require(dplyr)) install.packages("dplyr"); library(dplyr)
if (!require(arm)) install.packages("arm"); library(arm)
if (!require(ROCR)) install.packages('ROCR'); library(ROCR)
if (!require(parallelSVM)) install.packages("parallelSVM"); library(parallelSVM)
if (!require(sparklyr)) install.packages("sparklyr"); library(sparklyr)
if (!require(ada)) install.packages("ada"); library(ada)

#Importing the dataset
setwd("D:/final with presentation")
crashes<-read.csv("data (2).csv")


#Converting categorical into  factors
crashes$injuryka<-crashes$crash

crashes$injuryka<-factor(crashes$injuryka,levels = c(0,1), labels=c("No", "Yes"))

crashes1<-crashes[,-c(1:3)]
crashes1<-data.frame(crashes1)
crashes1<-na.omit(crashes1)

round(prop.table(table(crashes1$injuryka)),3)


#------------------------------------MODELING----------------------------------------------#
#Splitting training and testing datasets
set.seed(2018)
train_idx <- createDataPartition(crashes1$injuryka, p = 0.7, groups = 20, list = FALSE)
train_data<- crashes1[train_idx,]
test_data<- crashes1[-train_idx,]

table(train_data$injuryka); table(test_data$injuryka);

table(crashes1$injuryka)

#--------------------------------RANDOM FOREST--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number = 10)

set.seed(2018)
model_rf <- caret::train(injuryka~ ., data = train_data, method = "rf", trControl=trc)

#Prediction
predict<-predict(model_rf, newdata = test_data)

predict.prob<-predict(model_rf, newdata=test_data, type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_original <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_original

# AUC (Area Under the Curve) using ROCR package
ROCR_rf = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.rf <- as.numeric(performance(ROCR_rf,"auc")@y.values) # auc measure

# construct plot
ROCRperf.rf = performance(ROCR_rf,"tpr","fpr")
plot(ROCRperf.rf, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.rf <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.rf <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.rf <- 2*(Recall.rf * Precision.rf) / (Recall.rf + Precision.rf)

Results.rf <- c("Precision" = Precision.rf, "Recall" = Recall.rf, "F1scores" = F1scores.rf)
Results.rf


#--------------------------------BAYESIAN LOGISTIC REGRESSION--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number = 10)

set.seed(2018)
model_bayesglm <- caret::train(injuryka~ ., data = train_data, method = "bayesglm", trControl=trc)

#Prediction
predict<-predict(model_bayesglm, newdata = test_data)

predict.prob<-predict(model_bayesglm, newdata=test_data, type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_bayesglm <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_bayesglm

# AUC (Area Under the Curve) using ROCR package
ROCR_bayesglm = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.bayesglm<- as.numeric(performance(ROCR_bayesglm,"auc")@y.values) # auc measure

# construct plot
ROCRperf.bayesglm = performance(ROCR_bayesglm,"tpr","fpr")
plot(ROCRperf.bayesglm, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.bayesglm <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.bayesglm <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.bayesglm <- 2*(Recall.bayesglm * Precision.bayesglm) / (Recall.bayesglm + Precision.bayesglm)

Results.bayesglm <- c("Precision" = Precision.bayesglm, "Recall" = Recall.bayesglm, "F1scores" = F1scores.bayesglm)
Results.bayesglm


#--------------------------------BOOSTED CLASSIFICATION TREE--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number = 10)

set.seed(2018)
model_cl <- caret::train(injuryka~ ., data = train_data, method = "ada", trControl=trc)


#Prediction
predict<-predict(model_cl, newdata = test_data)

predict.prob<-predict(model_cl, newdata=test_data, type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_cl <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_cl

# AUC (Area Under the Curve) using ROCR package
ROCR_cl = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.cl<- as.numeric(performance(ROCR_cl,"auc")@y.values) # auc measure

# construct plot
ROCRperf.cl = performance(ROCR_cl,"tpr","fpr")
plot(ROCRperf.cl, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.cl <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.cl <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.cl <- 2*(Recall.cl * Precision.cl) / (Recall.cl + Precision.cl)

Results.cl <- c("Precision" = Precision.cl, "Recall" = Recall.cl, "F1scores" = F1scores.cl)
Results.cl


#--------------------------------NAIVE BAYES--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number=10)
grid <-data.frame(usekernel=FALSE,fL=0,adjust=FALSE)

set.seed(2018)
model_nb <- caret::train(injuryka~ ., data = train_data[,-7], method = "nb", trControl=trc, tuneGrid=grid)

#Prediction
predict<-predict(model_nb, newdata = test_data[,-7])

predict.prob<-predict(model_nb, newdata=test_data[,-7], type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_nb <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_nb

# AUC (Area Under the Curve) using ROCR package
ROCR_nb = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.nb<- as.numeric(performance(ROCR_nb,"auc")@y.values) # auc measure

# construct plot
ROCRperf.nb = performance(ROCR_nb,"tpr","fpr")
plot(ROCRperf.nb, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.nb <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.nb <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.nb <- 2*(Recall.nb * Precision.nb) / (Recall.nb + Precision.nb)

Results.nb <- c("Precision" = Precision.nb, "Recall" = Recall.nb, "F1scores" = F1scores.nb)
Results.nb

#--------------------------------K-NEAREST NEIGHBOR--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number = 10)

set.seed(2018)
model_knn<- caret::train(injuryka~ ., data = train_data, method = "knn", trControl=trc)


#Prediction
predict<-predict(model_knn, newdata = test_data)

predict.prob<-predict(model_knn, newdata=test_data, type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_knn <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_knn

# AUC (Area Under the Curve) using ROCR package
ROCR_knn = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.knn<- as.numeric(performance(ROCR_knn,"auc")@y.values) # auc measure

# construct plot
ROCRperf.knn = performance(ROCR_knn,"tpr","fpr")
plot(ROCRperf.knn, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.knn <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.knn <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.knn <- 2*(Recall.knn * Precision.knn) / (Recall.knn + Precision.knn)

Results.knn <- c("Precision" = Precision.knn, "Recall" = Recall.knn, "F1scores" = F1scores.knn)
Results.knn

#--------------------------------SUPPORT VECTOR MACHINE--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number=10, classProbs =  TRUE)


set.seed(2018)
model_svm <- caret::train(injuryka~ ., data = train_data, method = "svmLinear", trControl=trc)

#Prediction
predict<-predict(model_svm, newdata = test_data)

predict.prob.svm<-predict(model_svm, newdata=test_data, type="prob")


final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_svm <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_svm

# AUC (Area Under the Curve) using ROCR package
ROCR_svm = ROCR::prediction(predict.prob.svm[,2], test_data$injuryka)
AUC.svm<- as.numeric(performance(ROCR_svm,"auc")@y.values) # auc measure

# construct plot
ROCRperf.svm = performance(ROCR_svm,"tpr","fpr")
plot(ROCRperf.svm, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.svm <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.svm <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.svm <- 2*(Recall.svm * Precision.svm) / (Recall.svm + Precision.svm)

Results.svm <- c("Precision" = Precision.svm, "Recall" = Recall.svm, "F1scores" = F1scores.svm)
Results.svm



#------------------------------------SMOTE------------------------------------------------#
#--------------------------------RANDOM FOREST--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number = 10, sampling = "smote")

set.seed(2018)
model_rf.smote <- caret::train(injuryka~ ., data = train_data, method = "rf", trControl=trc)

#Prediction
predict<-predict(model_rf.smote, newdata = test_data)

predict.prob<-predict(model_rf.smote, newdata=test_data, type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_original <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_original

# AUC (Area Under the Curve) using ROCR package
ROCR_rf = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.rf.smote <- as.numeric(performance(ROCR_rf,"auc")@y.values) # auc measure

# construct plot
ROCRperf.rf.smote = performance(ROCR_rf,"tpr","fpr")
plot(ROCRperf.rf.smote, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.rf <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.rf <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.rf <- 2*(Recall.rf * Precision.rf) / (Recall.rf + Precision.rf)

Results.rf.smote <- c("Precision" = Precision.rf, "Recall" = Recall.rf, "F1scores" = F1scores.rf)
Results.rf.smote


#--------------------------------BAYESIAN LOGISTIC REGRESSION--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number = 10, sampling = "smote")

set.seed(2018)
model_bayesglm.smote <- caret::train(injuryka~ ., data = train_data, method = "bayesglm", trControl=trc)

#Prediction
predict<-predict(model_bayesglm.smote, newdata = test_data)

predict.prob<-predict(model_bayesglm.smote, newdata=test_data, type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_bayesglm <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_bayesglm

# AUC (Area Under the Curve) using ROCR package
ROCR_bayesglm = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.bayesglm.smote<- as.numeric(performance(ROCR_bayesglm,"auc")@y.values) # auc measure

# construct plot
ROCRperf.bayesglm.smote = performance(ROCR_bayesglm,"tpr","fpr")
plot(ROCRperf.bayesglm.smote, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.bayesglm <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.bayesglm <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.bayesglm <- 2*(Recall.bayesglm * Precision.bayesglm) / (Recall.bayesglm + Precision.bayesglm)

Results.bayesglm.smote <- c("Precision" = Precision.bayesglm, "Recall" = Recall.bayesglm, "F1scores" = F1scores.bayesglm)
Results.bayesglm.smote


#--------------------------------BOOSTED CLASSIFICATION TREE--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number = 10, sampling = "smote")

set.seed(2018)
model_cl.smote <- caret::train(injuryka~ ., data = train_data, method = "ada", trControl=trc)


#Prediction
predict<-predict(model_cl.smote, newdata = test_data)

predict.prob<-predict(model_cl.smote, newdata=test_data, type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_cl <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_cl

# AUC (Area Under the Curve) using ROCR package
ROCR_cl = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.cl.smote<- as.numeric(performance(ROCR_cl,"auc")@y.values) # auc measure

# construct plot
ROCRperf.cl.smote = performance(ROCR_cl,"tpr","fpr")
plot(ROCRperf.cl.smote, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.cl <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.cl <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.cl <- 2*(Recall.cl * Precision.cl) / (Recall.cl + Precision.cl)

Results.cl.smote <- c("Precision" = Precision.cl, "Recall" = Recall.cl, "F1scores" = F1scores.cl)
Results.cl.smote


#--------------------------------NAIVE BAYES--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number=10, sampling = "smote")
grid <-data.frame(usekernel=FALSE,fL=0,adjust=FALSE)

set.seed(2018)
model_nb.smote <- caret::train(injuryka~ ., data = train_data[,-7], method = "nb", trControl=trc, tuneGrid=grid)

#Prediction
predict<-predict(model_nb.smote, newdata = test_data[,-7])

predict.prob<-predict(model_nb.smote, newdata=test_data[,-7], type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_nb <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_nb

# AUC (Area Under the Curve) using ROCR package
ROCR_nb = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.nb.smote<- as.numeric(performance(ROCR_nb,"auc")@y.values) # auc measure

# construct plot
ROCRperf.nb.smote= performance(ROCR_nb,"tpr","fpr")
plot(ROCRperf.nb.smote, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.nb <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.nb <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.nb <- 2*(Recall.nb * Precision.nb) / (Recall.nb + Precision.nb)

Results.nb.smote <- c("Precision" = Precision.nb, "Recall" = Recall.nb, "F1scores" = F1scores.nb)
Results.nb.smote

#--------------------------------K-NEAREST NEIGHBOR--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number = 10, sampling = "smote")

set.seed(2018)
model_knn.smote<- caret::train(injuryka~ ., data = train_data, method = "knn", trControl=trc)


#Prediction
predict<-predict(model_knn.smote, newdata = test_data)

predict.prob<-predict(model_knn.smote, newdata=test_data, type="prob")

final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_knn <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_knn

# AUC (Area Under the Curve) using ROCR package
ROCR_knn = ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.knn.smote<- as.numeric(performance(ROCR_knn,"auc")@y.values) # auc measure

# construct plot
ROCRperf.knn.smote= performance(ROCR_knn,"tpr","fpr")
plot(ROCRperf.knn.smote, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.knn <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.knn <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.knn <- 2*(Recall.knn * Precision.knn) / (Recall.knn + Precision.knn)

Results.knn.smote <- c("Precision" = Precision.knn, "Recall" = Recall.knn, "F1scores" = F1scores.knn)
Results.knn.smote

#--------------------------------SUPPORT VECTOR MACHINE--------------------------------------------#
#Setting the sampling strategy and k-fold cross-validation
trc <-trainControl(method ="cv", number=10, sampling = "smote", classProbs =  TRUE)

set.seed(2018)
model_svm.smote <- caret::train(injuryka~ ., data = train_data, method = "svmLinear", trControl=trc)

#Prediction
predict<-predict(model_svm.smote, newdata = test_data)

predict.prob<-predict(model_svm.smote, newdata=test_data, type="prob")


final<-data.frame(predict,test_data$injuryka)

#Confusion matrix
cm_svm <- confusionMatrix(final$predict, final$test_data.injuryka, positive = "Yes")
cm_svm

# AUC (Area Under the Curve) using ROCR package
ROCR_svm= ROCR::prediction(predict.prob[,2], test_data$injuryka)
AUC.svm.smote<- as.numeric(performance(ROCR_svm,"auc")@y.values) # auc measure

# construct plot
ROCRperf.svm.smote = performance(ROCR_svm,"tpr","fpr")
plot(ROCRperf.svm.smote, colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

# accuracy
Precision.svm <- precision(predict, test_data$injuryka, na.rm = T, relevant = "Yes")

# Recall
Recall.svm <- recall(predict, test_data$injuryka, relevant = "Yes")

# F1scores
F1scores.svm <- 2*(Recall.svm * Precision.svm) / (Recall.svm + Precision.svm)

Results.svm.smote <- c("Precision" = Precision.svm, "Recall" = Recall.svm, "F1scores" = F1scores.svm)
Results.svm.smote



#----------------------------------COMBINING THE RESULTS------------------------------------#
#Tunning parameter for each model
cl.plot<-plot(model_cl,main="Classification tree") 
cl.plot.smote<-plot(model_cl.smote,main="Classification tree with SMOTE") 
rf.plot<-plot(model_rf, main="Random forest")
rf.plot.smote<-plot(model_rf.smote, main="Random forest with SMOTE")
knn.plot<-plot(model_knn, main="K-Nearest neighbor")
knn.plot.smote<-plot(model_knn.smote, main="K-Nearest neighbor with SMOTE")

library(gridExtra)
require(lattice)
grid.arrange(cl.plot, cl.plot.smote, rf.plot, rf.plot.smote, knn.plot, knn.plot.smote,  ncol=2)


#Variable importance plots
plot(varImp(model_bayesglm), main="Bayesian logistic")
plot(varImp(model_rf, main="Random forest"))
plot(varImp(model_rf.smote, main="Random forest with SMOTE"))


#Model assessment of all 4 methods
Results.all<- t(data.frame(Results.bayesglm,Results.nb, Results.rf, Results.svm, Results.cl, Results.knn))
Results.all.smote<- t(data.frame(Results.bayesglm.smote,  Results.nb.smote, Results.rf.smote, Results.svm.smote,Results.cl.smote, Results.knn.smote))

Result.roc<-t(data.frame(AUC.bayesglm, AUC.nb, AUC.rf, AUC.svm, AUC.cl, AUC.knn))
Result.roc.smote<-t(data.frame(AUC.bayesglm.smote, AUC.nb.smote, AUC.rf.smote, AUC.svm.smote, AUC.cl.smote, AUC.knn.smote))

#Plotting the results: Recall, Precision, F-Score
par(mfrow=c(1,2))
barplot(Results.all,space=c(0,3), xlab='Methods',main="Comparison of Models (No resampling)", beside = T, col=c(5:8,10:11), ylim=c(0,1))
legend("topright",legend=c("Bayesian Logistic", "Naive Bayes", "Random Forest","Support Vector Machine", "Classification tree", "K-Nearest Neighbor"), bty = "n", fill=c(5:8,10:11), ncol = 2)
grid(nx = NA, ny=5, col = "lightgray", lty = "dotted",
     lwd = par("lwd"), equilogs = TRUE)

barplot(Results.all.smote,space=c(0,3), xlab='Methods',main="Comparison of Models(SMOTE)", beside = T, col=c(5:8,10:11), ylim=c(0,1))
legend("topright",legend=c("Bayesian Logistic", "Naive Bayes", "Random Forest","Support Vector Machine", "Classification tree", "K-Nearest Neighbor"), bty = "n", fill=c(5:8,10:11), ncol = 2)
grid(nx = NA, ny=5, col = "lightgray", lty = "dotted",
     lwd = par("lwd"), equilogs = TRUE)

par(mfrow=c(1,1))

#Ploting the results based on ROC area
par(mfrow=c(1,2))
barplot(Result.roc, xlab='Area under ROC',main="Comparison of Models (No resampling)", beside = T, col=c(5:8,10:11), ylim=c(0,1))
legend("topright",legend=c("Bayesian Logistic", "Naive Bayes", "Random Forest","Support Vector Machine", "Classification tree", "K-Nearest Neighbor"), bty = "n", fill=c(5:8,10:11), ncol = 2)
grid(nx = NA, ny=5, col = "lightgray", lty = "dotted",
     lwd = par("lwd"), equilogs = TRUE)

barplot(Result.roc.smote, xlab='Area under ROC',main="Comparison of Models(SMOTE)", beside = T, col=c(5:8,10:11), ylim=c(0,1))
legend("topright",legend=c("Bayesian Logistic", "Naive Bayes", "Random Forest","Support Vector Machine", "Classification tree", "K-Nearest Neighbor"), bty = "n", fill=c(5:8,10:11), ncol = 2)
grid(nx = NA, ny=5, col = "lightgray", lty = "dotted",
     lwd = par("lwd"), equilogs = TRUE)

par(mfrow=c(1,1))

#ROC curve for each plot
par(mfrow=c(2,3))
plot(ROCRperf.nb, main="Naive Bayes, ROC Area=0.763", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.bayesglm, main="Bayesian Logistic, ROC Area=0.802", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.svm, main="Support Vector Machine, ROC Area=0.783", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.rf, main="Random forest, ROC Area=0.792", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.cl,main="Classification tree, ROC Area=0.808", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.knn, main="K-Nearest Neighbor, ROC Area=0.773", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve

par(mfrow=c(1,1))

#ROC curve for each plot
par(mfrow=c(2,3))
plot(ROCRperf.nb.smote, main="Naive Bayes, ROC Area=0.772", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.bayesglm.smote, main="Bayesian Logistic, ROC Area=0.799", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.svm.smote, main="Support Vector Machine, ROC Area=0.779", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.rf.smote, main="Random forest, ROC Area=0.782", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.cl.smote,main="Classification tree, ROC Area=0.793", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve
plot(ROCRperf.knn.smote, main="K-Nearest Neighbor, ROC Area=0.734", colorize=TRUE, print.cutoffs.at=seq(0,1,0.2), text.adj=c(-0.3,2),
     xlab="1 - Specificity", ylab="Sensitivity") # color coded, annotated ROC curve