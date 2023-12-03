function visualizer(posx, posy, posz, velx, vely)
%function will take position data (x, y) and plot them.
arrowScale = 25;
markerSize = 50;

%colour matrix
c = [1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 0 0 0; 0 0.4470 0.7410; 0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880; 0.3010 0.7450 0.9330;...
    0.6350 0.0780 0.1840];

%delete leading zeroes
stop_flag = false;
while ~stop_flag
    for j = 1:1:length(posx(:,1))
        if posx(j,1) ~= 0
            %raise flag if non-zero value detected
            stop_flag = true;
        end
    end

    %delete column
    if ~stop_flag
        posx(:,1) = [];
        posy(:,1) = [];
        posz(:,1) = [];
        velx(:,1) = [];
        vely(:,1) = [];
    end
end

%find position of trailing zeros for plotting the trajectory
for i = 1:1:length(posx(:,1))
    %check for edgecase
    if posx(i,1) ~= 0
        start = 1;
    end

    %find indices where trajectory is plotted
    for j = 1:1:length(posx(i,:))-1
        if posx(i,j+1) ~= 0 && posx(i,j) == 0
            start = j+1;
        elseif posx(i,j+1) == 0 && posx(i,j) ~= 0
            stop = j;
        end
    end

    trajLen(i,:) = [start stop];
end

%find max boundary for each direction
xmax = 0;
xmin = 0;
ymax = 0;
ymin = 0;
zmax = 0;
zmin = 0;

for i = 1:1:length(posx(:,1))
    for j = 1:1:length(posx(1,:))
        %find xmax and xmin
        if posx(i,j) > xmax
            xmax = posx(i,j);
        elseif posx(i,j) < xmin
            xmin = posx(i,j);
        end

        %find ymax and ymin
        if posy(i,j) > ymax
            ymax = posy(i,j);
        elseif posy(i,j) < ymin
            ymin = posy(i,j);
        end

        %find zmax and zmin
        if posz(i,j) > zmax
            zmax = posz(i,j);
        elseif posz(i,j) < zmin
            zmin = posz(i,j);
        end
    end
end

len = max(trajLen(:,2));

for i = 1:1:len+1%loop through frame step
    %reset figure each loop iteration
    clf("reset")
    hold on
    activeCount = 1;
    jActive =[];
    for j = 1:1:length(posx(:,1))%loop through car
        %creates vector arrow
        quiver3(posx(j,i),posy(j,i),posz(j,i), (arrowScale*velx(j,i)), (arrowScale*vely(j,i)), (arrowScale*0),'HandleVisibility','off');
    
        %only place the point marker if non zero position
        if posx(j,i) ~=0
            %place a dot to show location
            scatter3(posx(j,i),posy(j,i),posz(j,i),markerSize, 'MarkerEdgeColor','k','MarkerFaceColor',c(j,:));
            %allows dynamic sizing for the annotation
            jActive(activeCount) = j;
            activeCount = activeCount + 1;
        end

        %only plot pathline if we are larger than start and less than stop
        if i >= trajLen(j,1) && i <= trajLen(j,2)
            %pathline
            h = plot3(posx(j,trajLen(j,1):i),posy(j,trajLen(j,1):i),posz(j,trajLen(j,1):i),'HandleVisibility','off');
            h.Color = c(j,:);
        elseif i >= trajLen(j,1) && i >= trajLen(j,2)
            %pathline
            h = plot3(posx(j,trajLen(j,1):trajLen(j,2)),posy(j,trajLen(j,1):trajLen(j,2)),posz(j,trajLen(j,1):trajLen(j,2)),'HandleVisibility','off');
            h.Color = c(j,:);
        end

        temp = ["Car" j ", Current Velocity: "  (sqrt(velx(j,i)^2 + vely(j,i)^2)) "km/h"];
        temp = join(temp);
        velString(j) = temp;

    end
    

    %figure settings
    view(-35,55)
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');
    xlim([xmin xmax]);
    ylim([ymin ymax]);
    zlim([zmin zmax]);
    annotation('textbox', [0.05, 0.85, 0.1, 0.1], 'String', velString(jActive(:)), 'FitBoxToText','on');
    %needed to ensure plotting is update each time something happens
    pause(0.0000001);
    hold off


end
