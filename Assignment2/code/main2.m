clear all
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

F = eightPointsAlgorithm(leftPoints,rightPoints);  

E = zeros(3);
% TODO: Compute Essential Matrix (Question 1)

Rl = zeros(3);
tl = zeros(3,1);
Rr = zeros(3);
tr = zeros(3,1);
% TODO: Compute Rotations and translatiosn between views (Question 2)


% TODO: Reconstrct the 3D points (Question 3)

% TODO: Visualize 3D points (Question 4)
