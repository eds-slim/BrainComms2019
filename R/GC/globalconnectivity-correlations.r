d<-merge(merge(merge(data.patients,data.conn), data.hemispheres), data.subjects)
d<-droplevels(d[d$relpos=="ipsi",])

covs <- "age+sex+region+log(fuperiod)+"

par(mfrow=c(3,3),mai=c(.5,.5,.5,.5))
for(conn.meas in c("q50","lambda")){
  for(outcome in c("deltagrip","deltapinch","UEFM")){
    f.vol = as.formula(paste(outcome,"~",covs,"log(volume)",sep=""));
    f.full<-as.formula(paste(outcome,"~",covs,"log(volume)+",conn.meas,sep=""));
    
    LM.vol<-lm(f.vol,data=d);
    LM.full<-lm(f.full,data=d);
    s.LM.full<-summary(LM.full);
    
    aov.out<-anova(LM.vol,LM.full);
    #print(aov.out);
    print(s.LM.full);
    
    avp.out<-avPlots(LM.full,terms=as.formula(paste("~",conn.meas,sep = "")),col=d$region, col.lines="black", main = "");
    abline(lm(as.formula(paste(outcome,"~",conn.meas,sep = "")),data=as.data.frame((avp.out[[conn.meas]])[d$region=="LH",])), col=palette()[1]);
    abline(lm(as.formula(paste(outcome,"~",conn.meas,sep = "")),data=as.data.frame((avp.out[[conn.meas]])[d$region=="RH",])), col=palette()[2]);          
    title(main = paste("p=",sprintf("%1.5f",aov.out[2,"Pr(>F)"]),"\n Adj R^2=", sprintf("%1.5f",s.LM.full$adj.r.squared),sep = ""));
  }
}
for(outcome in c("deltagrip","deltapinch","UEFM")){
  f.vol = as.formula(paste(outcome,"~",covs,"log(volume)",sep=""));
  LM.vol<-lm(f.vol,data=d);
  s.LM.vol<-summary(LM.vol);
  
  aov.out<-Anova(LM.vol, contrasts=contr.sum, type=2);
  print(aov.out);
  
  avp.out<-avPlots(LM.vol,terms=as.formula(paste("~","log(volume)",sep = "")),col=d$region, col.lines="black", main="");
  abline(lm(as.formula(paste(outcome,"~.",sep = "")),data=as.data.frame((avp.out[["log(volume)"]])[d$region=="LH",])), col=palette()[1], main="");
  abline(lm(as.formula(paste(outcome,"~.",sep = "")),data=as.data.frame((avp.out[["log(volume)"]])[d$region=="RH",])), col=palette()[2], main="");  
  title(main = paste("p=",sprintf("%1.5f",s.LM.vol$adj.r.squared),"\n Adj R^2=", sprintf("%1.5f",s.LM.vol$adj.r.squared),sep = ""));
}
par(mfrow=c(1,1))