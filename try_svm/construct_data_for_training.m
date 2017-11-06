% Author: QIN Shuo
% Date: 2016/12/03
%
%%%%%%%%%%%
% Construct data for training
% 
% " Each row of X represents one observation. Each column of X represents one variable, or predictor. "
%  
%  |----Predictors----|----Response----|
%  | x  | y  |  gray  |    True/False  |
%
%

%%

clear;

ddir = 'E:\eos_curve_train2';
ffs = dir(ddir);
list = {};
for i = 1: length(ffs)
    if ffs(i).isdir == 0
        list = [list;{ffs(i).name}];
    end
end;

training_x = [];
training_y = [];
training_gray = [];
response = [];

re_sz = 0.1;

disp(strcat('Total: ',num2str(length(list))));
for i = 1: length(list)
    disp(strcat('Processing: ',num2str(i)));
    
    fn = fullfile(ddir,list{i});
    ss = load(fn);
    ss = ss.ss;
    f_name = ss{1};
    image = ss{2};
    image = imresize(image,re_sz);
    lb = int32(ss{3}*re_sz);
    label = zeros(size(image));
    label(lb) = 1;
    
    [m,n] = size(image);
    tempx = int32(zeros(m*n,1));tempx = repmat((1:m),n,1);tempx = reshape(tempx,[m*n,1]);
    tempy = int32(zeros(m*n,1));tempy = repmat((1:n),m,1);tempy = reshape(tempy,[m*n,1]);
    temp_gray = reshape(image,[m*n,1]);
    temp_response = reshape(label,[m*n,1]);
    
    training_y = [training_y;tempy];
    training_x = [training_x;tempx];
    training_gray = [training_gray;temp_gray];
    response = [response;temp_response];
end


training = struct;
training = setfield(training,'x',training_x);
training = setfield(training,'y',training_y);
training = setfield(training,'gray',training_gray);
training = setfield(training,'response',response);

disp('Saving training.mat');
save('training.mat','training');

clear;




