source('./Various scripts/loadpackages.r')
source('./Various scripts/auxiliaryfunctions.r')
source('./Various scripts/loaddata.r')

# Global conectivity
source("./GC/connectivityload.r")
source("./GC/connectivitystats.r")

require(tikzDevice)
options( tikzDocumentDeclaration = c(
  "\\documentclass[a4paper]{article}",
  "\\renewcommand{\\familydefault}{\\sfdefault}",
  "\\usepackage{siunitx}",
  "\\usepackage{tikz}",
  "\\sisetup{scientific-notation=true, round-mode=places, round-precision=4}",
  "\\usepackage{expl3,siunitx}
\\sisetup{scientific-notation=true}
\\ExplSyntaxOn
    \\cs_new_eq:NN \\fpcmpTF \\fp_compare:nTF
\\ExplSyntaxOff

\\newcommand*{\\ThresholdLow}{0.0001}
\\newcommand*{\\ThresholdHigh}{100}

\\let\\OldNum\\num%
\\renewcommand*{\\num}[2][]{%
    \\fpcmpTF{abs(#2)<=\\ThresholdLow}{%
        \\OldNum[scientific-notation=true,#1]{#2}%
    }{%
        \\fpcmpTF{abs(#2)>=\\ThresholdHigh}{%
            \\OldNum[scientific-notation=true,#1]{#2}%
        }{%
            \\OldNum[scientific-notation=false,#1]{#2}%
        }%
    }%
}%"
) )


conn.meas<-"q50"

#data<-merge(data.hemispheres,data.conn)
d<-gather(data, conn.meas, value,q50,lambda,factor_key=TRUE)

conn.meas.names <- c(
  'q50'=paste("Median connectivity ($p=\\num{",p.main.list[1], "}$)",sep = ""),
  'lambda'=paste("Characteristic path length ($p=\\num{",p.main.list[2], "}$)",sep = "")
)



x.list<-c(1,3,4.1)
d$relpos=ordered(d$relpos,c("healthy","contra","ipsi"))
d$x<-x.list[as.numeric(d$relpos)]
d$relposjitter <- jitter(d$x,2)

my.comparisons<-list(x.list[c(1,3)],x.list[c(1,2)],x.list[c(2,3)])


p<-ggplot(d,aes(x=x, y=value, color=relpos, fill=relpos))+
  geom_boxplot(alpha=.5, outlier.shape = NA, width = 1)+
  #geom_line(data=subset(d,x != x.list[1]), aes(x=relposjitter, group=ID), col="darkgray", alpha=.5)+
  geom_point(aes(x=relposjitter, shape=region), size=1, colour="black")+
  stat_signif(annotations = c("ipsi.vs.contra","contra.vs.control","ipsi.vs.control"), comparisons = my.comparisons,
              step_increase = -0.1, color="black", textsize = 2)+
  theme_pubr(base_size = 6)+
  stat_summary(fun.y=mean, fill="darkgray", colour="black", geom="point", shape=23, size=1)+
  theme(panel.background = element_rect(fill = "transparent", colour = "black"), plot.background = element_rect(fill = "transparent", colour = NA))+
  scale_color_manual(values=color_pal[c(2,3,1)])+scale_fill_manual(values=color_pal[c(2,3,1)])+
  theme(axis.text=element_text(size=7, hjust=c(.9,.8,.3)),axis.title=element_text(size=12,face="bold"), legend.position="none", strip.background = element_blank(), strip.text.x = element_blank(),panel.border = element_blank())+
  scale_x_discrete(limits=x.list, labels=c("Controls","Contralesional","Ipsilesional"))+
  scale_y_continuous(expand = c(0.1,0))+
  scale_shape_manual(values=c("LH"=24,"RH"=21))+
  labs(x='',y="")+
  facet_wrap(~conn.meas, scales = "free", labeller=as_labeller(conn.meas.names))


pg<-ggplot_build(p)
pv<-pg$data[[3]]$annotation
new<-as.numeric(rep(p.list, each=3))
pg$data[[3]]$annotation<-new
pg$data[[3]]<-pg$data[[3]][pg$data[[3]]$annotation<0.05,]


starsfcn<-function(p){return(strrep("*",floor(-log10(as.numeric(p)/5))-1))}
pg$data[[3]]$annotation<-unlist(lapply(pg$data[[3]]$annotation, starsfcn))

#pg$data[[3]]$annotation<-paste0("$p=\\num{",pg$data[[3]]$annotation,"}$")

q<-ggplot_gtable(pg)
dev.off()
grid.draw(q)

#tiff(filename = "LGP-boxplots-group.tiff",res=200,width=14,height=7, units = 'in');
pdf(file = file.path(OUTPUT_DIR,"final","Figures","GC.pdf"),width=12,height=6);
grid.draw(q)
dev.off()
ggsave(file.path(OUTPUT_DIR,"final","Figures","GC.png"), plot=q, width=7, height = 7, units = 'in')

tikz(file = file.path(OUTPUT_DIR,"final","Figures","GC.tex"),width=3.54331,height=2, standAlone = TRUE);
grid.draw(q)
dev.off()

## association with clinical
dd<- merge(d, data.patients)
LM<-lme(value~log(volume)*relpos, random=~1|ID, data=subset(dd, conn.meas=="q50"), method = "ML")
LM2<-lme(value~log(volume)+relpos, random=~1|ID, data=subset(dd, conn.meas=="q50"), method = "ML")
anova(LM,LM2)

summary(LM)
abline(LM)
ggplot(dd, aes(x=age, y=value, color=relpos))+
  geom_point()+
  geom_smooth(aes(group=relpos), method = "lm", se=T)+
  facet_wrap(conn.meas~., scales = "free", ncol = 1)

summary(lm(value~age, data=dd, subset = conn.meas=="q50" & relpos=="contra"))

ggplot(subset(dd, gripA>0), aes(x=value, y=UEFM, color=relpos))+
  geom_point()+
  geom_smooth(aes(group=relpos), method = "lm", se=T)+
  facet_wrap(conn.meas~., scales = "free", ncol = 1)

summary(lm(I(UEFM)~value, d=subset(dd, conn.meas=="q50" & relpos=="ipsi" & gripA>0)))

dd$value[dd$relpos=="ipsi" & conn.meas=="q50"]-dd$value[dd$relpos=="contra" & conn.meas=="q50"]
(dd$gripU-dd$gripA)[dd$relpos=="ipsi" & dd$conn.meas=="q50"]


####------------------
str(dd)
ddd<-subset(dd,conn.meas=='q50' & relpos=='ipsi')
LM<-lm(value~I(pinchA/ddd$pinchU), data=ddd)
summary(LM)
ggplot(ddd,aes(x=value, y=I(gripA/gripU)))+
  geom_point()
cor.test(ddd$value,ddd$gripA/ddd$gripU, method = 'pearson')
