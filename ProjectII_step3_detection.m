%% Project II face detection using RealBoost

% Load the realboost strong classifier
load('realboost_strong_classifier.mat');
load('realboost_feature_selected.mat');

current_dir = pwd;
img_test_filename = sprintf('Test_Image_%d.jpg',1);
first_img = imread(strcat(current_dir,'\Test_and_background_Images\', img_test_filename));
h = size(first_img,1);
w = size(first_img,2);
first_img = rgb2gray(first_img);
num_test_img = 2;
img_test_array = zeros(h,w,num_test_img);
img_test_array(:,:,1) = first_img;
[feature_selected_idx_rb_sorted, idx_sorted] = sort(feature_selected_idx_rb);
ht_bins_selected_sorted = ht_bins_selected(idx_sorted,:);
ht_bins_selected_sorted(ht_bins_selected_sorted==-inf) = 0;
num_features = length(feature_selected_idx_rb);
num_bins = size(ht_bins_selected_sorted,2);

for i = 2:num_test_img
    img_test_filename = sprintf('Test_Image_%d.jpg',i);
    img_test_array(:,:,i) = rgb2gray(imread(strcat(current_dir,'\Test_and_background_Images\', img_test_filename)));
    
end

for i = 1:1
    img_test_array_resized = imresize(img_test_array(:,:,i),0.10);
    h_resize = size(img_test_array_resized,1);
    w_resize = size(img_test_array_resized,2);
    energy_img = zeros(h_resize,w_resize);
    for x = 1:w_resize-16+1
        for y = 1:h_resize-16+1
              patch = imcrop(img_test_array_resized,[x,y,15,15]);
              p_int = integralImage(patch);
              % Compute the fx value for this patch
              fx = 0;
              for f = 1:num_features
                 f_val = compute_feature(p_int,x_selected(f),y_selected(f),sx_selected(f),sy_selected(f),type_selected(f));
                 
                 for b = 1:num_bins
                     if f_val >= ht_bins_left_bound(b) && f_val < ht_bins_right_bound(b)
                         fx = fx + ht_bins_selected_sorted(f,b); 
                     end
                 end
              end
              energy_img(y,x) = fx;
        end
        fprintf('Done %d row\n',x);
    end
end

disp('Done');
