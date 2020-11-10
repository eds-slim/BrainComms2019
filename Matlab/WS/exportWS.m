configWS

mat0=Watts_Strogatz(k,m,0);
filename=sprintf('%s/intermediate/WS_test.dat',OUTPUTDIR);
dlmwrite(filename,mat0);

%%
mat=Watts_Strogatz(k,m,p);
filename=sprintf('%s/intermediate/WS_full.dat',OUTPUTDIR);
dlmwrite(filename,mat);

%figure; circularGraph(mat)

%%
[I,J]=find(mat>0);
idx2=arrayfun(@(i,j)((abs(i-j)>m/2)*(abs(i+k-j)>m/2)*(abs(i-j-k)>m/2)*[i,j]),I,J,'uni',false);
idx3=idx2(cellfun(@(i)(any(i)),idx2));
idx4=cellfun(@(i,j)(sub2ind([k,k],i(1),i(2))),idx3);

filename=sprintf('%s/intermediate/rewired_edges.dat',OUTPUTDIR);
dlmwrite(filename,unique(cell2mat(cellfun(@sort,idx3,'uni',false)),'rows'));