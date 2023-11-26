
%floor plane
plane_norm = [0;0;1];
plane_loc = [0;0;0];

%adjust floor plane for centroid intersection, assuming scene's
%280m length and approximate centroid height at that distance of 1m
%which is 0.2deg about y, then rotating about the z axis 20deg
ang1 = -0.2;
rotation1 = [cosd(ang1)   0   sind(ang1);
             0            1          0;
             -sind(ang1)  0   cosd(ang1)];
ang2 = 15;
rotation2 = [cosd(ang2)  -sind(ang2)  0;
             sind(ang2)   cosd(ang2)  0;
             0            0           1];
plane_norm_r1 = rotation1*plane_norm;
plane_norm_r2 = rotation2*plane_norm_r1;
plane_norm_f = plane_norm_r2;

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

%plot ground
point = [0 0 0];
normal = [0 0 1];

[xx2,yy2]=ndgrid(0:250:30000,-2000:250:2000);

%# calculate corresponding z
z2 = (-normal(1)*xx2 - normal(2)*yy2 - d)/normal(3);

%plot calibration points
calib_x = [0	208.5	279.5	357.5	549.5	733.5	1227.5	357.5	733.5	549.5	279.5	208.5];
calib_y = [0	0	0	0	0	0	0	-237.5	-221	231	176	-367];
calib_z = [0	0	0	0	0	0	0	0	0	0	215.19	200.08];

maxPnts = 8;
startPnt = 1;

%# plot the surface
figure
axis equal
h = gca;  % Handle to currently active axes
set(h, 'YDir', 'reverse');
hold on
surf(xx,yy,z)
surf(xx2,yy2,z2)
plot3(calib_x,calib_y,calib_z,'r+','LineWidth',2)
plot3(camOrigin(1),camOrigin(2),camOrigin(3),'yo','LineWidth',2)
plot3(positionsCars_x(startPnt:(startPnt+maxPnts-1)),positionsCars_y(startPnt:(startPnt+maxPnts-1)),zeros(maxPnts),'yx','LineWidth',2)

for pnts=startPnt:(startPnt+maxPnts-1)
    plot3([camOrigin(1), positionsCars_x(pnts)],[camOrigin(2), positionsCars_y(pnts)],[camOrigin(3), positionsCars_z(pnts)],'y','LineWidth',1);
end
hold off

figure
imageMatrixScene = imread(sceneImage,'jpg');
imagesc(imageMatrixScene)
axis('equal')