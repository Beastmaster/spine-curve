% Whole spine segmentation method
% EOS image
%
% Main method: active contour algorithm
%
%Author: QIN Shuo
%Date: 2016/7/7
%Organization: RC-MIC (CUHK)

close all;
clear;

filename = 'D:/QIN/image/EOS2.dcm';
img = dicomread(filename);
metadata = dicominfo(filename);


%%%% image preprocess
%se = strel('square',10);
%img = imtophat(img,se);
%img = imbothat(img,se);
%  resize
img = imresize(img,0.3);
%  Extract ROI
[height,width] = size(img);
n_width = floor(width/3);
img = img(:,n_width:n_width*2);


if(0)
figure
imshow(img,[])
title('original image')
%%%  extract ROI
rect = getrect();
xmin = floor(rect(1));
ymin = floor(rect(2));
width = floor(rect(3));
height = floor(rect(4));
img = img(ymin:ymin+height,xmin:xmin+width);
end
%  gauss filtered image
img2 = double(imgaussfilt(img,2));
%img2(img<15000)=0;
% open
se = strel('disk',5);
img = imopen(img2,se);

figure
imshow(img,[])


%%%% wavelet process
wname = 'sym1';
[CA,CH,CV,CD] = dwt2(img,wname,'mode','per');

%shift scale
max1=max(CV(:,:));
min1=min(CV);
min1=min(min1);
CV=CV-min1;

figure
imshow(CV,[]);title('Wavelet')




%%%%% edge detection process
% sobel edge detection
BW = edge(img,'sobel','vertical');%'horizontal');vertical
figure
imshow(BW,[])
title('sobel edge')


% canny edge detection
if(0)
BW2 = edge(img,'canny');
figure
imshow(BW2,[])
title('canny edge')
end



%1. find a line in the middle of the image
[y_range,x_range] = size(img);
%2. range: 1/2 of the image
x_r = [floor(x_range/4),floor(x_range*3/4)];
%3. calculate the average value
% allocate memory for x
x_arr = zeros(1,y_range);
figure
for i=1:y_range
    imshow(BW,[])
    title('sobel edge plot')
    
    average=0;
    cnt = 0;
    for j = x_r(1): x_r(2)
       if BW(i,j) == 1
           average = average+j;
           cnt = cnt +1;
       end
    end
    
    if cnt == 0
        average = floor(x_range/2);
    else
        average = average/cnt;
    end
    
    x_arr(i) = average;
    hold on
    plot(x_arr,(1:y_range),  'r.');
    hold off
    %pause(0.001)
end

hold on
fit_curve = fit((1:y_range)',x_arr','smoothingspline');
x = 1:y_range;
y = fit_curve(x);
plot(y,x,'b')

return;

%%%%% use active snake to find a better contour
x = 1:y_range;
y = fit_curve(x);
xys = [y';x];
x = y_range:-1:1;
y = fit_curve(x)+1;
xys = [xys,[y';x]];

%figure
%scatter(xys(2,:),xys(1,:))
sigma = 1.0;
smask = fspecial('gaussian', ceil(3*sigma), sigma);
smth = filter2(smask, img, 'same');
figure
imshow(smth,[]);
title('smth');

% iteration parameters
alpha = 0.40;
beta = 0.20;
gamma = 1.00;
kappa = 0.15;
weline = 0.30;
wedge = 0.40;
weterm = 0.70;
iterations = 200;

[smth,xs,ys] = interate(smth, xys(2,:) , xys(1,:), alpha, beta, gamma, kappa, weline, wedge, weterm, iterations);




% no use
if 0
    %%%%% active contour method
    rect = getrect();
    xmin = rect(1);
    ymin = rect(2);
    width = rect(3);
    height = rect(4);
end


