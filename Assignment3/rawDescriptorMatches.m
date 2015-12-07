clear all;

% Import provided code
addpath(genpath('./provided_code'))

% Load the test data
load('twoFrameData.mat');

% Let the user select a region of interest
figure(1)
disp('Use the mouse to draw a polygon...');
inds = selectRegion(im1, positions1);

% Compute pairwise distances
% d2 = distSqr(descriptors2',descriptors1(inds,:)');
d2 = dist2(descriptors2,descriptors1(inds,:));

% Get the matches (based on minimal distance)
[~,matchIdx] = min(d2);

% Display matches in second image
figure(2)
imshow(im2);
displaySIFTPatches(positions2(matchIdx,:), scales2(matchIdx), ...
    orients2(matchIdx), im2); 