



files = importdata('list.txt');
for i = 1:length(files)
   filename = char(files(i));

    file_in = filename;
    out_dir = 'D:\Project\spine_seg_spline\temp\any_test_dcm_531';

    file_out=[num2str(randi(1e5)),'.dcm'];
    file_out = fullfile(out_dir,file_out);

    dicomanon(file_in,file_out);
end

