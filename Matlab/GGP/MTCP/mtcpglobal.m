%% MTCP for global graph parameters


%% load graph metrics


regions={'lh','rh'};

preprocess

%teststring = '2-way-anova';

%load GPPs
GGP=struct();
for region=regions
    region=region{1};
    prepare_region;
    filename = sprintf('%s/intermediate/GGP/data/combined/GGP-%s.mat',OUTPUTDIR,region);
    load(filename);
    GGP.(region)=GGPcombined.(region);
end

measures_labels=fields(GGP.(regions{1}));
n_GT = length(measures_labels);
GT_data = cell(n_GT,1); % each element matrix n_subj x n_thresh

n_subj = length(GGP.(regions{1}).(measures_labels{1}).raw);
n_thresh = length(thr_CI_arr);

disp(teststring)

idx_thr = 2:8;

switch teststring
    case '2-way-anova'
        i=0;
        for measures_label=measures_labels'
            measures_label=measures_label{1};
            i=i+1;
            GT_data{i} = [GGP.lh.(measures_label).raw(idx_con,idx_thr); GGP.rh.(measures_label).raw(idx_con,idx_thr); GGP.lh.(measures_label).raw(idx_lh,idx_thr); GGP.rh.(measures_label).raw(idx_rh,idx_thr); GGP.lh.(measures_label).raw(idx_rh,idx_thr); GGP.rh.(measures_label).raw(idx_lh,idx_thr)];
        end
        %[side,relpos]
        design = [ [zeros(sum(idx_con),1);ones(sum(idx_con),1); zeros(sum(idx_lh),1); ones(sum(idx_rh),1); zeros(sum(idx_rh),1); ones(sum(idx_lh),1)] ...
            [zeros(2*sum(idx_con),1); ones(sum(idx_lh+idx_rh),1); 2*ones(sum(idx_lh+idx_rh),1) ]];
        config.terms = [1 0; 0 1];
        
    case 'ipsi-vs-control'
        i=0;
        for measures_label=measures_labels'
            measures_label=measures_label{1};
            i=i+1;
            GT_data{i} = [GGP.lh.(measures_label).raw(idx_con,idx_thr); GGP.rh.(measures_label).raw(idx_con,idx_thr); GGP.lh.(measures_label).raw(idx_lh,idx_thr); GGP.rh.(measures_label).raw(idx_rh,idx_thr)];
        end
        %[side,relpos]
        design = [ [zeros(sum(idx_con),1);ones(sum(idx_con),1); zeros(sum(idx_lh),1); ones(sum(idx_rh),1)], [zeros(2*sum(idx_con),1); ones(sum(idx_lh+idx_rh),1) ]];
        config.terms = [1 0; 0 1];
    case 'contra-vs-control'
        i=0;
        for measures_label=measures_labels'
            measures_label=measures_label{1};
            i=i+1;
            GT_data{i} = [GGP.lh.(measures_label).raw(idx_con,idx_thr); GGP.rh.(measures_label).raw(idx_con,idx_thr); GGP.lh.(measures_label).raw(idx_rh,idx_thr); GGP.rh.(measures_label).raw(idx_lh,idx_thr)];
        end
        %[side,relpos]
        design = [ [zeros(sum(idx_con),1);ones(sum(idx_con),1); zeros(sum(idx_lh),1); ones(sum(idx_rh),1)], [zeros(2*sum(idx_con),1); ones(sum(idx_lh+idx_rh),1) ]];
        config.terms = [1 0; 0 1];
    case 'ipsi-vs-contra'
        i=0;
        for measures_label=measures_labels'
            measures_label=measures_label{1};
            i=i+1;
            GT_data{i} = [GGP.lh.(measures_label).raw(idx_lh,idx_thr); GGP.rh.(measures_label).raw(idx_rh,idx_thr); GGP.lh.(measures_label).raw(idx_rh,idx_thr); GGP.rh.(measures_label).raw(idx_lh,idx_thr)];
        end
        %[side,relpos]
        design = [ [zeros(sum(idx_lh),1);ones(sum(idx_rh),1); zeros(sum(idx_rh),1); ones(sum(idx_lh),1)], [zeros(sum(idx_lh+idx_rh),1); ones(sum(idx_lh+idx_rh),1) ]];
        config.terms = [1 0; 0 1];    
    case 'pat-vs-control' %only if tracking 'inter'
        i=0;
        for measures_label=measures_labels'
            measures_label=measures_label{1};
            i=i+1;
            GT_data{i} = [GGP.all.(measures_label).raw];
        end
        %[group]
        design = group;
        config.terms = [1];
    otherwise
        error('error')
end

%% Run MTCP

filename=sprintf('%s/intermediate/GGP/MTCP/MTCP-%s-raw.mat',OUTPUTDIR,teststring);
if runflag
    
    rng(0);
    
    clear config
    
    config.parallel = false;
    config.rand= 1e4;
    config.alpha=.05;
    config.alpha_glm=.05;
    config.alpha_corr=.05;
    config.method='mtpc+scauc';
    
    [stats,config] = MTPC_evaluate_metrics(GT_data,design,config);
    
    if ~exist(fileparts(filename),'dir'); mkdir(fileparts(filename)); end
    save(filename, 'stats','config','-mat')
else
    load(filename,'-mat');
end
%% Analyse results
j=2;
filename=sprintf('%s/final/MTCP-%s-raw.txt',OUTPUTDIR,teststring);
fid=fopen(filename,'w');
ylab = measures_labels;
if ~isfield(stats,'scauc_sig')
    fprintf(fid,'No significant differences in %s\n\n', teststring);
else
    fprintf(fid,'n=%d, method=%s, alpha=%1.2f, alpha_glm=%1.2f, alpha_corr=%1.2f\n\n', config.rand, config.method, config.alpha, config.alpha_glm, config.alpha_corr);
    for i=1:n_GT
        if isempty(stats(i).scauc_sig); continue; end
        if stats(i).scauc_sig(j)
            fprintf(fid,'%s significant in %s at kappa=%1.4f, t=%1.4f, f=%1.4f,\n A_{MTCP}=%1.4f and A_{crit}=%1.12f\n\n',...
                ylab{i},teststring, .2+griddelta*(stats(i).max_t_thresh_idx(j)-1), stats(i).t_orig2(j),max(stats(i).f_orig1(j,:)),stats(i).scauc_corr(j),stats(i).scauc_crit(j));
        end
    end
end
fclose(fid)