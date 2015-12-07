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

% Normalize histograms
normHists = cell2mat(cellfun(@(x)x'/norm(x), histCells, ...
    'UniformOutput', false));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Select 4 frames and let user select query-region
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get a list of all the frame .mat files
fnames = dir([siftdir '/*.mat']);
numFrames = length(fnames);
% selInds = randperm(numFrames,4); % Indices of selected frames
selInds = [100,300,500,700]; % Indices of selected frames

% Compute inverse-document frequency (idf) and term-frequency (tf) 
df = sum(cell2mat(cellfun(@(x)x'>0, histCells, 'UniformOutput', false)),2);
idf = log(bsxfun(@rdivide,numFrames,df));
tf = cellfun(@(x)x/sum(x),histCells,'UniformOutput', false);
% Compute document weights as l2-normalized tf
w_d = cellfun(@(x)x.*idf', tf,'UniformOutput', false);
w_d = cell2mat(cellfun(@(x)x'/norm(x), w_d,'UniformOutput', false));

lengths = cell2mat(cellfun(@(x)sum(x), histCells, 'UniformOutput', false));

for i=1:length(selInds)
    fname = [siftdir '/' fnames(selInds(i)).name];
    load(fname, 'positions', 'descriptors');
    % Let user select region in frame and get indices of descriptors within
    figure;
    oninds = selectRegion(imageWithNumber(selInds(i)), positions);
    % Get relevant sift-descriptors, convert to doubles and normalize
    feats = double(descriptors(oninds,:)')/128;
    % Compute distances to the words
    z = distSqr(feats,means);
    % Get the word closest to each feature
    [~,membership] = min(z,[],2);
    % Compute the histogram
    hist = histcounts(membership,size(means,2));
    % Computed the query weights as weighted by the idf and l2-normalized
    w_q = hist;
    w_q = w_q/norm(w_q);
    % Compute the match score
    score = w_q*w_d;
    % Find 6 best matches (highest dot product)
    [~, I] = sort(score,2,'descend');
    best6Idx = I(1:6);   
    
    % Display 
    figure;
    for j=1:6
        subplot(2,3,j);
        imshow(imageWithNumber(best6Idx(j)));
    end
end