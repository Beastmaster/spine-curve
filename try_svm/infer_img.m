%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inference on a whole image
%


img_name = 'F:\test\15-12-02_Y6124079/face.png';
img = imread(img_name);
img = imresize(img,0.5);
% img = dicomread(img_name);

%% split image into cell array
img_cells = [0];


%% load model.mat
load('model.mat');    % model
% octave=10;          % octave loaded..
% resize_factor = 0.5;% resize factor loaded..


%% inference
num_cells = numel(img_cells);
pos_cells = cell(1,num_cells);
octaves = cell(1,num_cells);
octaves(:) = {octave};
models = cell(1,num_cells);
models(:) = {model};

% resize patch
if(0)
% extract features
features=cellfun(@haar_feature,pos_cells,octaves,'UniformOutput',0);
% inference
labels = cellfun(@predict,models,features);
% reshape labels
img = repmat(labels,[1,1]);
end

any_func = @(patch) predict(model,haar_feature(patch,octave));
any_test = @(patch) numel(patch);

%I2 = blockproc(img,[100 120],any_func,'PadPartialBlocks',true);
%I2 = nlfilter(img,[100 120],any_func);
%I2 = colfilt(img,[100 120],'sliding',any_test);

stride = 20;

heights = 1:stride:size(img,1)-100;
widths = 1:stride:size(img,2)-120;
I = zeros(length(heights),length(widths));
for j=1:length(widths)
    parfor i=1:length(heights)
        patch = img(heights(i):heights(i)+100-1,widths(j):widths(j)+120-1);
        I(i,j)=any_func(patch); 
    end
    disp(j/length(widths));
end

I = imresize(I,stride,'nearest');

I2 = zeros(size(img));
I2(1:size(I,1),1:size(I,2)) = I;

