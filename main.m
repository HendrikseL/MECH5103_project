%{
This is the main script for the MECH5103 project.
This function will analyze a video and identify objects moving in it.
%}

clear
close all

%%
%video file location
vFile = ('/video/visiontraffic.avi');
imgRef = imread('./video/refImage.png');

%turn video into a series of jpeg files
[frameCount, imageDir] = videoProcessing(vFile);

%Import world coordinate measurements and corresponding pixel points
load("roadMeasurements.mat");

%Select first frame for scene setup
sceneImage = [imageDir, 'Frame1.jpg'];

%Check if pixel coordinates have already been selected/loaded
%Select pixel coordinates of matching world coordinate points
if (exist("pixelMeasurements.mat","file") > 0)
    fprintf("Pixel coordinates already saved, loading now.\n")
    load("pixelMeasurements.mat");
else
    fprintf("No pixel coordinates known, please select from image.\n")
    nPpmPoints = length(worldCoordinates_scene);
    imageMatrixScene = imread(sceneImage,'jpg');
    ppmFigNum = 7575;
    figure(ppmFigNum)
    imagesc(imageMatrixScene)
    axis('equal')
    [u1_ppm,v1_ppm] = ginput(nPpmPoints); 
    close(ppmFigNum)
end

%Get PPM, pseudo inverse of PPM, and origin for pixel to world mapping
pixelCoordinates_scene = [u1_ppm'; v1_ppm'];
[PPM, PPMi, origin] = createPPM(pixelCoordinates_scene, ...
    worldCoordinates_scene);

%%
%--------------------------------------------------------------------------
%Example calculation, to be integrated into main loop when we have
%centroid determination from pixel subtraction
car_centroid_p = [1820, 681]; %acquired from pixel coord (u,v)

[intersection,vect_n] = getWorldCoord(car_centroid_p,PPMi,origin);


%%
%This is the main loop
%read in each image one by one
for i = 1:1:frameCount
    %create image filepath
    imagePath = fullfile(imageDir, ['Frame' int2str(i), '.jpg']);
    
    %read in image
    im = imread(imagePath);
    % Background subtraction with reference image
    %diffImage = double(imgRef) - double(im);
    % and threshold above the noise level (say it's 10 gray levels.
    %mask = abs(diffImage) > 40;
    
    %image(diffImage);
end
