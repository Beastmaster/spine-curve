%%%%%%
% 2017/7/5
% Extract haar-like feature from image patch
%
%
%% haar feature extraction
%
% patch: image patch
% octave: resizing factor
%
function feature = haar_feature(patch,octave)
% reshape first
%patch = imresize(patch,[50,60]);

% normalize patch first
mmean = mean(patch(:));

sstd = std(double(patch(:)));
patch = (double(patch)-mmean)/sstd;

feature=[];
masks = haar_masks();
% resize factor
for oct = 1:4:octave
    patch_rsz = imresize(patch,oct/octave);
    for i = 1:length(masks)
        mask = masks{i};
        % convolve
        fea = conv2(patch_rsz,mask,'valid');
        fea = reshape(fea,[1 numel(fea)]);
        feature=[feature fea];
    end % end for mask
end % end for octave
feature = [feature mmean];
feature = [feature sstd];
end % end function

%%%%%%%%%%%%%%%%%%%%%%%%
% harr-like feature mask
%

function masks = haar_masks()
masks=[];
% viola feature
hor = [1 -1];
%masks=[masks;mat2cell(hor,1)];
ver = hor';
%masks=[masks;mat2cell(ver,2)];

hor3 = [1 -1 1];
%masks=[masks;mat2cell(hor3,1)];

ver3 = hor3';
%masks=[masks;mat2cell(ver3,3)];

sqr  = [-1 1; 1 -1];
sqr_ = [1 -1; -1 1];
masks=[masks;mat2cell(sqr,2)];
masks=[masks;mat2cell(sqr_,2)];

% Lienhart features
sqr3  = [1 0 0;0 -1 0;0 0 1];
sqr3_ = [0 0 1;0 -1 0;1 0 0];
masks=[masks;mat2cell(sqr3,3)];
masks=[masks;mat2cell(sqr3_,3)];

sqr4  = [0 0 0 1;0 0 -1 0;0 -1 0 0;1 0 0 0];
sqr4_ = [1 0 0 0;0 -1 0 0;0 0 -1 0;0 0 0 1];
masks=[masks;mat2cell(sqr4,4)];
masks=[masks;mat2cell(sqr4_,4)];

center3  = [1 1 1;1 -1 1; 1 1 1];
center3_ = [0 1 0;1 -1 1; 0 1 0];
masks=[masks;mat2cell(center3,3)];
masks=[masks;mat2cell(center3_,3)];

end
