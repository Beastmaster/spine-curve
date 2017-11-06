%%%%%%
% Extract haar-like feature from image patch
%
%
%% haar feature extraction
%
% patch: image patch
% octave: resizing factor
%
function feature = haar_feature(patch,octave)
% normalize patch first
mmean = mean(patch(:));
sstd = std(double(patch));
patch = (double(patch)-mmean)/sstd;

feature=[];
masks = haar_masks();
% resize factor
for oct = 1:2:octave
    patch_rsz = imresize(patch,oct/octave);
    for i = 1:length(masks)
        mask = masks{i};
        % convolve
        fea = conv2(patch_rsz,mask,'valid');
        fea = reshape(fea,[1 numel(fea)]);
        feature=[feature fea];
    end % end for mask
end % end for octave

end % end function

