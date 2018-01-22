%%%%
%  Matching by correlation
%      Locate pelvis and head
% Author: QIN Shuo
% Date: 2016/7/19
% Organization: RC-MIC (CUHK)
%
% Description: 
%   A template has been generated, use the template to generate a prob map
%
%% Matching by correlation
%Input:
% nargin = 0: extract template form default image
% nargin = 1: extract template form specified image
% nargin = 2:
%             temp: template
%             img: imput image
% nargin = 3:
%             varargin: 'head' or 'pelvis'
%Output:
% map: correlation map
% rc : position
function [map,rc ]= Matching_by_correlation(temp,img)
% load a templete
template = temp;
%template = pre_process(template);

% correlation map
ff = img;
ff = pre_process(ff);

% restrict area
ff_s = ff;

[map, rc] = correlation_map(template,ff_s);
end

%% Compute correlation map
function varargout = correlation_map(varargin)
%varargin:
%1. template
%2. image
%
%varargout:
%1. correlation map
%2. max position: [r c]

template = cell2mat(varargin(1));
image = cell2mat(varargin(2));

% shrink size to reduce processing time
scale = 0.05;
template = imresize(template,scale);
image = imresize(image,scale);

gg = abs(normxcorr2(template,image));
gT = gg == max ( gg ( : ) ) ;
idx = find(gT == 1);
[r,c] = ind2sub(size(gg),idx);
yoff = r-size(template,1);
xoff = c-size(template,2);

% remember to scale back
varargout(1) = {imresize(gg,1/scale)};
varargout(2) = {[yoff xoff]/scale};
end


%% Extract template
%nargin = 0 : output filename 'default.mat'
%nargin = 1 : input file
%
function varargout = extract_template(varargin)

if nargin<1
    % read
    outname = 'default.mat';
    original_img = dicomread('D:\QIN\image\lily\new\4.dcm');
    original_img = imgaussfilt(original_img,5);
else
    outname = 'default.mat';
    original_img = cell2mat(varargin(1));
end

% preprocess
img = imadjust(original_img);

% extract a template
imshow(img,[]);
[x,y] = ginput(2);

y = int16(y);
x = int16(x);

region = img(y(1):y(2),x(1):x(2));

close all;
imshow(region,[]);

%nn = strcat(outname,'.mat');
if nargout<1
    save(outname,'region');
else
    varargout(1) = region;
end

end



function out = pre_process(input)
% gauss filt
img = imgaussfilt(input,4);

% gray adjust
img = imadjust(input);

if(0)
% get gray scale range of the block
ma = max(max(img(:,:)));
mi = min(min(img(:,:)));
ran = ma-mi;
% threshold
region_threshold = 0.1;
thres = ma-(ran * region_threshold);
new_img = (img>thres);
end


out = img;
end