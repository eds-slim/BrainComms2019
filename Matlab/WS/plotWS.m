%%
figure
subplot(2,2,1)
boxplot(GGP.all.efficiency.raw,group,'Labels',{'Controls','Lesioned'})
title('Global efficiency (WS)')

subplot(2,2,3)
boxplot(GGP.all.efficiency.norm,group,'Labels',{'Controls','Lesioned'})
title('Normalised global efficiency (WS)')


subplot(2,2,2)
boxplot(GGP.all.clustering.raw,group,'Labels',{'Controls','Lesioned'})
title('Global clustering (WS)')

subplot(2,2,4)
boxplot(GGP.all.clustering.norm,group,'Labels',{'Controls','Lesioned'})
title('Normalised global clustering (WS)')


%subplot(2,4,3)
%boxplot(GGP.all.pathlength.raw,group,'Labels',{'Controls','Lesioned'})
%title('Pathlength (WS)')

%subplot(2,4,7)
%boxplot(GGP.all.pathlength.norm,group,'Labels',{'Controls','Lesioned'})
%title('Normalised pathlength (WS)')

%subplot(2,4,4)
%boxplot(GGP.all.modularity.raw,group,'Labels',{'Controls','Lesioned'})
%title('Modularity (WS)')

%subplot(2,4,8)
%boxplot(GGP.all.modularity.norm,group,'Labels',{'Controls','Lesioned'})
%title('Normalised modularity (WS)')

%% plot latest network
figure; scatter3(P(:,1),P(:,2),P(:,3),'filled');hold on
[x,y,z]=sphere(32);
surface(x, y, z, 'FaceAlpha', 0.01, 'EdgeColor', [1, 1, 1], 'FaceColor',[0,0,0]);
scatter3(lesion_pos(1),lesion_pos(2),lesion_pos(3),100,'filled')
surface(lesion_rad.*x+lesion_pos(1), lesion_rad.*y+lesion_pos(2), lesion_rad.*z+lesion_pos(3), 'FaceAlpha', 0.01, 'EdgeColor', 'red', 'FaceColor',[0,0,0]);
[I,J]=find(m2);
for i=1:length(I)
        plot3(P([I(i),J(i)],1),P([I(i),J(i)],2),P([I(i),J(i)],3),'magenta');
end
