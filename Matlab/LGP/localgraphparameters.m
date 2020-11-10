%% compute and export some local graph parameters

%provided by connmat.mat
%regions = {'lh','rh'}; %{'lh','rh'};

if ~runflag
    return;
end


filename = sprintf('%s/intermediate/LGP.mat',OUTPUTDIR);
delete(filename)

flag = exist(filename,'file');

if flag
    load(filename,'-mat');
else
    LGP = struct();
    for reg=regions
        region = reg{1};
        LGP.(region) = struct();
    end
end

if runflag
    
    for reg=regions
        region = reg{1};
        prepare_region
        createthrcomplex
        
        for i=1:length(measures_labels)
            
            lab = measures_labels{i};
            meas = measures{i}
            
            LGP.(region).(lab) = squeeze(cell2mat(cellfun(meas,CIJcomplex,'UniformOutput',false)));
            
        end
    end
    
    save(filename,'LGP','thr_CI_arr','thr_CI_l','regions','measures','measures_labels','-mat');
end


