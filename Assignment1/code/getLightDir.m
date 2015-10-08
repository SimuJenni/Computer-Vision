function [L] = getLightDir(method, chromeDir, nDir, chatty)
  % [L] = getLightDir(method)
  % Input:
  %  method = 0:  Use default directions
  %  method = 1:  Use chrome sphere images
  %  chromeDir (string) directory containing chrome images.
  %  nDir number of different light source images.
  %  chatty  (default false) show chrome images and estimated highlight center.
  % Return:
  %  L is a 3 x nDir image of light source directions.

  % Since we are looking down the z-axis, the direction
  % of the light source from the surface should have
  % a negative z-component, i.e., the light sources
  % are behind the camera.
    
  switch method
   case 0,
    % Default directions...
    % In case you have trouble getting the light source directions,
    % and you want to move on with the next part of the assignment, you
    % can use these.  They are NOT correct, but you can use them for now
    % until you come back and fix your estimation of the light source
    % directions later.
    L = [
        0.6354   -0.1634    0.7547
        -0.3576   -0.6556   -0.6650
        0.8793   -0.3195   -0.3531
        0.9705    0.1994    0.1353
        0.8307   -0.4209    0.3645
        0.9317   -0.2719    0.2406
        -0.7111   -0.7002    0.0640
        0.2611    0.9347   -0.2411
        0.0964   -0.0424   -0.9944
        -0.2163   -0.8842    0.4140
        -0.8486    0.0956   -0.5203
        0.3647   -0.7214    0.5887 ]';
    nrm = sqrt(sum(L.^2,1));
    L = L .* repmat(1./nrm, 3, 1);
   case 1,
    L = fitChromeSphere(chromeDir, nDir, chatty);
   otherwise,
    L = 0;
    fprintf(2, 'Invalid fitting method.\n');
  end
  
  return;
