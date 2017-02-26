function [ output_args ] = display_feature( img,idx_x,idx_y,sx,sy,type )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
if type == 1
    eIdx_x = idx_x + sx * 2 - 1;
    eIdx_y = idx_y + sy * 1 - 1;
    if eIdx_x <= 16 && eIdx_y <= 16
         middle = floor((idx_x + eIdx_x)/2);
         img(idx_y:eIdx_y,idx_x:middle)=0;
         img(idx_y:eIdx_y,middle+1:eIdx_x) = 255;
    end
    output_args = img;
end

if type == 2
    % Check if the current senario is outside the
    % boundary of the image
    eIdx_x = idx_x + sx * 1 - 1;
    eIdx_y = idx_y + sy * 2 - 1;
    if eIdx_x <= 16 && eIdx_y <= 16
         middle = floor((idx_y + eIdx_y)/2);
         img(idx_y:middle,idx_x:eIdx_x)=0;
         img(middle+1:eIdx_y,idx_x:eIdx_x) = 255;
    end
    output_args = img;
end

if type == 3
    eIdx_x = idx_x + sx * 3 - 1;
    eIdx_y = idx_y + sy * 1 - 1;
    if eIdx_x <= 16 && eIdx_y <= 16
         temp = floor((2*idx_x+eIdx_x)/3);
         img(idx_y:eIdx_y,idx_x:temp)=0;
         temp1 = floor((idx_x+2*eIdx_x)/3);
         img(idx_y:eidx_y,temp+1:temp1) = 255;
         img(idx_y:eidx_y,temp1+1:eIdx_x) = 255;
    end
    output_args = img;
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
         
         img(idx_y:temp1,idx_x:temp)=0;
         img(temp1+1:eIdx_y,temp+1:eIdx_x) = 0;
         img(idx_y:temp1,temp+1:eIdx_x)=255;
         img(temp1+1:eIdx_y,idx_x:temp)=255;
    end
    output_args = img;
end

end

