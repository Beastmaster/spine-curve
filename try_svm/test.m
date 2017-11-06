

mm = mean(gg2(:));
ss = std(gg2(:));

ggx = gather(gg2*100/ss);


imshow(bw,[]);



fname = 'D:\Project\spine_seg_spline\temp\test_dcm_531/M1700346.dcm';
%fname = 'D:\Project\spine_seg_spline\temp\test_dcm_531/M0081731.dcm';
img = im2double(dicomread(fname));
img2 = histogram_shift(img);
imshow(img2,[]);
return;
img = imresize(img,0.5);

% local contrast normalization
funx = @(x) (x.data-mean(x.data(:)))/std(x.data(:));
fun = @(x) std(x(:));

fun_mean = @(x) mean(x);
fun_std =  @(x) std(x);


sz = [10,10];
%mean_map = nlfilter(img,sz,fun_mean);
%std_map1 = nlfilter(img,sz,fun);
mean_map = colfilt(img,sz,'sliding',fun_mean);
std_map = colfilt(img,sz,'sliding',fun_std);

lcn_img = (img-mean_map)./std_map;
imshow(std_map,[]);


return

clear;

load('pos_train.mat'); % pos_train
load('neg_train.mat'); % neg_train

pos_train = pos_train(1:500);
neg_train = neg_train(1:500);

octave=8;
resize_factor=0.25;

% find patch size first
a1 = pos_train{1};
patch=imread(a1);
patch=imresize(patch,resize_factor);
feature=haar_feature(patch,octave);
feature_len = length(feature);

% allocate first
X=zeros(length(pos_train)+length(neg_train),feature_len);
Y=zeros(1,length(pos_train)+length(neg_train));

% shape patch: 200*240
parfor i=1:length(pos_train)
    a1 = pos_train{i};
    patch=imread(a1);
    patch=imresize(patch,resize_factor);
    feature=haar_feature(patch,octave);
    X(i,:)=feature;
    Y(i)=1;
end 

idx_map=(1+length(pos_train)):(length(neg_train)+length(pos_train));
parfor i=1:length(idx_map);
    a1 = neg_train{i};
    patch=imread(a1);
    patch=imresize(patch,resize_factor);
    feature=haar_feature(patch,octave);
    X(i,:)=feature;
    Y(i)=0;
end



return

%%%%% test crop patch
img_name = 'F:\test\15-11-27_Y9901289/face.png';
img = imread(img_name);

patch_size=[200,240];
stride=20;
method = 'valid';
crop_patch(img,patch_size,stride,method)

%

if(0)
pname ='F:\vertebra_patches_no_corrected/Y950820A_2.png';

patch = imread(pname);
patch = imresize(patch,0.1);

feature = haar_feature(patch,5);



postive_dir = 'F:\vertebra_patches_no_corrected';
negative_dir = 'F:\non_vertebra';

postive_pngs = dir(fullfile(postive_dir,'*.png'));
% shuffle
postive_shuffled = postive_pngs(randperm(numel(postive_pngs)));

negative_pngs = dir(fullfile(negative_dir,'*.png'));
% shuffle
negative_shuffled = negative_pngs(randperm(numel(negative_pngs)));

end



