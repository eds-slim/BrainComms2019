data.conn <- read.csv(file.path(OUTPUT_DIR,'intermediate','connectivity.csv'), header = T)
data.conn<-within(data.conn,{
  region<-revalue(as.factor(region),c("0"="LH","1"="RH"));
})
data.conn<-data.conn[!data.conn$ID%in%ID.exclude,]
