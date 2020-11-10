configGGP

if strcmp(tracking,'intra')
    regions={'lh','rh'};
elseif strcmp(tracking,'inter')
    regions={'all'};
end

preprocess


GGP=struct();
for region=regions
    region=region{1};
    filename = sprintf('%s/intermediate/GGP/data/combined/GGP-%s.mat',OUTPUTDIR,region);
    load(filename);
    GGP.(region)=GGPcombined.(region);
end



filename = sprintf('%s/intermediate/GGP-%s-raw.csv',OUTPUTDIR,tracking);

if exist(filename,'file'); delete(filename); end
fid=fopen(filename,'w');
fprintf(fid,'ID,threshold, region, lab, GGP\n');
fclose(fid);

MM=struct();
MMM=[];
% export to R
idx_region=-1;
for region=regions
    region=region{1};
    idx_region=idx_region+1;
    for i=1:length(measures_labels)
        
        lab = measures_labels{i};
        meas = measures{i};
        
        MM.(region).(lab) = [repmat((1:n)',[length(thr_CI_arr),1]), kron(thr_CI_arr',ones(n,1)), idx_region*ones(n*length(thr_CI_arr),1), i*ones(n*length(thr_CI_arr),1), reshape(GGP.(region).(lab).raw,[n*length(thr_CI_arr),1])];
        MMM = [MMM; MM.(region).(lab)];
    end
    clear fid
end
dlmwrite(filename,MMM,'-append')
clear filename