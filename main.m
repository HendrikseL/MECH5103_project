%{
This is the main script for the MECH5103 project.
This function will analyze a video and identify objects moving in it.
%}

clear
close all
clc


%% SCENE SELECT
%test case selection and init
sceneSelect = 4;

fprintf("Scene %d selected. \n", sceneSelect)
switch sceneSelect
    case 1
        selectionProcessedDir = './video/first1080Files/';
        selectionFileName = 'first';
        selectionCoordPixel = 'Final';
        selectionCoordWorld = 'Final';
        selectionPointIndexes = [1 2 3 7 9 5];
    case 3
        selectionProcessedDir = './video/third1080Files/';
        selectionFileName = 'third';
        selectionCoordPixel = '_v3_precise';
        selectionCoordWorld = '_v3';
        selectionPointIndexes = [1 7 8 10 11 12];
    case 4
        selectionProcessedDir = './video/fourth1080Files/';
        selectionFileName = 'fourth';
        selectionCoordPixel = '_v4_precise';
        selectionCoordWorld = '_v4';
        selectionPointIndexes = [1 7 9 11 12 13];
    case 5
        selectionProcessedDir = './video/fifth1080Files/';
        selectionFileName = 'fourth';
        selectionCoordPixel = '_v5';
        selectionCoordWorld = '_v5';
        selectionPointIndexes = [1 4 9 11 12 13];
    case 6
        selectionProcessedDir = './video/sixth1080Files/';
        selectionFileName = 'fourth';
        selectionCoordPixel = '_v6';
        selectionCoordWorld = '_v6';
        selectionPointIndexes = [1 4 9 11 12 13];
    otherwise
        fprintf("Incorrect scene selection. Exiting. \n")
        return
end


%% VIDEO PROCESSING
%video file location
vFile = append('/video/', selectionFileName, '1080.mp4');
imgRef = imread('./video/refImage.png');

%turn video into a series of jpeg files
if exist(selectionProcessedDir,'dir')
    fprintf("Video file already processed, using local files.\n")
    imageDir = selectionProcessedDir;
else
    [frameCount, imageDir] = videoProcessing(vFile);
end

%% SCENE INIT
%Import world coordinate measurements and corresponding pixel points
worldCoordName = append("roadMeasurements", selectionCoordWorld, ".mat");
load(worldCoordName);

%Select first frame for scene setup
sceneImage = append(imageDir,'Frame1.jpg');

pixelCoordName = append("pixelMeasurements",selectionCoordPixel,".mat");
%Check if pixel coordinates have already been selected and load them
if (exist(pixelCoordName,"file") > 0)
    fprintf("Pixel coordinates already saved, loading now.\n")
    load(pixelCoordName);
%Select pixel coordinates of matching world coordinate points
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

%select 6 out of the 12 points (offset by 1 because origin is point 1)
for selectedPnt=1:length(selectionPointIndexes)
    u1_ppm_f(selectedPnt) = u1_ppm(selectionPointIndexes(selectedPnt));
    v1_ppm_f(selectedPnt) = v1_ppm(selectionPointIndexes(selectedPnt));
    worldCoordinates_scene_f(:,selectedPnt) = worldCoordinates_scene(:,selectionPointIndexes(selectedPnt));
end

%Get PPM, pseudo inverse of PPM, and origin for pixel to world mapping
pixelCoordinates_scene_f = [u1_ppm_f; v1_ppm_f];
[PPM, PPMi, camOrigin] = createPPM(pixelCoordinates_scene_f, ...
    worldCoordinates_scene_f);


%% TEST DATA
%--------------------------------------------------------------------------
%Example calculation, to be integrated into main loop when we have
%centroid determination from pixel subtraction

framerate = 30; %todo: use metadata framerate

if exist('testFramePixels_v4_2.mat','file')
    load('testFramePixels_v4_2.mat');
else
    for testFrame=405:504
        testFrameName = append('./video/tempFrames/', selectionFileName, '/Frame', int2str(testFrame), '.jpg');
        imageMatrixScene = imread(testFrameName,'jpg');
        testFigNum = 8080;
        figure(testFigNum)
        imagesc(imageMatrixScene)
        axis('equal')
        [test_u(testFrame-404),test_v(testFrame-404)] = ginput(1); 
        close(testFigNum)
    end
end

%example centroid data (-1 is invalid)
centroids_u = [test_u];% test_u-200];
centroids_v = [test_v];% test_v];
maxCars = size(centroids_u,1);

%TODO: remove after test
frameCount = length(centroids_u);

%first frame that a car is detected tracker
carDetected = zeros(maxCars,1);
%temporary storage of positions for velocity calcs
newCarPos = zeros(3,maxCars);
oldCarPos = zeros(3,maxCars);
%initialize all pos/vel arrays
positionsCars_x = zeros(maxCars,frameCount);
positionsCars_y = zeros(maxCars,frameCount);
positionsCars_z = zeros(maxCars,frameCount);
velocitiesCars_x = zeros(maxCars,frameCount);
velocitiesCars_y = zeros(maxCars,frameCount);
velocitiesCars_abs = zeros(maxCars,frameCount);
velocitiesCars_abs_3d = zeros(maxCars,frameCount);


%% VELOCITY LOOP
%This is the second loop to use centroids to calculate velocities
%per frame, go through all detected blobs and see if they are in this frame
for currFrame=1:frameCount
    %go through every blob and see if it was detected in this frame
    for carCnt=1:maxCars
        car_centroid_p = [centroids_u(carCnt,currFrame) centroids_v(carCnt,currFrame)];
        %centroid value is invalid
        if (car_centroid_p(1) == -1)
            %car has been processed and is now out of frame
            %OR
            %car has yet to enter frame
            continue
        %centroid value is real
        else
            %centroid yet to be initialized
            if (carDetected(carCnt) == 0)
                carDetected(carCnt) = currFrame;
            end
            %calculate intersection of this centroid
            [intersection,vect_n] = getWorldCoord(car_centroid_p,PPMi,camOrigin);
            positionsCars_x(carCnt,currFrame) = intersection(1);
            positionsCars_y(carCnt,currFrame) = intersection(2);
            positionsCars_z(carCnt,currFrame) = intersection(3);
        end
        
        %if centroid initialized in this frame, no velocity calc yet
        if (carDetected(carCnt) == currFrame)
            newCarPos(:,carCnt) = intersection;
        %centroid initialized already, calculate velocity of past 2 frames
        else
            oldCarPos(:,carCnt) = newCarPos(:,carCnt);
            newCarPos(:,carCnt) = intersection;
            [velVec, velAbs, velAbs3d] = getWorldVelocity(oldCarPos(:,carCnt), newCarPos(:,carCnt), framerate);
            velocitiesCars_x(carCnt,currFrame) = velVec(1);
            velocitiesCars_y(carCnt,currFrame) = velVec(2);
            velocitiesCars_abs(carCnt,currFrame) = velAbs;
            velocitiesCars_abs_3d(carCnt,currFrame) = velAbs3d;
        end
    end
end

%% CENTROID LOOP
%This is first loop to get centroid data
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
