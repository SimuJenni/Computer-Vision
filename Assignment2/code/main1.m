% clear all
%close all
clc

maxSize = 500;
% We assume images have the same size
left = mean(single(imread('pics/left.jpg')),3);
[M N] = size(left);
ratio = max(M,N)/maxSize;
left = imresize(left,1/ratio);

right = mean(single(imread('pics/right.jpg')),3);
right = imresize(right,1/ratio);

[rows cols] = size(left);

h = figure(1);
clf;
subl = subplot(1,2,1);
imLeft = imagesc(left);
colormap(gray) 
title('Left Image');

subr = subplot(1,2,2);
imRight = imagesc(right);
colormap(gray)
title('Right Image');

% Number of corresponding points.
numPoints = 32;
% Set to true to save the points in the file savedPoints.mat.
savePoints = true;
% Set to true to select new points even if a the file savedPoints.mat
% exists.
selectNewPoints  = false;

if exist('savedPoints.mat','file') && ~selectNewPoints
    load('savedPoints.mat')
else
    % My code
    
    % Tag the images
    set(imLeft, 'Tag', 'l');
    set(imRight, 'Tag', 'r');
    
    [leftPoints,rightPoints] = getPointsFromUser(numPoints);
    
    if savePoints
        save('savedPoints.mat','leftPoints','rightPoints');
    end
end

% Computing the fundamental matrix
F = eightPointsAlgorithm(leftPoints,rightPoints);
F = estimateFundamentalMatrix(leftPoints(1:2,:)', rightPoints(1:2,:)', 'method', 'Norm8Point');
disp('The estimated fundamental matrix is: ')
disp(F)

disp('Select a point in the left image. Press ESC to exit.');
while true
    [x, y, key] = ginput(1);
    if key==27
        break;
    end
    
    % Mark chosen point in left image
    hold on;
    plot(x,y,'o','MarkerFaceColor','auto');
    
    % Get line parameters
    l = F*[x;y;1];
    
    % Compute boundary positions of epipolar line in right image and draw
    xpos = [0, -l(3)/l(1), size(left,2), (-l(3)-l(2)*size(left,1))/l(1)];
    ypos = [-l(3)/l(2), 0, (-l(3)-l(1)*size(left,2))/l(2), size(left,1)];
    subplot(subr);
    hold on;
    plot(xpos', ypos')
end

% Compute epipoles as left and right null-spaces of F
e1 = null(F);
e2 = null(F');

% homogenous division to get imagecoordinates of epipoles
e1ImCoord = e1(1:2)/e1(3);  
e2ImCoord = e2(1:2)/e2(3);

disp('Left epipole:');
disp(e1ImCoord);
disp('Right epipole:');
disp(e2ImCoord);


