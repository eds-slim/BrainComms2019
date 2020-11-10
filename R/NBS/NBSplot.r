source('./Various scripts/loadpackages.r')
source('./Various scripts/auxiliaryfunctions.r')
source('./Various scripts/loaddata.r')

data.NBS<-read.csv(file.path(OUTPUT_DIR,"intermediate","NBSstats.dat"),header = TRUE)

n<-1e3;

data.NBS$p<-data.NBS$p+0.00001
data.NBS$p.sd<-sqrt(data.NBS$p*(1-data.NBS$p)/n)

scaleFUN <- function(x) sprintf("%.6f", x)
scaleFUNn <- function(x) sprintf("%.0f", x)


p.p<-ggplot(data.NBS, aes(threshold, y=p, shape=as.factor(relpos), colour=as.factor(relpos), relpos=as.factor(relpos)))+
  geom_point(size=2)+
  geom_line()+
#  geom_ribbon(aes(ymin=p-p.sd,ymax=p+p.sd, fill=as.factor(relpos)), alpha="0.5", linetype="longdash")+
  geom_hline(yintercept = 0.05, color="darkgray")+
  geom_segment(aes(x=1.6,xend=1.6,y=0,yend=data.NBS$p[data.NBS$relpos==0][7], color="black"))+
  geom_segment(aes(x=.8,xend=1.6,y=data.NBS$p[data.NBS$relpos==0][7],yend=data.NBS$p[data.NBS$relpos==0][7], color="black"))+
  geom_segment(aes(x=3,xend=3,y=0,yend=data.NBS$p[data.NBS$relpos==1][21], color="black"))+
  geom_segment(aes(x=.8,xend=3,y=data.NBS$p[data.NBS$relpos==1][21],yend=data.NBS$p[data.NBS$relpos==1][21], color="black"))+
  theme_bw()+
  theme(panel.background = element_rect(fill = NA, color = "black"), panel.grid.major = element_line(colour="gray", size=0.1),
        legend.position = "horizontal", legend.background = element_rect(fill = NA, colour = NA), strip.text.y = element_blank())+
  scale_y_log10("Statistical significance (FWER)", position="left", labels = scaleFUN, limits=c(1e-6,1),breaks=c(1,.1,.01,.05,.001,.0001,0.00001,.000001,data.NBS$p[data.NBS$relpos==0][7],data.NBS$p[data.NBS$relpos==1][21]))+
  scale_x_continuous("Threshold $t$", limits=c(.8,5.2), expand=c(0,0), breaks=c(1:5,1.6))
  #scale_color_nejm()+scale_fill_nejm()+
  #scale_shape_manual(values=c(1,16))

p.p

p.n<-ggplot(data.NBS, aes(threshold, y=nedges, shape=as.factor(relpos),color=as.factor(relpos)))+
  geom_point(size=2)+
  geom_line()+
  geom_hline(yintercept = 0.05, color="lightgray")+
  geom_segment(aes(x=1.6,xend=1.6,y=0,yend=data.NBS$nedges[data.NBS$relpos==1][7], color="black"))+
  geom_segment(aes(x=.8,xend=1.6,y=data.NBS$nedges[data.NBS$relpos==0][7],yend=data.NBS$nedges[data.NBS$relpos==0][7], color="black"))+
  geom_segment(aes(x=.8,xend=1.6,y=data.NBS$nedges[data.NBS$relpos==1][7],yend=data.NBS$nedges[data.NBS$relpos==1][7], color="black"))+
  geom_segment(aes(x=3,xend=3,y=0,yend=data.NBS$nedges[data.NBS$relpos==1][21], color="black"))+
  geom_segment(aes(x=.8,xend=3,y=data.NBS$nedges[data.NBS$relpos==1][21],yend=data.NBS$nedges[data.NBS$relpos==1][21], color="black"))+
  theme_bw()+
  theme(panel.background = element_rect(fill = NA, color = "black"), panel.grid.major = element_line(colour="gray", size=0.1),
        legend.position = "horizontal", legend.background = element_rect(fill = NA, colour = NA), strip.text.y = element_blank())+
  scale_y_log10("Number of edges", position="left", labels = scaleFUNn, limits=c(1,250), breaks=c(1,10,data.NBS$nedges[data.NBS$relpos==0][7],data.NBS$nedges[data.NBS$relpos==1][c(7,21)]))+
  scale_x_continuous("Threshold $t$", limits = c(.8,5.2), expand = c(0,0), breaks=c(1:5,1.6))
  #scale_color_nejm()+scale_fill_nejm()+
  #scale_shape_manual(values=c(2,17))

p.n

prow<-plot_grid(p.n,p.p, nrow=1, align = "h")

p.comb<-ggplot_dual_axis(p.p, p.n, "y")

p.comb

ggsave(file.path(OUTPUT_DIR,"final","Figures","NBS.png"), plot=prow, width=7, height =4, units = 'in')

tikz(file = file.path(OUTPUT_DIR,"final","Figures","NBS.tex"),width=7.28346,height=4, standAlone = TRUE);
print(prow)
dev.off();
