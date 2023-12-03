%{
    Author: Paul Cormier
    ID:101065035

    This function will identify and catalog blobs from a binary image
    matrix
%}

function [output_u,output_v] = blobAnalysis(input)

    %Init variables and pad image
    height = size(input, 1);
    width = size(input, 2);
    im = double(padarray(input,[1 1],0,'both'));
    tag = 1;
    dict = dictionary(NaN,0);
    x = [];
    y = [];
    output_u = ones(100,1).*-1;
    output_v = ones(100,1).*-1;

    %First Pass
    for row = 2:height+1
        for col = 2:width+1
            if im(row,col) == 1
                %Get neighboring pixels: 8-connectivity representation
                neighbors =  [im(row,col-1),im(row-1,col-1),im(row-1,col),im(row-1,col+1)];
    
                %New component condition 
                if nnz(neighbors) ==0
                    %Set current pixel to new tag
                    im(row,col) = tag;
                    tag = tag + 1;

                %One neighbor condition 
                elseif nnz(neighbors) == 1
                    %Set current pixel to neighbor tag
                    index = find(neighbors);
                    im(row,col) = neighbors(index);

                %Multiple neighbors condition
                else
                    %Set current pixel to lowest neighbor tag
                    index = find(neighbors);
                    l_val = min(neighbors(index));
                    im(row,col) = l_val;

                    %Add equivalency to dictionary
                    for k = 1:length(index)
                        l_key = neighbors(index(k));

                        if l_key ~= l_val
                            dict(l_key) = l_val;
                        end
                    end
                end
            end
        end
    end

    %Restructure Dictionary
    for k = flip(keys(dict))'
        v = dict(k);
        while isKey(dict,v)
            v = dict(v);
        end
        dict(k) = v;
    end

    %Remove Padding
    im = im(2:height +1, 2:width+1);

    %Second Pass
    for row = 1:height
        for col = 1:width
            if isKey(dict,im(row,col))
                im(row,col) = dict(im(row,col));
            end
        end
    end
    
    %Identify Corners
    for blob = unique(im)'
        if blob ~= 0 && nnz(im==blob)>= 250
            [row, col] = find(im == blob);
            x = [x; min(col)];
            y = [y; max(row)];
        end
    end
    output_u(1:length(x)) = x;
    output_v(1:length(y)) = y;
end