im1_a=imread('/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_7_2_20221017/Atomo_7_2_183-20221017-183711.xry/D1.tif');
im1_b=imread('/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_7_2_20221017/Atomo_7_2_193-20221017-184613.xry/D1.tif');


im2_a=imread('/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_7_2_20221017/Atomo_7_2_183-20221017-183711.xry/D2.tif');
im2_b=imread('/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_7_2_20221017/Atomo_7_2_193-20221017-184613.xry/D2.tif');


im3_1=imread('/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_8_3_230517/Atomo_8_3_20230517-184948.xry/D1.tif');
im3_2=imread('/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_8_3_230517/Atomo_8_3_20230517-184948.xry/D2.tif');


im3_1(:,[255 256 257 767 768 769])=median(im3_1(:));
im3_2(:,[255 256 257 767 768 769])=median(im3_2(:));


% Convert the image to double for processing
im3_1 = im2double(im3_1);
im3_2 = im2double(im3_2);

% Define the vertical filter
vertical_filter = ones(6, 1) / 6;  % Filter size: 6 vertical, 1 horizontal

% Apply vertical filtering using convolution
im3_1_filtered = conv2(im3_1, vertical_filter, 'same');
im3_2_filtered = conv2(im3_2, vertical_filter, 'same');


figure,
subplot(2,2,1)
imshow((im3_1))
subplot(2,2,2)
imshow((im3_2))
subplot(2,2,3)
imshow(imadjust(im3_1_filtered))
subplot(2,2,4)
imshow(imadjust(im3_2_filtered))


im1_a(:,[255 256 257 767 768 769])=median(im1_a(:));


figure,
subplot(2,3,1)
imshow((im1_a))
subplot(2,3,2)
imshow(imadjust(im1_b))
subplot(2,3,3)
imshow(imadjust((im1_a+im1_b)/2));

%imagesc((im1_a+im1_b)); colormap('gray')

subplot(2,3,4)
imshow(imadjust(im2_a))
subplot(2,3,5)
imshow(imadjust(im2_b))
subplot(2,3,6)

