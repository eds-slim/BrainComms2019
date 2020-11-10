CIJcell_region=cell(1,1,n);

for i=1:n
    
    mat=Watts_Strogatz(k,m,p);
    
    
    [I,J]=find(mat>0);
    idx2=arrayfun(@(i,j)((abs(i-j)>m/2)*(abs(i+k-j)>m/2)*(abs(i-j-k)>m/2)*[i,j]),I,J,'uni',false);
    idx3=idx2(cellfun(@(i)(any(i)),idx2));
    idx4=unique(cell2mat(cellfun(@sort,idx3,'uni',false)),'rows');
    
    idx5=rand(size(idx4,1),1);
    
    idx6=idx5<q;
    idx7=idx4(idx6,:);
    
    mat2=mat;
    for j=1:size(idx7,1)
        mat2(idx7(j,1),idx7(j,2))=0;
        mat2(idx7(j,2),idx7(j,1))=0;
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