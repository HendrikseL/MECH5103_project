%{
This is the main script for the MECH5103 project.
This function will analyze a video and identify objects moving in it.
%}

clear all

%%
%video file location
vFile = ('/video/third1080.mp4');

%turn video into a series of jpeg files
[frameCount, imageDir] = videoProcessing(vFile);


%centroids_u = ones([100, frameCount]).*-1;
%centroids_v = ones([100, frameCount]).*-1;

nFilter = 50;
imageSum = zeros([1080,1920]);
for i = 1:nFilter
    imagePath = fullfile(imageDir, ['Frame' int2str(i), '.jpg']);
    imageSum = imageSum + double(imread(imagePath));
end

%This is the main loop
%read in each image one by one
for i = nFilter+1:frameCount    
    %Filter current frame
    [im, imageSum] = imageFilter(i,nFilter,imageDir,imageSum);

    %Perform blob analysis
    %[centroids_u(:,i), centroids_v(:,i)] = blobAnalysis(im);
    imshow(im)
    %hold on
    %plot(centroids_u(:,i),centroids_v(:,i), 'r.');
    %hold off
    pause(0.01)
end