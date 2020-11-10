combineddir=sprintf('%s/intermediate/GGP/data/combined',OUTPUTDIR);
if ~exist(combineddir,'dir'); mkdir(combineddir); end



files=dir(sprintf('%s/intermediate/GGP/data',OUTPUTDIR));
jobIDs=files([files.isdir]);
jobIDs=cellfun(@str2num,{jobIDs(3:end-1).name});

for region=regions
    region=region{1};
    
    preprocess;
    
    % GGPs
    GGPcombined=[]; GGPcombined.(region)=struct();
    for jobID=jobIDs
        filename = sprintf('%s/intermediate/GGP/data/%d/GGP-%s.mat',OUTPUTDIR,jobID,region);
        GGPold=load(filename);
        
        for i=1:length(measures_labels)
            lab = measures_labels{i};
            if ~isfield(GGPcombined.(region),lab)
                GGPcombined.(region).(lab).NM=[];
            end
            
            GGPcombined.(region).(lab).raw = GGPold.GGP.(region).(lab).raw;
            GGPcombined.(region).(lab).NM = cat(3,GGPold.GGP.(region).(lab).NM,GGPcombined.(region).(lab).NM);
            GGPcombined.(region).(lab).norm = squeeze(GGPcombined.(region).(lab).raw./mean(GGPcombined.(region).(lab).NM,3));
        end
        
    end
    
    clear filename GGPold
    
    filename = sprintf('%s/intermediate/GGP/data/combined/GGP-%s.mat',OUTPUTDIR,region);
    
    
    save(filename,'GGPcombined','-v7.3')
    
    clear filename GGPcombined
    
end



