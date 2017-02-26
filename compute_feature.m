function [ value ] = compute_feature( img_integrated, idx_x,idx_y,sx,sy,type )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
if type == 1
    eIdx_x = idx_x + sx * 2 - 1;
    eIdx_y = idx_y + sy * 1 - 1;
    if eIdx_x <= 16 && eIdx_y <= 16
         middle = floor((idx_x + eIdx_x)/2);
         sum_left = img_integrated(eIdx_y+1,middle+1) + img_integrated(idx_y,idx_x) - img_integrated(eIdx_y+1,idx_x) - img_integrated(idx_y,middle+1);
         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) + img_integrated(idx_y,middle+1) - img_integrated(eIdx_y+1,middle+1) - img_integrated(idx_y,eIdx_x+1);

        value = sum_right - sum_left;
    end
end

if type == 2
    % Check if the current senario is outside the
    % boundary of the image
    eIdx_x = idx_x + sx * 1 - 1;
    eIdx_y = idx_y + sy * 2 - 1;
    if eIdx_x <= 16 && eIdx_y <= 16
         middle = floor((idx_y + eIdx_y)/2);
         sum_left = img_integrated(middle+1,eIdx_x+1) - img_integrated(middle+1,idx_x) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,idx_x);
         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(middle+1,eIdx_x+1) + img_integrated(middle+1,idx_x);

         value = sum_right - sum_left;
    end
end

if type == 3
    eIdx_x = idx_x + sx * 3 - 1;
    eIdx_y = idx_y + sy * 1 - 1;
    if eIdx_x <= 16 && eIdx_y <= 16
         temp = floor((2*idx_x+eIdx_x)/3);
         sum_left = img_integrated(eIdx_y+1,temp+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(idx_y,temp+1) + img_integrated(idx_y,idx_x);
         temp1 = floor((idx_x+2*eIdx_x)/3);
         sum_middle = img_integrated(eIdx_y+1,temp1+1) - img_integrated(eIdx_y+1,temp+1) - img_integrated(idx_y,temp1+1) + img_integrated(idx_y,temp+1);
         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,temp1+1) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,temp1+1);

         value = sum_middle - (sum_right + sum_left);
    end
end

if type == 4
    eIdx_x = idx_x + sx * 1 - 1;
    eIdx_y = idx_y + sy * 3 - 1;
    if eIdx_x <= 16 && eIdx_y <= 16
         temp = floor((2*idx_y+eIdx_y)/3);
         sum_left = img_integrated(temp+1,eIdx_x+1) - img_integrated(temp+1,idx_x) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,idx_x);
         temp1 = floor((idx_y+2*eIdx_y)/3);
         sum_middle = img_integrated(temp1+1,eIdx_x+1) - img_integrated(temp1+1,idx_x) - img_integrated(temp+1,eIdx_x+1) + img_integrated(temp+1,idx_x);
         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(temp1+1,eIdx_x+1) + img_integrated(temp1+1,idx_x);

         value = sum_middle - (sum_right + sum_left);
    end
end

if type == 5
    eIdx_x = idx_x + sx * 2 - 1;
    eIdx_y = idx_y + sy * 2 - 1;
    if eIdx_x <= 16 && eIdx_y <= 16
         temp = floor((idx_x + eIdx_x)/2);
         temp1 = floor((idx_y + eIdx_y)/2);
         sum_topleft = img_integrated(temp1+1,temp+1) - img_integrated(temp1+1,idx_x) - img_integrated(idx_y,temp+1) + img_integrated(idx_y,idx_x);

         sum_topright = img_integrated(temp1+1,eIdx_x+1) - img_integrated(temp1+1,temp+1) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,temp+1);

         sum_bottomleft = img_integrated(eIdx_y+1,temp+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(temp1+1,temp+1) + img_integrated(temp1+1,idx_x);

         sum_bottomright = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,temp+1) - img_integrated(temp1+1,eIdx_x+1) + img_integrated(temp1+1,temp+1);

         value = sum_topright + sum_bottomleft - sum_topleft - sum_bottomright;
    end
end

end

