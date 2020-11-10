% creates normalised null models for normalisation

filename = sprintf('%s/intermediate/WS/data/CIJNM.mat',OUTPUTDIR);
if ~exist(fileparts(filename),'dir'); mkdir(fileparts(filename)); end

if exist(filename,'file')
    CIJNMold=load(filename);
else
    CIJNMold=struct();
    CIJNMold.CIJNM=[];
end

disp('Create null models')

n_NM = 10;

if n_NM==0
    CIJNM=CIJNMold.CIJNM;
    return;
end

NM=cellfun(@(m)(arrayfun(@(i)(null_model_und_sign(m)),1:n_NM,'uni',false)),CIJcell_region,'uni',false);
CIJNMnew = permute(reshape([NM{:}],[n_NM,size(NM)]),[2,3,4,1]);
CIJNM = cat(4,CIJNMold.CIJNM,CIJNMnew);

save(filename,'CIJNM','-v7.3')