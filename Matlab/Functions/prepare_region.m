%% load and prepare region-specific data

% redefine CIJcell according to value of region
% k = rumber of ROIs

disp(region)

switch region
    case 'all'
        ind = 1:k;
    case 'lh'
        ind = 1:(k/2);
    case 'rh'
        ind = (k/2+1):k;
    case 'inter'
        CIJcell_region = cellfun(@(m)(m(1:k/2,(k/2+1):end)),CIJcell,'uni',false);
        k=k/2;
        CIJstack_region = cell2mat(CIJcell_region);
        
        
        warning('do interhemispheric stuff');
        return;
    otherwise
        error('wrong region')
end

idx=cellfun(@(m)(~isempty(m)),CIJcell);
CIJcell_region=cell(size(CIJcell));
CIJcell_region(idx) = cellfun(@(m)(m(ind,ind)),CIJcell(idx),'uni',false);

clear idx