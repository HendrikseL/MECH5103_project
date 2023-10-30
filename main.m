%{
This is the main script for the MECH5103 project.
This function will analyze a video and identify objects moving in it.
%}

clear all

%This is the main loop
%%

%video file location
vFile = ('./video/testVideo.mp4');

%turn video into a series of jpeg files
videoProcessing(vFile);