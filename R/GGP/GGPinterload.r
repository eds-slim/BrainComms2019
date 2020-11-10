data.GGP<-read.csv(file.path(OUTPUT_DIR,'intermediate','GGP-inter-raw.csv'),header = TRUE)


data.GGP<-within(data.GGP,{
  region<-revalue(as.factor(region),c("0"="Whole brain"));
  lab<-revalue(as.factor(lab),c("1"="Efficiency","2"="Clustering","3"="Modularity"));
})
