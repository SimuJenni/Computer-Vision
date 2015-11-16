% clear all
%close all
clc

left = mean(double(imread('Matched Points/left.jpg')),3);
right = mean(double(imread('Matched Points/Right.jpg')),3);

figure(1)
clf;
subplot(1,2,1);
imagesc(left);
colormap(gray) 
title('Left Image');

subplot(1,2,2);
imagesc(right);
colormap(gray)
title('Right Image');

A=load('Matched Points/Matched_Points.txt');
[M N] = size(A);

leftPoints = [A(:,3)'; A(:,4)'; ones(1,M)];
rightPoints = [A(:,1)'; A(:,2)'; ones(1,M)];

% Calibration matrix and focal length from the given file
fl = 4;
K = [-83.33333,  0.00000, 250.00000;
      0.00000, -83.33333, 250.00000;
      0.00000,   0.00000,   1.00000];
  
% Intrinsic matrix
I = K;
I([1,5]) = I([1,5])*fl;

% To compute essential-matrix, first compute fundamental matrix 
F = eightPointsAlgorithm(leftPoints,rightPoints);

assert(rank(F)==2);
disp('Estimated fundamental matrix: ')
disp(F)

E = I'*F*I;
disp('Estimated essential matrix: ')
disp(E)

% TODO: Compute Rotations and translatiosn between views (Question 2)
[ Pl, Pr ] = decomposeE( E, I\leftPoints, I\rightPoints );

disp('Estimated translation: ')
disp(Pr(:,4))
disp('Estimated rotation: ')
disp(Pr(:,1:3))

% Reconstrct the 3D points (Question 3)

x3D = infer3D(I\leftPoints, I\rightPoints, Pl, Pr );

% Visualize 3D points (Question 4)
figure
scatter3(x3D(1,:),x3D(2,:),x3D(3,:), '.')
% pcshow(x3D');
axis equal
grid on

