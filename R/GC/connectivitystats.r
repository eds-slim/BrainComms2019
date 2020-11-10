## analyse global connectivity of stroke networks. normalisation='sum', idx_thr=idx_con

p.list=c()
p.main.list<-c()

covariates<-"+age+sex";
#covariates<-"";
data<-merge(merge(data.hemispheres,data.conn),data.subjects)
data$age[which(is.nan(data$age))]<-60
for(conn.meas in c("q50","lambda")){
  
  cat(paste("Analysis for ", conn.meas, ":\n\n", sep = ""))
  
  cat("absolute values:\n")
  d<-data
  print(aggregate(as.formula(paste(conn.meas,"~relpos+region",sep = )), FUN=mean, data=d))
  print(aggregate(as.formula(paste(conn.meas,"~relpos+region",sep = )), FUN=function(x) sd(x)/sqrt(length(x)), data=d))
  
  print(aggregate(as.formula(paste(conn.meas,"~region",sep = )), FUN=mean, data=d))
  print(aggregate(as.formula(paste(conn.meas,"~region",sep = )), FUN=function(x) sd(x)/sqrt(length(x)), data=d))
  
  print(aggregate(as.formula(paste(conn.meas,"~relpos",sep = )), FUN=mean, data=d))
  print(aggregate(as.formula(paste(conn.meas,"~relpos",sep = )), FUN=function(x) sd(x)/sqrt(length(x)), data=d))
  
  ## Kern Anfang
  cat("Omnisbus test\n")
  d<-data
  LM.full.ix<-lme(as.formula(paste(conn.meas,"~relpos*region",covariates,sep = )),random=~1|ID, d)
  LM.full<-lme(as.formula(paste(conn.meas,"~relpos+region",covariates,sep = )),random=~1|ID, d)
  LM.restricted<-lme(as.formula(paste(conn.meas,"~region",covariates,sep = )),random=~1|ID, d)
  LM.null<-lme(as.formula(paste(conn.meas,"~1",covariates,sep = )),random=~1|ID, d)
  print(aov.out<-anova(update(LM.null, .~., method="ML"), update(LM.restricted, .~., method="ML"), update(LM.full, .~., method="ML"),update(LM.full.ix, .~., method="ML")))
  ## Kern Ende
  
  p<-aov.out$`p-value`[[3]]
  p.main.list<-c(p.main.list,p)
  
  cat("Main effects:\n")
  LMR<-lmer(as.formula(paste(conn.meas,"~region+(1|ID)",covariates, sep = "")),data=d); summary(LMR); print(anova(LMR))
  LMR<-lmer(as.formula(paste(conn.meas,"~relpos+(1|ID)",covariates, sep = "")),data=d); summary(LMR); print(anova(LMR))
  
  cat("Main effects by factor level:\n")
  LMR<-lmer(as.formula(paste(conn.meas,"~region+(1|ID)", covariates, sep = "")),data=d[d$relpos=="healthy",]); summary(LMR); print(anova(LMR));
  for(lesion.status in c("contra","ipsi")){
  LM<-lm(as.formula(paste(conn.meas,"~region", covariates, sep = "")),data=d[d$relpos==lesion.status,]); summary(LM); print(anova(LM));
  }
  
  for(side in c("LH","RH")){
    LM<-lm(as.formula(paste(conn.meas,"~relpos",covariates, sep = "")),data=d[d$region==side,]); summary(LM); print(anova(LM));
  }
  
  cat("Marginal contrasts:\n")
  cat("ipsi vs control\n")
  cat("left\n")
  d<-data[data$region=='LH' & data$group!='right',]
  LM<-lm(as.formula(paste(conn.meas,"~relpos",covariates,sep = )),data=d)
  print(summary(LM))
  print(t.test(as.formula(paste(conn.meas,"~relpos",sep = )),data=d, var.equal=TRUE))
  print(wilcox.test(as.formula(paste(conn.meas,"~relpos",sep = )),data=d, var.equal=TRUE))
  cat(paste("Cohen's: ", cohensD(d[d$relpos=="healthy",conn.meas],d[d$relpos=="ipsi",conn.meas]),"\n",sep = ""))
  
  cat("right\n")
  d<-data[data$region=='RH' & data$group!='left',]
  LM<-lm(as.formula(paste(conn.meas,"~relpos",covariates,sep = )),data=d)
  print(summary(LM))
  print(t.test(as.formula(paste(conn.meas,"~relpos",sep = )),data=d, var.equal=TRUE))
  print(wilcox.test(as.formula(paste(conn.meas,"~relpos",sep = )),data=d, var.equal=TRUE))
  cat(paste("Cohen's: ", cohensD(d[d$relpos=="healthy",conn.meas],d[d$relpos=="ipsi",conn.meas]),"\n",sep = ""))
  
  cat("combined\n")
  d<-data[data$relpos!='contra',]
  LM.full.ix<-lme(as.formula(paste(conn.meas,"~relpos*region",covariates,sep = )),random=~1|ID, d)
  LM.full<-lme(as.formula(paste(conn.meas,"~relpos+region",covariates,sep = )),random=~1|ID, d)
  LM.restricted<-lme(as.formula(paste(conn.meas,"~region",covariates,sep = )),random=~1|ID, d)
  LM.null<-lme(as.formula(paste(conn.meas,"~1",covariates,sep = )),random=~1|ID, d)
  print(aov.out<-anova(update(LM.null, .~., method="ML"), update(LM.restricted, .~., method="ML"), update(LM.full, .~., method="ML"),update(LM.full.ix, .~., method="ML")))
  
  p<-aov.out$`p-value`[3]
  p.list <- c(p.list,p)
  
  cat("contra vs control\n")
  cat("left\n")
  d<-data[data$region=='LH' & data$group!='left',]
  LM<-lm(as.formula(paste(conn.meas,"~relpos",covariates,sep = )),data=d)
  print(summary(LM))
  print(t.test(as.formula(paste(conn.meas,"~relpos",sep = )),data=d, var.equal=TRUE))
  print(wilcox.test(as.formula(paste(conn.meas,"~relpos",sep = )),data=d, var.equal=TRUE))
  cat(paste("Cohen's: ", cohensD(d[d$relpos=="healthy",conn.meas],d[d$relpos=="contra",conn.meas]),"\n",sep = ""))
  
  cat("right\n")
  d<-data[data$region=='RH' & data$group!='right',]
  LM<-lm(as.formula(paste(conn.meas,"~relpos",covariates,sep = )),data=d)
  print(summary(LM))
  print(t.test(as.formula(paste(conn.meas,"~relpos",sep = )),data=d, var.equal=TRUE))
  print(wilcox.test(as.formula(paste(conn.meas,"~relpos",sep = )),data=d, var.equal=TRUE))
  cat(paste("Cohen's: ", cohensD(d[d$relpos=="healthy",conn.meas],d[d$relpos=="contra",conn.meas]),"\n",sep = ""))
  
  cat("combined\n")
  d<-data[data$relpos!='ipsi',]
  LM.full.ix<-lme(as.formula(paste(conn.meas,"~relpos*region",covariates,sep = )),random=~1|ID, d)
  LM.full<-lme(as.formula(paste(conn.meas,"~relpos+region",covariates,sep = )),random=~1|ID, d)
  LM.restricted<-lme(as.formula(paste(conn.meas,"~region",covariates,sep = )),random=~1|ID, d)
  LM.null<-lme(as.formula(paste(conn.meas,"~1",covariates,sep = )),random=~1|ID, d)
  print(aov.out<-anova(update(LM.null, .~., method="ML"), update(LM.restricted, .~., method="ML"), update(LM.full, .~., method="ML"),update(LM.full.ix, .~., method="ML")))
  
  p<-aov.out$`p-value`[3]
  p.list <- c(p.list,p)
  
  cat("ipsi vs contra\n")
  cat("left\n")
  d<-data[data$region=='LH',]
  LM.full<-lme(as.formula(paste(conn.meas,"~relpos",covariates,sep = )),random=~1|ID, d)
  print(summary(LM.full))
  LM.null<-lme(as.formula(paste(conn.meas,"~1",covariates,sep = )),random=~1|ID, d)
  print(anova(update(LM.null, .~., method="ML"), update(LM.full, .~., method="ML")))
  
  
  cat("right\n")
  d<-data[data$region=='RH',]
  LM.full<-lme(as.formula(paste(conn.meas,"~relpos",covariates,sep = )),random=~1|ID, d)
  print(summary(LM.full))
  LM.null<-lme(as.formula(paste(conn.meas,"~1",covariates,sep = )),random=~1|ID, d)
  print(anova(update(LM.null, .~., method="ML"), update(LM.full, .~., method="ML")))
  
  
  cat("combined\n")
  d<-data[data$group!='control',]
  LM.full.ix<-lme(as.formula(paste(conn.meas,"~relpos*region",covariates,sep = )),random=~1|ID, d)
  LM.full<-lme(as.formula(paste(conn.meas,"~relpos+region",covariates,sep = )),random=~1|ID, d)
  LM.restricted<-lme(as.formula(paste(conn.meas,"~region",covariates,sep = )),random=~1|ID, d)
  
  print(summary(LM.full))
  LM.null<-lme(as.formula(paste(conn.meas,"~1",covariates,sep = )),random=~1|ID, d)
  print(aov.out<-anova(update(LM.null, .~., method="ML"),update(LM.restricted, .~., method="ML"), update(LM.full, .~., method="ML"), update(LM.full.ix, .~., method="ML")))
  p<-aov.out$`p-value`[3]
  p.list <- c(p.list,p)
  
  print(p.list)
}


