% thresholding grid
m=.05; d=.05; M=1;
thr_CI_arr = m:d:M;
thr_CI_l = length(thr_CI_arr);

tracking='intra';
regions={'lh','rh'};


measures = {@strengths_und,@(m)(efficiency_wei(m,1)), @clustering_coef_wu, @eigenvector_centrality_und};
measures_labels = {'strength','efficiency','clustering','evcentrality'};

preprocess;
idx_thr=eval(thresholding);