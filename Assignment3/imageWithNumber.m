function [ im ] = imageWithNumber( n )
%Retrieves image with the specified index n from Data/frames

framesdir = './data/frames/';
siftdir = './data/sift/';
load([siftdir num2str(n) '.mat'], 'imname');
imPath = strcat(framesdir,imname);
im = imread(imPath);

end

