function [depth] = getDepthFromNormals(n, mask)
  % [depth] = getDepthFromNormals(n, mask)
  %
  % Input:
  %    n is an [N, M, 3] matrix of surface normals (or zeros
  %      for no available normal).
  %    mask logical [N,M] matrix which is true for pixels
  %      at which the object is present.
  % Output
  %    depth an [N,M] matrix providing depths which are
  %          orthogonal to the normals n (in the least
  %          squares sense).
  %
  
  imsize = size(mask);
  n_x = n(:,:,1);
  n_y = n(:,:,2);
  n_z = n(:,:,3);

  % Only interested in points belonging to object
  [rowObj, colObj] = find(mask);
  objCoord = [rowObj, colObj];
  numPoints = size(objCoord, 1);
  
  % Geneerate an index-map to quickly map form image-coordinates to indices
  indexMap = zeros(imsize);
  for i=1:numPoints
      indexMap(objCoord(i,1),objCoord(i,2)) = i;
  end
  
  A = sparse(2*numPoints,numPoints);
  b = zeros(2*numPoints,1);
  
  % Constructing A and b
  for i=1:numPoints
    row = objCoord(i,1);
    col = objCoord(i,2);
    nx = n_x(row,col);
    ny = n_y(row,col);
    nz = n_z(row,col);
    if(indexMap(row+1, col)>0&&indexMap(row, col+1)>0)
        A(2*i-1,indexMap(row, col)) = -nz;
        A(2*i-1,indexMap(row, col+1)) = nz;
        A(2*i,indexMap(row, col)) = -nz;
        A(2*i,indexMap(row+1, col)) = nz;   
        b(2*i-1) = -nx;
        b(2*i) = -ny;
    elseif(indexMap(row+1, col)>0&&indexMap(row, col-1)>0)
        A(2*i-1,indexMap(row, col)) = -nz;
        A(2*i-1,indexMap(row, col-1)) = nz;
        A(2*i,indexMap(row, col)) = -nz;
        A(2*i,indexMap(row+1, col)) = nz;   
        b(2*i-1) = nx;
        b(2*i) = -ny;         
    elseif(indexMap(row-1, col)>0&&indexMap(row, col+1)>0)
        A(2*i-1,indexMap(row, col)) = -nz;
        A(2*i-1,indexMap(row, col+1)) = nz;
        A(2*i,indexMap(row, col)) = -nz;
        A(2*i,indexMap(row-1, col)) = nz;   
        b(2*i-1) = -nx;
        b(2*i) = ny;                
    elseif(indexMap(row-1, col)>0&&indexMap(row, col-1)>0)
        A(2*i-1,indexMap(row, col)) = -nz;
        A(2*i-1,indexMap(row, col-1)) = nz;
        A(2*i,indexMap(row, col)) = -nz;
        A(2*i,indexMap(row-1, col)) = nz;   
        b(2*i-1) = nx;
        b(2*i) = ny;         
    end
  end
  
  % Solve the system and set minimum depth to zero
  x = A\b;
  x = x-min(x)+0.001;
  
  depth = zeros(imsize);
  maxDepth = max(x);
  for i=1:numPoints
      depth(objCoord(i,1),objCoord(i,2)) = x(i);
  end
  depth(find(depth==0)) = maxDepth;