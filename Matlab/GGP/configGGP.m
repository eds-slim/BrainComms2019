% thresholding grid
thr_CI_arr = griddelta:griddelta:1;

measures = {@(m)(efficiency_wei(m)), @(m)(mean(clustering_coef_wu(m))),@modularity}; % user-defined handle for Louvain_modularity_und
measures_labels = {'efficiency','clustering','modularity'};