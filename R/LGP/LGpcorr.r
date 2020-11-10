palette(terrain.colors(3))
par(mfrow=c(1,2),mai=c(1,1,1,.35))
for(LGP in c("strength","efficiency","clustering")){
#for(LGP in c("clustering")){
  #LGP="clustering"
  for(outcome in c("deltagrip","deltapinch","UEFM")){
    for(node in nodes.LGP[[LGP]]){
      #for(node in unique(levels(data.LGP$node))){
      
      d<-data.LGP[(data.LGP$node==node) & (data.LGP$relpos=="ipsi"),];
      dd<-merge(d,data.patients);
      dd<-merge(dd,data.hemispheres);
      dd<-merge(dd,data.subjects);
      
      pc.out<-princomp(dd[,c("strength","efficiency","clustering")]);
      dd$PC_LGP<-pc.out$scores[,"Comp.1"];
      if(cor(dd$PC_LGP,dd$strength)<0) dd$PC_LGP<--dd$PC_LGP;
      f<-as.formula(paste(outcome,"~",LGP,"+region+log(volume)+log(fuperiod)+age+sex",sep = ""));
      LM<-lm(f,data=dd);
      #LM<-MASS::stepAIC(LM, scope=c(lower=as.formula(paste("~",LGP,sep = "")),upper=f), trace = F)
      s.LM<-summary(LM);
      p<-s.LM$coefficients[LGP,"Pr(>|t|)"];print(p);
      #aov.out<-Anova(LM, contrasts=contr.sum, type=2);
      #p<-aov.out[LGP,"Pr(>F)"];
      if(p<0.5/length(unlist(nodes.LGP[[LGP]]))){
        print(node); 
        print(summary(LM));
        avp.out<-avPlots(LM, terms=as.formula(paste("~",LGP,sep = "")), col=as.factor(dd$region), col.lines="black", pch=4, main = "");
        abline(lm(as.formula(paste(outcome,"~",LGP,sep = "")),data=as.data.frame((avp.out[[LGP]])[dd$region=="LH",])), col=palette()[1]);
        abline(lm(as.formula(paste(outcome,"~",LGP,sep = "")),data=as.data.frame((avp.out[[LGP]])[dd$region=="RH",])), col=palette()[2]);  
        
        title(main = paste("Outcome=", outcome,"\n region=", node, "\n p=", sprintf("%1.5f",p), sep = ""));
      }
    }
  }
}