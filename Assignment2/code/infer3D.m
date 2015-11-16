function [ x3D ] = infer3D( x1, x2, Pl, Pr )
%INFER3D Infers 3d-positions of the point-correspondences x1 and x2, using 
%the rotation matrices Rl, Rr and translation vectors tl, tr. Using a
%least-squares approach.

M = size(x1,2);

% Extract rotation and translation
Rl = Pl(1:3,1:3);
tl = Pl(1:3,4);
Rr = Pr(1:3,1:3);
tr = Pr(1:3,4);

% Construct matrix A with constraints on 3d points
rowIdx = reshape(repmat(1:4*M,3,1),1,12*M);
colIdx = repmat(1:3*M,[1 4]);
A = zeros(4*M,3);
A(1:M,1:3) = x1(1,:)'*Rl(3,:)-repmat(Rl(1,:),M,1);
A(M+1:2*M,1:3) = x1(2,:)'*Rl(3,:)-repmat(Rl(2,:),M,1);
A(2*M+1:3*M,1:3) = x2(1,:)'*Rr(3,:)-repmat(Rr(1,:),M,1);
A(3*M+1:4*M,1:3) = x2(2,:)'*Rr(3,:)-repmat(Rr(2,:),M,1);
A = sparse(rowIdx',colIdx',reshape(A',12*M,1),4*M,3*M);

% Construct vector b 
b = zeros(4*M,1);
b(1:M) = repmat(tl(1),[M,1])-x1(1,:)'*tl(3);
b(M+1:2*M) = repmat(tl(2),[M,1])-x1(2,:)'*tl(3);
b(2*M+1:3*M) = repmat(tr(1),[M,1])-x2(1,:)'*tr(3);
b(3*M+1:4*M) = repmat(tr(2),[M,1])-x2(2,:)'*tr(3);

% Solve for 3d-positions in a least-squares way
w = A\b;
x3D = reshape(w,3,M);

end

