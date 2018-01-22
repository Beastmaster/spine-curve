%
%
%
%

original_list = 'F:\EOS_for_segmentation\test\list.txt';
list = importdata(original_list);
save_path = 'F:\EOS_for_segmentation\test_patches';



path = 'F:\EOS_for_segmentation\test_patches\result';
prefix = '002';
mid = '_res';
im = assemble_parts(path,prefix,mid);
imshow(im,[])
return


h=waitbar(0,'wait');
for i=1:length(list)
    item = list{i};
    items = strsplit(item);
    
    img_name = items{1};
    label_name = items{2};

    prefix = num2str(i,'%03d');
    split_patch(img_name,label_name,save_path,prefix)
    
    waitbar(i/length(list));
end
close(h)

