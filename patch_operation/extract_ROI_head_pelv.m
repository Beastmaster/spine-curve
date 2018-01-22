%%%%%
%
% crop image patches
%
%

function extract_ROI_head_pelv()

imname='D:\Project\spine_seg_spline\temp\test_dcm_531/xx.dcm';

dds = dir('D:\Project\spine_seg_spline\temp\test_dcm_531/*.dcm');
base_dir = 'D:\Project\spine_seg_spline\temp\test_dcm_531/';

for i=1:length(dds)
    dd = dds(i).name;
    imname = fullfile(base_dir,dd);
    %extract_ROI_per(imname);
    extract_clavicle(imname);
end

end


function extract_clavicle(imname)
    image = dicomread(imname);
    imshow(image,[]);

    h=imrect(gca,[600,180,600,350]);
    ph = wait(h);
    ph = int32(ph);

    head = image(ph(2):(ph(2)+ph(4)),ph(1):(ph(1)+ph(3)));

    [~,id,~] = fileparts(imname);
    imwrite(head,strcat(id,'_t1.png'));
end

function extract_ROI_per(imname)

image = dicomread(imname);
imshow(image,[]);

h=imrect(gca,[600,1,800,301]);
ph = wait(h);
ph = int32(ph);

h=imrect(gca,[1140,2634,500,600]);
pp = wait(h);
pp=int32(pp);

head = image(ph(2):(ph(2)+ph(4)),ph(1):(ph(1)+ph(3)));
pelv = image(pp(2):(pp(2)+pp(4)),pp(1):(pp(1)+pp(3)));

[~,id,~] = fileparts(imname);
imwrite(head,strcat(id,'_head.png'));
imwrite(pelv,strcat(id,'_pelv.png'));

end


