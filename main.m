%{
This is the main script for the MECH5103 project.
This function will analyze a video and identify objects moving in it.
%}

clear
close all


%% SCENE SELECT
%test case selection and init
sceneSelect = 3;

if sceneSelect == 1
    selectionFileName = 'first';
    selectionCoordPixel = 'Final';
    selectionCoordWorld = 'Final';
    selectionPointIndexes = [1 2 3 7 9 5];
elseif sceneSelect == 3
    selectionFileName = 'third';
    selectionCoordPixel = '_v3';
    selectionCoordWorld = '_v3';
    selectionPointIndexes = [1 7 8 10 11 12];
end


%% VIDEO PROCESSING
%video file location
vFile = append('/video/', selectionFileName, '1080.mp4');
imgRef = imread('./video/refImage.png');

%turn video into a series of jpeg files
[frameCount, imageDir] = videoProcessing(vFile);


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


%% VELOCITY LOOP
%This is the second loop to use centroids to calculate velocities
%per frame, go through all detected blobs and see if they are in this frame
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
            [intersection,vect_n] = getWorldCoord(car_centroid_p,PPMi,camOrigin);
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
%Initialize rolling average for filter
nFilter = 150;
imageSum = zeros([1080,1920]);
for i = 1:nFilter
    imagePath = fullfile(imageDir, ['Frame' int2str(i), '.jpg']);
    imageSum = imageSum + double(imread(imagePath));
end

corners_u = ones([100, frameCount]).*-1;
corners_v = ones([100, frameCount]).*-1;


%% CENTROID LOOP
%This is first loop to get centroid data
%read in each image one by one
for i = nFilter+1:frameCount
    %Filter current frame
    [im, imageSum] = imageFilter(i,nFilter,imageDir,imageSum);

    %Perform blob analysis
    [corners_u(:,i), corners_v(:,i)] = blobAnalysis(im);

    %Display image and detected points
    imshow(im)
    hold on
    plot(corners_u(:,i),corners_v(:,i), 'r.');
    hold off
    pause(0.01)
end