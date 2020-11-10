#%BASE_DIR<-"~/Documents/Chronic stroke refactored"
#BASE_DIR<-"/home/eckhard/Dropbox/2018 05 02 Chronic stroke refactored/Chronic stroke refactored"
#BASE_DIR<-"/home/eckhard/Documents/2018 05 02 b Chronic stroke refactored/Chronic stroke refactored"

source("./makeconfig.r")

setwd(file.path(getwd(),".."))
BASE_DIR<-getwd();
setwd(file.path(getwd(),"R"))

OUTPUT_DIR <- file.path(BASE_DIR,".output",normalisation,thresholding,sprintf("%1.2f",griddelta))

color_pal <- pal_npg()(10)

ID.exclude <- c(28,30,32,36); 

data.subjects<-read.csv(file.path(OUTPUT_DIR,'intermediate','subjectdata.csv'),header = TRUE)
data.subjects<-within(data.subjects,{
  group<-revalue(as.factor(group),c("0"="control","1"="left","2"="right"));
  sex<-as.character(sex);
  sex <- factor(revalue(sex,c("1"="male","2"="female")));
})
data.subjects<-data.subjects[!data.subjects$ID%in%ID.exclude,]


data.patients<-read.csv(file.path(OUTPUT_DIR,'intermediate','patientdata.csv'),header = TRUE)
data.patients<-data.patients[!data.patients$ID%in%ID.exclude,]


data.hemispheres<-read.csv(file.path(OUTPUT_DIR,'intermediate','hemispheredata.csv'),header = TRUE)
data.hemispheres<-within(data.hemispheres,{
  region<-revalue(as.factor(region),c("0"="LH","1"="RH"));
  group<-revalue(as.factor(group),c("0"="control","1"="left","2"="right"));
})
data.hemispheres$relpos <- as.factor(mapply(relposfcn,data.hemispheres$region, data.hemispheres$group))
data.hemispheres$relpos<-factor(data.hemispheres$relpos, levels=c("healthy","contra","ipsi"))
data.hemispheres<-data.hemispheres[!data.hemispheres$ID%in%ID.exclude,]





data.conn <- read.csv(file.path(OUTPUT_DIR,'intermediate','connectivity.csv'), header = T)
data.conn<-within(data.conn,{
  region<-revalue(as.factor(region),c("0"="LH","1"="RH"));
})


#data.conn$relpos <- as.factor(mapply(relposfcn,data.conn$region, data.conn$group))
#data.conn$relpos<-factor(data.conn$relpos, levels=c("healthy","contra","ipsi"))

data.conn<-data.conn[!data.conn$ID%in%ID.exclude,]

