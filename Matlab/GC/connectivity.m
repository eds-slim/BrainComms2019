tracking = 'intra';
regions= {'lh','rh'}

preprocess;
extractclinicaldata


%% q50 and unnormalized charpath length
q=.5;
cpl=struct(); % output from charpath
i=0;
for region = regions
    region=region{1};    
    prepare_region;
    i=i+1;
    
    qtl.(region)=squeeze(cellfun(@(m)(quantile(m(:),q)),CIJcell_region));
    
    CIJ_thr_cell = thresholdCIJ(CIJcell_region,1,eval(thresholding));
    Dcell = cellfun(@(m)(distance_wei(1./m)),CIJ_thr_cell,'uni',false);
    [lambda,eff,ecc,radius,diameter]=cellfun(@charpath,Dcell,'uni',false);
    
    cpl.(region).lambda=squeeze(cell2mat(lambda));
    cpl.(region).radius=squeeze(cell2mat(radius));
    cpl.(region).diameter=squeeze(cell2mat(diameter));
    
end


%% export for R, only works for tracking='intra'
filename=[OUTPUTDIR '/intermediate/connectivity.csv'];
if exist(filename,'file'); delete(filename); end
fid=fopen(filename,'w');
fprintf(fid,'ID,region,q50,lambda\n');
fclose(fid);

M=[repmat(ID,[2,1]) kron([0;1],ones(n,1)) [qtl.lh; qtl.rh] [cpl.lh.lambda; cpl.rh.lambda]];

dlmwrite(filename,M,'-append')

clear fid filename

