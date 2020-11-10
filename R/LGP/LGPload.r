
data.LGP<-read.csv(file.path(OUTPUT_DIR,"intermediate","LGP_50.csv"),header = TRUE)
data.LGP<-within(data.LGP,{
  node<-as.factor(node);
})
data.LGP<-within(data.LGP,{
  region<-revalue(as.factor(region),c("0"="LH","1"="RH"));
})

str(data.LGP)

#replace numerical nodes by proper labels
labels<-read.csv(file.path(BASE_DIR,"R","labels_short.txt"),header = FALSE)
levels(data.LGP$node)<-labels$V1

data.LGP<-data.LGP[!data.LGP$ID%in%ID.exclude,]
str(data.LGP)


####-------------
d<-merge(data.hemispheres,data.LGP)
dd<-merge(d,data.patients)

for(nn in c('precentral','postcentral','putamen','pallidum','thalamus')){
  ddd<-subset(dd, relpos == 'ipsi' & node == nn)
  cor.test(ddd$strength,ddd$gripA, method = 'pearson')  %>% print()
}


