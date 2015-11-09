function [ leftPoints, rightPoints ] = getPointsFromUser( numPoints )
%getPointsFromUser Asks the user to select numPoints corresponding points
%in the left and right image and returns the selected points.

% Corresponding points in homogeneous coordinates.
leftPoints = zeros(3, numPoints);
rightPoints = zeros(3, numPoints);

for i=1:numPoints
    % Get the left point
    disp(['Please choose point ' num2str(i) '/' num2str(numPoints) ' in the left image']);
    leftPoints = getCoordinates ( leftPoints, i, 'l' );

    % Get the right point
    disp('Please choose corresponding point in the right image');
    rightPoints = getCoordinates ( rightPoints, i, 'r' );
end


end

function points = getCoordinates ( points, idx, tag )
%getCoordinates extracts the image-coordinates where the user has clicked.
%   To check if the user clicked on the correct image, the tags will be 
% compared. The coordinates of the mouse are then extracted and added to 
% points.
    
    % Get point in figure
    p = ginput(1); %
    
    % Check if the correct image has been clicked and throw error otherwise
    if(tag ~= get(gco, 'Tag'))
        error('You clicked the wrong image!');
    end

    % Get the image coordinates
    coord = get(gca,'CurrentPoint'); 
    points(:,idx) = coord(1,:);
        
    % Mark selected point
    figure(gcf);
    hold on;
    n = size(points,2);
    plot(p(1), p(2), 'MarkerFaceColor',[sqrt(1-idx/n),1/idx,idx/n],...
        'Marker', 'o', 'MarkerSize', 8);

end

