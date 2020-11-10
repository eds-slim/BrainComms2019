source('./Various scripts/loadpackages.r')
source('./Various scripts/auxiliaryfunctions.r')
source('./Various scripts/loaddata.r')

source("./WS/WSplotall_lesion.r")


data<-read.csv(file.path(OUTPUT_DIR,'intermediate','WS_test.dat'), header = FALSE)

'%ni%' <- Negate('%in%')

g<-graph_from_adjacency_matrix(as.matrix(data), weighted = TRUE)

a<-"V18"
b<-"V19"
c<-"V28"

aa<-"V14"
bb<-"V16"
cc<-"V26"

p.list<-c()
for(i in 1:9){
  
  
  if(i==1){
    g2=delete.edges(g,E(g));
    V(g2)$highlight<-0;
  }
  if(i==2){
    g2=delete.edges(g,E(g));
    V(g2)$highlight<-0;
    V(g2)$highlight[1]<-1;
  }
  if(i==3){
    g2<-delete.edges(g,which(E(g) %ni% incident(g,"V1")));
    V(g2)$highlight<-0;
    E(g2)$highlight<-1;
    V(g2)$highlight[1]<-1;
  }
  if(i==4){
    g2<-delete.edges(g,which((E(g) %ni% incident(g,"V1")) & (E(g) %ni% incident(g,"V2"))));
    V(g2)$highlight<-0;
    V(g2)$highlight[1]<-0;
    E(g2)$highlight<-0;
    E(g2)[.from("V2") | .to("V2")]$highlight<-1;
  }
  if(i==5){
    g2<-g;
    V(g2)$highlight<-0;
    E(g2)$highlight<-0;
  }
  if(i==6){
    g2<-g;
    E(g2)$highlight<-0
    e<-E(g2)[(.from(a) & .to(b))|(.from(b) & .to(a))];
    E(g2)[e]$highlight<-1;
    V(g2)$highlight<-0;
    V(g2)$highlight[c(which(V(g2)$name==a),which(V(g2)$name==b))]<-1;
  }
  if(i==7){
    E(g2)$highlight<-0;
    g2<-delete.edges(g2,e);
    g2<-add.edges(g2,c(a,c, c,a), highlight=1, weight=1)
    V(g2)$highlight<-0;
    V(g2)$highlight[c(which(V(g2)$name==a),which(V(g2)$name==c))]<-1;
  }
  if(i==8){
    E(g2)$highlight<-0
    ee<-E(g2)[(.from(aa) & .to(bb))|(.from(bb) & .to(aa))]
    E(g2)[ee]$highlight<-1;
    V(g2)$highlight<-0
    V(g2)$highlight[c(which(V(g2)$name==aa),which(V(g2)$name==bb))]<-1;
  }
  if(i==9){
    E(g2)$highlight<-0;
    g2<-delete.edges(g2,ee);
    g2<-add.edges(g2,c(bb,cc, cc,bb), highlight=1, weight=.5)
    V(g2)$highlight<-0;
    V(g2)$highlight[c(which(V(g2)$name==bb),which(V(g2)$name==cc))]<-1;
  }


  par(bg=NA)
  dir.create(file.path(OUTPUT_DIR,"final","Figures","WSpics"), recursive = TRUE, showWarnings = FALSE)
  png(filename = file.path(OUTPUT_DIR,"final","Figures","WSpics",paste("WSplot_",i,".png",sep = "")), res = 400, width = 7, height = 7, units = 'in')
  
 p<-ggraph(g2, layout = 'linear', circular=TRUE) + 
    geom_node_point(aes(color=factor(highlight)), size=.1)+
    scale_color_manual(values=c("black","darkred"))+
    theme_minimal()+
    theme(axis.line=element_blank(),axis.text.x=element_blank(),
          axis.text.y=element_blank(),axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),legend.position="none",
          panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),plot.background=element_blank())
  if(i>2){
    p<-p  + geom_edge_arc(aes(width=weight,color=factor(highlight)))+
      scale_edge_color_manual(values=c("0"="darkblue","1"="red"))+  scale_edge_width_continuous(range = c(0,.1))
  }
  p.list[[i]]<-p
  print(p)
  dev.off()
  
}

lab<-c("Circular grid","Watts-Strogatz network")
p.WS.2x2<-plot_grid(p.list[[5]],p.lesioned.list[[1]], p.lesioned.list[[2]], p.lesioned.list[[3]],  scale=0.9, ncol=2)
ggsave(file.path(OUTPUT_DIR,"final","Figures","WS2x2.pdf"), width=21, height = 10.5, units = 'in')

plot_grid(p.WS.2x2, p.WS, labels="AUTO", scale=0.9, ncol=2)
ggsave(file.path(OUTPUT_DIR,"final","Figures","WS.png"), width=21, height = 10.5, units = 'in')

tikz(file = file.path(OUTPUT_DIR,"final","Figures","WS.tex"),width=3.54331,height=1.7716, standAlone = TRUE);
plot_grid(p.WS.2x2, q1, labels="", scale=0.9, ncol=2)
dev.off();
