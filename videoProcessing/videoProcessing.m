%{
    Auther: Luke Hendrikse
    ID:101101824
    
    this function willread in a .mp4 file and

%}

function [framesCount, dir] = videoProcessing(vFile)

    %Read in video file
    video = VideoReader(vFile);
    
    %create a file path to place the video in
    i = 1;
    while i < length(vFile)
        if vFile(i) == '.'
            break;
        end

        filePath(i) = vFile(i);
        i = i+1;
    end
    
    %add 'files' extension
    filePath = [filePath 'Files/'];

    %make a directory at filepath
    dir = ['.' filePath];
    %convert filePath to a string
    dir = convertCharsToStrings(dir);
    %create a directory to save the images to
    status = mkdir(dir);

    %throw an error is the directory can not be made
    if status == 0
        error('Directory could not be made');
    end

    %counts the number of frames in the video
    framesCount = video.NumFrames;
    
    %save each frame to a jpg file and save to the filepath made above
    for i =1:1:framesCount
        frames = read(video, i);
        fullPath = fullfile(dir, ['Frame' int2str(i), '.jpg']);
        imwrite(frames, fullPath);
    end
