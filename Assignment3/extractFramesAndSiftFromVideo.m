% Setup VLFeat
VLFEATROOT = '~/3rd_party_libs/vlfeat-0.9.20';
run([VLFEATROOT '/toolbox/vl_setup']);

% Check if data folders exist and create them if not
if (~exist('./data','dir'))
    mkdir('./data');
end
if (~exist('./data/frames','dir'))
    mkdir('./data/frames');
end
if (~exist('./data/sift','dir'))
    mkdir('./data/sift');
end

% Get video data
videoPath = 'Chicken_Dance.mp4';
numFrames = get(VideoReader(videoPath), 'numberOfFrames');
v = VideoReader(videoPath);

N = 100;    % Number of frames that are extracted
for idx = 1:N
    if(mod(idx,20)==1)
        disp(['Extracting frame ' num2str(idx) '/' num2str(N)]);
    end
    
    % Extract frame
    frame = readFrame(v);

    % Save image
    imname = ['ChickenDance_' num2str(idx) '.png'];
    imPath = ['./data/frames/' imname];
    imwrite(frame,imPath);
    
    % Convert to expected format for SIFT
    I = single(rgb2gray(frame)) ;

    % Compute SIFT-features
    [f,d] = vl_sift(I) ;
    
    % Extract relevant information
    numfeats = size(d,2);
    descriptors = d';
    positions = f(1:2,:)';
    scales = f(3,:)';
    orients = f(4,:)';
    
    % Save sift data
    siftPath = ['./data/sift/' num2str(idx)];
    save(siftPath,'descriptors','imname', 'numfeats', 'positions', ...
        'scales', 'orients');
end

