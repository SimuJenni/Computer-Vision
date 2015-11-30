%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Build the vocabulary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

siftdir = './data/sift/';

% Get a list of all the .mat files in that directory.
fnames = dir([siftdir '/*.mat']);
numFrames = length(fnames);

% Init parameters
k = 1500;                       % Number of cluster centers
randIdx = randperm(numFrames);  % Random indices of frames 
numSelection = 100;             % Number of frames to get sift from
p = 0.25;                       % Ratio of selected features per frame

descriptorCells = cell(1);
positionsCell = cell(1);  
orientsCell = cell(1);           
scalesCell = cell(1);    
imnames = cell(1);           
imNameIdxCell = cell(1);
for i=1:numSelection
    % Choose random frame
    frameIdx = randIdx(i);
    fname = [siftdir '/' fnames(frameIdx).name];
    load(fname);
    n = size(descriptors,1);
    % Select randomly p*n features
    inds = randperm(n);  
    numFeat = ceil(n*p);
    % Get the data
    descriptorCells{i} = descriptors(1:numFeat,:);
    positionsCell{i} = positions(1:numFeat,:);
    orientsCell{i} = orients(1:numFeat,:);
    scalesCell{i} = scales(1:numFeat,:);
    imnames{i} = imname;
    imNameIdxCell{i} = repmat(i,[numFeat,1]);
end

% Concatenate and convert to doubles
feat = vertcat(descriptorCells{:});
feat = double(feat)/128;

% Cache sift data for later
positions = vertcat(positionsCell{:});
orients = vertcat(orientsCell{:});
scales = vertcat(scalesCell{:});
imNameIdx = vertcat(imNameIdxCell{:});

% K-means clustering
disp('Clustering...')
[membership,means,rms] = kmeansML(k,feat');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Get two distinct words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numVis = 20;    % Number of examples patches per word

% Count how many members each cluster has
memberCount = zeros(size(means,2),1);
for i=1:size(means,2)
    memberCount(i) = sum(membership==i);
end

% Only look at means with at least numVis members
bigInds = find(memberCount>numVis);
bigClust = means(:,bigInds);

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
h2 = figure(2);

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