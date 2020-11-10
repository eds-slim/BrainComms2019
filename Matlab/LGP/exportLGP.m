%% export intrahemispheric LGPs for analysis / plotting in R

filename = sprintf('%s/intermediate/LGP.mat',OUTPUTDIR);
load(filename);

% M = [id, region, node, measures]
% single threshold, relpos in R

% print headers
filename = sprintf('%s/intermediate/LGP_100.csv',OUTPUTDIR);
if exist(filename,'file'); delete(filename); end
fid=fopen(filename,'w');
fprintf(fid,'ID,region,node');
for i=1:length(measures_labels)
    fprintf(fid,',%s',measures_labels{i});
end
fprintf(fid,'\n');
fclose(fid);


% build data matrix
% encoding:
%   region:         {lh,rh}->{0,1}
%   lesion/group:   {con,lh,rh}->{0,1,2}
n_reg = 2; %length(regions);

MM = [repmat(kron(ID,ones(k/2,1)),[n_reg,1]), kron((0:n_reg-1)',ones(n*k/2,1)), repmat((1:k/2)',[n_reg*n,1]) ];


for i=1:length(measures_labels)
    
    lab = measures_labels{i};
    meas = measures{i};
    newcol= [];
    for reg={'lh','rh'}
        region=reg{1};
        newcol = [newcol; reshape(LGP.(region).(lab)(:,:,20),1,[])'];
    end
    MM = [MM, newcol];
end


dlmwrite(filename,MM,'Delimiter',',','precision','%2.10f','-append')

