%% Use to display 10 best features
img_filename = sprintf('face16_%06d.bmp', 1);
img_filefullpath = strcat(current_dir, '/newface16/', img_filename);
img_gray = rgb2gray(imread(img_filefullpath)); % Convert to grayscale image

load('adaboost_strong_classifier.mat');

x = [8 4 4 3 8 6 9 1 7 6];
y = [4 2 8 6 3 13 8 15 2 6];
sx = [2 10 5 3 2 6 4 1 1 10];
sy = [3 2 4 1 7 1 1 2 5 1];
type = [1 2 5 2 2 2 1 1 1 2];

figure
for i = 1:10
    subplot(2,5,i);
    imshow(display_feature(img_gray,x(i),y(i),sx(i),sy(i),type(i)),[]);
end