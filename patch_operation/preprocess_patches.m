%
% Run preprocess on extracted pathces
% 
% Preprocess patches
% 1. image patch: run histogram equalization
% 2. label patch: convert to double type
%

function preprocess_patches()

old_dir = 'F:\EOS_for_segmentation\patches';
new_dir = 'F:\EOS_for_segmentation\patches\test';

struct_dir = dir(old_dir);

wait = waitbar(0,'Please wait...');
for i = 1:length(struct_dir)
    waitbar(i/length(struct_dir))
    
    struct = struct_dir(i);
    if struct.isdir == 1
        continue;
    end 
    fname = struct.name;
    if strfind(fname,'lab')
        im_name = fullfile(old_dir,fname);
        im=double(imread(im_name));
        
        filename = fullfile(new_dir,fname);
        imwrite(im,filename);
        %disp(filename)

    elseif strfind(fname,'img')
        im_name = fullfile(old_dir,fname);
        im=imread(im_name);
        % histogram equalization
        im = histeq(im); %j =  adapthisteq(im);
        im = double(im);
        % gauss filt
        im = imgaussfilt(im);
        % normalize
        im = (im - mean(im(:)) )/(max(im(:))-min(im(:)));
        filename = fullfile(new_dir,fname);
        imwrite(im,filename);
        %disp(filename)
    end % end if: strfind(fname)
end % for loop
close(wait);


end % end function

