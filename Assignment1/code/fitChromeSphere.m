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
  
  % First recover the center of the sphere and its radius from the mask  
  [row, col] = find(mask>0);
  center = [mean(row), mean(col)];  % one way of finding the center
  radius = mean([max(row)-min(row), max(col)-min(col)])/2;
  
  
  
  return;
  

