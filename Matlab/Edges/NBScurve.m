%%
plotflag=false
if ~runflag
    return;
end

tt=1:.1:5;

figure; ax=gca;


filenameNBS = sprintf('%s/intermediate/NBSstats.dat', OUTPUTDIR);

if exist(filenameNBS,'file'); delete(filenameNBS); end
fid=fopen(filenameNBS,'w');
fprintf(fid,'threshold, relpos, nedges, p\n');
fclose(fid);


side='contra';
NBSall_bl;
M = [tt', repmat(0,size(tt')), nedges, p];

filenameNBS
p


side='ipsi';
NBSall_bl;
M = [M; [tt', repmat(1,size(tt')), nedges, p]];
p

dlmwrite(filenameNBS,M,'-append')
clear filename
