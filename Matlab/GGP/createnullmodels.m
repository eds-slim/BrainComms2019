%% creates normalised null models for normalisation

if ~exist(sprintf('%s/intermediate/GGP/data/%d',OUTPUTDIR,jobID),'dir'); mkdir(sprintf('%s/intermediate/GGP/data/%d',OUTPUTDIR,jobID)); end
filename = sprintf('%s/intermediate/GGP/data/%d/CIJNM-%s.mat',OUTPUTDIR,jobID,region);


if exist(filename,'file')
    CIJNMold=load(filename);
else
    CIJNMold=struct();
    CIJNMold.CIJNM=[];
end

disp('Create null models')

n_NM = 500; % number of null models to create

if n_NM==0
    CIJNM=CIJNMold.CIJNM;
    return;
end

NM=cellfun(@(m)(arrayfun(@(i)(null_model_und_sign(m)),1:n_NM,'uni',false)),CIJcomplex,'uni',false);
CIJNMnew = permute(reshape([NM{:}],[n_NM,size(NM)]),[2,3,4,5,1]);
CIJNM = cat(5,CIJNMold.CIJNM,CIJNMnew);

save(filename,'CIJNM','-v7.3')