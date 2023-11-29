
%calculate per 10 frame average
stepSize = 10;
step=1;
for cars=1:maxCars
    for index=stepSize:stepSize:(length(velocitiesCars_abs))
        averageVel(cars,step) = sum(velocitiesCars_abs(cars,index-stepSize+1:index))/stepSize;
        step=step+1;
    end
end

%calculate 10 frame moving average
averageMovingVel = zeros(maxCars,length(velocitiesCars_abs));
stepSize = 10;
figure
hold on
for cars=1:maxCars
    step = 1;
    for index=stepSize:1:(length(velocitiesCars_abs))
        averageMovingVel(cars,step) = sum(velocitiesCars_abs(cars,index-stepSize+1:index))/stepSize;
        step=step+1;
    end
    plot(1:1:90,averageMovingVel(cars,1:90))
end
hold off