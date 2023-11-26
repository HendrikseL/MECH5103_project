function [velocity, velocity_abs] = getWorldVelocity(position1, position2, frameRate)
%GETWORLDVELOCITY Calculated velocity in world coordinates
%   inputs
%       position1: t0 world coordinates
%       position2: t0+1 world coordinates
%       frameRate: frames per second of video
%   outputs
%       velocity: world coordinate velocity
    timeD = 1/frameRate;

    x_dkm = (position2(1)-position1(1))/100/1000;
    y_dkm = (position2(2)-position1(2))/100/1000;
    x_kmh = x_dkm/timeD*3600;
    y_kmh = y_dkm/timeD*3600;
    velocity = [x_kmh y_kmh];
    velocity_abs = sqrt(x_kmh^2+y_kmh^2);
end

