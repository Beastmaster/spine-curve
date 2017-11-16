
%% Split big images to a small patch
%
% output format:  path/prefix[patch_id].nii
%                 path/prefix[patch_id].dcm
%
function split_patch(dcm_file,nii_file,path,prefix)
%
% path: extracted patch save location
% prefix: image prefix label
%
% patches may be overlapped
[pathstr,~,~] = fileparts(dcm_file);
if ~isempty(path)
    pathstr = path;
end

if ~isempty(dcm_file)
    img = dicomread(dcm_file);
    % threshold
    img = pre_process(img);
    
    % extract ROI
    roi = extract_roi(img);
    extract_patches(roi,'_img',pathstr,prefix);
end % end if: dcm_file valid

if ~isempty(nii_file)
    label = nii2img(nii_file);
    roi_label = extract_roi(label);
    extract_patches(roi_label,'_lab',pathstr,prefix);
end % end if: nii valid

end  % end function convert_patch

%% extract patches from single image
% Input: 
%   1. img: 4000*1500
%   2. modal: '_img'/'_lab'
%   3. pathstr: save path
%   4. prefix: save file name prefix
function extract_patches(img,modal,pathstr,prefix)

patch_x = 300;  % patch size x
patch_y = 400;  % patch size y

x_num = 10;  % x direction split
y_num = 3;   % y direction split

id = 0;
for xi = 1:x_num
    for yi = 1:y_num 
        id = id+1;
        
        if xi==1
            idx1 = 1;
        else
            idx1 = (xi-1)*patch_x + 1;
        end
        idx2 = xi*patch_x;
        
        if yi==1
            idy1 = 1;
        else
            idy1 = (yi-1)*patch_y + 1;
        end
        idy2 = yi*patch_y;
        patch = img(idx1:idx2,idy1:idy2);
        img_patch_name = fullfile(pathstr,strcat(prefix,modal,num2str(id),'.png'));
        imwrite(patch,img_patch_name);
    end % end for: yi
end % end for: xi

end % end function


% pre_process image
function img_out = pre_process(img_in)
    img_in = img_in/3*2;
    img_in(img_in>65535/2) = 65535/2;
    img = histogram_equ(img_in);
    img_out = imgaussfilt(img);% gauss filt
end

function img_out = extract_roi(img_in)
    sz = [4000,1500];
    img_out = imresize(img_in,sz);
end


%
% x: 8 segments; 300
% y: 5 segments; 400
%
function imout = extract_roi2(im_in)

sz = size(im_in);

x_center = int16(sz(1)/2);
y_center = int16(sz(2)/2);

height = 4000;
if sz(1)>=height
    x_lower = x_center-height/2;
    x_upper = x_center+height/2;
else
   x_lower = 1 ;
   x_upper = sz(1);
end

width = 1500;
if sz(1)>=width
    y_lower = y_center-width/2;
    y_upper = y_center+width/2;
else
   y_lower = 1 ;
   y_upper = sz(2);
end

imout = im_in(x_lower:x_upper,y_lower:y_upper);

end % end function extract_roi

function img_out = histogram_equ(img_in)
    if ischar(img_in)
        img_in = dicomread(img_in);
    end
    
    th = 65535/2;
    img_in(img_in>=th) = th;
    img_out = adapthisteq(img_in);
end % end function

