%%%%
%  EOS image
%   Spine line Detection:
%       GrayScale based method:  find largest gray value pixels in several
%       rows. Coronal view
%
%Author: QIN Shuo
%Date: 2016/7/7
%Organization: RC-MIC (CUHK)
%
%%%% This is the main function for my stupid algorithm... 
% Threshold, gradient threshold, and fit with spline


%% GrayScaleBased method
% Required: head.mat
%           pelvis.mat
%%%%%% Codition: First generate a curve %%%%%
% Input: varargin: {1}: process; {2}: dicom file
% Output:varargout:{1}: curve;   {2}: processed binary image
%%%%%% Condition: Update curve   %%%%%%%%%%%
% Input: varargin: {1}: update; {2}: preprocessed binary image; {3}: click
%        position
% Output:varargout:{1}: curve; {2}: updated binary image
function varargout = GrayScaleBased(varargin)
warning('off','all')

%% Default run block
% If no var set in, the program will run to search a default folder
% GrayScaleBased('dir','D:/QIN/image/lily/new/');
if (nargin == 0) || strcmp(varargin{1},'dir')
    if nargin == 0
        lst = dir('D:/QIN/image/lily/new/');
    elseif strcmp(varargin{1},'dir')
        lst = dir(varargin{2});
    end
dicom_list = {};
jpg_list = {};
for i=1:length(lst)
    if lst(i).isdir==0
        nn = strcat('D:/QIN/image/lily/new/',lst(i).name);
        if ~isempty(strfind(nn,'dcm'))
            dicom_list = [dicom_list;nn];
        elseif ~isempty(strfind(nn,'jpg'))
            jpg_list = [jpg_list;nn];
        else
            ;
        end
    end
end
for i=1:1:length(dicom_list)
    filename = char(dicom_list(i));
    
    % Read Files
    img = dicomread(filename);
    [curve,output,grad]= process(img);  % pre-process is integraded
    
    % plot
    subplot(1,3,1);imshow(imresize(img,0.5),[]);hold on;
    subplot(1,3,2);imshow(output ,[]);hold on;
    subplot(1,3,3);imshow(grad   ,[]);hold on;
    
    subplot(1,3,1);scatter(curve(2,:),curve(1,:),1,'.');
    subplot(1,3,2);scatter(curve(2,:),curve(1,:),1,'.');
    subplot(1,3,3);scatter(curve(2,:),curve(1,:),1);
    
    info = sprintf('Processing: %d',i);
    disp(info);

    % write result to txt file
    [path,name,~] = fileparts(filename);
    path = 'D:\QIN\image\lily\result';
    
    newname = strcat(path,'/',name,'.jpg');
    % Write to a file
    print(newname,'-djpeg')
    close;
    % Write curve points
    outputname = strcat(path,'/',name,'.txt');
    fileID = fopen(outputname,'w');
    fprintf(fileID,'%f %f\n',curve);
    fclose(fileID);
    
    %%%% gray plot %%%%
    img_r = imresize(img,0.5);
    cc = int16(curve);
    vv = zeros(length(curve),1);
    for i=1:length(curve)
        vv(i) = img_r(cc(1,i),cc(2,i));
    end
    
    % save .mat
    newname = strcat(path,'/',name,'.mat');
    save(newname,'vv');
end
disp('done');

%[curve,output] = GrayScaleBased('process',img);
elseif strcmp('process',varargin{1})
    [curve,output]= process(varargin{2});
    varargout{1} = curve;
    varargout{2} = output;

%[curve,output] = GrayScaleBased('update',bin_img,pos);
elseif strcmp('update',varargin{1})
    [curve,output] = update_curve(varargin{2},varargin(3));
    varargout{1} = curve*2;
    varargout{2} = output;
end

end

%% Process
% function body of finding spine line
%
%Output:
%   curve       : spline curve
%   varargout{1}: output: binary image used to generate curve
%   varargout{2}: gard: thresholded gradient map
%   varargout{3}: smth: smoothed original image
function [curve,varargout]= process(img)
 hw = waitbar(0,'Processing ...');
% Parameters
p=0.000000001;
p=0.00000001;
iterations = 3; % RANSAC iteration
distance = 200; % ROI extent around the spine line

% Resize
img_ori = imresize(img,0.5);
[~,width] = size(img_ori);

% Pre process
% output is a image: threshold -> overlay line ROI
waitbar(1/5);
[output smth]= pre_process(img_ori);
% strip head and pelvis
pos = strip_head_pelvis(img_ori,'head');  %pos = int16(pos/2);
smth(1:pos,:)=0;
output(1:pos,:)=0;

pos = strip_head_pelvis(img_ori,'pelvis');  %pos = int16(pos/2);
smth(pos:end,:)=0;
output(pos:end,:)=0;

% Generate gradient map
grad = gradient(smth);
grad(:,1:width*1/4) = 0;
grad(:,width*3/4:width) = 0;
grad(grad<0) = 0;
grad = threshold_histogram(grad,0.01);
waitbar(2/5);

% curve fitting with RANSAC
for itr = 1:iterations
    waitbar(itr/iterations);
    % Way 1
    output = output+grad;
    [row,col] = find(output~=0);
    row = row(1:5:length(row));
    col = col(1:5:length(col));
    % Way 2
    %[output_row,output_col] = find(output~=0);
    %[grad_row,grad_col] = find(grad~=0);
    %row = [output_row;grad_row];
    %col = [output_col;grad_col];

    % fit in the first
    xxi = min(row):1:max(row);
    ys = csaps(row,col,p,xxi);
    
    for ll = 1:length(xxi)
        d1 = int16(ys(ll)-distance/2);
        d2 = int16(ys(ll)+distance/2);
        
        output(xxi(ll),1:d1) = 0;
        output(xxi(ll),d2:width) = 0;
        grad(xxi(ll),1:d1) = 0;
        grad(xxi(ll),d2:width) = 0;
    end
end
close(hw);

%test_plot(smth,grad);

curve = [xxi;ys]*2;
if nargout >= 2
    varargout{1} = output;
end
if nargout >= 3
    varargout{2} = grad;
end
if nargout >= 4
    varargout{3} = smth;
end

end


%% update curve by specifying a position
%Input:
%   bin_img: thresholded binary image
%   pos    : ginput get position
function [curve,varargout] = update_curve(bin_img,pos)
pos = int16(cell2mat(pos)); % col,row
[x,y] = size(bin_img);
 hw = waitbar(0,'Re-adjusting ...');
%1. earse a block
row = 100;
col = 100;
if (pos(2)+row)>x
    row_u = x; % upper bounding of row
else
    row_u = pos(2)+row;
end

if (pos(2)-row)<1
    row_l = 1; % lower bounding of row
else
    row_l = pos(2)-row; % lower bounding of row
end

if (pos(1)+col)>y
    col_u = y; % upper bounding of colum
else
    col_u = pos(1)+col; % upper bounding of colum
end


if (pos(1)-col)<1
    col_l = 1; % lower bounding of colum
else
    col_l = pos(1)-col; % lower bounding of colum
end


block_row = ( row_l : row_u );
block_col = ( col_l : col_u );
bin_img(block_row,block_col) = 0;
bin_img(block_row, : ) = 0;
 waitbar(1/3);
%2. add a new block
row = 50;
col = 50;
nblock_row = ( (pos(2)-row) : (pos(2)+row) );
nblock_col = ( (pos(1)-col) : (pos(1)+col) );
bin_img(nblock_row,nblock_col) = 1;

%3. fit again
[row,col] = find(bin_img~=0);
xxi = min(row):1:max(row);
p=0.000000001;
ys = csaps(row,col,p,xxi);
waitbar(2/3);
 
curve = [xxi;ys];
if nargout == 2
    varargout{1} = bin_img;
end

close(hw);
end

%% Pre process
% input a image
% output: binary image
% image:  pre_processed gray image ( Central ROI are extracted )
function [output,image] = pre_process(img)
 hw = waitbar(0,'Thresholding ...');
global_threshold = 50000;
region_threshold = 0.1; % percentage
[~,width] = size(img);

% 0. Gauss smoothing
img = imgaussfilt(img,10);
%img = imadjust(img);

% 1. global threshold
threshold = global_threshold;
img(img>threshold) = 0;

% 2. Image Open
se = strel('square',5);
img = imclose(img,se);
sq = ones(20,20);
sq = sq/400;
img = conv2(img,sq,'same');
img = img/350;
%imwrite(img,'D:/QIN/matlab/pre_processd.jpg');

% 2. extract ROI
%img = img(:,width*1/3:width*2/3);
img(:,1:width*1/4) = 0;
img(:,width*3/4:width) = 0;
[height,width] = size(img);
image = img;

% allocate memory first
output = zeros([height,width]);

%%%% extract rows === Detrending
row_step = 20;
% loop outside
for i=1:row_step:height
    waitbar(i*row_step/height);
    % loop boundary
    if (i+row_step-1)>height
        row_step = height-i+1;
    end
    
    % extract a block
    row = img(i:i+row_step-1,:);
    
    % threshold 1
    %row = threshold_gray_percent(row,region_threshold);
    
    % threshold 2
    row = threshold_histogram(row,region_threshold);
    
    %output(i:i+row_step-1,:)=output(i:i+row_step-1,:) + row;
    output(i:i+row_step-1,:)=row;
end
close(hw);

end

%% Theshold by gray-value percent
% calculate the range of gray-scale of the block
% and then multiply range with a specific percent
% and then threshold
% Parameters:
%   block: input block
%   region_threshold: percentage of threshold level
function new_block = threshold_gray_percent(block,region_threshold)
    % get gray scale range of the block
    ma = max(max(block(:,:)));
    mi = min(min(block(:,:)));
    ran = ma-mi;
    % threshold
    thres = ma-(ran * region_threshold);
    new_block = (block>thres);
end

%% Theshold by histogram
% calculate the histogram of the matrix
% set largest n values to 1 and others to 0
% Parameters:
%   block: input block
%   region_threshold: percentage
function new_block = threshold_histogram(block, region_threshold)
    [aa,bb] = size(block);
    sz = aa*bb;
    sorted_block = sort(block(:));
    % Generate threshold
    thres_index = int32(sz*(1-region_threshold));
    thres = sorted_block(thres_index);
    % Threshold
    new_block = (block>=thres);
end

%% Strip head and pelvis
%Strip head area from the image
%Input: 
%       img: Preprocessed image
%       option: 'head' or 'pelvis'
%       pre: pre-process the image or not, if you specify a parameter
function position = strip_head_pelvis(img, option ,pre)
if nargin > 2
    [out,imm] = pre_process(img);
else
    imm = img;
end
[height,width] = size(imm);

position =0;

%% strip head
if strcmp(option,'head')
    head = load('resources/head.mat');
    template = imresize(head.region,0.5);
    hh = 1/5;
    block = imm(1:int16(height*hh),:);
    [~,rc] = Matching_by_correlation(template,block,'head');
    position = rc(1)+ size(template,1);
    return;
    
    region_threshold = 0.1;
    hh = 1/5;
    
    block = imm(1:int16(height*hh),:);
    new_block = threshold_histogram(block, region_threshold);
    
    % find boundary position
    % from the top to the bottom, find the first non-zero row and record the position
    se = strel('disk',5);
    new_block = imerode(new_block,se);
    for i = int16(height*hh):-1:1
        row = new_block(i,:);
        if ~isempty(nonzeros(row))
            position = i;
            break;
        end
    end
    position = position + int16(height/25);
    

%% strip pelvis
elseif strcmp(option,'pelvis')
    pelvis = load('resources/pelvis.mat');
    template =imresize( pelvis.region ,0.5);
    hh = 1/3;
    block = imm(int16(height*hh):height,:);
    [~,rc] = Matching_by_correlation(template,block,'pelvis');
    position = rc(1) + int16(height*hh)+100;
    return;
    
    region_threshold = 0.1;
    hh = 3/10;
    
    block = imm(int16(height*hh):height,:);
    new_block = threshold_histogram(block, region_threshold);
    
    % find boundary position
    % from the top to the bottom, find the first non-zero row and record the position
    se = strel('disk',5);
    new_block = imerode(new_block,se);
    % find centeroid of image
    [block_x,block_y] = find (new_block) ;
    position = mean(block_x);
    position = int16(height*hh)+position;
    
%% option error
else
    disp('Options error: input head or pelvis');
end

end








%% Test Polot
% Create 2 figure
% 1. display the image and a line moving from up to the bottom
% 2. plot the gray value of the line in 1.
function test_plot(background,img)
background = imresize(background,0.2);
%img = imresize(img,0.2);
[row col] = size(background);
[row_ col_] = size(img);
xx_b = 1:col;
yy_b = zeros(col);

xx = 1:col_;

subplot(1,2,1);
imshow(background);
for i=500:row
% plot the line on the image
subplot(1,2,1)
yy_b(:) = i;
hold on
plot(xx_b,yy_b); 
hold off;

% extract a row in the image
line = img(i*5,:);
subplot(1,2,2);
plot(xx,line);
% pause to refresh the image view
pause(0.000001)
end

end

%% Test plot by click
% Mouse click a position
% Plot gray-value of that row
function test_plot_click(img)
    figure(1);
    imshow(img,[]);
    [row,col] = size(img)
    
    while(1)
    figure(1)
    [x,y] = ginput(1);
    disp(int32(x));
    disp(int32(y));
    
    figure(2)
    plot(img(int32(y),:))
    end
end


%% Horizontal Peak
% Compute the horizontal peak map of a matrix
function out = horizontal_peak( ma )
out = sign((diff(ma'))');
%% To be continued
end


%% Write to picture
% Input a picture name list
% Put all the pictures in to one
function write_to_picture_matric(name_list,name)

% Parameters
output_pic_name = strcat('D:/QIN/image/lily/new/rr',name);
output_pic_name = strcat(output_pic_name,'.jpg');


% Total 27 pictures
total = length(name_list); % total number of pictures
col = 6 ;
row = 1 ;

xx=[163 408];
yy=[134 738];

figure(1)
for i=1:min(col*row,total)
    name = char(name_list(i));
    img = imread(name);
    % Extract ROI
    img_roi = img(yy(1):yy(2),xx(1):xx(2),:);
    subplot(row,col,i);imshow(img_roi);title(i)
end

% Write this image to a jpg file
print(output_pic_name,'-djpeg');

end
