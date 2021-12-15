%% Facing a Clustering Problem with a Self-Organizing Map
%
% This example shows how to implement a Self-Organizing Map (SOM) to
% identify clusters within data.
%
% SOMs are implemented in the MATLAB Deep Learning Toolbox.
%
% Self-organizing maps learn to cluster data based on similarity, topology,
% with a preference (but no guarantee) of assigning the same number of
% instances to each class.
% Self-organizing maps are used both to cluster data and to reduce the
% dimensionality of data.
%
% selforgmap(dimensions,coverSteps,initNeighbor,topologyFcn,distanceFcn)
% takes these arguments:
% dimensions	 Row vector of dimension sizes (default = [8 8])
% coverSteps	 Number of training steps for initial covering of the input
%                space (default = 100)
% initNeighbor	 Initial neighborhood size (default = 3)
% topologyFcn	 Layer topology function (default = 'hextop')
% distanceFcn	 Neuron distance function (default = 'linkdist')
% Other topologies are gridtop, hextop, randtop, and distance functions are
% dist, linkdist, mandist, boxdist.
%
% This is an example of a clustering problem, where we would like to group
% samples into classes based on the similarity between samples.
% We would like to create a neural network which not only creates class
% definitions for the known inputs, but that will allow us to classify
% unknown inputs accordingly.
%
% The feature attributes will act as inputs to the SOM, which will map
% them onto a 2-dimensional layer of neurons (the Self Organizing Map
% or Kohonen feature map).

close all
clear

%% Read the ABIDE data

filename='../DATASETS/FEATURES/Brain_MRI_FS_ABIDE/FS_features_ABIDE_males_someGlobals.csv';
data=readtable(filename, 'ReadRowNames', true);

% and define the array of features
data.Properties.VariableNames{5:end}   % to show some variable names
feature_names=data.Properties.VariableNames(5:end); % smooth parentheses here
features=data(:,5:end);

%% Prepare the input data for the SOM
%
% Data for clustering problems are set up for a SOM by organizing the data
% into an input matrix X.
% Each ith column of the input matrix will have N elements representing
% the N measurements taken on a single dataset entry (N= number of features).
%
feature_array = table2array(features);

% to have features all in a same range we trasform them with zscore
feature_array=zscore(feature_array);

% in other examples we arranged data with
% examples in the rows
% features in the columns
% For SOM we need a row for each feature. We can just transpose our matrix:
input = feature_array';

%% Create a Self-Organizing Map

dimension1 = 4;
dimension2 = 4;

net = selforgmap([dimension1 dimension2]);

%% View the Network

view(net)
% we can view the network now, but it has "0" input as we haven't yet
% provided the input

%% Train the Network
% The Neural Network Training Tool shows the network being trained and the
% algorithms used to train it. It also displays the training state during
% training and the criteria which stopped training will be highlighted in green.

[net,tr] = train(net,input);

%% View the Network

view(net)
% if we view the network now, we can see the right input dimension (= number
% of features)

%% Test the Network
% Here the self-organizing map is used to compute the class vectors of each
% of the training inputs. These classifications cover the feature space
% populated by the known examples, and can now be used to classify
% new examples accordingly.
% The network output will be a N_neurons x N_examples matrix, where each
% ith column represents the jth cluster for each ith input vector with a
% 1 in its jth element

output = net(input);

%% Clustering
% The function vec2ind returns the index of the neuron with an output of 1,
% for each vector. The indices will range between 1 and N_neurons for the
% N_neurons clusters represented by the N neurons.

cluster_index = vec2ind(output);
% it is the same as
% [cluster_index,case_index]=find(output);

%% Plots
% Uncomment the lines below to enable various plots.
%% plotsomtop	Plot self-organizing map topology
% plotsomtop plots the self-organizing maps topology of N neurons positioned
% in an dim1xdim2 hexagonal grid. Each neuron has learned to represent a
% different class of examples, with adjacent neurons typically representing
% similar classes.

figure, plotsomtop(net)

%% plotsomnc	Plot self-organizing map neighbor connections
% plotsomnc shows the neuron neighbor connections. Neighbors typically
% classify similar samples.

figure, plotsomnc(net)

%% plotsomnd	Plot self-organizing map neighbor distances
% plotsomnd shows the weight distance matrix (also called the U-matrix).
% It shows how distant (in terms of Euclidian distance) each neuron's
% class is from its neighbors. Connections which are bright indicate highly
% connected areas of the input space. While dark connections indicate classes
% representing regions of the feature space which are far apart, with few
% or no examples between them.
% Long borders of dark connections separating large regions of the input
% space indicate that the classes on either side of the border represent
% examples with very different features.

figure, plotsomnd(net)

%% plotsomplanes	Plot self-organizing map weight planes
% plotsomplanes shows the weight plane for each input features
% (also referred to as component planes).
% They are visualizations of the weights that connect each input to each of
% the N_neurons in the dim1xdim2 grid. Darker colors represent
% larger weights. If two inputs have similar weight planes (their color
% gradients may be the same or in reverse) it indicates they are highly
% correlated.
% (Darker colors represent larger weights)

figure, plotsomplanes(net)

%% plotsomhits	Plot self-organizing map sample hits
% plotsomhits calculates the classes for each example and shows the number
% of examples in each class. Areas of neurons with large numbers of hits
% indicate classes representing similar highly populated regions of the
% feature space. Whereas areas with few hits indicate sparsely populated
% regions of the feature space.

figure, plotsomhits(net,input)


%% I can check whether ASD and CTRL were assigned to different nodes

figure
input_ASD=input(:,data.DX_GROUP==1);  % the columns are the examples, we have to group the according to data.site
plotsomhits(net,input_ASD)
title('ASD')

figure
input_CTR=input(:,data.DX_GROUP==-1);  % the columns are the examples, we have to group the according to data.site
plotsomhits(net,input_CTR)
title('CTR')

% We find out very similar SOM for ASD and CTRL

%% I can check in which clusters fell the subjects acquired at different sites

fileID_parts=split(data.FILE_ID,'_00');
data.site=categorical(fileID_parts(:,1));
[Site_names,ia,ic]=unique(data.site);

%% use plotsomhits(net,input) on input from different sites

%close all
for ip=1:numel(Site_names)
    input_site=input(:,data.site==Site_names(ip));  % the columns are the examples, we have to group the according to data.site
    
    figure;
    plotsomhits(net,input_site);
    title(Site_names(ip));
    pause(0.4)
end


%% Notice that the features 1 and 2, 3 and 4, 5 and 6, are extremely correlated
% try with a reduced set of features, where the correlated features are
% averaged/combined, e.g. add to the section "Read the ABIDE data"
% the following lines:
% data.LR=(data.lh_MeanThickness-data.rh_MeanThickness)./(data.lh_MeanThickness+data.rh_MeanThickness);
% data.GMavg=(data.lhCortexVol+data.rhCortexVol)/2;
% data.WMavg=(data.lhCerebralWhiteMatterVol+data.rhCerebralWhiteMatterVol)/2;
% features=data(:,{'LR', 'GMavg','WMavg'});


%% Repeat the excercise with different sets of features available in
% filename='../DATASETS/FEATURES/Brain_MRI_FS_ABIDE/FS_features_ABIDE_males.csv';
% Using data of the most populated site only, investigate whether ASD vs CTRL
% fall in different areas of the Kohonen map
