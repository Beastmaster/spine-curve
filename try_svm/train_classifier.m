%%%%%%%
% Date: 2017/7/5
%
% load training data and train
%

clear

load('pos_train.mat'); % pos_train
load('neg_train.mat'); % neg_train

octave=9;
resize_factor=0.25;

% find patch size first
a1 = pos_train{1};
patch=imread(a1);
patch=imresize(patch,resize_factor);
feature=haar_feature(patch,octave);
feature_len = length(feature);

% allocate first
X=zeros(length(pos_train)+length(neg_train),feature_len);
Y=zeros(1,length(pos_train)+length(neg_train));

% shape patch: 200*240
parfor i=1:length(pos_train)
    a1 = pos_train{i};
    patch=imread(a1);
    patch=imresize(patch,resize_factor);
    feature=haar_feature(patch,octave);
    X(i,:)=feature;
    Y(i)=1;
end 

idx_map=(1+length(pos_train)):(length(neg_train)+length(pos_train));
parfor i=1:length(idx_map);
    a1 = neg_train{i};
    patch=imread(a1);
    patch=imresize(patch,resize_factor);
    feature=haar_feature(patch,octave);
    X(i,:)=feature;
    Y(i)=0;
end


model = fitcsvm(X,Y,'Standardize',true,'KernelFunction','RBF','KernelScale','auto');
save('model.mat','model','octave','resize_factor');
disp('training finished..');


