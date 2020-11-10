function Q = modularity(m)
    
    cnt=10;
    Qarr = nan(cnt,1);
    for i=1:cnt
        [~,Qarr(i)] = community_louvain(m);
    end
    Q=mean(Qarr);
end

