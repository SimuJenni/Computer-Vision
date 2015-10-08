function [ spotPosition ] = findSpot( I )
%Finds the position of brightest spot in an image. 
%   Input is an m*n image and the function outputs a vector indicating the
%   postition of the brightest spot in the image

m = max(I(:));
idx = find(I(:)>0.95*m);    % find brightest pixels

[row, col] = ind2sub(size(I), idx);
spotPosition = round(mean([row, col]));
end

