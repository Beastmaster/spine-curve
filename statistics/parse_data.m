
%% wash: delete Not avaliable data
if(1)
load('full_test.mat');
test_data;
for i=length(test_data):-1:1
    if strcmp(test_data{i,5},'NA')
       disp(test_data{i,1}); 
       test_data(i,:) = [];
    end
end
xlswrite('washed_data.xlsx',test_data);
return;
end

%% search and append items to test_data
if(0)
clear;
load('xlsx_data.mat'); truth_data = raw;
[truth_num_pid,truth_num_item] = size(truth_data);

load('my_res.mat');  test_data = my_res;
[test_num_pid,test_num_item] = size(test_data);
new_items = cell(test_num_pid,truth_num_item-1);
test_data = [test_data new_items];

for i=2:truth_num_pid
    pid = raw{i,1};

    % search pid in my_res
    for j =1:test_num_pid
        my_pid = my_res{j,1};
        if strcmp(pid,my_pid)
            disp(pid)
            truth_row = truth_data(i,2:truth_num_item);
            test_data(j,test_num_item+1:size(test_data,2)) = truth_row;
            continue;
        end
    end
end

return;
end

%% Read my_res.txt and convert to my_res.mat
if(0)
clear;
fid = fopen('my_res.txt');
my_res=[];
tline = fgets(fid);
while ischar(tline)
    tline = fgets(fid);
    % split line
    try
        C = strsplit(tline);
        c1 = C(1);
        c2 = str2double(C(2));
        c3 = str2double(C(3));
        my_res=[my_res ;{c1,c2,c3}];
    catch
        disp(strcat('error: ',tline));
    end
end

save('my_res.mat','my_res');
fclose all;
end
