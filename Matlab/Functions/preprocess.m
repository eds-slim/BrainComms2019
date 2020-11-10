filename = sprintf('%s/Input/Tracking data/%s/CI_results_%s.mat',BASEDIR,tracking,tracking);
data=load(filename);

clear filename

n=length(data.allsubj);
n_con=length(data.CI_con);
n_pat=length(data.CI_pat);


CIJcell = reshape(data.CI,[1,1,n]);
k=size(CIJcell{1},1);

CIJcell=cellfun(@(m)(m.*(1-eye(k))),CIJcell,'uni',false);


clear j 
ROIsizecell = reshape(data.ROI_size,[1,1,n]);
labels=data.ROI{1,1};


idx_con = false(n,1); idx_con(1:n_con) = true;
idx_pat = false(n,1); idx_pat(n_con+1:end) = true;

idx_lh = false(n,1); idx_rh=false(n,1);
idx_lh(n_con+find(strcmp(data.lesion_sides{:,2},'lh'))) = true;
idx_rh(n_con+find(strcmp(data.lesion_sides{:,2},'rh'))) = true;

group = nan(n,1); group(idx_con)=0; group(idx_lh)=1; group(idx_rh)=2;

subjID = data.allsubj([n_con+1:end, 1:n_con]);
ID = (1:n)';
clear idx_pat data;

if ~exist('normalisation','var'); normalisation = 'prod'; end
switch normalisation
    case 'raw'
        CIJcell = cellfun(@(m,v)(m.*(v'*v)),CIJcell,ROIsizecell,'uni',false);
    case 'prod'
        CIJcell = CIJcell;
    case 'sum'
        CIJcell = cellfun(@(m,v)(m.*(v'*v)./(repmat(v,[k,1])+repmat(v',[1,k]))),CIJcell,ROIsizecell,'uni',false);
end

for i=1:length(CIJcell)
   mat=CIJcell{i};
   mat(isnan(mat))=0;
   CIJcell{i}=mat;
end

clear ROIsizecell mat i