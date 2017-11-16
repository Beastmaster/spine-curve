

%% head
% read all imge
basedir = 'D:\Project\spine-curve/patch_operation/sample';
ddir = dir(fullfile(basedir,'*head.png'));

fst_name = fullfile(basedir,ddir(1).name);
imsz = size(imread(fst_name));

heads = zeros(length(ddir),imsz(1)*imsz(2));
for i=1:length(ddir)
    fname = fullfile(basedir,ddir(i).name);
    im = imread(fname);
    heads(i,:) = im(:);
end
mean_head = reshape(mean(heads,1),imsz);
[coeff,~,~] = pca(heads');
heads = heads';
principle_head = heads*coeff(:,1:5);
principle_head = mean(principle_head,2);
principle_head = reshape(principle_head,imsz);

imshow(principle_head,[]);


%% pelvis
% read all imge
basedir = 'D:\Project\spine-curve/patch_operation/sample';
ddir = dir(fullfile(basedir,'*pelv.png'));

fst_name = fullfile(basedir,ddir(1).name);
imsz = size(imread(fst_name));

pelviss = zeros(length(ddir),imsz(1)*imsz(2));
for i=1:length(ddir)
    fname = fullfile(basedir,ddir(i).name);
    im = imread(fname);
    pelviss(i,:) = im(:);
end
mean_pelvis = reshape(mean(pelviss,1),imsz);
[coeff,~,~] = pca(pelviss');
pelviss = pelviss';
principle_pelvis = pelviss*coeff(:,1:5);
principle_pelvis = mean(principle_pelvis,2);
principle_pelvis = reshape(principle_pelvis,imsz);

imshow(principle_pelvis,[]);

