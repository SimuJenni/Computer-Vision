function [ Pl, Pr ] = decomposeE( E, x1, x2 )
%DECOMPOSEE Decomposes E into a rotation and translation matrix using the
%normalized corresponding points x1 and x2.

% Fix left camera-matrix
Rl = eye(3);
tl = [0;0;0];
Pl = [Rl,tl];

% Factor E
[U,S,V] = svd(E);

% Check if E is valid essential matrix
if(abs(S(1,1)-S(2,2))>0.01 || S(3,3)~=0 ) 
    S = diag([1,1,0]);  % enforce if not
end

% Compute possible rorations and translations
W = [0, -1, 0;
     1,  0, 0;
     0,  0, 1];
T = U*S*W*U';
R1 = U*W'*V';
R2 = U*W*V';
t1 = [T(3,2);T(1,3);T(2,1)];
t2 = -t1;

% Four possibilities
Pr = {[R1, t1],[R1, t2],[R2, t1],[R2, t2]};

% Compute reconstructions for all possible right camera-matrices
X3Ds = cellfun(@(x) infer3D(x1(:,1), x2(:,1), Pl, x), Pr,...
    'UniformOutput', false);

% Compute projections on image-planes and find when both cameras see point
test = arrayfun(@(i) prod([Pl*[X3Ds{i};1],Pr{i}*[X3Ds{i};1]]>0,2), 1:4,...
    'UniformOutput', false);
idx = find([test{1}(3),test{2}(3),test{3}(3), test{4}(3)]>0);

% Choose correct matrix
Pr = Pr{idx};

end

