%%%%
%Find cobbs angle given the spine line
%
%Author: QIN Shuo
%Date: 2016/7/29
%Organization: RC-MIC (CUHK)
%


%% Find_cobbs
% Find cobbs angle given a spine line
% Input: 
%   spine line
% Output:
%   couple: position couple
%   angle: cobbs angle
%   varargout{1}: first couple lines
%   varargout{2}: second couple lines
function [couple,angle,varargout] = find_cobbs( line )

tanl = zeros(size(line));
tanl(:,1) = line(:,1);
for i = 1:length(line)-1
    tanl(i,2) = (line(i+1,2)-line(i,2))/(line(i+1,1)-line(i,1));
end
tanl(i+1,2) = tanl(i,2);  

[~,locs] = findpeaks(abs(tanl(:,2)));

locs = [1;locs;length(tanl)];

tans = tanl(locs,2);
angl = atan(tans);

% find 2 near points that has largest angle
diffs = angl(2:end)-angl(1:end-1);
[max_angle,max_id] = max(diffs);
[min_angle, min_id] = min(diffs);

% if angle<0: curve center locates on the left
% if angle>0: curve center locates on the right
max_angle = 360 * max_angle/(2*pi);
min_angle = 360 * min_angle/(2*pi);
if max_id<min_id
    angle = [max_angle,min_angle];
else
    angle = [min_angle,max_angle];
end

couple1 = line(locs(max_id:max_id+1),:);
couple2 = line(locs(min_id:min_id+1),:);
couple = [couple1;couple2];

if nargout>3
    len=200;
    
    tan_u = -1/tans(max_id);
    tan_d = -1/tans(max_id+1);
    
    center1 = couple1(1,:);
    center2 = couple1(2,:);
    lv1_line_u = get_perpend(tan_u,len,center1);
    lv1_line_d = get_perpend(tan_d,len,center2);
    varargout{1} = { lv1_line_u;lv1_line_d };
        
    tan_u = -1/tans(min_id);
    tan_d = -1/tans(min_id+1);
    
    center1 = couple2(1,:);
    center2 = couple2(2,:);
    lv2_line_u = get_perpend(tan_u,len,center1);
    lv2_line_d = get_perpend(tan_d,len,center2);
    varargout{2} = { lv2_line_u; lv2_line_d };
end

end

function output = get_perpend(tan,len,center)
    sin_u = tan/sqrt(1+tan*tan);
    cos_u = 1/sqrt(1+tan*tan);

    yyu = [len*sin_u , -len*sin_u] + center(2);
    xxu = [len*cos_u , -len*cos_u] + center(1);
    output = [yyu;xxu];
end
