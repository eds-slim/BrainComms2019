data<-read.csv(file.path(OUTPUT_DIR,"intermediate","WS_full.dat"),header = FALSE)

g<-graph_from_adjacency_matrix(as.matrix(data), weighted = TRUE)


V(g)$highlight<-0
E(g)$highlight<-0


rewired.edges<-read.csv(file.path(OUTPUT_DIR,"intermediate","rewired_edges.dat"),header = FALSE);
lesioned.edges<-sample_n(rewired.edges,nrow(rewired.edges)/2)

p.lesioned.list<-c();

for(j in 0:2){
  if(j==0){
    
  }
  if(j==1){
    for(i in 1:nrow(lesioned.edges)){
      E(g)[(.from(rewired.edges[i,1]) & .to(rewired.edges[i,2])) | (.from(rewired.edges[i,2]) & .to(rewired.edges[i,1]))]$highlight<-2;
    }
  }
  if(j==2){
    for(i in 1:nrow(lesioned.edges)){
      g<-delete.edges(g,E(g)[(.from(rewired.edges[i,1]) & .to(rewired.edges[i,2])) | (.from(rewired.edges[i,2]) & .to(rewired.edges[i,1]))]);
    }
  }
    par(bg=NA)
    dir.create(file.path(OUTPUT_DIR,"final","Figures","WSpics"), recursive = TRUE, showWarnings = FALSE)
    png(filename = file.path(OUTPUT_DIR,"final","Figures","WSpics",paste("WSplot_lesioned",j,".png",sep = "")), res = 400, width = 7, height = 7, units = 'in')
    
    p<-ggraph(g, layout = 'linear', circular=TRUE) + 
      geom_node_point(aes(color=factor(highlight)), size=.1)+
      scale_color_manual(values=c("black","yellow"))+
      #geom_node_label(aes(label=name))+
      theme_minimal()+
      theme(axis.line=element_blank(),axis.text.x=element_blank(),
            axis.text.y=element_blank(),axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),legend.position="none",
            panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),plot.background=element_blank())
    p<-p  + geom_edge_arc(aes(width=weight,color=factor(highlight)))+
      scale_edge_color_manual(values=c("darkblue","red","green"))+  scale_edge_width_continuous(range = c(0,.1))
    print(p);
    p.lesioned.list[[j+1]]<-p;
    dev.off()
}

grid.arrange(grobs=p.lesioned.list)
