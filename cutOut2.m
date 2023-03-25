function [z, indexCutOut, indexOriginal] = cutOut2(v, ivAlign, i0, i1)
% v is vector of data to cut out
% ivAlign is where in v to cut out
% i0 and i1 are range to cutout relative to ivAlign
% i0 = 1  i1 = 4  cuts out 1 sample AFTER ivAlign to 4 samples AFTER ivALign
% i0 = -1  i1 = 4  cuts out 1 sample BEFORE ivAlign to 4 samples AFTER ivALign
% i0 = -4  i1 = -1  cuts out 4 samples BEFORE ivAlign to 1 sample BEFORE ivALign
%
% Example
% x = [1 2 3 4 5 6 7];
% y = cutOut2(x,4,-10,2)
% returns
% y = NaN   NaN   NaN   NaN   NaN   NaN   NaN     1     2     3     4     5     6

    if i0 > i1
        error('i0 > i1');
    end
    Lv = length(v);
    Lz = length(i0:i1);
    if size(v,1) == 1
        z = nan(1, Lz);
    else
        z = nan(Lz, 1);
    end

    iv0 = ivAlign + i0;
    iv1 = ivAlign + i1;
     
    %disp(['Before   Lz = ' int2str(Lz) '   iv0 = ' int2str(iv0) '   iv1 = ' int2str(iv1)]);
    
    if iv0 < 1 && iv1 < 1
        return;
    elseif iv0 > Lv && iv1 > Lv
        return;
    end
    iz0 = 1;
    if iv0 < 1
        % shift left indexes to the right
        % shift amount is 1 - iv0
        iz0 = iz0 + (1 - iv0);
        iv0 = 1;
    end
    iz1 = Lz;
    if iv1 > Lv
        % shift right indexes to the left
        % shift amount is iv1 - Lv
        iz1 = iz1 - (iv1 - Lv);
        iv1 = Lv; 
    end
    try 
        z(iz0 : iz1) = v(iv0 : iv1);
    catch
        Lz
        Lv
        iz0
        iz1
        iv0
        iv1
        error('Bad indexing in cutOut2');
    end
    if nargout > 1
        indexCutOut = iv0 : iv1;
    end
    if nargout > 2
        indexOriginal = iz0 : iz1;
    end
    
        
end