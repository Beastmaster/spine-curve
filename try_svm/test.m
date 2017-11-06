

clear()


pname ='F:\vertebra_patches_no_corrected/Y950820A_2.png';

patch = imread(pname);
patch = imresize(patch,0.1);

feature = haar_feature(patch,5);



postive_dir = 'F:\vertebra_patches_no_corrected';
negative_dir = 'F:\non_vertebra';

postive_pngs = dir(fullfile(postive_dir,'*.png'));
% shuffle
postive_shuffled = postive_pngs(randperm(numel(postive_pngs)));

negative_pngs = dir(fullfile(negative_dir,'*.png'));
% shuffle
negative_shuffled = negative_pngs(randperm(numel(negative_pngs)));





