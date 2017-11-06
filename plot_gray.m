%%%%
% Polt the gray value variation on the spine line
%
%
%Author: QIN Shuo
%Date: 2016/7/29
%Organization: RC-MIC (CUHK)
%

%% Plot gray
%Input: 
%   img_name: dicom EOS image name, must resize to 0.5
%   line_name: a txt file to store point on the line
%Output: 
%   vv: gray value secquence
function vv = plot_gray(img_name,line_name)

% read dicom
img = dicomread(img_name);
img = imresize(img,0.5);
% read curve
curve = load(line_name);

% gaussian smooth
img = imgaussfilt(img,2);

cc = int16(curve);
vv = zeros(length(curve),2);
for i=1:length(curve)
    vv(i,1) = cc(i,1);
    vv(i,2) = img(cc(i,1),cc(i,2));
end

if(0)
subplot(1,2,1)
imshow(img,[]);hold on;
subplot(1,2,1);
scatter(cc(:,2),cc(:,1),'.');hold off;

%[row,~] = size(img);
%blank = ones(row,int16(range(vv(:,1))));
subplot(1,2,2)
plot(vv(:,2),vv(:,1)); hold off;
end

end