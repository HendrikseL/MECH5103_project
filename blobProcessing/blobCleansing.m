%BLOBCLEANSING Delete any blobs that appear for less than the given
%threshold
%       Author: Vladislav Pripotnev
%       ID:300331564
%   inputs
%       thresh: detection number of frames required to be kept
%       car_in_u: u coordinate matrix of blobs input
%       car_in_v: v coordinate matrix of blobs input
%   outputs
%       car_out_u: u coordinates of remaining blobs
%       car_out_v: v coordinates of remaining blobs
function [car_out_u,car_out_v] = blobCleansing(car_in_u,car_in_v,thresh)
    minFramesDetected = thresh;
    for blobIter=1:size(car_in_u,1)
        detectedIndeces = find(car_in_u(blobIter,:)>=0);
        framesDetected = length(detectedIndeces);
        if framesDetected < minFramesDetected
            deleteBlob(blobIter) = true;
        else
            deleteBlob(blobIter) = false;
        end
    end
    
    for blobIter = length(deleteBlob):-1:1
        if deleteBlob(blobIter)
            car_in_u(blobIter,:) = [];
            car_in_v(blobIter,:) = [];
        end
    end

    car_out_u = car_in_u;
    car_out_v = car_in_v;
end

