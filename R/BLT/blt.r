source('./Various scripts/loadpackages.r')
source('./Various scripts/auxiliaryfunctions.r')
source('./Various scripts/loaddata.r')

## demo table
d<-data.subjects
d$group<-factor(d$group, levels=c(levels(d$group),"patient"))
d$group[d$group %in% c("left","right")]<-"patient"
d$group<-droplevels(d$group)
xt<-xtabs(~sex+group,data=d)
xt
chisq.test(xt)

mean(d$age[d$group=="patient"], na.rm=TRUE)
sd(d$age[d$group=="patient"], na.rm=TRUE)

t.test(d$age[d$group=="control"],d$age[d$group=="patient"], var.equal = TRUE)
LM<-lm(age~group,data=d)
summary(LM)
anova(LM)


d<-merge(data.patients,data.subjects)
count(d,group)

aggregate(d$age,list(group=d$group),mean)
aggregate(d$age,list(group=d$group),sd)
aggregate(d$age,list(group=d$group),IQR)

count(data.subjects,group)
xtabs(~sex+group,data=data.subjects)
aggregate(list(age=data.subjects$age),list(group=data.subjects$group),mean)
aggregate(list(age=data.subjects$age),list(group=data.subjects$group),sd)

LM<-lm(age~group,data=data.subjects)
summary(LM)

xt=xtabs(~group+sex,data=data.subjects)
res=fisher.test(xt, conf.int = TRUE)
res$p.value

chisq.test(xt, simulate.p.value = TRUE,B=1e7)

range(data.patients$UEFM)
median(data.patients$gripA-data.patients$gripU)
c(quantile(data.patients$UEFM, 1/4),quantile(data.patients$UEFM, 3/4))

LM<-lm(volume~age+sex+group,data=d)
summary(LM)
anova(LM)



LM<-lm(volume~UEFM, data=d)
summary(LM)
ggplot(d,aes(x=volume, y=I(gripA)))+
  geom_point()
cor.test(d$volume,d$pinchA/d$pinchU)


d.wide<-gather(d, griptype, grip, gripU:gripA, factor_key=TRUE)
d.wide<-gather(d.wide, pinchtype, pinch, pinchU:pinchA, factor_key=TRUE)
d.wide<-d.wide[!duplicated(d.wide),]


plot(grip~sex, data=subset(d.wide, grip>9))
LM<-lm(grip~sex+griptype+age+log(fuperiod),data=d.wide, subset = pinchtype=="pinchA")
summary(LM)
LM<-lm(pinch~sex+pinchtype+age+log(fuperiod),data=d.wide, subset = griptype=="gripA")
summary(LM)




LM<-lm(I((pinchA))~log(volume),data=d, subset=gripA>0)
summary(LM)
LM<-lm(grip~sex+age+log(volume),data=d.wide, subset = pinchtype=="pinchA" & griptype=="gripU")
summary(LM)
ggplot(subset(d, gripA>20), aes(x=log(volume), y=I(pinchU), color=sex, shape=group))+
  geom_point(aes(size=log(volume)))+
  geom_smooth(aes(group=1), method = "lm")

require(effsize)
summary(lm(pinch~age, data=subset(d.wide,griptype=="gripU")))
