dd<-merge(data.patients[,c("ID","Stroke.side")],data.clinical[,c("ID","vol","age","gender","NIHSS_T1","FM_T1","NHP_ratio_T1","Gripstrength_ratio_T1","dominant_affected")])

dd<-data.clinical[,c("numID","Stroke.side","vol","age","gender","NIHSS_T1","FM_T1","NHP_ratio_T1","Gripstrength_ratio_T1","dominant_affected")]
dd<-unique(dd)
dd$NHP_ratio_T1<-1/dd$NHP_ratio_T1
dd$logvol<-log(dd$vol)
str(dd)

pca_T1<-dd.pca<-prcomp(~Gripstrength_ratio_T1+NHP_ratio_T1+I(FM_T1/60), data=dd, na.action = na.exclude)
pca_T1

dd<-merge(data.patients[,c("ID","Stroke.side")],data.clinical[,c("ID","vol","age","gender","NIHSS_T3","FM_T3","NHP_ratio_T3","Gripstrength_ratio_T3","dominant_affected")])

dd<-data.clinical[,c("numID","Stroke.side","vol","age","gender","NIHSS_T3","FM_T3","NHP_ratio_T3","Gripstrength_ratio_T3","dominant_affected")]
dd<-unique(dd)
dd$NHP_ratio_T3<-1/dd$NHP_ratio_T3
dd$logvol<-log(dd$vol)
str(dd)

pca_T3<-dd.pca<-prcomp(~Gripstrength_ratio_T3+NHP_ratio_T3+I(FM_T3/60), data=dd, na.action = na.exclude)
pca_T3
