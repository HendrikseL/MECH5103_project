function [velocity] = getWorldVelocity(position1, position2, framerate)
%GETWORLDVELOCITY Summary of this function goes here
%   Detailed explanation goes here
    timeD = 1/frameRate;
    velocity = (position2 - position1)./timeD;
end

