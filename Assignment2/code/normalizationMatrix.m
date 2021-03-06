function [ T ] = normalizationMatrix( x )
%NORMALIZATIONMATRIX Returns the transformation matrix used to normalize
%the inputs x
%   Normalization corresponds to subtraicting mean-position and postiions
%   have a mean distance of sqrt(2) to the centre

x2d = x(1:2,:);
n = size(x,2);

% Get centroid and mean-distance to centroid
centre = mean(x2d,2);
meanDist = mean(sqrt(sum((x2d-repmat(centre,[1,n])).^2)));

% Construct transformation matrix
T = [sqrt(2)/meanDist, 0, -centre(1)*sqrt(2)/meanDist;...
     0, sqrt(2)/meanDist, -centre(2)*sqrt(2)/meanDist;...
     0, 0, 1];
end

