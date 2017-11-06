

clear;

training = load('training.mat');
training = training.training;

tbl = [training.x training.y training.gray];
y = training.response;

Mdl = fitcsvm(tbl,y);



clear;