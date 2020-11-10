%% compute normalised GGPs

jobID = randi([1,100],1);
if ~exist('jobID','var'); jobID=000; end


if ~runflag
    return;
end



if strcmp(tracking,'intra')
    regions={'lh','rh'};
elseif strcmp(tracking,'inter')
    regions={'all'};
end



preprocess;

idx_thr=eval(thresholding);

return,

GGPnew = struct(); GGP = struct();
for region=regions;
    region=region{1};
    prepare_region;
    
    %createthrcomplex
    %createnullmodels
    
    %globalgraphparams
    
end

combineGGP