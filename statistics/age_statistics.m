%%%%%%%% statistics of sample ages


basedir = 'D:\Project\spine_seg_spline\temp\test_dcm_531';

ddirs = dir(fullfile(basedir,'*.dcm'));

ages = [];
for i=1:length(ddirs)
    name = fullfile(basedir,ddirs(i).name);
    info = dicominfo(name);
    age = info.PatientAge;
    age = str2num(age(1:end-1));
    ages = [ages age];
end



