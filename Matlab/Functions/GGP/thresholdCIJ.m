function [CIJ_thr_cell, mask] = thresholdCIJ2(CIJcell,thr, idx)

if ~exist('idx','var'); idx=1:length(CIJcell); end


CIJstack = cell2mat(CIJcell(1,1,idx));


CIJ_thr_mean = threshold_proportional(nanmedian(CIJstack,3),thr);
mask = CIJ_thr_mean ~= 0;
mask = double(mask);

missing = cellfun(@isempty,CIJcell);

CIJ_thr_cell = cell(size(CIJcell));
CIJ_thr_cell(~missing) = cellfun(@(m)(mask.*m),CIJcell(~missing),'UniformOutput',false);

end

