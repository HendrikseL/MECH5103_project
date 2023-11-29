
%road plane centered at the 15m mark in x from our origin (where the road
%starts)
plane_norm = [0;0;1];
plane_loc = [1500;0;0];

%adjust road plane for centroid intersection, assuming scene's
%280m length and approximate centroid height at that distance of 1m
%which is 0.2deg about y, then rotating about the z axis 20deg
ang_y = -5;
rotation_y = [cosd(ang_y)   0   sind(ang_y);
             0            1          0;
             -sind(ang_y)  0   cosd(ang_y)];
ang_z = 45;
rotation_z = [cosd(ang_z)  -sind(ang_z)  0;
             sind(ang_z)   cosd(ang_z)  0;
             0            0           1];
ang_x = 5;
rotation_x = [1          0           0;
             0   cosd(ang_x)  -sind(ang_x);
             0   sind(ang_x)  cosd(ang_x)];
plane_norm_r1 = rotation_y*plane_norm;
plane_norm_r2 = rotation_z*plane_norm_r1;
plane_norm_r3 = rotation_x*plane_norm_r2;
plane_norm_f = plane_norm_r3;

point = plane_loc';
normal = plane_norm_f';

%# a plane is a*x+b*y+c*z+d=0
%# [a,b,c] is the normal. Thus, we have to calculate
%# d and we're set
d = -point*normal'; %'# dot product for less typing

%# create x,y
[xx,yy]=ndgrid(0:250:30000,-2000:250:2000);

%# calculate corresponding z
z = (-normal(1)*xx - normal(2)*yy - d)/normal(3);

%measurement plane (our world coord axes)
point = [0 0 0];
normal = [0 0 1];
d = -point*normal';

[xx2,yy2]=ndgrid(0:250:30000,-2000:250:2000);

%# calculate corresponding z
z2 = (-normal(1)*xx2 - normal(2)*yy2 - d)/normal(3);

%plot calibration points
calib_x = [0	199.5	233.5	340.5	440	640	1068	1221	340.5	640	440	233.5	199.5];
calib_y = [0	0	0	0	0	0	0	0	-223.5	-220	242	192	-352];
calib_z = [0	0	0	0	0	0	0	0	0	0	0	216	212.2];

%based on manually selected pixels
maxPnts = 99;
startPnt = 1;

%# plot the surface
figure
axis equal
h = gca;  % Handle to currently active axes
set(h, 'YDir', 'reverse');
hold on
surf(xx,yy,z,'FaceColor','b')
surf(xx2,yy2,z2,'FaceColor','g')
plot3(calib_x,calib_y,calib_z,'r+','LineWidth',2)
plot3(camOrigin(1),camOrigin(2),camOrigin(3),'yo','LineWidth',2)
plot3(positionsCars_x(:,startPnt:(startPnt+maxPnts-1)),positionsCars_y(:,startPnt:(startPnt+maxPnts-1)),zeros(maxCars,maxPnts),'yx','LineWidth',2)

for cars=1:maxCars
    for pnts=startPnt:(startPnt+maxPnts-1)
        plot3([camOrigin(1), positionsCars_x(cars,pnts)],[camOrigin(2), positionsCars_y(cars,pnts)],[camOrigin(3), positionsCars_z(cars,pnts)],'y','LineWidth',1);
    end
end
hold off
