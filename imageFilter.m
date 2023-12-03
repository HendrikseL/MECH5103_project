%{
    Author: Paul Cormier
    ID:101065035

    This function reads the last n images and applies a mean filter for
    background subtraction
%}

function [im, sum] = imageFilter(index,n,dir,sum)
    %Subtract outdated frame from sum
    imagePath = fullfile(dir, ['Frame' int2str(index-n), '.jpg']);
    sum = sum - double(imread(imagePath));

    %Read current frame and add it to the sum
    imagePath = fullfile(dir, ['Frame' int2str(index), '.jpg']);
    sum = sum + double(imread(imagePath));

    %Apply gaussian blur to current frame and mean image
    im = imgaussfilt(imread(imagePath),4);
    imageMean = imgaussfilt(uint8(sum ./ n),4);

    %Perform image subtraction
    im = double(imageMean) - double(im);
    im = abs(im) > 32;
    im = any(im, 3);
end