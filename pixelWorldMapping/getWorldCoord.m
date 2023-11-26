function [intersect_p, o_p_vect] = ... 
    getWorldCoord(pixelCoord, PPMi, origin)
%GETWORLDCOORD Outputs intersection of pixel ray with road plane
%   inputs
%       pixelCoord: two element vector with pixel coordinates to be mapped
%       PPMi: pseudo inverse of PPM to perform mapping
%       origin: origin of camera for ray determination
%   outputs
%       intersect_p: intersection point world coordinates (z should be 0)
%       o_p_vect: unit vector from camera to intersection point
    pixelCoord = [pixelCoord, 1]; %acquired from pixel coord (u,v,1)
    
    %calculate one of the solutions to the equation yielding a 1x4 vector
    %pixel coord = PPM * world coord
    %world coord = PPMi * pixel coord
    worldCoord = PPMi*pixelCoord';
    
    %normalize for extra dimension
    worldCoord = worldCoord ./ worldCoord(4);
    
    %calculate unit vector of origin to test_p_w
    origin_to_point = worldCoord(1:3)-origin;
    origin_to_point_n = origin_to_point./norm(origin_to_point);
    
    %floor plane
    plane_norm = [0;0;1];
    plane_loc = [0;0;0];

    %adjust floor plane for centroid intersection, assuming scene's
    %280m length and approximate centroid height at that distance of 1m
    %which is 0.2deg about y, then rotating about the z axis 20deg
    ang1 = -0.2;
    %ang1 = 0;
    rotation1 = [cosd(ang1)   0   sind(ang1);
                 0            1          0;
                 -sind(ang1)  0   cosd(ang1)];
    %ang2 = -20;
    ang2 = 15;
    rotation2 = [cosd(ang2)  -sind(ang2)  0;
                 sind(ang2)   cosd(ang2)  0;
                 0            0           1];
    plane_norm_r1 = rotation1*plane_norm;
    plane_norm_r2 = rotation2*plane_norm_r1;
    plane_norm_f = plane_norm_r2;

    %calculate intersection point
    %equation to get intersection of vector+point and plane norm+point
    intersect_p = origin + (plane_loc-origin)'*plane_norm_f/ ...
        (plane_norm_f'*origin_to_point_n) * origin_to_point_n;

    %project intersection down to ground plane
    %intersect_p(3) = 0;

    %output vector
    o_p_vect = origin_to_point_n;

end

