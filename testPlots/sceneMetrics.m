%SCENEMETRICS calculate some averages
%       Author: Vladislav Pripotnev
%       ID:300331564
%   inputs
%       velocitiesCars_abs: absolute velocities
%   outputs
%       averageVel: average velocity per 10 frames
%       averageMovingVel: moving average per 10 frames
function [averageVel, averageMovingVel] = sceneMetrics(velocitiesCars_abs)
    maxCars = size(velocitiesCars_abs,1);
    
    %calculate per 10 frame average
    stepSize = 10;
    step=1;
    for cars=1:maxCars
        for index=stepSize:stepSize:(size(velocitiesCars_abs,2))
            averageVel(cars,step) = sum(velocitiesCars_abs(cars,index-stepSize+1:index))/stepSize;
            step=step+1;
        end
    end
    
    %calculate 10 frame moving average
    averageMovingVel = zeros(maxCars,size(velocitiesCars_abs,2));
    stepSize = 10;
    for cars=1:maxCars
        step = 1;
        for index=stepSize:1:(size(velocitiesCars_abs,2))
            averageMovingVel(cars,step) = sum(velocitiesCars_abs(cars,index-stepSize+1:index))/stepSize;
            step=step+1;
        end
    end
    
    averageMovingVel(averageMovingVel>100) = 0;
    
    figure
    hold on
    plot(1:1:size(averageMovingVel,2),averageMovingVel)
    hold off
end