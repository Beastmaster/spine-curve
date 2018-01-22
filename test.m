
imshow('pout.tif');
h = imline(gca,[10 100], [100 100]);
setColor(h,[0 1 0]);
id = addNewPositionCallback(h,@(pos) title(mat2str(pos,3)));

% After observing the callback behavior, remove the callback.
% using the removeNewPositionCallback API function.
%removeNewPositionCallback(h,id);
return;


fname = 'D:\Project\spine_seg_spline\temp\test_dcm_531/Z9549146.dcm';
while(1)
    ddir = 'D:\Project\spine_seg_spline\temp\test_dcm_531';
    fname = uigetfile(fullfile(ddir,'*.dcm'));
    img = dicomread(fullfile(ddir,fname));
    
    % Resize
    img_ori = imresize(img,0.5);
    [height,width] = size(img_ori);
    
    % clavicle
    clavicle = load('resources/t1.mat');
    template = imresize(clavicle.t1,0.5);
    hh = 1/3;
    block = img_ori(1:int16(height*hh),:);
    [~,rc] = Matching_by_correlation(template,block);
    pos_clavicle = rc ;%+ size(template); %,2);
    
    imshow(img_ori,[]); hold on;
    scatter(pos_clavicle(2)+85,pos_clavicle(1)+150,100);
    hold off;
end

return


img = imread('F:\vertebra_patches\train_pos/M233338A_7.png');
img = imresize(img,0.5);

wavelength = 4;
orientation = 60;
[mag,phase] = imgaborfilt(img,wavelength,orientation);

subplot(1,3,1);
imshow(img);
title('Original Image');
subplot(1,3,2);
imshow(mag,[])
title('Gabor magnitude');
subplot(1,3,3);
imshow(phase,[]);
title('Gabor phase');


return
BW = edge(img,'Canny');
[H,T,R] = hough(BW);
P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
figure, imshow(BW), hold on
max_len = 0;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    
    % Plot beginnings and ends of lines
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    
    % Determine the endpoints of the longest line segment
    len = norm(lines(k).point1 - lines(k).point2);
    if ( len > max_len)
        max_len = len;
        xy_long = xy;
    end
end

return;


basedir = 'D:\Project\spine_seg_spline\temp\test_1106';
dstdir = 'D:\Project\spine_seg_spline\temp\test_1106\xx';
files = dir(fullfile(basedir,'*.jpg'));
for i =1:length(files)
    fname = files(i).name;
    fullname = fullfile(basedir,fname);
    
    nfname = [num2str(randi(1e5)),'.jpg'];
    nfname = fullfile(basedir,nfname);
    movefile(fullname,nfname);
    
end


return;







I=uint16(smth_crop);
level = graythresh(I);
BW = im2bw(I,level);
imshow(smth_crop,[]);
return;



dcm='\\SERVER\qinshuo\WorkPlace\unet_keras\tmp\face_test\test3/11-30-15_15h48m14_Y8680025_face.dcm'
png='\\SERVER\qinshuo\WorkPlace\unet_keras\tmp\face_test\test3/11-30-15_15h48m14_Y8680025_face.png'

label='E:\EOS_data\washed_data_test_cobb\all_segmentation\train\15-11-30_Y8680025/face_label.png';

im1 = dicomread(dcm);
im2=imread(png);
im3 = imread(label);

figure;
subplot(131);
imshow(im1,[]);

subplot(132);
imshow(im2>200,[]);
subplot(133);
imshow(im3,[]);



return;

fname = 'D:\Project\spine_seg_spline\temp\test_dcm_531\M0081731.dcm';
im = dicomread(fname); %im = imresize(im);
im=im(400*2:1000*2,300*2:700*2);
BW = edge(im);
BW = edge(im,'Prewitt');

subplot(121);
imshow(BW,[]);
subplot(122);
imshow(im,[]);

return
im = imresize(im,0.5);

[y,x]=size(im);
[x,y]=meshgrid(1:x,1:y);
x=x/10;
aa=normrnd(1:948,1./(1:948))/11;
x=bsxfun(@plus,x,aa);
y=y/10;


D = zeros(size(im,1),size(im,2),2);
D(:,:,1)=x;
D(:,:,2)=y;

B=imwarp(im,D);

%figure;
imshow(B,[]);

return;



%% fitting test

p=1e-3;
[row,col] = find(output~=0);
row = row(1:5:length(row));
col = col(1:5:length(col));
% Way 2
%[output_row,output_col] = find(output~=0);
%[grad_row,grad_col] = find(grad~=0);
%row = [output_row;grad_row];
%col = [output_col;grad_col];

% fit in the first
xxi = min(row):0.5:max(row);
ys = csaps(row,col,p,xxi);

figure;
imshow(output~=0,[]);hold on;
scatter(ys,xxi,5,'r');

return;


%%
path = 'D:\Project\spine_seg_spline\temp\test_dcm_531';
%fname = uigetfile(fullfile(path,'*.dcm'));
fname = 'Y8478757';
fname = fullfile(path,fname);
if exist(fname, 'file')~=2
    disp(fname);
end

img = double(dicomread(fname));
img = imresize(img,0.5);

% 0. Gauss smoothing
img = imgaussfilt(img,10);
%img = imadjust(img);

grad = gradient(img);

grad(1:300,:)=0;
grad(1600:2119,:)=0;
grad(:,1:250)=0;
grad(:,700:909)=0;
figure;imshow(grad,[]);
return;

mma = max(img(:));
mmi = min(img(:));

BW = (img>35000);

imshow(BW,[]);
return;




% check histograms
path = 'D:\Project\spine_seg_spline\temp\test_dcm_531';
fname = fullfile(path,'*.dcm');
ddir = dir(fname);
for i = 1:length(ddir)
    fname = fullfile(path,ddir(i).name);
    img = dicomread(fname);
    histogram(img);
    
end

return;





% 1. global threshold
threshold = 50000;
img(img>threshold) = 0;

% 2. Image Open
se = strel('square',5);
img = imclose(img,se);
sq = ones(20,20);
sq = sq/400;
img = conv2(img,sq,'same');
img = img/350;



[Gx,Gy] = imgradientxy(img);
%Gx = gradient(img);
%grad(grad<0.01) = 0;

block = Gx;
region_threshold = 0.1;
[aa,bb] = size(block);
%sz = aa*bb;
sz = numel(block);
sorted_block = sort(block(:));
% Generate threshold
thres_index = int32(sz*(1-region_threshold));
thres = sorted_block(thres_index);
% Threshold
new_block = (block>=thres);
Gxx = new_block;

subplot(131);
imshow(img,[]);
subplot(132);
imshow(Gx,[]);
subplot(133);
imshow(Gxx,[]);


return
[a,b] = size(grad);
grad1 = zeros([a,b,3]);
grad1(:,:,1) = 100*double(grad);

output1 = zeros([a,b,3]);
output1(:,:,3) = 100*double(output);

output3 = grad1+output1;

subplot(131)
imshow(grad1,[]);
subplot(132)
imshow(output1,[]);

subplot(133)
imshow(output3,[]);


return;




return;
new = cell([91,25+6]);

for i=1:size(manual,1)
    id = manual{i,1};
    for j=1:size(test_data,1)
        pid = test_data{j,1};
        if strcmp(id,pid)==1  % find position
            for k=1:25% copy test_data
                new{i,k} = test_data{j,k};
            end
            
            for k=25+1:25+6 % copy manual
                new{i,k} = manual{i,k-25+1};
            end
            break;
        end
    end
    
end

return;
folder = 'statistics/manual_method';
ddir = dir(fullfile(folder,'*.mat'));

manual = [];

for i=1:length(ddir)
    d1 = ddir(i);
    fname = fullfile(folder,d1.name);
    
    [~,id,~] = fileparts(fname);
    
    info = load(fname);
    info = {id,info.ang1,info.ang1_upper,info.ang1_lower,info.ang2, info.ang2_upper,info.ang2_lower};
    manual = [manual;info];
end
save('statistics/manual_method/manual.mat','manual');



return;
fname = 'D:\Project\spine_seg_spline\temp\test_dcm_531\M0081731.dcm';


tmp = load('resources/pelvis.mat');
pelvis_tplt = tmp.region;
tmp = load('resources/head.mat');
head_tplt = tmp.region;
image = dicomread(fname);

template = head_tplt;
template = pelvis_tplt;

% region size
[~,temp_sz] = size(template);
[~,img_sz] = size(image);
scale = temp_sz/img_sz;
%template = imresize(template,scale);

gg = abs(normxcorr2(template,image));

sz = int16(size(image));
sz2 = int16(size(gg));
gg = gg(sz2(1)/2-sz(1)/2:sz2(1)/2+sz(1)/2, sz2(2)/2-sz(2)/2:sz2(2)/2+sz(2)/2);

imshow(gg,[]);












