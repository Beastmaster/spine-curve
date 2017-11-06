%%%%%%
% Date: 2017/7/4
% sort data to train and test set
%
%



postive_dir = 'F:\vertebra_patches_no_corrected';
negative_dir = 'F:\non_vertebra';

postive_pngs = dir(fullfile(postive_dir,'*.png'));
% shuffle
postive_shuffled = postive_pngs(randperm(numel(postive_pngs)));
postive_pngs=cell(1,length(postive_shuffled));
for i=1:length(postive_shuffled)
    postive_pngs(i) = cellstr(fullfile(postive_dir,postive_shuffled(i).name));
end

negative_pngs = dir(fullfile(negative_dir,'*.png'));
% shuffle
negative_shuffled = negative_pngs(randperm(numel(negative_pngs)));
negative_pngs=cell(1,length(negative_pngs));
for i=1:length(negative_pngs)
    negative_pngs(i) = cellstr(fullfile(negative_dir,negative_shuffled(i).name));
end

% select 3/4 of data as training
th = int32(3/4*length(postive_pngs));
pos_train=postive_pngs(1:th);
pos_test = postive_pngs(th:length(postive_pngs));

th = int32(3/4*length(negative_pngs));
neg_train= negative_pngs(1:th);
neg_test = negative_pngs(th:length(negative_pngs));

save('pos_train.mat','pos_train');
save('pos_test.mat', 'pos_test');
save('neg_train.mat','neg_train');
save('neg_test.mat', 'neg_test');


