d<-merge(data.hemispheres,data.GGP)
d$n<-1
d$GGP[d$lab=="Clustering"]<-(d$GGP[d$lab=="Clustering"]-1)*(d$threshold[d$lab=="Clustering"])^2




str(d)
d.sum<-aggregate(list(n=d$n),list(threshold=d$threshold, group=d$group, region=d$region, lab=d$lab),sum)
d.mean<-aggregate(list(GGP.mean=d$GGP),list(threshold=d$threshold, group=d$group, region=d$region, lab=d$lab),mean)
d.sd<-aggregate(list(GGP.sd=d$GGP),list(threshold=d$threshold, group=d$group, region=d$region, lab=d$lab),sd)

d2<-join_all(list(d.mean,d.sd, d.sum), by=c("group","threshold","region","lab"))

d2<-merge(d2,data.conn)

scaleFUN <- function(x) sprintf("%.2f", x)

#d2<-d2[d2$lab!="Modularity",]
d2<-droplevels(d2[!(d2$threshold<0.2 | d2$threshold>0.8),])
p.hemi.sep<-ggplot(d2, aes(threshold, GGP.mean, colour=group, shape=group))+
  geom_point(size=1)+
  geom_line()+
  geom_ribbon(aes(ymin=GGP.mean-GGP.sd/sqrt(n),ymax=GGP.mean+GGP.sd/sqrt(n), fill=group), alpha="0.1", linetype="solid", size=.1)+
  theme_pubr(base_size = 6)+
  theme(panel.background = element_rect(fill = NA, color = "black"), panel.grid.major = element_line(colour="gray", size=0.1),
        legend.position = "horizontal", legend.background = element_rect(fill = NA, colour = NA), strip.text = element_text(size=10), strip.text.y = element_blank(), axis.text=element_text(size=6))+
  facet_grid(lab~region, scales="free_y",switch="y")+
  scale_x_continuous("Density", limits=c(.2,.8))+
  scale_y_continuous("", position="left", labels = scaleFUN, expand=c(0,0))+
  scale_shape_manual(values = c("control"=0, "left"=2, "right"=1))+
  scale_color_manual(values=color_pal[4:6])+scale_fill_manual(values=color_pal[4:6])

p.hemi.sep
######

d<-as.data.frame(d %>%
                   group_by(threshold,lab,region) %>%
                   mutate_at(c("GGP"),funs(.-mean(.))))

str(d)
d.sum<-aggregate(list(n=d$n),list(threshold=d$threshold, lab=d$lab, relpos=d$relpos),sum)
d.mean<-aggregate(list(GGP.mean=d$GGP),list(threshold=d$threshold, lab=d$lab, relpos=d$relpos),mean)
d.sd<-aggregate(list(GGP.sd=d$GGP),list(threshold=d$threshold, lab=d$lab, relpos=d$relpos),sd)

d2<-join_all(list(d.mean,d.sd, d.sum), by=c("threshold","lab","relpos"))

d2<-merge(d2,data.conn)

#d2<-d2[d2$lab!="Modularity",]
d2$facet<-as.factor("Residuals")
p.hemi.combined<-ggplot(d2, aes(threshold, GGP.mean, colour=relpos, fill=relpos, shape=relpos))+
  geom_point(size=1)+
  geom_line()+
  geom_ribbon(aes(ymin=GGP.mean-GGP.sd/sqrt(n),ymax=GGP.mean+GGP.sd/sqrt(n), fill=relpos), alpha="0.1", linetype="solid", size=.1)+
  theme_pubr(base_size = 6)+
  theme(panel.background = element_rect(fill = NA, color = "black"), panel.grid.major = element_line(colour="gray", size=0.1),
        legend.position = "none",legend.background = element_rect(fill = NA, colour = NA),
        legend.direction="none", strip.text = element_text(size=10), strip.text.y = element_blank(),  axis.text=element_text(size=6))+
  facet_grid(lab~facet, scales="free_y",switch="y")+
  scale_y_continuous("", position="left", labels = scaleFUN)+
  scale_x_continuous("", limits=c(.2,.8))+
  scale_shape_manual(values = c("healthy"=3, "ipsi"=4, "contra"=8))+
  scale_color_manual(values=color_pal[c(2,3,1)])+scale_fill_manual(values=color_pal[c(2,3,1)])

####-----------
dd<-merge(d,data.patients)
ddd<-subset(dd,lab=='Modularity' & relpos=='ipsi' & threshold==0.5)
str(ddd)
LM<-lm(GGP~gripA, data=ddd)
summary(LM)
ggplot(ddd,aes(x=GGP, y=I(gripA)))+
  geom_point()
cor.test(ddd$GGP,ddd$gripA/ddd$gripU, method = 'pearson')
