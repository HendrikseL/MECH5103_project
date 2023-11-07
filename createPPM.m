function [PPM, PPMi, origin] = createPPM(pCoord,wCoord)
%CREATEPPM Calculate PPM, PPMi, and origin of camera using measurements
%   inputs
%       wCoord: vector of length 6 of world coordinate measurements
%       pCoord: corresponding pixel coordinates of same 6 measured points
%   outputs
%       PPM: projection matrix for mapping wCoord to pCoord
%       PPMi: pseudo inverse of PPM to map pCoord to wCoord
%       origin: origin of camera taking video

    nPpmPoints = 6;
    worldCoord_X = wCoord(1,1:nPpmPoints); 
    worldCoord_Y = wCoord(2,1:nPpmPoints);
    worldCoord_Z = wCoord(3,1:nPpmPoints);
    u1ppm = pCoord(1,1:nPpmPoints);
    v1ppm = pCoord(2,1:nPpmPoints);
    
    %build ai vectors
    ai_ppm = zeros(6,12);
    for i=1:nPpmPoints
        ai_ppm(i,:) = [worldCoord_X(i), worldCoord_Y(i), worldCoord_Z(i),... 
            1,0,0,0,0, -u1ppm(i)*worldCoord_X(i), -u1ppm(i)*worldCoord_Y(i),...
            -u1ppm(i)*worldCoord_Z(i), -u1ppm(i)];
    end
    
    %build bi vectors
    bi_ppm = zeros(6,12);
    for i=1:nPpmPoints
        bi_ppm(i,:) = [0,0,0,0, worldCoord_X(i), worldCoord_Y(i), ...
            worldCoord_Z(i), 1, -v1ppm(i)*worldCoord_X(i), ...
            -v1ppm(i)*worldCoord_Y(i), -v1ppm(i)*worldCoord_Z(i), -v1ppm(i)];
    end
    
    %assemble the A matrix
    A_ppm = [ai_ppm(1,:);
             bi_ppm(1,:);
             ai_ppm(2,:);
             bi_ppm(2,:);
             ai_ppm(3,:);
             bi_ppm(3,:);
             ai_ppm(4,:);
             bi_ppm(4,:);
             ai_ppm(5,:);
             bi_ppm(5,:);
             ai_ppm(6,:);
             bi_ppm(6,:)];
    
    %SVD of A matrix
    [~,~,VA] = svd(A_ppm);
    
    %build PPM matrix from last column of VA
    PPM = reshape(VA(:, end), [4, 3]);
    PPM = PPM.';
    
    PPM_123 = PPM(:,1:3);
    PPM_4 = PPM(:,4);
    
    %Acquire RQ decomposition using built in QR function
    ReverseRows = [0 0 1; 0 1 0 ; 1 0 0];
    [Q1, R1] = qr((ReverseRows*PPM_123)');
    
    R2 = ReverseRows * R1' * ReverseRows;
    Q2 = ReverseRows * Q1';
    
    %calculate origin using inverses of the rotation and intrinsic matrices
    origin = -Q2.' * inv(R2) * PPM_4;
    
    %calculate pseudo inverse of PPM
    PPMi = pinv(PPM);

end

