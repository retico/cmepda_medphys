%% Implement a linear regression model to predict subjects' age from brain features

% The Objective is to train an SVM regression model, e.g. fitrsvm for low-dimensional 
% and moderate-dimensional predictor data sets, or fitrlinear for 
% high-dimensional data sets.

% Mdl = fitrsvm(Tbl,ResponseVarName)
% fitrsvm function returns a full, trained support vector machine (SVM) 
% regression model Mdl trained using the predictors values in the 
% table Tbl and the response values in ResponseVarName.

clear
close all

%% 1. Read the ABIDE data

filename='../DATASETS/FEATURES/Brain_MRI_FS_ABIDE/FS_features_ABIDE_males_someGlobals.csv';
data=readtable(filename, 'ReadRowNames', true);

% and define features and labels

% features
data.Properties.VariableNames{5:end}  
feature_names=data.Properties.VariableNames(5:end)
features=data(:,feature_names);

% labels
data.Properties.VariableNames{1}
labels=data.AGE_AT_SCAN;  

%% 2. Train a regression model based on SVM

SVMModel =fitrsvm(features,labels,'Standardize',true);  % applies zscore to train data

%% 3. Evaluate the model performance
% We evaluate the model on the training data set (i.e. we are evaluating at
% this time the regression performance in training

predicted_AGE=predict(SVMModel,features);

[data.AGE_AT_SCAN predicted_AGE]

%% 4. Plot the results
% We make a scatter plot of the predicted age versus the anagraphic age

figure, scatter(data.AGE_AT_SCAN,predicted_AGE)
xlabel('Anagraphic AGE (y) ')
ylabel('Predicted AGE (y)')
title('Predicted vs. actual age')
axis equal
xlim([0 70])
ylim([0 70])

%% 5. The performance can be quantified in terms of Root Mean Squared Error (RMSE)

RMSE = sqrt(mean((data.AGE_AT_SCAN-predicted_AGE).^2))
% it means that on average there are 6 years of discrepancy between the
% predicted and the anagraphic age

%% 6. Residual plot
% The residual plot shows the discrepancy between the
% predicted and the anagraphic age as a function of age

figure, scatter(data.AGE_AT_SCAN,(predicted_AGE-data.AGE_AT_SCAN))
xlabel('Anagraphic AGE (y) ')
ylabel('Residuals (y)')
title('Residuals plot')

% This plot show that the prediction is worst of elderly subjects. This can 
% be understood, as there are few examples to learn from in that age range 

%% 7. Try to reduce the number of features, e.g. by averaging L and R thickness or L and R cortex vol, ....

filename='../DATASETS/FEATURES/Brain_MRI_FS_ABIDE/FS_features_ABIDE_males_someGlobals.csv';
data=readtable(filename, 'ReadRowNames', true);

data.ThickMean=(data.lh_MeanThickness+data.rh_MeanThickness)/2;
data.ThickLR=(data.lh_MeanThickness-data.rh_MeanThickness)./(data.lh_MeanThickness+data.rh_MeanThickness);
data.WMvolMean=(data.lhCerebralWhiteMatterVol+data.rhCerebralWhiteMatterVol)/2;
data.GMcortMean=(data.lhCortexVol+data.rhCortexVol)/2;


feature_names={data.Properties.VariableNames{11:15}}
features=data(:,feature_names);

% train a regression model on the reduced set of features

SVMModel =fitrsvm(features,labels,'Standardize',true,'KernelFunction','gaussian');

% we evaluate the model on the training data set, i.e. we are evaluating
% the regression performance in training
predicted_AGE=predict(SVMModel,features);

%% figure

figure, scatter(data.AGE_AT_SCAN,predicted_AGE)
xlabel('Anagraphic AGE (y) ')
ylabel('Predicted AGE (y)')
title('Predicted vs. actual age')
axis equal
xlim([0 70])
ylim([0 70])

%% RMSE

RMSE = sqrt(mean((data.AGE_AT_SCAN-predicted_AGE).^2))
% No improvement has occurred reducing the nuomber of features

%% Try with different kernels

SVMModel_gauss =fitrsvm(features,labels,'Standardize',true,'KernelFunction','gaussian')
RMSE = sqrt(mean((data.AGE_AT_SCAN-predicted_AGE).^2))
% The performance improve 

%% Implement a cross validation evaluation of the model 

% SVMModel =fitrsvm(features,labels,'Standardize',true, 'KFold',5);
% mse = kfoldLoss(SVMModel)


%% Repeat by considering all features
% filename='../DATASETS/FEATURES/Brain_MRI_FS_ABIDE/FS_features_ABIDE_males.csv';
% the RMSE decrease to 3.4 years


