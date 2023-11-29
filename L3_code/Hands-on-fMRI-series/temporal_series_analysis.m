%% Example of brain connectivity study
% the dataset for this excercise is available in the shared forder 
% on drive in: DATASETS/FEATURES/Brain_fMRI_HOseries_ABIDE 
% the README file explains that
% this dataset is a subset of the rs-fMRI temporal series acquired 
% within the ABIDE project and publicly shared 
% http://preprocessed-connectomes-project.org/abide/

% The dataset includes three files:
% - table_phen_NYU.csv withe the ID of the 124 subjects (59 subjects with ASD and 65 control subjects) with information about the diagnostic group (1 for ASD, 2 for control), age at scan, the Full Scale IQ score  (FIQ), and the SEX (1 for males, only males are present in this dataset);  
% - data_struct.mat, a MATLAB struct containing the 110 time series for each subjects 
% - legend_series.mat, a MATLAB table containing the names of the 110 ROIs of the HO atlas and their correspondence to the Mesulam functional areas.
% - Each time point in the series has a duration of 2 seconds.

clear
close all
clc

%% load the data

load data_struct
load legend_series.mat
T_phen = readtable('table_phen_NYU.csv');

vt = 2; % each timepoint corresponds to 2 seconds

%% Plot some series for the first subject of the dataset

i_sbj = 1; % we plot time series for the first subject


N_ROIs = size(data(i_sbj).t_series,2);

label_all=[];
x = 1:176;
figure;
for i = 1:N_ROIs
    plot(x, data(i_sbj).t_series(:,i))
    label_all = [label_all; string(legend_series{i,3})];
    hold on
end
legend(label_all)

%% Compute the functional connectivity (FC) matrix for one subject

FuncConn = zeros(N_ROIs);
for i = 1:N_ROIs
    for j = i+1:N_ROIs
        S1 = data(i_sbj).t_series(:,i);
        S2 = data(i_sbj).t_series(:,j);
        FuncConn(i,j) = corr2(S1,S2);
    end
end

 figure; imagesc(FuncConn)
%% Identify and plot the pair of time series with the highest FC value

[R,C] = find(FuncConn == max(FuncConn(:)));
string(legend_series{R,3})
string(legend_series{C,3})

label_all=[];
x = 1:176;
figure;
for i = [R, C]
    plot(x, data(i_sbj).t_series(:,i))
    label_all = [label_all; string(legend_series{i,3})];
    hold on
end
legend(label_all)

%% Identify and plot some pairs of time series with high and positive FC value

[R,C] = find(FuncConn > 0.9*max(FuncConn(:)));

x = 1:176;

for i_pairs= 1:size(R,1)
    label_all=[];
    figure;
    for i = [R(i_pairs), C(i_pairs)]
        plot(x, data(i_sbj).t_series(:,i))
        label_all = [label_all; string(legend_series{i,3})];
        hold on
    end
    legend(label_all)
end


%% Identify and plot some pairs of time series with high and negative 
% FC value (i.e. anticorrelated)

[R,C] = find(FuncConn < 0.9*min(FuncConn(:)));

for i_pairs= 1:size(R,1)
    label_all=[];
    figure;
    for i = [R(i_pairs), C(i_pairs)]
        plot(x, data(i_sbj).t_series(:,i))
        label_all = [label_all; string(legend_series{i,3})];
        hold on
    end
    legend(label_all)
end



%% The time series can be grouped according to Mesulam areas

% we are still working only on the first subject of the dataset 
% subject, as with fixed  i_sbj = 1 at the beginning

areas_M = unique(legend_series{:,4})

for i_areas = 1: size(areas_M,1)
    series_M(i_areas).ID  = areas_M{i_areas}

    selected_series=strcmp(legend_series{:,4}, areas_M{i_areas});
    series_M(i_areas).series = data(i_sbj).t_series(:,selected_series);
    series_M(i_areas).mean = mean(data(i_sbj).t_series(:,selected_series),2)
end

%% Plot of the average temporal signals within the 6 Mesulam areas 

figure;
label_all=[];

for i_areas= 1:size(areas_M,1)

    plot(x, series_M(i_areas).mean)
    label_all = [label_all; string(areas_M{i_areas})];
    hold on

    legend(label_all)
end

%% Compute the FC between Measulam areas

N_ROIs = size(areas_M,1)

FuncConn_M = zeros(N_ROIs);
for i = 1:N_ROIs
    for j = i+1:N_ROIs
        S1 = series_M(i).mean;
        S2 = series_M(j).mean;
        FuncConn_M(i,j) = corr2(S1,S2);
    end
end

figure; imagesc(FuncConn_M)
colorbar

%% Plot the most correlated areas

[R,C] = find(FuncConn_M == max(FuncConn_M(:)));
string(legend_series{R,3})
string(legend_series{C,3})


label_all=[];
x = 1:176;
figure;
for i = [R, C]
    plot(x, series_M(i).mean)
    label_all = [label_all; string(areas_M{i})];
    hold on
end
legend(label_all)

%% Identification of the average signals of the 6 Mesulam areas for:
% 1) wavelet time-serie analysis

S_heteromodal = series_M(1).mean';
S_limbic = series_M(2).mean';
S_paralimbic = series_M(3).mean';
S_primary = series_M(4).mean';
S_subcortical = series_M(5).mean';
S_unimodal = series_M(6).mean';

% (start the wavelet time-series analizer App e load the time series from the workspace)
%% and to carry out the
% 2) wavelet coherence analysis to identify coherent time-varying oscillations in two signals

figure;
wcoherence(S_unimodal,S_primary)

figure;
wcoherence(S_heteromodal,S_limbic)


