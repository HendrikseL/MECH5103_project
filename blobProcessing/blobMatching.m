%BLOBMATCHING Goes through blob pixel coordinates and matches them from one
%frame to the next
%       Author: Vladislav Pripotnev
%       ID:300331564
%   inputs
%       car_pixel_u: u coordinate matrix of blobs
%       car_pixel_v: v coordinate matrix of blobs
%   outputs
%       car_pixel_u_f: matched u coordinate matrix of blobs
%       car_pixel_v_f: matched v coordinate matrix of blobs
function [car_pixel_u_f, car_pixel_v_f] = blobMatching(car_pixel_u, car_pixel_v)
    frameCount = size(car_pixel_u,2);
    numBlobsPrev = 0;
    numBlobs = 0;
    uniqueBlobCnt = 0;
    moveThresh = 100;
    car_pixel_u_f = -ones(800,frameCount);
    car_pixel_v_f = -ones(800,frameCount);

    for frameIter = 1:frameCount
        %init frame variables
        matchCntBest = 0;
        bestMatch = [];
        u_vec = car_pixel_u(:,frameIter);
        v_vec = car_pixel_v(:,frameIter);
        if (frameIter > 1)
            u_vec_prev = car_pixel_u(:,frameIter-1);
            v_vec_prev = car_pixel_v(:,frameIter-1);
        end
        
        %get blob count in this frame
        for blobIter = 1:length(u_vec)
            if u_vec(blobIter) == -1
                break
            end
        end
        numBlobsPrev = numBlobs;
        numBlobs = blobIter - 1;
        
        %frame has no blobs
        if numBlobs == 0
            continue
        %previous frame has no blobs, current ones are new
        elseif numBlobsPrev == 0
            for blobIter = 1:numBlobs
                uniqueBlobCnt = uniqueBlobCnt+1;
                car_pixel_u_f(uniqueBlobCnt,frameIter) = u_vec(blobIter);
                car_pixel_v_f(uniqueBlobCnt,frameIter) = v_vec(blobIter);
            end
        %have to match prev to curr frame blobs
        else
            %loop through all combinations of blob distances
            for currIter = 1:numBlobs
                matchCntCurr = 0;
                matchCurr =[];
                for prevIter = 1:numBlobsPrev
                    u_diff = u_vec(currIter) - u_vec_prev(prevIter);
                    v_diff = v_vec(currIter) - v_vec_prev(prevIter);
                    pixelDist = sqrt(u_diff^2+v_diff^2);
                    
                    %if distance is below threshold save as potential match
                    if (pixelDist < moveThresh)
                       absDiffMin = pixelDist;
                       matchCntCurr = matchCntCurr+1;
                       matchCurr(:,matchCntCurr) = [prevIter; currIter; absDiffMin];
                    end
                end
                
                %blob(currIter) is a new blob, continue match finding
                if isempty(matchCurr)
                    continue
                %find smallest diff and save that match
                else
                    [~, idx] = min(matchCurr(3,:));
                    matchCntBest = matchCntBest+1;
                    bestMatch(:,matchCntBest) = matchCurr(1:2,idx);
                end
            end

            %go through current blobs and assign if matched
            for blobIter = 1:numBlobs
                %prev and curr frame has blobs but don't match
                if isempty(bestMatch)
                    newBlob = true;
                %some blobs were matched
                else
                    [~, col] = find(bestMatch(2,:)==blobIter);
                    %curr blob is not one of the matches
                    if isempty(col)
                        newBlob = true;
                    else
                        newBlob = false;
                    end
                end
                %create new blob entry if newBlob flag is true
                if newBlob
                    uniqueBlobCnt = uniqueBlobCnt+1;
                    car_pixel_u_f(uniqueBlobCnt,frameIter) = u_vec(blobIter);
                    car_pixel_v_f(uniqueBlobCnt,frameIter) = v_vec(blobIter);
                %curr blob was matched, add to known blob
                else
                    %find the blob it's associated with
                    [blobId, ~] = find(car_pixel_u_f(:,frameIter-1)==u_vec_prev(bestMatch(1,col)));
                    car_pixel_u_f(blobId, frameIter) = u_vec(blobIter);
                    car_pixel_v_f(blobId, frameIter) = v_vec(blobIter);
                end
            end
        end
    end
end

