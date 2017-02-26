    %% CS231 - Project II Face detection by boosting techniques
% Name: Da Teng, ID: 804592061
FLAG_compute_features = true;
%% Loading images
% Assume the face data is placed under the same folder
current_dir = pwd;
load('realboost_strong_classifier.mat');
if FLAG_compute_features

% selected feature by adaboost/realboost algorithm, find their
% corresponding x,y,sx,xy,type
feature_selected_idx_rb = sort(feature_selected_idx_rb);
num_selected_features = length(feature_selected_idx_rb);
y_selected = zeros(num_selected_features,1);
x_selected = zeros(num_selected_features,1);
sx_selected = zeros(num_selected_features,1);
sy_selected = zeros(num_selected_features,1);
type_selected = zeros(num_selected_features,1);
    
    
% Create features for the face image
for i = 1:1
    img_filename = sprintf('face16_%06d.bmp', i);
    img_filefullpath = strcat(current_dir, '/newface16/', img_filename);
    img_gray = rgb2gray(imread(img_filefullpath)); % Convert to grayscale image
    % Compute integrated images to ease the computation later
    img_integrated = integralImage(img_gray);
    cnt = 1;
    selected_cnt = 1;
    last_selected = -1;
    %% ----------------
    % *-*-*
    % | |*|  first type of feature 1x2
    % *-*-*
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 2 - 1;
                    eIdx_y = idx_y + sy * 1 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         middle = floor((idx_x + eIdx_x)/2);
                         sum_left = img_integrated(eIdx_y+1,middle+1) + img_integrated(idx_y,idx_x) - img_integrated(eIdx_y+1,idx_x) - img_integrated(idx_y,middle+1);
                         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) + img_integrated(idx_y,middle+1) - img_integrated(eIdx_y+1,middle+1) - img_integrated(idx_y,eIdx_x+1);
                         feature_f(cnt, i) = sum_right - sum_left;
                         if cnt == feature_selected_idx_rb(selected_cnt)
                             y_selected(selected_cnt) = idx_y;
                             x_selected(selected_cnt) = idx_x;
                             sx_selected(selected_cnt) = sx;
                             sy_selected(selected_cnt) = sy;
                             type_selected(selected_cnt) = 1;
                             selected_cnt = selected_cnt + 1;
                             last_selected = feature_selected_idx_rb(selected_cnt-1);
                             while last_selected == feature_selected_idx_rb(selected_cnt-1)
                                 y_selected(selected_cnt) = idx_y;
                                 x_selected(selected_cnt) = idx_x;
                                 sx_selected(selected_cnt) = sx;
                                 sy_selected(selected_cnt) = sy;
                                 type_selected(selected_cnt) = 1;
                                 selected_cnt = selected_cnt + 1;
                             end
                         end
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end                
    
    
    %% -----------------
    % *-*
    % | |  second type of feature 2x1
    % *-*
    % |*|
    % *-*
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 1 - 1;
                    eIdx_y = idx_y + sy * 2 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         middle = floor((idx_y + eIdx_y)/2);
                         sum_left = img_integrated(middle+1,eIdx_x+1) - img_integrated(middle+1,idx_x) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,idx_x);
                         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(middle+1,eIdx_x+1) + img_integrated(middle+1,idx_x);
                         if cnt == 15697
                            disp('here'); 
                         end
                         feature_f(cnt, i) = sum_right - sum_left;
                         if cnt == feature_selected_idx_rb(selected_cnt)
                             y_selected(selected_cnt) = idx_y;
                             x_selected(selected_cnt) = idx_x;
                             sx_selected(selected_cnt) = sx;
                             sy_selected(selected_cnt) = sy;
                             type_selected(selected_cnt) = 2;
                             selected_cnt = selected_cnt + 1;
                             last_selected = feature_selected_idx_rb(selected_cnt-1);
                             while last_selected == feature_selected_idx_rb(selected_cnt-1)
                                 y_selected(selected_cnt) = idx_y;
                                 x_selected(selected_cnt) = idx_x;
                                 sx_selected(selected_cnt) = sx;
                                 sy_selected(selected_cnt) = sy;
                                 type_selected(selected_cnt) = 2;
                                 selected_cnt = selected_cnt + 1;
                             end
                         end
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end
    %% -----------------
    % *-*-*-*
    % | |*| | third type of feature 1x3
    % *-*-*-*
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 3 - 1;
                    eIdx_y = idx_y + sy * 1 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         temp = floor((2*idx_x+eIdx_x)/3);
                         sum_left = img_integrated(eIdx_y+1,temp+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(idx_y,temp+1) + img_integrated(idx_y,idx_x);
                         temp1 = floor((idx_x+2*eIdx_x)/3);
                         sum_middle = img_integrated(eIdx_y+1,temp1+1) - img_integrated(eIdx_y+1,temp+1) - img_integrated(idx_y,temp1+1) + img_integrated(idx_y,temp+1);
                         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,temp1+1) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,temp1+1);
                         feature_f(cnt, i) = sum_middle - (sum_right + sum_left);
                         if cnt == feature_selected_idx_rb(selected_cnt)
                             y_selected(selected_cnt) = idx_y;
                             x_selected(selected_cnt) = idx_x;
                             sx_selected(selected_cnt) = sx;
                             sy_selected(selected_cnt) = sy;
                             type_selected(selected_cnt) = 3;
                             selected_cnt = selected_cnt + 1;
                             last_selected = feature_selected_idx_rb(selected_cnt-1);
                             while last_selected == feature_selected_idx_rb(selected_cnt-1)
                                 y_selected(selected_cnt) = idx_y;
                                 x_selected(selected_cnt) = idx_x;
                                 sx_selected(selected_cnt) = sx;
                                 sy_selected(selected_cnt) = sy;
                                 type_selected(selected_cnt) = 3;
                                 selected_cnt = selected_cnt + 1;
                             end
                         end
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end 
   
    %% -----------------
    % *-*
    % | |  
    % *-* The fourth features
    % |*|
    % *-*
    % | |
    % *-* %% -----------------
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 1 - 1;
                    eIdx_y = idx_y + sy * 3 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         temp = floor((2*idx_y+eIdx_y)/3);
                         sum_left = img_integrated(temp+1,eIdx_x+1) - img_integrated(temp+1,idx_x) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,idx_x);
                         temp1 = floor((idx_y+2*eIdx_y)/3);
                         sum_middle = img_integrated(temp1+1,eIdx_x+1) - img_integrated(temp1+1,idx_x) - img_integrated(temp+1,eIdx_x+1) + img_integrated(temp+1,idx_x);
                         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(temp1+1,eIdx_x+1) + img_integrated(temp1+1,idx_x);
                         if cnt == 15762
                            disp('here'); 
                         end
                         feature_f(cnt, i) = sum_middle - (sum_right + sum_left);
                         if cnt == feature_selected_idx_rb(selected_cnt)
                             y_selected(selected_cnt) = idx_y;
                             x_selected(selected_cnt) = idx_x;
                             sx_selected(selected_cnt) = sx;
                             sy_selected(selected_cnt) = sy;
                             type_selected(selected_cnt) = 4;
                             selected_cnt = selected_cnt + 1;
                             last_selected = feature_selected_idx_rb(selected_cnt-1);
                             while last_selected == feature_selected_idx_rb(selected_cnt-1)
                                 y_selected(selected_cnt) = idx_y;
                                 x_selected(selected_cnt) = idx_x;
                                 sx_selected(selected_cnt) = sx;
                                 sy_selected(selected_cnt) = sy;
                                 type_selected(selected_cnt) = 4;
                                 selected_cnt = selected_cnt + 1;
                             end
                         end
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end 
    %% -----------------
    % *-*-*
    % | |*| 
    % *-*-*
    % |*| |
    % *-*-*
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 2 - 1;
                    eIdx_y = idx_y + sy * 2 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         temp = floor((idx_x + eIdx_x)/2);
                         temp1 = floor((idx_y + eIdx_y)/2);
                         sum_topleft = img_integrated(temp1+1,temp+1) - img_integrated(temp1+1,idx_x) - img_integrated(idx_y,temp+1) + img_integrated(idx_y,idx_x);
                         
                         sum_topright = img_integrated(temp1+1,eIdx_x+1) - img_integrated(temp1+1,temp+1) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,temp+1);
                         
                         sum_bottomleft = img_integrated(eIdx_y+1,temp+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(temp1+1,temp+1) + img_integrated(temp1+1,idx_x);
                         
                         sum_bottomright = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,temp+1) - img_integrated(temp1+1,eIdx_x+1) + img_integrated(temp1+1,temp+1);
                         
                         feature_f(cnt, i) = sum_topright + sum_bottomleft - sum_topleft - sum_bottomright;
                         if cnt == feature_selected_idx_rb(selected_cnt)
                             y_selected(selected_cnt) = idx_y;
                             x_selected(selected_cnt) = idx_x;
                             sx_selected(selected_cnt) = sx;
                             sy_selected(selected_cnt) = sy;
                             type_selected(selected_cnt) = 5;
                             selected_cnt = selected_cnt + 1;
                             last_selected = feature_selected_idx_rb(selected_cnt-1);
                             while last_selected == feature_selected_idx_rb(selected_cnt-1)
                                 y_selected(selected_cnt) = idx_y;
                                 x_selected(selected_cnt) = idx_x;
                                 sx_selected(selected_cnt) = sx;
                                 sy_selected(selected_cnt) = sy;
                                 type_selected(selected_cnt) = 5;
                                 selected_cnt = selected_cnt + 1;
                             end
                         end
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end 
    if mod(i,100) == 0
        str = sprintf('Finish generating the %d th image feature', i);
        disp(str);
    end
end

% Create features for the face image
for i = 1:1000
    img_filename = sprintf('nonface16_%06d.bmp', i);
    img_filefullpath = strcat(current_dir, '/nonface16/', img_filename);
    img_gray = rgb2gray(imread(img_filefullpath)); % Convert to grayscale image
    % Compute integrated images to ease the computation later
    img_integrated = integralImage(img_gray);
    cnt = 1;
    %% ----------------
    % *-*-*
    % | |*|  first type of feature 1x2
    % *-*-*
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 2 - 1;
                    eIdx_y = idx_y + sy * 1 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         middle = floor((idx_x + eIdx_x)/2);
                         sum_left = img_integrated(eIdx_y+1,middle+1) + img_integrated(idx_y,idx_x) - img_integrated(eIdx_y+1,idx_x) - img_integrated(idx_y,middle+1);
                         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) + img_integrated(idx_y,middle+1) - img_integrated(eIdx_y+1,middle+1) - img_integrated(idx_y,eIdx_x+1);
                         
                         feature_nf(cnt, i) = sum_right - sum_left;
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end                
    
    
    %% -----------------
    % *-*
    % | |  second type of feature 2x1
    % *-*
    % |*|
    % *-*
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 1 - 1;
                    eIdx_y = idx_y + sy * 2 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         middle = floor((idx_y + eIdx_y)/2);
                         sum_left = img_integrated(middle+1,eIdx_x+1) - img_integrated(middle+1,idx_x) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,idx_x);
                         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(middle+1,eIdx_x+1) + img_integrated(middle+1,idx_x);
                         
                         feature_nf(cnt, i) = sum_right - sum_left;
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end 
    %% -----------------
    % *-*-*-*
    % | |*| | third type of feature 1x3
    % *-*-*-*
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 3 - 1;
                    eIdx_y = idx_y + sy * 1 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         temp = floor((2*idx_x+eIdx_x)/3);
                         sum_left = img_integrated(eIdx_y+1,temp+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(idx_y,temp+1) + img_integrated(idx_y,idx_x);
                         temp1 = floor((idx_x+2*eIdx_x)/3);
                         sum_middle = img_integrated(eIdx_y+1,temp1+1) - img_integrated(eIdx_y+1,temp+1) - img_integrated(idx_y,temp1+1) + img_integrated(idx_y,temp+1);
                         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,temp1+1) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,temp1+1);
                         
                         feature_nf(cnt, i) = sum_middle - (sum_right + sum_left);
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end 
   
    %% -----------------
    % *-*
    % | |  
    % *-* The fourth features
    % |*|
    % *-*
    % | |
    % *-* %% -----------------
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 1 - 1;
                    eIdx_y = idx_y + sy * 3 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         temp = floor((2*idx_y+eIdx_y)/3);
                         sum_left = img_integrated(temp+1,eIdx_x+1) - img_integrated(temp+1,idx_x) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,idx_x);
                         temp1 = floor((idx_y+2*eIdx_y)/3);
                         sum_middle = img_integrated(temp1+1,eIdx_x+1) - img_integrated(temp1+1,idx_x) - img_integrated(temp+1,eIdx_x+1) + img_integrated(temp+1,idx_x);
                         sum_right = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(temp1+1,eIdx_x+1) + img_integrated(temp1+1,idx_x);
                         
                         feature_nf(cnt, i) = sum_middle - (sum_right + sum_left);
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end 
    %% -----------------
    % *-*-*
    % | |*| 
    % *-*-*
    % |*| |
    % *-*-*
    for sx = 1:16
        for sy = 1:16
            for idx_x = 1:16
                for idx_y = 1:16
                    % Check if the current senario is outside the
                    % boundary of the image
                    eIdx_x = idx_x + sx * 2 - 1;
                    eIdx_y = idx_y + sy * 2 - 1;
                    if eIdx_x <= 16 && eIdx_y <= 16
                         temp = floor((idx_x + eIdx_x)/2);
                         temp1 = floor((idx_y + eIdx_y)/2);
                         sum_topleft = img_integrated(temp1+1,temp+1) - img_integrated(temp1+1,idx_x) - img_integrated(idx_y,temp+1) + img_integrated(idx_y,idx_x);
                         
                         sum_topright = img_integrated(temp1+1,eIdx_x+1) - img_integrated(temp1+1,temp+1) - img_integrated(idx_y,eIdx_x+1) + img_integrated(idx_y,temp+1);
                         
                         sum_bottomleft = img_integrated(eIdx_y+1,temp+1) - img_integrated(eIdx_y+1,idx_x) - img_integrated(temp1+1,temp+1) + img_integrated(temp1+1,idx_x);
                         
                         sum_bottomright = img_integrated(eIdx_y+1,eIdx_x+1) - img_integrated(eIdx_y+1,temp+1) - img_integrated(temp1+1,eIdx_x+1) + img_integrated(temp1+1,temp+1);
                         
                         feature_nf(cnt, i) = sum_topright + sum_bottomleft - sum_topleft - sum_bottomright;
                         cnt = cnt + 1;
                    end
                end
            end
        end
    end 
    if mod(i,100) == 0
        str = sprintf('Finish generating the %d th non-image feature', i);
        disp(str);
    end
end


end





