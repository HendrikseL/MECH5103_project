%{
    Author: Paul Cormier
    ID:101065035

    This function will identify and catalog blobs from a binary image
    matrix
%}

function [output_u,output_v] = blobAnalysis(input)
    
    hBlob = vision.BlobAnalysis('AreaOutputPort',false,'BoundingBoxOutputPort',false);

    output_u = ones([100,1]).*-1;
    output_v = ones([100,1]).*-1;

    input = medfilt2(input);
    centroid = hBlob(input);
    for i = 1:1:size(centroid,1)
        output_u(i) = centroid(i,1);
        output_v(i) = centroid(i,2);
    end
end

