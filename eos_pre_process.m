%% Pre-process of EOS image
% This script is designed for later 
% process of SIFT feature extraction
% implementation in python + opencv2
%
%
%%Author: QIN Shuo
%Date: 2016/7/7
%Organization: RC-MIC (CUHK)

%% EOS_Pre_Process
% input a dicom file name
function eos_pre_process(filename)
clc;
close all;

%check existance of file
if exist(filename,'file') ~= 2
    display('File not exists')
    return
end

img = dicomread(filename);
img = imresize(img,0.5);
[height,width] = size(img);

%%% pre-process
% 0. Gauss smoothing
%img = imgaussfilt(img,2);

% 1. global threshold
threshold = 49000;
img(img>threshold) = 0;

% 2. Image Open
se = strel('square',5);
%img = imclose(img,se);
sq = ones(1,1);%ones(20,20);
%sq = sq/400;
img = conv2(img,sq,'same');
img = img/40000;


out_name = strsplit(filename,'.');
out_name = char(out_name(1));
out_name = strcat(out_name,'.jpg');
display(out_name)

imwrite(img,out_name);
imshow(img,[])
end


%% EOS image enhancement 
% top-hat function
function img_out = eos_enhance(img)
% top-hat sharp
se = strel('square',10);
img_out = imtophat(img,se);
end





