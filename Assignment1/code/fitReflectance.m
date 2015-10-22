function [n, albedo] = fitReflectance(im, L)
  % [n, albedo] = fitReflectance(im, L)
  % 
  % Input:
  %   im - nPix x nDirChrome array of brightnesses,
  %   L  - 3 x nDirChrome array of light source directions.
  % Output:
  %   n - nPix x 3 array of surface normals, with n(k,1:3) = (nx, ny, nz)
  %       at the k-th pixel.
  %   albedo - nPix x 1 array of estimated albdedos
    
  % Solve the least-squares problem im'=L'*X, where X encodes the scaled
  % normals (albedo~scale)
  X=(L'\im')';
  
  % Extract albedo and normals
  X_cell = num2cell(X,2);
  albedo = cellfun(@norm, X_cell);
  n = bsxfun(@rdivide, X, albedo);
  
  return;


