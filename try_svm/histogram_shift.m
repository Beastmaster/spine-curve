%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%  shift histogram
%
% set a cutting percentage per; threshold;
% count number of pixels at the largest intensity by percentage
% shift by division.
%



function img_out = histogram_shift( img_in )
    h=histogram(int32(img_in),65536);bins = h.Values; close(gcf);
    
    per = 0.9;
    threshold = 3000;
    sum_bin = cumsum(bins);
    [~,pos] = min(sum_bin-numel(img_in)*per);
    img_out = im2double(img_in*threshold/pos);
end

