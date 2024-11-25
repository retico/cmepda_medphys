%% Example of brain connectivity study
% the dataset for this excercise is available in the shared forder 
% on drive in: DATASETS/FEATURES/Brain_fMRI_HOseries_ABIDE 
% the README file explains that
% this dataset is a subset of the rs-fMRI temporal series acquired 
% within the ABIDE project and publicly shared 
% http://preprocessed-connectomes-project.org/abide/

% The dataset includes three files:
% - table_phen_NYU.csv with the ID of the 124 subjects (59 subjects with ASD and 65 control subjects) with information about the diagnostic group (1 for ASD, 2 for control), age at scan, the Full Scale IQ score (FIQ), and the SEX (1 for males, only males are present in this dataset);  
% - data_struct.mat, a MATLAB struct containing the 110 time series for each subjects 
% - legend_series.mat, a MATLAB table containing the names of the 110 ROIs of the HO atlas and their correspondence to the Mesulam functional areas.
% - Each time point in the series has a duration of 2 seconds.

clear
close all
clc

%% load the data

data_dir = "/Users/retico/Desktop/CMEPDA/DATASETS/FEATURES/Brain_fMRI_HOseries_ABIDE/";

load(strcat(data_dir, "data_struct"))
load(strcat(data_dir,"legend_series.mat"))
T_phen = readtable(strcat(data_dir, 'table_phen_NYU.csv'));

vt = 2; % each timepoint corresponds to 2 seconds

%% Plot some series for the first subject of the dataset

i_sbj = 1; % we plot time series for the first subject


N_ROIs = size(data(i_sbj).t_series,2);
time_points = size(data(i_sbj).t_series(:,1),1);
x = 1:time_points;
x = x*vt;

label_all=[];
figure;
for i = 1: 10 %N_ROIs
    
    plot(x, data(i_sbj).t_series(:,i))
    label_all = [label_all; string(legend_series{i,3})];
    xlabel('t (s)')
    ylabel('bold signal (a.u.)')
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
 colorbar
%% Identify and plot the pair of time series with the highest FC value

[i_max, j_max] = find(FuncConn == max(FuncConn(:)));

pair = [i_max, j_max]; 

string(legend_series{pair(1),3})
string(legend_series{pair(2),3})

label_all=[];

figure;
for i = pair(:)
    plot(x, data(i_sbj).t_series(:,i))
    label_all = [label_all; string(legend_series{i,3})];
    hold on
    %print(string(legend_series{i,3}))
end
legend(label_all)
colorbar


%% Identify and plot some pairs of time series with high and positive FC value

[i_set, j_set] = find(FuncConn > 0.9*max(FuncConn(:)));

pairs = [i_set, j_set]; 

for i_pairs= 1:size(pairs,1)
    label_all=[];
    figure;
    for i = [pairs(i_pairs,1), pairs(i_pairs,2)]
        plot(x, data(i_sbj).t_series(:,i))
        label_all = [label_all; string(legend_series{i,3})];
        hold on
    end
    legend(label_all)
end



%% write a function which makes the plots of the selected tipe series

function plot_pair_series(data,i_sbj, x, pairs, legend_series)
%plots two time series 

for i_pairs= 1:size(pairs,1)
    label_all=[];
    figure;
    for i = [pairs(i_pairs,1), pairs(i_pairs,2)]
        plot(x, data(i_sbj).t_series(:,i))
        label_all = [label_all; string(legend_series{i})];
        hold on
    end
    legend(label_all)
    xlabel('t (s)')
    ylabel('bold signal (a.u.)')
    hold on
end


end

%% Identify and plot the pair of time series with the highest FC value (as before, but now using the function)

[i_max, j_max] = find(FuncConn == max(FuncConn(:)));
pair = [i_max, j_max]; 

plot_pair_series(data,i_sbj, x, pair, legend_series{:,3})


%% Identify and plot some pairs of time series with high and positive FC value

[i_set, j_set] = find(FuncConn > 0.9*max(FuncConn(:)));
pairs = [i_set, j_set]; 

plot_pair_series(data,i_sbj, x, pairs, legend_series{:,3})


%% Identify and plot the pairs of time series with the highest and negative FC value (i.e. anticorrelated)

[i_min,j_min] = find(FuncConn == min(FuncConn(:)));
pair = [i_min, j_min]; 

plot_pair_series(data,i_sbj, x, pair, legend_series{:,3})


%% Identify and plot some pairs of anticorrelated time series

[i_min,j_min] = find(FuncConn < 0.9*min(FuncConn(:)));
pair = [i_min, j_min]; 

plot_pair_series(data,i_sbj, x, pair, legend_series{:,3})



%% Identify and plot some pairs of uncorrelated time series (FC value close to 0)

[i_set, j_set]  = find((abs(FuncConn) < 0.0001)&(abs(FuncConn) ~= 0));

pairs = [i_set, j_set]; 

plot_pair_series(data,i_sbj, x, pair, legend_series{:,3})




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

[i_max, j_max]  = find(FuncConn_M == max(FuncConn_M(:)));

label_all=[];

figure;
for i = [i_max, j_max]
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


