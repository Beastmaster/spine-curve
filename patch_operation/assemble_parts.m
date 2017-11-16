

%% Assemble patches 
%
% path: patches path
% prefix: in patch name xx_img.png, xx part
% mid: op1:'_img'; op2:'_lab'
% surfix: format of patches
function full_img = assemble_parts(path,prefix,varargin)

mid='_img';
surfix='.png';

if nargin >2
    mid = varargin{1};
end
if nargin >3
    surfix = varargin{2};
end


patch_x = 300;  % patch size x
patch_y = 400;  % patch size y

x_num = 10;  % x direction split
y_num = 3;   % y direction split


sz = [patch_x*x_num patch_y*y_num];
im = zeros(sz);

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
        
        filename = fullfile(path,strcat(prefix,mid,num2str(id),surfix));
        patch = imread(filename);
        im(idx1:idx2,idy1:idy2) = patch;
        
    end % end for: yi
end % end for: xi
full_img = im;

end % end function: assemble_parts


