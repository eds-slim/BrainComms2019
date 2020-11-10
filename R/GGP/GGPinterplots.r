d<-merge(subset(data.hemispheres, select=-c(region)),data.GGP)
d$n<-1

d$GGP[d$lab=="Clustering"]<-(d$GGP[d$lab=="Clustering"]-1)*(d$threshold[d$lab=="Clustering"])^2

str(d)
d.sum<-aggregate(list(n=d$n),list(threshold=d$threshold, group=d$group, region=d$region, lab=d$lab),sum)
d.mean<-aggregate(list(GGP.mean=d$GGP),list(threshold=d$threshold, group=d$group, region=d$region, lab=d$lab),mean)
d.sd<-aggregate(list(GGP.sd=d$GGP),list(threshold=d$threshold, group=d$group, region=d$region, lab=d$lab),sd)

d2<-join_all(list(d.mean,d.sd, d.sum), by=c("group","threshold","lab","region"))

d2<-merge(subset(data.conn, select=-c(region)),d2)
#d2 <- d2[, !duplicated(colnames(d2), fromLast = TRUE)] 

GGP.names <- c(
  'Efficiency'="Gloabl efficiency",
  'Clustering'="$\\text{Clustering} / \\kappa^2$",
  "Modularity"="Modularity",
  "Whole brain"="Whole brain"
)

d2$facet<-as.factor("Whole brain")
d2<-droplevels(d2[!(d2$threshold<0.0 | d2$threshold>1.8),])
#d2<-d2[d2$lab!="Modularity",]
p.whole<-ggplot(d2, aes(threshold, GGP.mean, colour=group, shape=group))+
  geom_point(size=1)+
  geom_line()+
  geom_ribbon(aes(ymin=GGP.mean-GGP.sd/sqrt(n),ymax=GGP.mean+GGP.sd/sqrt(n), fill=group), alpha="0.1", linetype="solid", size=.1)+
  theme_pubr(base_size = 6)+
  theme(panel.background = element_rect(fill = NA, color = "black"), panel.grid.major = element_line(colour="gray", size=0.1),
        legend.position = "none", legend.background = element_rect(fill = NA, colour = NA),
        legend.direction="vertical", axis.text=element_text(size=6), strip.text = element_text(size=10))+  
  facet_grid(lab~facet, scales="free_y",switch="y", labeller = (as_labeller(GGP.names)))+
  scale_y_continuous("", position="left", labels = scaleFUN)+
  scale_x_continuous("", limits=c(0.2,.8))+
  scale_shape_manual(values = c("control"=0, "left"=2, "right"=1))+
  scale_color_manual(values=color_pal[4:6])+scale_fill_manual(values=color_pal[4:6])

