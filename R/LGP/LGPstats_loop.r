
covariates<-''
d<-merge(data.hemispheres,data.LGP)
nodes.LGP=list();
effects.LGP=list();
stats.LGP<-data.frame("node"=character(),"LGP"=character(),"pval"=double(), "pvaladjust"=double(), "p.ipsi.vs.control"=double(), "p.contra.vs.control"=double(), "p.ipsi.vs.contra"=double(), stringsAsFactors = F);
#for(LGP in c("strength","efficiency","clustering")){
for(LGP in c("strength")){
    
  png(filename = paste(LGP,"-boxplot-groups.png",sep = ""),res=400,width=7,height=7, units = 'in');
  
  par(mfrow=c(3,3),mai=c(.5,.5,.3,.3), oma=c(0,0,2,0), cex.lab=2, cex.axis=.5, cex.main=2)
  nodes.LGP[[LGP]]<-list();
  effects.LGP[[LGP]]<-list();
  for(node in levels(data.LGP$node)){
    dd<-d[d$node==node,];
    
    #omnibus test 
    LM.lmer<-tryCatch(lme(as.formula(paste(LGP,"~1+relpos+region",sep = "")),random=~1|ID, data=dd), error=function(e)NULL)

    print(LM.lmer)
    if(is.null(LM.lmer)) next()
    print(LM.lmer)
    
    aov.out<-Anova(LM.lmer, contrasts = contr.sum, type=2, test.statistic = "Chisq");
    p<-aov.out["relpos","Pr(>Chisq)"];
    #p<-anova(LM.lmer)["relpos","p-value"]

    #main effects
    ddd<-dd[dd$relpos!='contra',]
    LM.full.ix<-lme(as.formula(paste(LGP,"~relpos*region",covariates,sep = )),random=~1|ID, ddd)
    LM.full<-lme(as.formula(paste(LGP,"~relpos+region",covariates,sep = )),random=~1|ID, ddd)
    LM.restricted<-lme(as.formula(paste(LGP,"~region",covariates,sep = )),random=~1|ID, ddd)
    LM.null<-lme(as.formula(paste(LGP,"~1",covariates,sep = )),random=~1|ID, ddd)
    aov.out<-anova(update(LM.null, .~., method="ML"), update(LM.restricted, .~., method="ML"), update(LM.full, .~., method="ML"),update(LM.full.ix, .~., method="ML"))
    p.ipsi.vs.control<-as.numeric(aov.out$`p-value`[3])

    ddd<-dd[dd$relpos!='ipsi',]
    LM.full.ix<-lme(as.formula(paste(LGP,"~relpos*region",covariates,sep = )),random=~1|ID, ddd)
    LM.full<-lme(as.formula(paste(LGP,"~relpos+region",covariates,sep = )),random=~1|ID, ddd)
    LM.restricted<-lme(as.formula(paste(LGP,"~region",covariates,sep = )),random=~1|ID, ddd)
    LM.null<-lme(as.formula(paste(LGP,"~1",covariates,sep = )),random=~1|ID, ddd)
    aov.out<-anova(update(LM.null, .~., method="ML"), update(LM.restricted, .~., method="ML"), update(LM.full, .~., method="ML"),update(LM.full.ix, .~., method="ML"))
    p.contra.vs.control<-as.numeric(aov.out$`p-value`[3])
    
    ddd<-dd[dd$relpos!='healthy',]
    LM.full.ix<-lme(as.formula(paste(LGP,"~relpos*region",covariates,sep = )),random=~1|ID, ddd)
    LM.full<-lme(as.formula(paste(LGP,"~relpos+region",covariates,sep = )),random=~1|ID, ddd)
    LM.restricted<-lme(as.formula(paste(LGP,"~region",covariates,sep = )),random=~1|ID, ddd)
    LM.null<-lme(as.formula(paste(LGP,"~1",covariates,sep = )),random=~1|ID, ddd)
    aov.out<-anova(update(LM.null, .~., method="ML"), update(LM.restricted, .~., method="ML"), update(LM.full, .~., method="ML"),update(LM.full.ix, .~., method="ML"))
    p.ipsi.vs.contra<-as.numeric(aov.out$`p-value`[3])
    
    stats.LGP[nrow(stats.LGP)+1,]=c(node,LGP,p,0,p.ipsi.vs.control,p.contra.vs.control,p.ipsi.vs.contra);
    
    effects.LGP[[LGP]][length(effects.LGP[[LGP]])+1]<-aov.out["dI","F value"];
    
    if(p<0.05/41){
      LM<-lme(as.formula(paste(LGP,"~relpos+region",covariates,sep = )),random=~1|ID, dd[dd$relpos!='ipsi',])
      p.pw<-summary(LM)$tTable["relposcontra","p-value"]
      print(p.pw);
      col<-ifelse(p.pw<0.05, "orange","black");
      boxplot(as.formula(paste(LGP,"~relpos",sep = "")),data=dd, cex=2, medcol = col, yaxt="n", names=c("Healthy controls","Contralesional","Affected by Stroke"));
      title(main = paste(node,sep = "")); #,"; p=",sprintf("%1.8f",p)
      nodes.LGP[[LGP]][length(nodes.LGP[[LGP]])+1]<-node;
    }
  }
  print(unlist(nodes.LGP[[LGP]]));
  stats.LGP$pval<-as.numeric(stats.LGP$pval);
  stats.LGP$pvaladjust[stats.LGP$LGP==LGP]<-p.adjust(stats.LGP$pval[stats.LGP$LGP==LGP], method="holm");
  #title(toupper(LGP), outer=TRUE)
  dev.off()
}


stats.LGP$pvaladjust<-as.numeric(stats.LGP$pvaladjust);
stats.LGP$pval<-as.numeric(stats.LGP$pval);
stats.LGP$col<-mapply(function(p){ifelse(p<0.05,"*","n.s.")},stats.LGP$pval);
stats.LGP$col<-mapply(function(p,c){ifelse(p<0.05,"**",c)},stats.LGP$pvaladjust, stats.LGP$col);



