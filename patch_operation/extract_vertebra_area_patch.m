%% Author: QIN Shuo
% Date: 2017/03/25
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A data preparation procedure
%   Extract the vertebra area. 
%


% patch name pattern: {img_index}_{patch_index}_{modality}.png
%   img_index: %3d
%   patch_index: %3d
%   modality: img/lab
%

function extract_vertebra_area_patch()
close all ;
addpath('D:\Project\spine_seg_spline');
addpath('D:\Project\spine-curve\try_svm');

ddir = 'E:\EOS_data\washed_data_test_cobb\all_segmentation\train';
savepath = 'F:\vertebra_patches\hist_shift_patch\train_pos';

dirinf = dir(ddir);
for i = 1:length(dirinf)
    dd = dirinf(i);
    if(strcmp(dd.name,'.') || strcmp(dd.name,'..'))
        continue;
    end
    
    nddir = fullfile(ddir,dd.name);
    dcm = dir(fullfile(nddir,'*face.dcm')); dcm = fullfile(nddir,dcm.name);
    png = dir(fullfile(nddir,'face_label.png')); png = fullfile(nddir,png.name);
    
    img_name = dcm;
    lab_name = png;
    prefix=num2str(i);
    for_each_pair_vertebra(img_name,lab_name,prefix,savepath);
end % end for

end % end function

%% Process a single image, random extract
% filename: prefix = num2str(id,'%03d'); 
%           fullfile(path,strcat(prefix,'_img',num2str(id),'.png'))
% No resize
function [img] = random_extract(img_name,idx,save_path)
img = preprocess(img_name);
imwrite(img,'test.png');
sz = size(img);

% bounding of vertebra
for i=1:50:sz(1)-200
    for j=1:50:sz(2)-200
        patch = img(i:i+200,j:j+200);
        % save
        prefix = num2str(idx,'%03d'); % idx: image ID
        fname = fullfile(save_path,strcat(prefix,'_',num2str(i),'_',num2str(j),'.png'));
        imwrite(patch,fname);
    end % end for
end % end for
end

%% Process a single image, for vertebra area only
% filename: prefix = num2str(id,'%03d'); 
%           fullfile(path,strcat(prefix,'_img',num2str(id),'.png'))
% No resize
function [img,lab] = for_each_pair_vertebra(img_name,lab_name,prefix,save_path)

img= im2double(dicomread(img_name));
img = histogram_shift(img);
%lab =  nii2img(lab_name);
lab = imread(lab_name);


sz = size(img);
conn = bwconncomp(lab);
centroids = int16(ind_centroid(conn.PixelIdxList,sz));

% bounding of vertebra
for i=1:length(conn.PixelIdxList)
    idxs = conn.PixelIdxList{i};
    if(length(idxs)<1000)
        continue;
    end
    if(i>size(centroids,1))
        continue;
    end
    cnd = centroids(i,:);
    
    [subx,suby] = ind2sub(sz,idxs);
    xrange = [min(subx) max(subx)];
    yrange = [min(suby) max(suby)];
    % extract patch
    %patch = img(xrange(1)-10:xrange(2)+10,yrange(1)-10:yrange(2)+10);
    patch = img(cnd(1)-100:cnd(1)+100-1,cnd(2)-120:cnd(2)+120-1);
    % save
    fname = fullfile(save_path,strcat(prefix,'_vtb',num2str(i),'.png')); % i: patch ID
    imshow(patch,[]);
    disp(strcat('creating patch :',fname));
    imwrite(patch,fname);
end % end for

end % end function

%% Process a single image, for non-vertebra area only
% filename: prefix = num2str(id,'%03d'); 
%           fullfile(path,strcat(prefix,'_img',num2str(id),'.png'))
%
%  patch_size: 
%
function [img,lab] = for_each_pair_nonvertebra(img_name,lab_name,idx,save_path)

img = preprocess(img_name);
lab = nii2img(lab_name);

se = strel('disk',20);
lab = imerode(lab,se);

patch_size = [200,200];

sz = size(img);

% bounding of non-vertebra area
i=1;
while i <= 40
    st_ptx = randi([1 sz(1)-patch_size(1)]);
    st_pty = randi([1 sz(2)-patch_size(2)]);
    
    % extract patch
    patch = img(st_ptx:st_ptx+patch_size(1)-1,st_pty:st_pty+patch_size(2)-1);
    
    pp = lab(st_ptx:st_ptx+patch_size(1)-1,st_pty:st_pty+patch_size(2)-1);
    if sum(pp(:))>0
        continue;
    end
    
    % save
    fname = fullfile(save_path,strcat(prefix,'_non-vtb',num2str(i),'.png')); % i: patch ID
    imshow(patch,[]);
    disp(strcat('creating patch :',fname));
    imwrite(patch,fname);
    i = i+1;
end % end for

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
