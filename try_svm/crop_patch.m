%%%%%%%%%%%%%%
% Date: 2017/7/5
% Crop patches from a large image
% similar parameters as convolution operation
%
%

%% Crop patches from image
% Input:
%   img: large image tobe processed 
%   patch_size: a 2 elements array: [height, width]
%   stride: marching step
%   method: subsection of crop (similar to conv2 para: shape, 'full','same','valid')
% Return:
%   patches: a cell array (row), containing image patches
%
function patches = crop_patch(img,patch_size,stride,method)

im_height = size(img,1);
im_width  = size(img,2);
pa_height = patch_size(1);
pa_width  = patch_size(2);

lst_height = splitx(im_height,pa_height);
lst_width = splitx(im_width,pa_width);

patches = mat2cell(img,lst_height,lst_width);

end % end function



function lst = splitx(total,len_seg)
    n_seg = int32(total/len_seg)-1;
    n_seg_ = mod(total,len_seg);
    lst = zeros(1,n_seg+1);
    lst(:)=len_seg;
    lst(n_seg+1) = n_seg_;
end




