% create thresholded complex

%if ~exist(sprintf('%s/Matlab/GGP/%s/data/%d',BASEDIR,tracking,jobID),'dir'); mkdir(sprintf('%s/Matlab/GGP/%s/data/%d',BASEDIR,tracking,jobID)); end
%filename = sprintf('%s/Matlab/GGP/%s/data/%d/CIJcomplex-%1.2f-%1.2f-%1.2f-%s-%s-%s.mat',BASEDIR,tracking,jobID,m,d,M,normalisation,idx_thr_str{1},region);

%if exist(filename,'file'); load(filename); return; end


disp('Create complex')

CIJcomplex = arrayfun(@(thr)(thresholdCIJ(CIJcell_region,thr,idx_thr)),thr_CI_arr,'uni',false);
CIJcomplex = cat(4,CIJcomplex{:});

%save(filename,'CIJcomplex','-v7.3')