%%%%%%%%%%%%%%%%%%%%%%%%
% Extract eigen vertebra from PCA
%



%% create mean vertebra first

load('pos_train.mat') % pos_train

if(0)
f1 = pos_train{1};
sz = size(imread(f1));
sum_vertebra = zeros(int32(length(pos_train)/5),sz(1),sz(2));
ii = 1:5:length(pos_train);
parfor i=1:length(ii)
    img = imread(pos_train{ii(i)});
    sum_vertebra(i,:,:)=img;
end
mean_vertebra = squeeze(mean(sum_vertebra,1));
save('mean_vertebra.mat','mean_vertebra');
return;
end



load('mean_vertebra.mat');
mean_vertebra_gpu = gpuArray(mean_vertebra);
fname = 'D:\Project\spine_seg_spline\temp\test_dcm_531/M1700346.dcm';
img = im2double(dicomread(fname));
img = histogram_shift(img);

im_sz = size(img);
sz=size(mean_vertebra);
nsz = int16(im_sz./sz-1).*int16(sz);
img = img(1:nsz(1),1:nsz(2));
img_gpu = gpuArray(img);

%% cross correlation
%gg = xcorr2(mean_vertebra,img);
gg1 = normxcorr2(mean_vertebra_gpu,img_gpu);
gg = xcorr2(img_gpu,mean_vertebra_gpu);
gg2 = gg(sz(1):size(gg,1)-sz(1),sz(2):size(gg,2)-sz(2));

%% edi distance
rsz_factor=0.5;
mean_vertebra = imresize(mean_vertebra,rsz_factor);
img = imresize(img,rsz_factor);
fun_dist = @(x) sum(abs(x(:)-mean_vertebra(:)));
%dist_map = colfilt(img_gpu,size(mean_vertebra_gpu),[10,10],'sliding',fun_dist);
dist_map = nlfilter(img,size(mean_vertebra),fun_dist);

%fun_dist2 = @(x) sum(abs(x.data(:)-mean_vertebra(:)));
%mean_map = blockproc(img,sz,fun_dist2);

subplot(1,3,1);
imshow(img,[]);
subplot(1,3,2);
imshow(gg,[]);
subplot(1,3,3);
imshow(dist_map,[]);
