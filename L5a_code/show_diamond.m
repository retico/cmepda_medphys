% This script shows a number N of diamonds in a random position
% We can use two difference fuctions to generate diamonds
% diamond_bad.m contains many loops 
% diamond.m contains vectorized code
%
% Despite computation time differences may be not not appreciable while 
% using either diamond_bad.m or diamond.m, the vectorized code is 
% definitely more easy to read, modify and maintain


close all   % close all figures
clear       % deletes all variables in the workspace

tic         % starts a stopwatch timer to measure performance
for i=1:20
diamond_max_size= 50;
image_size=100;
diamond_size = randi([1 diamond_max_size]);

row=randi([1 image_size]);
col=randi([1 image_size]);

%Im=diamond(row,col,diamond_size,image_size);
Im=diamond_bad(row,col,diamond_size,image_size);

imagesc(Im)
pause(0.2) 
end
toc         % reads the elapsed time from the stopwatch timer started by the tic function