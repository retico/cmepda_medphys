%% Radiomic Feature Mapping: SOM vs. t-SNE 
clear; clc; close all;

%% =========================
% LOAD DATA Sample
% =========================
% 
% Data should contain a numerical array with the features (X) and a vector 
% with categorical labels (e.g. Malignant/Benign)

DB_path='/Users/retico/Desktop/CMEPDA/DATASETS/FEATURES/Mammography_masses_mal_ben/'
fileB='ben_feature.xls';
fileM='mal_feature.xls';
data=[readtable(strcat(DB_path,fileB), 'ReadRowNames',true);readtable(strcat(DB_path,fileM),'ReadRowNames',true)];

%% Select the numerical array of features (X)

X = data;
X.Out_mal = [];
X.Out_ben = [];
X.SegmQual = [];
X = table2array(X);
size(X)

%% Select the labels and ensure labels are categorical
labels = categorical(data.Out_mal, [0 1],  {'Benign','Malignant'});

%% Normalize features
X = zscore(X);

%% =========================
% 1. SELF-ORGANIZING MAP (SOM)
% =========================
disp('Training SOM...');

gridSize = [4 4];
net = selforgmap(gridSize);

net = train(net, X');

% Get neuron positions
y = net(X');
[~, bmu] = max(y); % Best Matching Units

% Convert linear indices to grid coordinates
[x_coord, y_coord] = ind2sub(gridSize, bmu);

figure;
gscatter(x_coord, y_coord, labels, 'rb', 'ox');
title('SOM Projection');
xlabel('Neuron X');
ylabel('Neuron Y');
grid on;

%% use plotsomhits(net,input) on input data with different labels
% the columns are the examples, we have to group the according to labels

idx = (labels=='Malignant');

input_mal = X(idx,:)';
input_ben = X(~idx,:)';

figure
plotsomhits(net,input_mal)
title('Malignant')

figure
plotsomhits(net,input_ben)
title('Benign')


%% =========================
% 2. t-SNE
% =========================
disp('Running t-SNE...');

Y_tsne = tsne(X, ...
    'NumDimensions', 2, ...
    'Perplexity', 30, ...
    'Standardize', false);

figure;
gscatter(Y_tsne(:,1), Y_tsne(:,2), labels, 'rb', 'ox');
title('t-SNE Projection');
xlabel('t-SNE 1');
ylabel('t-SNE 2');
grid on;

%% We can visualize whether data are "separable" according to specific features

labels_feat_median = data.MassArea > median(data.MassArea);

figure;
gscatter(Y_tsne(:,1), Y_tsne(:,2), labels_feat_median, 'rb', 'ox');
title('t-SNE Projection - high vs low mass area values');
xlabel('t-SNE 1');
ylabel('t-SNE 2');
grid on;
