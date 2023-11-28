%{
This is the main script for the MECH5103 project.
This function will analyze a video and identify objects moving in it.
%}

clear all

%%
%video file location
vFile = ('/video/visiontraffic.avi');
imgRef = imread('./video/Frame1.jpg');

%turn video into a series of jpeg files
[frameCount, imageDir] = videoProcessing(vFile);



%This is the main loop
%read in each image one by one
centroids_u = ones([100, frameCount]).*-1;
centroids_v = ones([100, frameCount]).*-1;
for i = 1:1:frameCount
    %create image filepath
    imagePath = fullfile(imageDir, ['Frame' int2str(i), '.jpg']);
    
    %read in image
    im = imread(imagePath);
    % Background subtraction with reference image
    diffImage = double(imgRef) - double(im);
    % and threshold above the noise level (say it's 10 gray levels.
    mask = abs(diffImage) > 40;
    %display the white blob
    %store the file for later use
    mask = any(mask, 3);

    %Noise reduction and blob centroid detection
    [centroids_u(:,i), centroids_v(:,i)] = blobAnalysis(mask);
    imshow(mask)
    hold on
    plot(centroids_u(:,i),centroids_v(:,i), 'r.');
    hold off
    pause(0.05)
end
