function [ histCells ] = computeHistograms(words, siftdir)
%COMPUTEHISTOGRAMS Computes the histograms of words for all the frames in
%siftdir and returns them in a cell-array histCells (unnormalized).
%The computed histograms are saved in histograms.mat and reused if already
%computed.

if (~exist('histograms.mat','file'))
    % Number of words
    d = size(words,2);

    % Get a list of all the frame .mat files
    fnames = dir([siftdir '/*.mat']);
    numFrames = length(fnames);

    % Iterate over all frames and compute the histograms
    histCells = cell(1,numFrames);
    disp('Compute histograms...')
    for i=1:numFrames
        % Load the features
        fname = [siftdir '/' fnames(i).name];
        load(fname, 'descriptors');
        % Convert to doubles and normalize
        feats = double(descriptors')/128;
        % Compute distances to the words
        z = distSqr(feats,words);
        % Get the word closest to each feature
        [~,membership] = min(z,[],2);
        % Compute the histpgram
        histCells{i} = histcounts(membership,d);
    end
    disp('done!')
    % Save the computed histograms for later use...
    save('histograms','histCells');
else
    load('histograms');
end

end

