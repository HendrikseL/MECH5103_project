function [velocity] = getWorldVelocity(position1, position2, frameRate)
%GETWORLDVELOCITY Calculated velocity in world coordinates
%   inputs
%       position1: t0 world coordinates
%       position2: t0+1 world coordinates
%       frameRate: frames per second of video
%   outputs
%       velocity: world coordinate velocity
    timeD = 1/frameRate;
    velocity = (position2 - position1)./timeD;
end

