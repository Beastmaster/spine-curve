%%%%%%%%%%%%%%%
% Author: QIN Shuo
% Organization: CUHK
% Date: long long ago
% 
%
%% process a bundle of files
% Input: files is a cell list of full-filenames
% output file: dicom filename and cobb angle
function bundle_process(files,dst_dir)
%%%%% Required parameters %%%%
%dst_dir = 'D:\Project\spine_seg_spline\temp\test_1106';
%files = importdata(list);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output = [];
fail = [];
log = fullfile(dst_dir,'output.csv');
fid = fopen(log,'w');

color = [1,0,0;1,1,0;0,0,1];
plot_size = 2;
add_fig = figure();
for i = 1:length(files)
    filename = char(files(i));
    [~,pname,~] = fileparts(filename);
    fprintf(fid,'%s,',pname);
    try
        Ori_Image = dicomread(filename);
        
        %------ fit
        [Curve,~]= GrayScaleBased('process',Ori_Image);
        
        vv = Curve';
        [~,Angle,pen_line] = find_cobbs(vv);
        
        % display
        try
            cla(add_fig);
        catch
            break;
        end
        figure(add_fig);
        imshow(Ori_Image,[]); hold on;
        %scatter(Curve(2,:),Curve(1,:),3,'b','filled-o'); hold on;
        for ii= 1:4:size(pen_line,1)
            color_id = (ii-1)/4+1;
            plot(pen_line(ii,:),pen_line(ii+1,:),'LineWidth', plot_size,'Color',color(color_id,:));hold on;
            plot(pen_line(ii+2,:),pen_line(ii+3,:),'LineWidth', plot_size,'Color',color(color_id,:));hold on;
        end
        
        try
            for ii=1:3
                if Angle(ii)>0
                    direct = 'right';
                else
                    direct = 'left ';
                end
                str = sprintf('%d: %6s : %3f',ii,direct,abs(Angle(ii)));
                text(0,ii*120-60,str,'Color','red','FontSize',14);
                
                % write to log file
                fprintf(fid,'%6s, %3f,',direct,abs(Angle(ii)));
            end
        catch
            % no ops
        end
        fprintf(fid,'\n');
        F = getframe(add_fig); %gcf
        Image = frame2im(F);
        imwrite(Image, fullfile(dst_dir,strcat(pname,'.png')));
    catch
        fprintf(fid,'failed\n');
        disp(filename);
    end
end % end for
fclose(fid);

try
    close(add_fig);
catch
    % no ops
end

end % end functions

% get patient ID from filename
function id = id_from_fname(filename)
    [~,name,~] = fileparts(file);
    id = name;
end


function test_basic_fucntion()
clear;
close all;
warning ('off','all');

line_name = '/home/qinshuo/Disks/QIN/image/lily/result/10.txt';
img_name = '/home/qinshuo/Disks/QIN/image/lily/new/6.dcm';
dicom_list = search_file_inpath('D:\QIN\image\lily\new\','.dcm');
line_list = search_file_inpath('D:\QIN\image\lily\result\','.txt');

imm = dicomread(img_name);
draw_sagittal_line(imm);

return;
%extract_head_template(img_name);
%extract_pelvis_template(img_name);
%draw_cobb_angle(line_name,img_name);
%Extract_head_pelvis('pelvis');%'head'

    pelvis = load('pelvis.mat');
    template = pelvis.region;
    hh = 1/2;
    imm = dicomread(img_name);
    [height,~] = size(imm);
    block = imm(int16(height*hh):height,:);
    [gg,rc] = Matching_by_correlation(template,block,'pelvis');
    position = rc(1) + int16(height*hh);
    
    imshow(imm,[]);
    hold on;
    scatter(rc(2),position,50,'o','filled');
    
return;

img = dicomread(img_name);
[curve,output] = GrayScaleBased('process',img);
img2 = imresize(img,0.5);
subplot(1,2,1);imshow(img2,[]); hold on;
subplot(1,2,1);scatter(curve(2,:),curve(1,:),1,'.'); hold off;
subplot(1,2,2);imshow(output,[]); 
%update
pos = ginput(1);
[curve,output] = GrayScaleBased('update',output,pos);
subplot(1,2,1);imshow(img2,[]); hold on;
subplot(1,2,1);scatter(curve(2,:),curve(1,:),1,'.'); hold off;
subplot(1,2,2);imshow(output,[]); 

% draw cobb angle
draw_cobb_angle(img2,curve);

return;



for i = 1:length(line_list);
    %draw_cobb_angle(char(line_list(i)),char(dicom_list(i)));
    find_vertebra_plot_gray(char(dicom_list(i)),char(line_list(i)));
    
    [~,name,~] = fileparts(char(dicom_list(i)));
    path = 'D:\QIN\image\lily\draw_locate';
    newname = strcat(path,'/',name,'.jpg');
    print(newname,'-djpeg')
end


end



function draw_cobb_angle(img_name,line_name)
close all;

if ischar(img_name)
    img = dicomread(img_name);
    img = imresize(img,0.5);
else
    img = img_name;
end
if ischar(line_name)
    vv = load(line_name);
else
    vv = line_name';
end

[couple,angle,line1,line2] = find_cobbs(vv);

imshow(img,[]);
hold on;
scatter(vv(:,2),vv(:,1),'.');
hold on;
scatter(couple(:,2),couple(:,1),'filled--o');
hold on;
scatter(line1(2,:),line1(1,:),5,'filled--o');
hold on;
scatter(line2(2,:),line2(1,:),5,'filled--o');

ang = num2str(angle);
title(ang);

end




function find_vertebra_plot_gray(img_name,line_name)
close all;

if ischar(img_name)
    img = dicomread(img_name);
    img = imresize(img,0.5);
else
    img = img_name;
end
if ischar(line_name)
    vv = load(line_name);
else
    vv = line_name;
end

line = plot_gray(img_name,line_name);

ll = extract_locate(line);
pp = ll(:,3);

imshow(img,[]);
hold on;
scatter(vv(:,2),vv(:,1),'.');
%subplot(1,2,2);
nn = ones(size(img));
[~,wd] = size(img);
pp = (pp - min(pp))/ range(pp)* wd;
%imshow(nn,[]);
hold on;
plot(pp,ll(:,1));
hold on;
% find peaks
[pk,locs] = findpeaks(pp);
scatter(vv(locs,2),vv(locs,1),10,'o','filled');

end


function list = search_file_inpath(path,suffix)
lst = dir(path);
list = {};
for i=1:length(lst)
    if lst(i).isdir==0
        nn = strcat(path,lst(i).name);
        if ~isempty(strfind(nn,suffix))
            list = [list;nn];
        end
    end
end

end


function Extract_head_pelvis(opt)
path = 'D:/QIN/image/lily/new/';
lst = dir(path);
dicom_list = {};
jpg_list = {};
for i=1:length(lst)
    if lst(i).isdir==0
        nn = strcat(path,lst(i).name);
        if ~isempty(strfind(nn,'dcm'))
            dicom_list = [dicom_list;nn];
        elseif ~isempty(strfind(nn,'jpg'))
            jpg_list = [jpg_list;nn];
        else
            ;
        end
    end
end

if strcmp(opt,'head')
    head = load('head.mat');
    template = head.region;    
else
    pelvis = load('pelvis.mat');
    template = pelvis.region;
end


for i=1:length(dicom_list)
    close  all;
    disp(i);
    
    filename = char(dicom_list(i));
    img = dicomread(filename);    
    
    [~,rc] = Matching_by_correlation(template,img,opt);
    
    hFig = figure;
    hAx  = axes;
    imshow(img,'Parent', hAx);
    imrect(hAx, [rc(2), rc(1), size(template,2), size(template,1)]);
    
    % Write to a file
    [~,name,~] = fileparts(filename);
    if strcmp(opt,'head')
        path = 'D:\QIN\image\lily\result_head';
    else
        path = 'D:\QIN\image\lily\result_pelvis';
    end
    newname = strcat(path,'/',name,'.jpg');
    print(newname,'-djpeg')
end

end


function extract_head_template(img_name)

img = dicomread(img_name);
%img = imresize(img,0.5);

Matching_by_correlation(img);

movefile('default.mat', 'head.mat');

end



function extract_pelvis_template(img_name)

img = dicomread(img_name);

Matching_by_correlation(img);


movefile('default.mat', 'pelvis.mat');
end



function draw_sagittal_line(img)

imshow(img);hold on;

[x,y] = ginput(20);

pos = [x';y'];

curve = Sagittal_line(pos);

scatter(curve(2,:),curve(1,:));

end



