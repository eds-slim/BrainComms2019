source('./Various scripts/loadpackages.r')
source('./Various scripts/auxiliaryfunctions.r')
source('./Various scripts/loaddata.r')

## Local graph parameters
source("./LGP/LGPload.r")
source("./LGP/LGPstats.r")

for(plot.LGP in levels(as.factor(stats.LGP$LGP))){
print(plot.LGP);
data.LGP <- merge(data.hemispheres,data.LGP)

d<-data.LGP[data.LGP$node %in% nodes.LGP[[plot.LGP]],]
d$relposjitter <- jitter(as.numeric(d$relpos),1)

d.sort <- stats.LGP[stats.LGP$LGP==plot.LGP,]

d$facet<-factor(d$node, levels=d.sort[order(d.sort$pval),"node"])

ddd<-d.sort[order(d.sort$pval),][d.sort[order(d.sort$pval),]$node %in% nodes.LGP[[plot.LGP]],]
LGP.names<-setNames(paste(ddd$node,"\n(p=",format(ddd$pval, digits=4, scientific=TRUE), ", p*=",format(ddd$pvaladjust, digits=4, scientific=TRUE), ")", sep = ""),ddd$node)

p1<-ggplot(d,aes(x=relpos, y=get(plot.LGP),color=relpos, fill=relpos))+
  geom_boxplot(alpha=.5, outlier.shape = NA)+
  geom_line(data=subset(d,relpos != "healthy"), aes(x=relposjitter, group=ID), col="darkgray", alpha=.5)+
  geom_point(aes(x=relposjitter, shape=region), size=1)+
  stat_signif(annotations = c("ipsi.vs.control","ipsi.vs.contra","contra.vs.control"), comparisons = list(c(1,3),c(2,3),c(1,2)),
               step_increase = -.075, color="black", textsize = 2)+
  theme_pubr()+
  theme(panel.background = element_rect(fill = "transparent", colour = "black"), 
        plot.background = element_rect(fill = "transparent", colour = NA),
        legend.direction = "horizontal", legend.position = "none",
          axis.text=element_text(size=8),strip.text.x = element_text(size = 6, colour = "black"))+
  scale_color_manual(values=color_pal[1:3])+scale_fill_manual(values=color_pal[1:3])+
  scale_shape_manual(name="", values=c(16,17), labels=c("Left hemisphere","Right hemisphere"))+
  scale_x_discrete("", labels=c("Controls","Contra","Ipsi"))+scale_y_continuous(plot.LGP)+
  facet_wrap(~facet, nrow = 2, scales = "free", labeller = as_labeller(LGP.names))

p1
pg<-ggplot_build(p1)
pg$data[[4]]$annotation<-as.character(pg$data[[4]]$annotation)
pg$data[[4]]$annotation[pg$data[[4]]$annotation=="ipsi.vs.control"]<-rep(format(as.numeric(ddd$p.ipsi.vs.control), digits=4,scientific=TRUE),each=3)
pg$data[[4]]$annotation[pg$data[[4]]$annotation=="contra.vs.control"]<-rep(format(as.numeric(ddd$p.contra.vs.control), digits=4,scientific=TRUE),each=3)
pg$data[[4]]$annotation[pg$data[[4]]$annotation=="ipsi.vs.contra"]<-rep(format(as.numeric(ddd$p.ipsi.vs.contra), digits=4,scientific=TRUE),each=3)

pg$data[[4]]<-pg$data[[4]][as.numeric(pg$data[[4]]$annotation)<.05,]

#dev.off()
q1<-ggplot_gtable(pg)
grid.draw(q1)



stats.LGP$logpval <- -log(stats.LGP$pval)
p.holm<-unlist(lapply(1:41,function(k){-log(0.05/(41-k+1))}))
stats.LGP$p.holm<-rep(p.holm[order(order(-stats.LGP[stats.LGP$LGP==plot.LGP,"logpval"]))],3)

p2<-ggplot(stats.LGP,aes(x=reorder(node,-logpval, FUN=function(v)nth(v,4-which(levels(as.factor(stats.LGP$LGP))==plot.LGP))),logpval, color=reorder(col,-logpval), fill=reorder(col,-logpval), shape=reorder(LGP,-logpval)))+
  geom_hline(yintercept = -log(0.05), color="darkgray")+
  geom_hline(yintercept = -log(0.05/41), color="lightgray")+
  geom_linerange(aes(ymin=0,ymax=logpval), alpha=.5, size=.75, stat = "identity", position = position_dodge(width=.75))+
  geom_point(stat="identity", position=position_dodge(width=.75), size=2, color="black")+
  scale_color_manual(values=color_pal[7:9])+
  theme_pubr()+theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1, size = 8), legend.position = "bottom")+
  #scale_fill_jco(guide=FALSE)+scale_color_jco(name="SigLevel")+scale_shape_manual(values = c(21,22,24),name="LGP")+
  scale_x_discrete("")+  scale_y_continuous("Significance of main effect of lesion status on local graph parameter")+
  annotate("text",x=41,y=-log(0.05/41), label="p***=0.05/41", vjust = -.5, hjust=1, size=2)+
  annotate("text",x=41,y=-log(0.05), label="p*=0.05", vjust = 1.5, hjust=1, size=2)+
  annotate("text",x=41,y=-log(0.05/20), label="p**=B-H", vjust = 1.5, hjust=1, size=2)+
  geom_step(aes(y=p.holm, group=""), color="darkgray", direction = "hv", position = position_nudge(x=.5))+
  geom_segment(inherit.aes = FALSE, x=0, xend=1.5, y=-log(0.05/41), yend=-log(0.05/41), color="darkgray", size=.2)
  
p2

vp <- viewport(width = 0.75, height = 0.55, x = 0.2, y = 1,just=c("left","top"))
#dev.off()
p2+theme(legend.position = "none")+annotation_custom(grob=ggplot_gtable(pg), xmin=6, ymin=7)
ggsave(file.path(OUTPUT_DIR,"final","Figures",paste("LGP_",plot.LGP,".pdf",sep = "")), width=10, height = 7, units = 'in')

}


## relation to clinical
plot.LGP<-"clustering"
#data.LGP <- merge(data.hemispheres,data.LGP)
d<-data.LGP[data.LGP$node %in% nodes.LGP[[plot.LGP]],]
data<-merge(d, data.patients)
data<-merge(data, data.subjects)
data<-droplevels(data)
data$logvol<-log(data$volume)
require(ggrepel)


for(plot.LGP in levels(as.factor(stats.LGP$LGP))){
  labelInfo <-
    split(data, list(data$relpos, data$node)) %>%
    lapply(function(t){
      data.frame(
        predAtMax = lm(as.formula(paste(plot.LGP," ~ logvol",sep = "")), data = t) %>%
          predict(newdata = data.frame(logvol = max(t$logvol)))
        , max = max(t$logvol),
        relpos = t$relpos[1]
      )}) %>%
    bind_rows
  labelInfo$label = levels(factor(interaction(data$relpos, data$node)))
  labelInfo
  
p<-ggplot(data, aes(y=!!ensym(plot.LGP), x=log(volume), color=relpos, shape=node))+
  geom_point()+
  geom_smooth(aes(group=interaction(relpos,node)),method = "lm", se = F)+
  #geom_line()+
  geom_label_repel(data = labelInfo
                   , aes(x = max
                         , y = predAtMax
                         , label = label
                         , color = relpos
                   )
                   , nudge_x = 1
  )+
  theme_classic()+
  coord_cartesian(xlim = c(min(data$logvol),3.3))+
  scale_color_manual(values=color_pal[2:3])+
  theme_pubr()+scale_shape_manual(values=1:nlevels(data$node)) +
  scale_x_continuous("Lesion volume (log)")+scale_y_continuous(paste0(toupper(substring(plot.LGP, 1,1)), substring(plot.LGP, 2)))+
  guides(color=F, shape=F)
print(p)
}
summary(lm(I(gripU-gripA)~strength+node+sex, data=data))

require(lmerTest)
summary(lmer(clustering~log(volume)+(1|ID)+(1|node), data=subset(data, relpos=="contra")))
summary(lm(gripU~efficiency+log(volume)+age+node, data=subset(data, relpos=="ipsi")))

ggplot(data=data, aes(x=efficiency, y=gripA, color=relpos))+
  geom_point()+
geom_smooth(aes(group=interaction(relpos, node)), method = "lm", se = T, alpha=.1)
