%{
This is the main script for the MECH5103 project.
This function will analyze a video and identify objects moving in it.
%}

clear all

%%
%video file location
vFile = ('/video/testVideo.mp4');

%turn video into a series of jpeg files
[frameCount, imageDir] = videoProcessing(vFile);

%This is the main loop
%read in each image one by one
for i = 1:1:frameCount
    %create image filepath
    imagePath = fullfile(imageDir, ['Frame' int2str(i), '.jpg']);
    
    %read in image
    im = imread(imagePath);

    image(im);
end
