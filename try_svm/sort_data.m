%%%%%%
% Date: 2017/7/4
% sort data to train and test set
%
%

function sort_data()

train_pos_dir = 'F:\vertebra_patches\train_pos';
train_pos_dir = 'F:\vertebra_patches\hist_shift_patch\train_pos';
train_neg_dir = 'F:\vertebra_patches\train_neg';
test_pos_dir='F:\vertebra_patches\test_pos';
test_neg_dir='F:\vertebra_patches\test_neg';


pos_train = sub_func(train_pos_dir);
pos_test  = sub_func(test_pos_dir);
neg_train = sub_func(train_neg_dir);
neg_test  = sub_func(test_neg_dir);

save('pos_train.mat','pos_train');
save('pos_test.mat', 'pos_test');
save('neg_train.mat','neg_train');
save('neg_test.mat', 'neg_test');


end



function pos_train = sub_func(train_pos_dir)
    train_postive = dir(fullfile(train_pos_dir,'*.png'));
    train_postive = train_postive(randperm(numel(train_postive)));
    pos_train=cell(1,length(train_postive)); 
    parfor i=1:length(train_postive) 
        pos_train(i) = cellstr(fullfile(train_pos_dir,train_postive(i).name)); 
    end 
end