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
%   spine line (interpolated)
% Output:
%   couple: position couple (upper/lower vertebra)
%   angle: cobbs angle (right: >0; left:<0)
%   varargout{1}: coupled lines perpendicular lines
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

[~,cob_id] = sort(abs(diffs),'descend'); 
if(length(cob_id)>3)
    cob_id=cob_id(1:3);
end

[~,s_cob_id] = sort(cob_id);
cob_id = cob_id(s_cob_id);

%angle = 360*diffs(cob_id)/(2*pi);
angle = rad2deg(diffs(cob_id));
couple = [];
for i = 1:length(angle) 
    if(abs(angle(i))<10)
        continue
    end
    couple = [couple;line(locs(cob_id(i):cob_id(i)+1),:)];
end
cob_id = cob_id(abs(angle)>=10);
angle = angle(abs(angle)>=10);

if nargout>2
    pen_lines = [];
    len=200;
    
    for i = 1:size(cob_id)
        center1 = couple(2*i-1,:);
        center2 = couple(2*i,:);

        tan_u = -1/tans(cob_id(i));
        tan_d = -1/tans(cob_id(i)+1);

        lv1_line_u = get_perpend(tan_u,len,center1);
        lv1_line_d = get_perpend(tan_d,len,center2);
        pen_lines = [pen_lines;lv1_line_u;lv1_line_d];
    end
    varargout{1} = pen_lines;
end % end if

end % end function

%% draw perpendicular lines
% return value:
%  | y1 y2 |
%  | x1 x2 |
%
function output = get_perpend(tan,len,center)
    sin_u = tan/sqrt(1+tan*tan);
    cos_u = 1/sqrt(1+tan*tan);

    yyu = [len*sin_u , -len*sin_u] + center(2);
    xxu = [len*cos_u , -len*cos_u] + center(1);
    output = [yyu;xxu];
end
