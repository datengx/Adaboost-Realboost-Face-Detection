load('value_face.mat');
load('value_nonface.mat');

num_features = size(value_face, 1);
num_face_imgs = size(value_face, 2);
num_nonface_imgs = size(value_nonface, 2);

classification = zeros(1,num_features);
for i = 1:num_features
    % Calculate mean value of the face of the current feature
    mu_face = mean(value_face(i, :));
    % Calculate mean value of the nonface of the current feature
    mu_nonface = mean(value_nonface(i,:));
    sigma_face = var(value_face(i, :));
    sigma_nonface = var(value_nonface(i, :));
    a = (sigma_face*mu_nonface - sigma_nonface*mu_face)/(sigma_face - sigma_nonface);
    b = (sigma_face*(mu_nonface^2) - sigma_nonface*(mu_face^2) - sigma_face*sigma_nonface*log(sigma_face/sigma_nonface))...
        / (sigma_face - sigma_nonface);
    x_1(i) = a + sqrt(a^2 - b);
    x_2(i) = a - sqrt(a^2 - b );
    
    [count_face, feature_value_face] = hist(value_face(i, :));
    [count_nonface, feature_value_nonface] = hist(value_nonface(i, :));
    
    num_bins = size(count_face, 2);
    
    % See which category of image has higher frequency to determine the
    % parity of the weak classifier
    pos_f_1 = min(find(feature_value_face > x_2(i)));
    pos_f_2 = max(find(feature_value_face < x_1(i)));
    pos_nf_1 = min(find(feature_value_nonface > x_2(i)));
    pos_nf_2 = max(find(feature_value_nonface < x_1(i)));
    
    pos_face = count_face(pos_f_1:pos_f_2);
    pos_nonface = count_nonface(pos_nf_1:pos_f_2);
    
    if (max(pos_face) > max(pos_nonface))
        % face distribution has higher peak
        classification(i) = 1; 
    else
        % nonface distribution has higher peak
        classification(i) = 0;
    end
end

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
beta_t = zeros(1, num_iters);
alpha_t = zeros(1, num_iters);
feature_selected_idx = zeros(1, num_iters);
roc_bin_size = 100;
roc_idx = 1;
tp_values = zeros(10,roc_bin_size);
fp_values = zeros(10,roc_bin_size);
for t = 1:num_iters
   normalize_factor = sum(w_f(t,:)) + sum(w_nf(t,:));
   % Normalize the weight so incorrectly classified objects will be put
   % more weight
   w_f(t,:) = w_f(t,:) / normalize_factor;
   w_nf(t,:) = w_nf(t,:) / normalize_factor;
   
   % Train the classifier and calculate the error
   errors = zeros(1,num_features);
   
   for f = 1:num_features
       h_f(f, value_face(f,:) > x_2(f) & value_face(f,:) < x_1(f)) = classification(f);
       h_f(f, value_face(f,:) <= x_2(f) | value_face(f,:) >= x_1(f)) = ~classification(f);
       % Calculate the error for all the face images
       errors(f) = errors(f) + sum(w_f(t,:) .* abs(h_f(f,:) - 1));
       
       h_nf(f, value_nonface(f,:) > x_2(f) & value_nonface(f,:) < x_1(f)) = classification(f);
       h_nf(f, value_nonface(f,:) <= x_2(f) | value_nonface(f,:) >= x_1(f)) = ~classification(f);
       % Calcualte the error for all the nonface images
       errors(f) = errors(f) + sum(w_nf(t,:) .* abs(h_nf(f,:)));
   end
   
   [errors_sorted, idx_sorted] = sort(errors);
   error_t(t) = errors_sorted(1);
   
   if t == 1 || t == 10 || t == 50 || t == 100
       figure;
       plot(errors_sorted(1:1000));
       pause(0.1);
   end
   
   % Keep track of the feature selected for each iteration
   % in order to calculate the value for testing image since
   % we need to know the threshold 
   feature_selected_idx(t) = idx_sorted(1);
   beta_t(t) = error_t(t)/(1-error_t(t));
   alpha_t(t) = log(1/beta_t(t));
   w_f(t+1,:) = w_f(t,:).*beta_t(t).^(h_f(idx_sorted(1),:)==1); % face, 1 if classified correctly
   w_nf(t+1,:) = w_nf(t,:).*beta_t(t).^(h_nf(idx_sorted(1),:)==0);% nonface, 
   h_t(t,:) = [h_f(idx_sorted(1),:), h_nf(idx_sorted(1),:)];
   fprintf('Finish processing the %dth iterations\n', t);
   % Plot the histograms of the positive and negative populations over F(x)
   % axis
   if (t == 10) || (t == 50) || (t == 100)
       fx = zeros(1,num_face_imgs + num_nonface_imgs);
       for kk = 1:t
          fx = fx + h_t(kk,:) * alpha_t(kk);
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
       set(gca,'fontsize',18);
        figure;
       [fq_all, v_all] = hist(fx, roc_bin_size);
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



