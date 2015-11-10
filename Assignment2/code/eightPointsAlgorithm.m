function [F] = eightPointsAlgorithm(x1,x2)
% function Fundamental_Matrix =Eight_Point_Algorithm(x1,x2)
% Calculates the Fundamental matrix between two views from the normalized 8 point algorithm
% Inputs: 
%               x1      3xN     homogeneous coordinates of matched points in view 1
%               x2      3xN     homogeneous coordinates of matched points in view 2
% Outputs:
%               F       3x3     Fundamental matrix

N = size(x1,2);

% Construct transformation matrices to normalize the coordinates
T1 = normalizationMatrix(x1);
T2 = normalizationMatrix(x2);

% Normalize inputs
x1 = T1*x1;
x2 = T2*x2;

% Construct matrix A encoding the constraints on x1 and x2
A = [x2(1,:)'.*x1(1,:)',x2(1,:)'.*x1(2,:)',x2(1,:)',x2(2,:)'.*x1(1,:)',...
    x2(2,:)'.*x1(2,:)',x2(2,:)',x1(1,:)',x1(2,:)',ones(N,1)];

% Solve for f using SVD
[U,S,V] = svd(A);
F = reshape(V(:,9), 3, 3)'; 

% Enforce that rank(F)=2
[U,S,V] = svd(F);
S(3,3) = 0;
F = U*S*V';

% Transform back
F = T2'*F*T1;