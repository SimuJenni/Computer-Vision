clear all;

% Import provided code
addpath(genpath('./provided_code'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Compute histograms of words for all the frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the vocabulary
load('./vocabulary');
siftdir = './data/sift/';

% Compute histograms
histCells = computeHistograms(means, siftdir);
% Compute normalized histograms
normHists = cell2mat(cellfun(@(x)x'/norm(x), histCells, ...
    'UniformOutput', false));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Select 3 frames and find and display 5 best matching frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get a list of all the frame .mat files
fnames = dir([siftdir '/*.mat']);
numFrames = length(fnames);

% Indices of selected frames
selInds = randperm(numFrames,3); 

% Compute normalized dot products
ndot = normHists(:,selInds)'*normHists;

% Find 5 best matches (highest dot product)
[sortedNdot, I] = sort(ndot,2,'descend');
best5Idx = I(:,2:6);    % first column is identity

% Display results
framesdir = './data/frames/';

h1 = figure(1);
set(h1, 'name', 'Frame query 1');
subplot(2,3,1)
imshow(imageWithNumber(selInds(1)));
h2 = figure(2);
set(h2, 'name', 'Frame query 2');
subplot(2,3,1)
imshow(imageWithNumber(selInds(2)));
h3 = figure(3);
set(h3, 'name', 'Frame query 3');
subplot(2,3,1)
imshow(imageWithNumber(selInds(3)));

for i=1:5
    % Display
    figure(h1);
    subplot(2,3,i+1)
    imshow(imageWithNumber(best5Idx(1,i)));
    figure(h2);
    subplot(2,3,i+1)
    imshow(imageWithNumber(best5Idx(2,i)));
    figure(h3);
    subplot(2,3,i+1)
    imshow(imageWithNumber(best5Idx(3,i)));
end
