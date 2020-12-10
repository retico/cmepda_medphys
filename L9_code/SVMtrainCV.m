function AUC_CV = SVMtrainCV(features,labels)
%This function trains a SVMmodel with cross-validation and provides AUC 

SVMModelCV =fitcsvm(features,labels,'Standardize',true,'Crossval','on');

% we can see how examples are distributed in train and test samples
% SVMModelCV.Partition;

[class_out_CV, score_CV] =kfoldPredict(SVMModelCV); % Predict response for observations not used for training
scoreNorm= normalize(score_CV(:,2),'range');
labels_01=(labels+1)/2;

%figure;plotroc(labels_01',scoreNorm') 

[X,Y,T,AUC_CV]=perfcurve(labels,scoreNorm,1); 
