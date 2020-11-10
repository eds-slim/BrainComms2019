## power analysis for NBS

require(lme4)
require(lmerTest)
F<-c()
tt<-c()

for(n in 1:100000){
d<-data.frame(ID=c(rep(1:21,2),22:30,31:38),side=c(rep(0,21),rep(1,21),rep(0,9),rep(1,8)), relpos=c(rep(0,42),rep(1,17)),value=rnorm(59))

LM<-lmer(value~relpos+side+(1|ID), data=d)
aov.out<-anova(LM)

s<-summary(LM)
F[n]<-aov.out$`F value`[1]
tt[n]<-s$coefficients[2,4]
}

plot(ecdf(F))
plot(ecdf(tt))

TT <- sort(tt)
e_cdf <- 1:length(TT) / length(TT)
plot(TT, e_cdf, type = "s")
abline(h = 0.6, lty = 3)
TT[which(e_cdf >= 1-0.0001)[1]]

1-e_cdf[which(TT>=3.1)[1]]
