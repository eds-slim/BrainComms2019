tracking='intra';
regions={'lh','rh'};
preprocess

idx_rh(pat_ex)=0;
idx_lh(pat_ex)=0;
idx_all = logical(idx_con+idx_lh+idx_rh);

q=0.5;

idx_thr=eval(thresholding);

region='lh';
prepare_region
CIJstack=cell2mat(thresholdCIJ(CIJcell_region(1,1,idx_all),q,idx_thr));

region='rh';
prepare_region
CIJstack=cat(3,CIJstack,cell2mat(thresholdCIJ(CIJcell_region(1,1,idx_all),q,idx_thr)));
save(sprintf('%s/Matlab/Edges/NBSfiles/CIJstack.mat',BASEDIR),'CIJstack','-mat')

% design 2x3 anova [1 left right ipsi contra]
design = [kron(eye(2),ones(n,1)), [idx_lh; idx_rh], [idx_rh;idx_lh]];
design=design([idx_all;idx_all],:);
dlmwrite(sprintf('%s/Matlab/Edges/NBSfiles/design.txt',BASEDIR),design);

exchangeblocks = [ones(1,n), 2*ones(1,n)];
dlmwrite(sprintf('%s/Matlab/Edges/NBSfiles/exchangeblocks.txt',BASEDIR),exchangeblocks);

reps=length(tt);
p=nan(reps,1);
nedges=nan(reps,1);

subcortical={'CAU','THA','PAL','PUT','ACC','AMY'};  %% hard coded from LGP results
LGPnodes={'IP','PAL','PoCe','PreCe','PUT','SP','SM','THA'}; %% hard coded from LGP results


if ~exist('plotflag','var'); plotflag=false; end

for i=1:reps
    
    clearvars -global nbs UI
    
    UI=struct();
    UI.method.ui='Run NBS';
    UI.test.ui='t-test';
    UI.size.ui='Extent';
    UI.thresh.ui=num2str(tt(i));
    UI.perms.ui='1e2';
    UI.alpha.ui='1';
    
    UI.matrices.ui = sprintf('%s/Matlab/Edges/NBSfiles/CIJstack.mat',BASEDIR);
    UI.design.ui = sprintf('%s/Matlab/Edges/NBSfiles/design.txt',BASEDIR);
    if strcmp(side,'ipsi')
        UI.contrast.ui='[0,0,-1,0]';
    elseif strcmp(side,'contra')
        UI.contrast.ui='[0,0,0,-1]';
    else
        error('Wrong side');
    end
    UI.exchange.ui=sprintf('%s/Matlab/Edges/NBSfiles/exchangeblocks.txt',BASEDIR);
    UI.node_coor.ui = sprintf('%s/Matlab/Edges/NBSfiles/coords.txt',BASEDIR);
    UI.node_label.ui = sprintf('%s/Matlab/Edges/NBSfiles/labels.txt',BASEDIR);
    
    idx=1:k/2;
    coords = dlmread(sprintf('%s/Input/NBS/cogmmhemi.txt',BASEDIR));
    fid = fopen(sprintf('%s/Input/NBS/labels_shorter.txt',BASEDIR));
    lab=textscan(fid,'%s');
    lab=lab{1};
    fclose(fid);
    
    global nbs
    
    NBSrun(UI,[])
    
    
    if ~isempty(nbs.NBS.pval)
        [p(i),idxmin]=min(nbs.NBS.pval);
        nedges(i)=full(sum(nbs.NBS.con_mat{idxmin}(:)));
        if ~plotflag
            continue;
        end
        SDNmask=full(nbs.NBS.con_mat{idxmin});
        SDNmask=SDNmask+SDNmask';
        idxx=sum(SDNmask)==1;
        SDNmask(idxx,:)=0;
        SDNmask(:,idxx)=0;
        %nodess
        sizes = degrees_und(SDNmask);
        file_node = ['SDNmask-' region '.node'];
        fid = fopen(file_node,'w');
        for j=1:size(SDNmask,1)
            sc_flag = any(strcmp(subcortical,lab{j}));
            if sc_flag
                module = 1; %double(any(strcmp(LGPnodes,lab{j})));
            else
                module = 2; %2+double(any(strcmp(LGPnodes,lab{j})));
            end
            fprintf(fid,'%f\t%f\t%f\t%f\t%f\t%s\n',coords(idx(j),1), coords(idx(j),2), coords(idx(j),3), double(module), sizes(j), lab{j});
        end
        fclose(fid);
        
        %edges
        file_edge = ['SDNmask-' region '.edge'];
        dlmwrite(file_edge,SDNmask,' ');
        
        for light={''}%{'-light',''}
            light=light{1};
            for labflag={'with'}%{'with','no'}
                labflag=labflag{1};
                
                filename_opt = sprintf('%s/Matlab/Edges/BNVoptions/BNVopt_high_%slabels%s.mat',BASEDIR,labflag,light);
                filename_save = sprintf('%s/final/Figures/NBS/NBSall-high-side-%s-labels-%s-t-%1.4f-p-%1.4f%s.png',OUTPUTDIR,side,labflag,tt(i),p(i),light);
                %filename_save = sprintf('/home/eckhard/NBS/NBSall-high-side-%s-labels-%s-t-%1.4f-p-%1.4f%s.png',side,labflag,tt(i),p(i),light);

                if ~exist(fileparts(filename_save),'dir'); mkdir(fileparts(filename_save)); end
                
                BrainNet_MapCfg('/home/eckhard/Documents/MATLAB/toolboxes/BrainNet/Data/SurfTemplate/BrainMesh_ICBM152Left.nv',file_node,file_edge,filename_save,filename_opt);
                pause(5)
                close all
                pause(5)
            
            end
        end
        %return;
    end
end

if length(tt)==1
    return;
end
%%
[ax,h1,h2]=plotyy(ax,tt,p,tt,nedges,@semilogy,@semilogy);
ylim(ax(2),[0,10^3])
xlim(ax(1),[min(tt),max(tt)])

hold(ax(1),'on')
hold(ax(2),'on')

plot(ax(1),tt,p+sqrt(p.*(1-p))/sqrt(reps),'--', 'Color','blue');
plot(ax(1),tt,p-sqrt(p.*(1-p))/sqrt(reps),'--', 'Color','blue');
plot(ax(1),tt,.05*ones(reps,1),'-k');
ylim(ax(2),[1e0,1e3])% xlim(ax(1),[min(tt),max(tt)])
%
h1.Marker='o'; h1.Color='blue'; ax(1).YColor='blue';
h2.Marker='+'; h2.Color='red'; ax(2).YColor='red';
drawnow