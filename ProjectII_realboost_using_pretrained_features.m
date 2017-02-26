%% Realboost using pretrained features

load('adaboost_strong_classifier.mat');

%% Implement real adaboost algorithm

load('feature_f.mat');
load('feature_nf.mat');

% Import only the 100 features that you selected in adaboost
feature_f = feature_f(feature_selected_idx,:);
feature_nf = feature_nf(feature_selected_idx,:);
%% Implement real adaboost algorithm
flag_continuing = false;
if ~flag_continuing
start_iter = 1;
num_features = size(feature_f, 1);
num_face_imgs = size(feature_f, 2);
num_nonface_imgs = size(feature_nf, 2);

 

%% Come up with a real function representing the bins
num_bins = 40;
pt_bins = zeros(num_features,num_bins);
qt_bins = zeros(num_features,num_bins);
ht_bins = zeros(num_features,num_bins);
ht_bins_left_bound = zeros(1,num_bins);
ht_bins_right_bound = zeros(1,num_bins);
% Calculate the bin range
for i = 1:num_bins
    % every bin has a length of 10
    ht_bins_left_bound(i) = (i-num_bins/2-1)*10;
    ht_bins_right_bound(i) = ht_bins_left_bound(i) + 10;
end
% Put the range to infinity
ht_bins_left_bound(1) = -inf;
ht_bins_right_bound(end) = inf;
 
% Perform AdaBoosting to the weak classifier
num_iters = 100;
w_f = zeros(num_iters+1, num_face_imgs);
w_nf = zeros(num_iters+1, num_nonface_imgs);
% Initialize the weight for both face and nonface images
w_f(1,:) = 1/(2*num_face_imgs);
w_nf(1,:) = 1/(2*num_nonface_imgs);

 

 

h_f = zeros(num_features, num_face_imgs);
h_nf = zeros(num_features, num_nonface_imgs);
error_t = zeros(1, num_iters);
h_t = zeros(num_iters, num_face_imgs + num_nonface_imgs);
roc_bin_size = 100;
tp_values = zeros(10,roc_bin_size);
fp_values = zeros(10,roc_bin_size);
ht_bins_selected = zeros(num_iters,num_bins);
roc_idx = 1;
 

else
% Is continuing setup the place and parameters that you want to continue
start_iter = 14;

end

 

for t = start_iter:num_iters
   normalize_factor = sum(w_f(t,:)) + sum(w_nf(t,:));
   % Normalize the weight so incorrectly classified objects will be put
   % more weight
   w_f(t,:) = w_f(t,:) / normalize_factor;
   w_nf(t,:) = w_nf(t,:) / normalize_factor;
   
   % Train the classifier and calculate the error
   errors = zeros(1,num_features);
   tic
   for f = 1:num_features
       cur_fea_f = feature_f(f,:);
       cur_fea_nf = feature_nf(f,:);
       for b = 1:num_bins
          f_within_bin_idx = (cur_fea_f >= ht_bins_left_bound(b) & cur_fea_f < ht_bins_right_bound(b));
          nf_within_bin_idx = (cur_fea_nf >= ht_bins_left_bound(b) & cur_fea_nf < ht_bins_right_bound(b));
          pt_bins(f,b) = sum(w_f(t,:) .* f_within_bin_idx);
          qt_bins(f,b) = sum(w_nf(t,:) .* nf_within_bin_idx);
          % !! Make sure no division by 0 is happening
          if qt_bins(f,b) == 0
             if pt_bins(f,b) == 0
                ht_bins(f,b) = 0;
             else
                ht_bins(f,b) = 1;
             end
          elseif pt_bins(f,b)==0
              ht_bins(f,b) = 0;
          else  
             % Calculate the value for each of the bins
             ht_bins(f,b) = 0.5 * log(pt_bins(f,b)/qt_bins(f,b));
          end

         
          % Face images bin value
          h_f(f, f_within_bin_idx) = ht_bins(f,b);
          % non Face images bin value
          h_nf(f, nf_within_bin_idx) = ht_bins(f,b);
       end
       % Calculate the error
       % THE errors is the Z in the note
       errors(f) = 2 * sum( sqrt(pt_bins(f,:) .* qt_bins(f,:)) );
       if mod(f,1000) == 0
           fprintf('finish training %d samples\n', f);
       end
       if errors(f) == 0
           fprintf('Something is wrong');
       end
   end
   toc
   [errors_sorted, idx_sorted] = sort(errors);

   error_t(t) = errors_sorted(1);
   % Keep track of the feature selected for each iteration
   % in order to calculate the value for testing image since
   % we need to know the threshold 
   feature_selected_idx_rb(t) = feature_selected_idx(idx_sorted(1));
   ht_bins_selected(t,:) = ht_bins(idx_sorted(1),:);
   % Update the weights for the next iteration
   w_f(t+1,:) = 1/error_t(t) * (w_f(t,:) .* exp( -1 * h_f(idx_sorted(1),:)));
   w_nf(t+1,:) = 1/error_t(t) * (w_nf(t,:) .* exp( h_nf(idx_sorted(1),:)));

   
   h_t(t,:) = [h_f(idx_sorted(1),:), h_nf(idx_sorted(1),:)];
   fprintf('Finish processing the %dth iterations\n', t);
   % Plot the histograms of the positive and negative populations over F(x)

   % axis
   if (t == 10) || (t == 50) || (t == 100)
       fx = zeros(1,num_face_imgs + num_nonface_imgs);
       for kk = 1:t
          fx = fx + h_t(kk,:);
       end
       figure;
       % histogram for positive population
       histogram(fx(1:num_face_imgs), 100);
       hold on;
       % histogram for negative population
       histogram(fx( (num_face_imgs+1):(num_face_imgs+num_nonface_imgs)), 100);
       legend('face', 'non-face');
       str = sprintf('Histogram of +/- population over F(x) axis at T=%d.',t);
       title(str);
       xlabel('F(x)');

       
       figure;
       [fq_all, v_all] = hist(fx, roc_bin_size);
%        [fq_f,v_f] = hist(fx(1:num_face_imgs), roc_bin_size);
%        [fq_nf,v_nf] = hist(fx((num_face_imgs+1):(num_face_imgs+num_nonface_imgs)), roc_bin_size);
       % Create ROC curve
       for cc=1:roc_bin_size
           pos_cnt_left = sum(fx(1:num_face_imgs)<v_all(cc));
           neg_cnt_left = sum(fx(num_face_imgs+1:num_face_imgs+num_nonface_imgs)<v_all(cc));
           pos_cnt_right = num_face_imgs - pos_cnt_left;
           neg_cnt_right = num_nonface_imgs - neg_cnt_left;

          
           fp_values(roc_idx,cc) = pos_cnt_left/(pos_cnt_left + neg_cnt_left);
           tp_values(roc_idx,cc) = pos_cnt_right/(pos_cnt_right + neg_cnt_right);
       end
       plot(fp_values(roc_idx,:), tp_values(roc_idx,:),'LineWidth',2);
       str = sprintf('ROC curve of histogram at T=%d.',t);
       set(gca,'fontsize',18);
       xlabel('false positive');
       ylabel('true positive');
       title(str);
       roc_idx = roc_idx + 1;

   end

   

end