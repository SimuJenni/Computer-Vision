function [ spotPosition ] = findSpot( I )
%Finds the position of brightest spot in an image. 
%   Input is an m*n image and the function outputs a vector indicating the
%   postition of the brightest spot in the image

m = max(I(:));
idx = find(I(:)>=0.98*m);    % find brightest pixels

[row, col] = ind2sub(size(I), idx);
spotPosition = round(mean([row, col]));

% % Visualization for testing
% image(I);
% hold on;
% plot(spotPosition(2),spotPosition(1),'r.-');
end

