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
load("roadMeasurementsFinal.mat");

%Select first frame for scene setup
sceneImage = append(imageDir,'Frame1.jpg');

%Check if pixel coordinates have already been selected/loaded
%Select pixel coordinates of matching world coordinate points
if (exist("pixelMeasurementsFinal.mat","file") > 0)
    fprintf("Pixel coordinates already saved, loading now.\n")
    load("pixelMeasurementsFinal.mat");
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

framerate = 60; %todo: use metadata framerate

%example centroid data (-1 is invalid)
centroids_u = [0 0 0 0 0 1 2 3 4 0 0 0 0 0 0 0;
             0 1 2 3 4 5 0 0 0 0 0 0 0 0 0 0;
             0 0 0 0 0 0 0 1 2 3 4 5 0 0 0 0;
             0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4;
             0 0 0 0 0 1 2 3 4 0 0 0 0 0 0 0;
             0 0 0 0 0 1 2 3 4 0 0 0 0 0 0 0];
centroids_v = [0 0 0 0 0 1 2 3 4 0 0 0 0 0 0 0;
             0 1 2 3 4 5 0 0 0 0 0 0 0 0 0 0;
             0 0 0 0 0 0 0 1 2 3 4 5 0 0 0 0;
             0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4;
             0 0 0 0 0 1 2 3 4 0 0 0 0 0 0 0;
             0 0 0 0 0 1 2 3 4 0 0 0 0 0 0 0];
maxCars = size(centroids_u,1);
%first frame detected tracker
centroidDetected = zeros(maxCars,1);
%velocity per blob per frame (0 is invalid)
velocitiesCars_x = zeros(maxCars,frameCount);
velocitiesCars_y = zeros(maxCars,frameCount);

%per frame
for currFrame=1:frameCount
    %go through every blob and see if it was detected in this frame
    for carCnt=1:maxCars
        car_centroid_p = [centroids_u(carCnt) centroids_v(carCnt)];
        %centroid value is invalid
        if (car_centroid_p(1) == -999)
            %car has been processed and is now out of frame
            %OR
            %car has yet to enter frame
            continue
        %centroid value is real
        else
            %centroid yet to be initialized
            if (centroidDetected(carCnt) == 0)
                centroidDetected(carCnt) = currFrame;
            end
            %calculate intersection of this centroid
            [intersection,vect_n] = getWorldCoord(car_centroid_p,PPMi,origin);
        end
        
        %if centroid initialized in this frame, no velocity calc yet
        if (centroidDetected(carCnt) == currFrame)
            newCarPos = intersection;
        %centroid initialized already, calculate velocity of past 2 frames
        else
            oldCarPos = newCarPos;
            newCarPos = intersection;
            velocity = getWorldVelocity(oldCarPos, newCarPos, framerate);
            velocitiesCars_x(carCnt,currFrame) = velocity(1);
            velocitiesCars_y(carCnt,currFrame) = velocity(2);
        end
    end
end

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
