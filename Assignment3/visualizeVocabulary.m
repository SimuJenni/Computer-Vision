clear all;

% Import provided code
addpath(genpath('./provided_code'))

% Setup VLFeat
VLFEATROOT = '~/3rd_party_libs/vlfeat-0.9.20';
run([VLFEATROOT '/toolbox/vl_setup']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Build the vocabulary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

siftdir = './data/sift/';

% Get a list of all the .mat files in that directory.
fnames = dir([siftdir '/*.mat']);
numFrames = length(fnames);

% Init parameters
k = 1600;                       % Number of cluster centers
% selIdx = randperm(numFrames); % Random indices of frames 
selIdx = 1:10:numFrames;        % Features from every 10th frame 
numSelection = numFrames/10;    % Number of frames to get sift from
p = 0.9;                        % Ratio of selected features per frame

descriptorCells = cell(1);
positionsCell = cell(1);  
orientsCell = cell(1);           
scalesCell = cell(1);    
imnames = cell(1);           
imNameIdxCell = cell(1);
for i=1:numSelection
    % Choose random frame
    frameIdx = selIdx(i);
    fname = [siftdir '/' fnames(frameIdx).name];
    load(fname);
    n = size(descriptors,1);
    % Select randomly p*n features
    inds = randperm(n);  
    numFeat = ceil(n*p);
    % Get the data
    descriptorCells{i} = descriptors(inds(1:numFeat),:);
    positionsCell{i} = positions(inds(1:numFeat),:);
    orientsCell{i} = orients(inds(1:numFeat),:);
    scalesCell{i} = scales(inds(1:numFeat),:);
    imnames{i} = imname;
    imNameIdxCell{i} = repmat(i,[numFeat,1]);
end

% Concatenate, convert to doubles and normalize
feat = vertcat(descriptorCells{:});
feat = double(feat)/128;

% Cache sift data for later
positions = vertcat(positionsCell{:});
orients = vertcat(orientsCell{:});
scales = vertcat(scalesCell{:});
imNameIdx = vertcat(imNameIdxCell{:});

% K-means clustering
disp('Clustering...')
% [membership,centers,rms] = kmeansML(k,feat');
[centers, membership] = vl_kmeans(feat', k,'verbose', 'algorithm', 'elkan'); 

% Count how many members each cluster has
memCount = zeros(size(centers,2),1);
for i=1:size(centers,2)
    memCount(i) = sum(membership==i);
end
sortCount = sort(memCount);
% Stoplist: discard words that are very common
inds = memCount<sortCount(k*0.97);
means = centers(:,find(inds));

% Save the vocabulary
save('./vocabulary','means');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Get two distinct words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numVis = 25;    % Number of examples patches per word

% Only look at clusters with at least numVis members
bigInds = find(memCount>numVis);
bigClust = centers(:,bigInds);

% Compute pairwise distance of cluster centers
d2 = distSqr(bigClust,bigClust);

% Find indices of most dissimilar centers
I = find(d2==max(d2(:)));
[idx1,idx2] = ind2sub(size(d2),I(1));

% Get indices of frames belonging to each center
frameIdx1 = find(membership==bigInds(idx1));
frameIdx2 = find(membership==bigInds(idx2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Visualize all the things
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

framesdir = './data/frames/';
h1 = figure(1);
set(h1, 'name', 'Examples of visual word 1');
h2 = figure(2);
set(h2, 'name', 'Examples of visual word 2');

for i=1:numVis
    idx1 = frameIdx1(i);
    idx2 = frameIdx2(i);
    % Load the images
    imPath1 = strcat(framesdir,imnames(imNameIdx(idx1)));
    imPath2 = strcat(framesdir,imnames(imNameIdx(idx2)));
    im1 = rgb2gray(imread(imPath1{1}));
    im2 = rgb2gray(imread(imPath2{1}));
    % Get image patches
    [patch1] = getPatchFromSIFTParameters(positions(idx1,:), scales(idx1),...
        orients(idx1), im1);
    [patch2] = getPatchFromSIFTParameters(positions(idx2,:), scales(idx2),...
        orients(idx2), im2);
    % Display
    figure(h1);
    subplot(5,numVis/5,i)
    imshow(patch1);
    figure(h2);
    subplot(5,numVis/5,i)
    imshow(patch2);
end