function [L] = fitChromeSphere(chromeDir, nDir, chatty)
  % [L] = fitChromeSphere(chromeDir, nDir, chatty)
  % Input:
  %  chromeDir (string) -- directory containing chrome images.
  %  nDir -- number of different light source images.
  %  chatty -- true to show results images. 
  % Return:
  %  L is a 3 x nDir image of light source directions.

  % Since we are looking down the z-axis, the direction
  % of the light source from the surface should have
  % a negative z-component, i.e., the light sources
  % are behind the camera.
    
  if ~exist('chatty', 'var')
    chatty = false;
  end
    
  mask = imread([chromeDir, 'chrome.mask.png']);
  mask = mask(:,:,1) / 255.0;

  for n=1:nDir
    fname = [chromeDir,'chrome.',num2str(n-1),'.png'];
    im = imread(fname);
    imData(:,:,n) = im(:,:,1);           % red channel
  end
  
  %% My Code
  
  % Convert to cell array of images for personal preference 
  imCells = squeeze(num2cell(imData, [1 2]));
  
  % First recover the center of the sphere and its radius from the mask  
  [row, col] = find(mask>0);
  maskIndices = find(mask>0);
  center = [mean(row), mean(col)];  % one way of finding the center
  radius = max([max(row)-min(row), max(col)-min(col)])/2;
  
  % Recover the locations of the spots in the images
  spots = cellfun(@(x) findSpot(x), imCells, 'UniformOutput', false);
  
  % Retrieve surface-normals at each mask postion from center and radius
  nx = (col-center(2))/radius;
  ny = (row-center(1))/radius;
  nz = -sqrt(max(1-nx.^2-ny.^2,0)); % want negative z-values
  normals = [nx, ny, nz];
  
  % Get normal of the spots by mapping spot positions to the corect normals
  map = @(x) find(maskIndices==sub2ind(size(mask),x(1),x(2)));
  spotNormals = cellfun(@(x) normals(map(x),:), spots, 'UniformOutput', false);
  
  % Reflect camera direction around surface normal to get light direction
  camDir = [0;0;-1]; 
  L = cellfun(@(x) 2*(x*camDir)*x-camDir', spotNormals, 'UniformOutput', false);
  L = cellfun(@(x) x/norm(x,2), L, 'UniformOutput', false); % normalize
  L = cell2mat(L)';
  return;
  

