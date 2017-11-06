
%%%%%%%
%
% load training data and train
%



load('pos_train.mat'); % pos_train
load('neg_train.mat'); % neg_train

octave=20;
resize_factor=0.5;

% find size first
a1 = pos_train{1};
patch=imread(a1);
patch=imresize(patch,resize_factor);
feature=haar_feature(patch,octave);
feature_len = length(feature);
% allocate first
X=zeros(length(pos_train)+length(neg_train),feature_len);
Y=zeros(1,length(pos_train)+length(neg_train));

% shape patch: 200*240
for i=1:length(pos_train)
    a1 = pos_train{i};
    patch=imread(a1);
    patch=imresize(patch,resize_factor);
    feature=haar_feature(patch,octave);
    X(i,:)=feature;
    Y(i)=1;
end 

for i=1:length(neg_train)
    a1 = neg_train{i};
    patch=imread(a1);
    patch=imresize(patch,resize_factor);
    feature=haar_feature(patch,octave);
    X(i+length(pos_train),:)=feature;
    Y(i+length(pos_train))=0;
end


model = fitcsvm(X,Y,'Standardize',true,'KernelFunction','RBF','KernelScale','auto');
save('model.mat','model','octave','resize_factor');
disp('training finished..');


