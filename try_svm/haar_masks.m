%%%%%%%%%%%%%%%%%%%%%%%%
% harr-like feature mask
%

function masks = haar_masks()
masks=[];
% viola feature
hor = [1 -1];
masks=[masks;mat2cell(hor,1)];
ver = hor';
masks=[masks;mat2cell(ver,2)];

hor3 = [1 -1 1];
masks=[masks;mat2cell(hor3,1)];

ver3 = hor3';
masks=[masks;mat2cell(ver3,3)];

sqr  = [-1 1; 1 -1];
sqr_ = [1 -1; -1 1];
masks=[masks;mat2cell(sqr,2)];
masks=[masks;mat2cell(sqr_,2)];

% Lienhart features
sqr3  = [1 0 0;0 -1 0;0 0 1];
sqr3_ = [0 0 1;0 -1 0;1 0 0];
masks=[masks;mat2cell(sqr3,3)];
masks=[masks;mat2cell(sqr3_,3)];

sqr4  = [0 0 0 1;0 0 -1 0;0 -1 0 0;1 0 0 0];
sqr4_ = [1 0 0 0;0 -1 0 0;0 0 -1 0;0 0 0 1];
masks=[masks;mat2cell(sqr4,4)];
masks=[masks;mat2cell(sqr4_,4)];


center3  = [1 1 1;1 -1 1; 1 1 1];
center3_ = [0 1 0;1 -1 1; 0 1 0];
masks=[masks;mat2cell(center3,3)];
masks=[masks;mat2cell(center3_,3)];

end

