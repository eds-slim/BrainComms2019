%% compute normalised GGPs
configWS
%WS2 %% long AND short edges lesiones
WS %% ONLY long edges lesiones

region='all';

measures = {@(m)(efficiency_bin(m)), @(m)(mean(clustering_coef_bu(m))),@modularity,@(m)(charpath(distance_bin(1./m)))}; % user-defined handle for Louvain_modularity_und
measures_labels = {'efficiency','clustering','modularity','pathlength'};
%measures = {@(m)(efficiency_wei(m)), @(m)(mean(clustering_coef_wu(m)))}; % user-defined handle for Louvain_modularity_und
%measures_labels = {'efficiency','clustering'};

GGPnew = struct(); GGP = struct();

createnullmodelsWS

globalgraphparams_factred

delete(sprintf('%s/intermediate/WS/data/CIJNM.mat',OUTPUTDIR)) 
delete(sprintf('%s/intermediate/WS/data/GGP.mat',OUTPUTDIR))

%% export for plotting in R
%measures_labels = {'efficiency','clustering'};

filename = sprintf('%s/intermediate/WSGGP-ls.dat', OUTPUTDIR);

if exist(filename,'file'); delete(filename); end
fid=fopen(filename,'w');
fprintf(fid,'ID, group, norm, lab, GGP\n');
fclose(fid);

MM=struct();
MMM=[];
    for i=1:length(measures_labels)
        
        lab = measures_labels{i};
        meas = measures{i};
        
        mmm = [(1:n)', kron([0;1],ones(n/2,1)), 0*ones(n,1), i*ones(n,1), reshape(GGP.all.(lab).norm,[n,1])];
        mmm = [mmm; [(1:n)', kron([0;1],ones(n/2,1)), 1*ones(n,1), i*ones(n,1), reshape(GGP.all.(lab).raw,[n,1])]];   

        MMM = [MMM; mmm];
    end
    clear fid
dlmwrite(filename,MMM,'-append')
clear filename

