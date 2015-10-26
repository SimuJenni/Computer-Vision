%
clear all
close all

dataDir = '../images/';
chromeDir = [dataDir, 'chrome/'];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spatial coordinates:
% We'll assume a right handed coordinate frame with
% X to the right, Y down, Z in the direction we are looking.
% We assume orthographic imaging, with the camera coords 
% aligned with world coordinates.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
dirMethod  = 1;  % 0 -- Use default light source directions.
                 % 1 -- Use chrome images to estimate lightsource
                 % directions
                 

% The number of different shading images we have
nDir = 12;


chattyChrome = true;  % show intermediate results in chrome images.
chatty = true;  % Show intermediate results of normal and surface fitting.

% Clear figure to be used for light source directions,
% for which we will superimpose results from all image sets.
figure(1); clf;

% Loop over the test image sets to be used
for useImageSet = 1:6 % or just choose one image set, e.g. 3
  switch useImageSet
   case 1
    name = 'gray';
   case 2
    name = 'buddha';
   case 3
    name = 'cat';
   case 4
    name = 'owl';
   case 5
    name = 'horse';
   case 6
    name = 'rock'; 
   otherwise
    fprintf(2, 'Invalid choice of image set, # %d\n', useImageSet);
  end

  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % PART 1:  Estimate Light Source Directions using chrome 
  %          sphere images.
  [Lchrome] = getLightDir(dirMethod, chromeDir, nDir, chattyChrome);

  % Sanity check
  nrm = sqrt(sum(Lchrome.^2,1));
  if any(abs(nrm - 1) > 1.0e-6)
    fprintf(2, 'Error: Lchrome are not unit vectors\n');
  end
  
  % Plot recovered directions
  theta = 0:0.1:2*pi;
  theta = [theta 2*pi];
  figure(1);
  plot(cos(theta), sin(theta), 'k');
  hold on;
  hLS(1) = plot(Lchrome(1,:), Lchrome(2,:), '*r');
  for k = 1:nDir
    text(Lchrome(1,k), Lchrome(2,k), sprintf(' %d', k-1));
  end
  axis ij; axis equal;
  title('Orthographic image of light source directions.');
  xlabel('x'); ylabel('y');

  if chatty
    fprintf(2, 'Press any key to continue ... ');
    pause; 
  end

  % END OF PART 1.
  % Uncomment/comment the following continue statement.  This
  % allows you to run your partially completed code on
  % each of the examples.
  %continue;
  
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Read in images of the object

  imageDir = [dataDir, name, '/'];

  % Read mask image and binarize
  mask = imread([imageDir,name,'.mask.png']);
  mask = mask(:,:,1) / 255.0;
  mask = mask > 0.5;

  % Get image size and number of pixels.
  imsize = [size(mask,1), size(mask,2)];
  numPixels = prod(imsize);

  % Vectorize mask
  mask = mask(:);

  % We will switch between storing images as 2D arrays of size
  % imsize(1) x imsize(2) and vectorizing them as long numPixels x 1
  % vectors.  Here, by default, we store them in the vector form,
  % since this makes most of the operations we need to do easier
  % (other than display).  When we integrate the normals to get z
  % it will be convenient to reshape the normal image to be a
  % imsize(1) x imsize(2) x 3 array.

  % Read in images, store gray-scale vectorized images.
  imData = zeros(numPixels, nDir);
  for n=1:nDir
    fname = [imageDir,name,'.',num2str(n-1),'.png'];
    RGBim = double(imread(fname));
    if chatty
      figure(1); clf;
      image(RGBim/255); 
      axis equal;
      axis off;
      title(sprintf('Data image %d',n));
      pause(0.5);
    end
    % Calculate a grayscale image
    imGray = sum(RGBim,3)/3;
    imData(:, n) = imGray(:);
  end


  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % PART 2: Fit surface normals and the albedo for pixels within 
  %         the object mask using the images for which corresponding 
  %         images of the chrome sphere (and hence light source 
  %         directionss) are available.

  imDataCrop = imData(mask,:);

  [nCrop, albedoCrop] = fitReflectance(imDataCrop, Lchrome);


  % Unpack the normals and albedos estimated from within the mask
  % into imsize sized images, and display.

  n = zeros([numPixels, 3]);
  n(mask,:) = nCrop;
  albedoGray = zeros(numPixels,1);
  albedoGray(mask) = albedoCrop;

  % Display gray albedo
  figure(3); clf;
  imagesc(reshape(albedoGray,imsize) );
%   imshow(uint8(reshape(albedoGray,imsize)))
  title('Recovered albedo (gray)');
  pause(1);

  % Display each component of the normal as a separate image.
  n = reshape(n, [imsize, 3]);
  figure(4)
    
  subplot(2,2,1);
  imagesc(n(:,:,1));
  title('Surface Normal (nx)');
  subplot(2,2,2);
  imagesc(n(:,:,2));
  title('Surface Normal (ny)');
  subplot(2,2,3);
  imagesc(n(:,:,3));
  title('Surface Normal (nz)');

  figure(7)
  b = n;
  b(:,:,3)=b(:,:,3)+0.5; % Add some bias to n_z for better visualization
  b = bsxfun(@times,((b+1)./2).*255,reshape(mask,imsize));
  imshow(uint8(b));
  title('Normal-map');

  n = reshape(n, [numPixels, 3]);
  pause(1);

  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Compute the reconstruction error and display
  L = Lchrome;
  rmsErr = zeros(numPixels, 1);
  for k = 1:nDir
    nDotL = n * L(:,k);
    rec = nDotL .* albedoGray;
    err = (rec -  imData(:,k)).*mask;
    figure(5); clf;
    subplot(2,2,1); imagesc(reshape(imData(:,k), imsize));
    title(sprintf('Image %d', k));
    subplot(2,2,2); imagesc(reshape(rec, imsize));
    title('Reconstruction');
    subplot(2,2,3); imagesc(reshape(err, imsize));
    title('Error');
    subplot(2,2,4); imagesc(reshape(double(nDotL <0), imsize));
    title('n dot L < 0');
    rmsErr = rmsErr + err.^2;
    pause(1);
  end
  rmsErr = sqrt(rmsErr/nDir);
  figure(6); clf; imagesc(reshape(rmsErr, imsize));
  title(sprintf('RMS error (total: %f)', sqrt(sum(rmsErr.^2))));
  pause(1);

  if chatty
    fprintf(2, 'Press any key to continue ... ');
    pause; 
  end

  % END OF PART 2.
  % Uncomment/comment the following continue statement.  This
  % allows you to run your partially completed code on
  % each of the examples.
  % continue;
  

  % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % PART 3: Given normals and light source directions, 
  %         calculate the albedo in each color channel

  % Get red, green and blue channel images
  imRed = zeros(numPixels, nDir);
  imGreen = zeros(numPixels, nDir);
  imBlue = zeros(numPixels, nDir);
  for i=1:nDir
    fname = [imageDir,name,'.',num2str(i-1),'.png'];
    RGBim = double(imread(fname));
    imRed(:, i) = reshape(RGBim(:,:,1),[numPixels 1]);
    imGreen(:, i) = reshape(RGBim(:,:,2),[numPixels 1]);
    imBlue(:, i) = reshape(RGBim(:,:,3),[numPixels 1]);
  end 
  nDotL = n*L;
  % Compute albedos of red, green and blue channels
  albedoR = sum(nDotL.*imRed,2)./sum(nDotL.^2,2);
  albedoG = sum(nDotL.*imGreen,2)./sum(nDotL.^2,2);
  albedoB = sum(nDotL.*imBlue,2)./sum(nDotL.^2,2);
  albedo = [albedoR, albedoG, albedoB];
 
  
  % Clip albedo to range [0, 255] 
  albedo = max(albedo,0);
  albedo = min(albedo,255);
  figure(3); clf; 
  image(reshape(albedo/255, [imsize, 3]));
  title('Recovered Albedo (RGB)');
  axis equal; axis off;
  pause(1);

  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Show images for synthetic light sources
  t = 0:0.15:2*pi;
  r = 0.5;
  Lsyn = zeros(3, length(t));
  Lsyn(1,:) = r * cos(t);
  Lsyn(2,:) = r *sin(t);
  Lsyn(3,:) = -sqrt(1 - sum(Lsyn(1:2,:).^2,1));

  figure(2); hold on;
  hLS(2) = plot(Lsyn(1,:), Lsyn(2,:), '-*g');
  %legend(hLS(1:2), {'Chrome', 'Synthetic'});
  for k = 1:size(Lsyn,2)
    im = albedo .* repmat(n * Lsyn(:,k), 1,3);
    im = max(im,0);
    im = min(im, 255);
    figure(1); clf; 
    image(reshape(im/255, [imsize, 3]));
    axis equal; axis off;
    title('Synthetically Shaded Image');
    pause(0.1);
  end

  if chatty
    fprintf(2, 'Press any key to continue ... ');
    pause; 
  end

  % END OF PART 3.
  % Uncomment/comment the following continue statement.  This
  % allows you to run your partially completed code on
  % each of the examples.
  %continue;


  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % PART 4: Estimate depth from normals
  maskDepth = mask & (sum(n.^2,2) > 0);
  [depth] = getDepthFromNormals(reshape(n, [imsize, 3]), ...
                                reshape(maskDepth,imsize));

  % Display depth map as image and as surface mesh.
  figure(5); 
  imagesc(depth);
  title('Estimated Object Depth');

  figure(6);
  clf;
  mesh(depth);
  colormap(jet(256));
  title('Estimated Depth as Mesh');
  xlabel('x');
  ylabel('y');
  zlabel('z');
  axis equal;
  pause(1);
  
  figure(8); 
  maxDepth = max(max(depth));
  imshow(uint8((maxDepth-depth)*255/maxDepth));
  title('Depth-map');
     
  if chatty
    fprintf(2, 'Press any key to continue ... ');
    pause; 
  end

  % END OF PART 4.

  %%%%%%%%%%%%%%%%%%%%%%%%%%
end % loop over different objects at beginning of script
