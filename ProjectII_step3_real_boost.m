%% Implement real adaboost algorithm


load('feature_f.mat');
load('feature_nf.mat');

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
feature_selected_idx = zeros(1, num_iters);

for t = 1:num_iters
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
          % Calculate the value for each of the bins
          ht_bins(f,b) = 0.5 * log(pt_bins(f,b)/qt_bins(f,b));
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
   end
   toc
   [errors_sorted, idx_sorted] = sort(errors);
   error_t(t) = errors_sorted(1);
   % Keep track of the feature selected for each iteration
   % in order to calculate the value for testing image since
   % we need to know the threshold 
   feature_selected_idx(t) = idx_sorted(1);
   % Update the weights for the next iteration
   w_f(t+1,:) = 1/error_t(t) * (w_f(t,:) .* exp( -1 * h_f(idx_sorted(1),:)));
   w_nf(t+1,:) = 1/error_t(t) * (w_nf(t,:) .* exp( h_nf(idx_sorted(1),:)));
   
   h_t(t,:) = [h_f(idx_sorted(1),:), h_nf(idx_sorted(1),:)];
   fprintf('Finish processing the %dth iterations\n', t);
   % Plot the histograms of the positive and negative populations over F(x)
   % axis
   if (t < 10) || (t == 50) || (t == 100)
       fx = zeros(1,num_face_imgs + num_nonface_imgs);
       for kk = 1:t
          fx = fx + h_t(kk,:);
       end
       figure(t);
       % histogram for positive population
       histogram(fx(1:num_face_imgs), 100);
       hold on;
       % histogram for negative population
       histogram(fx( (num_face_imgs+1):(num_face_imgs+num_nonface_imgs)), 100);
   end
end