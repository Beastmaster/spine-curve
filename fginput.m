%%%%%%%%
% fast ginput

function [ out1,out2,out3 ] = fginput( N , ax )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
xl = get(ax,'xlim'); 
yl = get(ax,'ylim'); 
pos = get(ax,'pos'); 
xc = get(ax,'xcolor'); 
yc = get(ax,'ycolor'); 
xsc = get(ax,'xscale'); 
ysc = get(ax,'yscale'); 
xdir = get(ax,'xdir'); 
ydir = get(ax,'ydir'); 

tmpax = axes('pos',pos,...
    'xlim',xl,'ylim',yl,...
    'color','none',...
    'xcolor',xc,'ycolor',yc,...
    'xtick',[],'xticklabel','',...
    'ytick',[],'yticklabel','',...
    'xdir',xdir,'ydir',ydir,...
    'xscale',xsc,'yscale',ysc); 


switch nargout
    case {0,1} 
        if nargin
            out1 = ginput(N); 
        else
            out1 = ginput;
        end
            
    case 2
        if nargin
            [out1,out2] = ginput(N); 
        else
            [out1,out2] = ginput; 
        end
            
    case 3
        if nargin
            [out1,out2,out3] = ginput(N); 
        else
            [out1,out2,out3] = ginput; 
        end
end   

% Delete temporary set of axes: 
delete(tmpax)

end

