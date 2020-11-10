%lesion long AND short connections with probab ql, qs respectively.

CIJcell_region=cell(1,1,n);

for i=1:n
    
    mat=Watts_Strogatz(k,m,p);
    
    
    [I,J]=find(mat>0);
    %long connections
    idx2l=arrayfun(@(i,j)((abs(i-j)>m/2)*(abs(i+k-j)>m/2)*(abs(i-j-k)>m/2)*[i,j]),I,J,'uni',false);
    idx3l=idx2l(cellfun(@(i)(any(i)),idx2l));
    idx4l=unique(cell2mat(cellfun(@sort,idx3l,'uni',false)),'rows');
    
    %random proportion of long conns
    idx5l=rand(size(idx4l,1),1);
    
    idx6l=idx5l<ql;
    idx7l=idx4l(idx6l,:);
    
    
    %short connections
    idx2s=arrayfun(@(i,j)((1-(abs(i-j)>m/2)*(abs(i+k-j)>m/2)*(abs(i-j-k)>m/2))*[i,j]),I,J,'uni',false);
    idx3s=idx2s(cellfun(@(i)(any(i)),idx2s));
    idx4s=unique(cell2mat(cellfun(@sort,idx3s,'uni',false)),'rows');
    
    %random proportion of short conns
    idx5s=rand(size(idx4s,1),1);
    
    idx6s=idx5s<qs;
    idx7s=idx4s(idx6s,:);
    
    
    
    
    mat2=mat;
    for j=1:size(idx7l,1)
        mat2(idx7l(j,1),idx7l(j,2))=0;
        mat2(idx7l(j,2),idx7l(j,1))=0;
    end
    for j=1:size(idx7s,1)
        mat2(idx7s(j,1),idx7s(j,2))=0;
        mat2(idx7s(j,2),idx7s(j,1))=0;
    end
    
    if i<=21
        CIJcell_region{1,1,i}=mat;
    elseif i>n/2
        CIJcell_region{1,1,i}=mat2;
    end
    
end

idx_con=(1:n)<=n/2;
idx_pat=(1:n)>n/2;

group=idx_con+2*idx_pat;