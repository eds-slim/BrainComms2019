%% Global graph parameters (efficiency, clustering, modularity, etc), as functions of thresholding parameter

% Creates and updates structure array GGP satisfying
%       GGP.(region).region.measure.raw = n_thr x n_subj
%       GGP.(region).region.measure.norm = n_thr x n_subj
%       GGP.(region).region.measure.NM = n_thr x n_NM x n_subj
%
% where n_thr = thr_CI_l = length(thr_CI_arr) is the fixed number of thresholds

% uses precomputed CIJcomplex nullmodels


filename = sprintf('%s/intermediate/WS/data/GGP.mat',OUTPUTDIR);

if exist(filename,'file')
    GGPold=load(filename);
else
    GGPold=[]; GGPold.GGP.(region)=struct();
end

if n_NM==0
    GGP=GGPold;
    return;
end

disp('Compute GGPs')





for i=1:length(measures_labels)
    
    lab = measures_labels{i};
    meas = measures{i};

    if ~isfield(GGPold.GGP.(region),lab)
        GGPold.GGP.(region).(lab).NM=[];
    end

    
    GGPnew.(region).(lab).raw = squeeze(cellfun(meas,CIJcell_region));
    GGPnew.(region).(lab).NM = squeeze(cellfun(meas,CIJNMnew));
       
    GGP.(region).(lab).raw = GGPnew.(region).(lab).raw;
    GGP.(region).(lab).NM = cat(2,GGPold.GGP.(region).(lab).NM,GGPnew.(region).(lab).NM);
    GGP.(region).(lab).norm = squeeze(GGP.(region).(lab).raw./mean(GGP.(region).(lab).NM,2));
end

save(filename,'GGP','-v7.3')

