%%%%%%%%
% Test classifier
%
% note: use cellfun to parallelize predication


load('neg_test.mat'); % neg_test
load('pos_test.mat'); % pos_test
load('model.mat');    % model

% octave=10; %octave loaded..
% resize_factor = 0.5;

len_pos=length(pos_test);
len_neg=length(neg_test);

label_truth = zeros(1,len_pos+len_neg);
label_truth(1:len_pos)=1;
label_truth(len_pos+1:len_pos+len_neg)=0;

label = zeros(1,len_pos+len_neg);

% inference positive test data
pos_cells = cell(1,len_pos);
octaves = cell(1,len_pos);
models = cell(1,len_pos);
for i=1:len_pos
    a1 = pos_test{i};
    patch=imread(a1);
    patch=imresize(patch,resize_factor);
    pos_cells(i)=mat2cell(patch,size(patch,1));
    octaves{i}=octave;
    models{i}=model;
end
features=cellfun(@haar_feature,pos_cells,octaves,'UniformOutput',0);
lab_pos = cellfun(@predict,models,features);

% inference negative test data
neg_cells = cell(1,len_neg);
octaves = cell(1,len_neg);
models = cell(1,len_neg);
for i=1:len_neg
    a1 = neg_test{i};
    patch=imread(a1);
    patch=imresize(patch,resize_factor);
    neg_cells(i)=mat2cell(patch,size(patch,1));
    octaves{i}=octave;
    models{i}=model;
end
features=cellfun(@haar_feature,neg_cells,octaves,'UniformOutput',0);
lab_neg = cellfun(@predict,models,features);

% re-allocate
label(1:len_pos) = lab_pos;
label(len_pos+1:len_pos+len_neg) = lab_neg;

acc = mean(double((label==label_truth)));
true_lab = label(1:len_pos);
true_lab_truth = label_truth(1:len_pos);
acc_true = mean(double(true_lab==true_lab_truth));

false_lab = label(len_pos+1:len_pos+len_neg);
false_lab_truth = label_truth(len_pos+1:len_pos+len_neg);
acc_fals = mean(double(false_lab==false_lab_truth));

disp(strcat('global accuracy',num2str(acc)));
disp(strcat('true accuracy',  num2str(acc_true)));
disp(strcat('false accuracy', num2str(acc_fals)));


