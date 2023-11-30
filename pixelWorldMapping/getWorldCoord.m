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
    
    %calculate intersection point
    plane_norm = [0;0;1];
    plane_loc = [0;0;0];
    
    %equation to get intersection of vector+point and plane norm+point
    intersect_p = origin + (plane_loc-origin)'*plane_norm/ ...
        (plane_norm'*origin_to_point_n) * origin_to_point_n;

    o_p_vect = origin_to_point_n;

end

