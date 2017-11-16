% Author: QIN Shuo
% Date: 2017/03/02
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Resize whole image to [4000,1500]
% Run histogram equalization
% Extract parts size: [300 * 400]
% Positive training data: extract patches around vertebra
%
% Require centroid in ground segmentation truth
%

function preprocess_extract_patch()

% import original image-label 
original_list = 'F:\EOS_for_segmentation\list.txt';
original_list = importdata(original_list);
save_dir = 'F:\EOS_for_segmentation\train_patches';
%save_dir = 'F:\EOS_for_segmentation\new_patch2';

hd = waitbar(0,'Please wait...');
for id = 1:length(original_list);
    percentage = id / length(original_list);
    waitbar(percentage,hd,num2str(percentage))
    
    pair_str = original_list{id}; pair_str = strsplit(pair_str,' ');
    img_name = pair_str{1};
    label_name = pair_str{2};

    % resize
    img = resize_img(img_name);
    label = resize_img(nii2img(label_name));

    % preprocess image
    img = preprocess(img);

    % save patches
    prefix = num2str(id,'%03d');
    extract_patches(img,label,save_dir,prefix);
end % end for loop
close(hd);

end % end main function


%% Resize Image
% default: resize to [4000,1500]
function img_out = resize_img(img_in,varargin)
    sz = [4000,1500];
    if nargin >1
        sz = varargin{1};
    end
    if ischar(img_in)
        img_in = dicomread(img_in);
    end
    img_out = imresize(img_in,sz);
end % end function

%% Sum of preprocess operation
% 1. threshold
% 2. histogram equalization
% 3. gauss filter
function img_out = preprocess(img_in)
    img = threshold(img_in);
    img = histogram_equ(img);
    img_out = imgaussfilt(img);% gauss filt
end % end function

%% Threshold
function img_out= threshold(img_in,varargin)
    th = 65535/2;
    if nargin >1
        th = varargin{1};
    end
    if ischar(img_in)
        img_in = dicomread(img_in);
    end
    img_out = img_in;
    img_out(img_in>=th) = th;
end % end function

%% histogram_equalization
% Input: image array / dicom image filename
% Output: equalized image
%
function img_out = histogram_equ(img_in)
    if ischar(img_in)
        img_in = dicomread(img_in);
    end
    img_out = adapthisteq(img_in);
end % end function

%% Normalize (not completed)
% Input: image array / dicom image filename
% Output: normalized image
function img_out = normalize(img_in)
    img_out = img_in;
end % end function


%% Extract patches from image and label pair
%
% Input: 
%   img: preprocessed image
%   label: resized label with same size as img
%   prefix: patch save name prefix
%
function extract_patches(img,label,path,prefix)
patch_sz = [300,400];

conn = bwconncomp(label);
sz = size(label);
centroids = int16(ind_centroid(conn.PixelIdxList,sz)); % function from: ind_centroid.m
% shift centroid randomly
shift = {[100,0];[-100,0];[0,100];[0,-100];[100,100];[100,-100];[-100,100];[-100,-100]};
n_centroids = {};
fun_add = @(A,B) A+B;  % add on each row
for i = 1: length(shift)
    n_centroids = [n_centroids;bsxfun(fun_add,centroids,shift{i})];
end
for i = 1:length(n_centroids)
   centroids = [centroids;n_centroids{i}]; 
end

% crop patches
bound = repmat(centroids,1,2);
bound = bsxfun(fun_add,bound,[1-patch_sz(1)/2,1-patch_sz(2)/2,patch_sz(1)/2,patch_sz(2)/2]);


for id = 1:length(bound)
    bd = bound(id,:);
    patch = img(bd(1):bd(3),bd(2):bd(4));
    patch_label = label(bd(1):bd(3),bd(2):bd(4));
    img_patch_name = fullfile(path,strcat(prefix,'_img',num2str(id),'.png'));
    label_patch_name = fullfile(path,strcat(prefix,'_lab',num2str(id),'.png'));
    imwrite(patch,img_patch_name);
    imwrite(patch_label,label_patch_name);
end % end for

end % end function

