source('./Various scripts/loadpackages.r')
source('./Various scripts/auxiliaryfunctions.r')
source('./Various scripts/loaddata.r')

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
  \\OldNum[scientific-notation=true,round-precision=2,#1]{#2}%
  }{%
  \\fpcmpTF{abs(#2)>=\\ThresholdHigh}{%
  \\OldNum[scientific-notation=true,#1]{#2}%
  }{%
  \\OldNum[scientific-notation=false,#1]{#2}%
  }%
  }%
  }%"
) )

d<-read.csv(file.path(OUTPUT_DIR,"intermediate","WSGGP-ls.dat"),header = TRUE)

d$group<-as.factor(d$group)
   

# recode norm --> raw for modularity
d$norm[d$lab==3]<-c(1,0)[d$norm[d$lab==3]+1]

WS.names <- c(
  '1'='Efficiency',
  '2'='Clustering',
  '3'='Modularity',
  '4'='Pathlength'
)
scaleFUN <- function(x) sprintf("%.2f", x)
d$groupjitter <- jitter(as.numeric(d$group),1)
require(scales)


p.WS<-ggplot(subset(d,norm==1 & lab <=3),aes(x=as.factor(group), y=GGP,color=group, fill=group))+
  geom_boxplot(alpha=.5, outlier.shape = NA)+
  geom_point(aes(x=groupjitter), size=.75, color="black", shape=21)+
  #stat_compare_means(aes(x-relpos), comparisons=list(c(1,2),c(1,3),c(2,3)))+
  theme_pubr(base_size = 6)+
  stat_summary(fun.y=mean, fill="darkgray", colour="black", geom="point", shape=23, size=1)+
  stat_signif(comparisons = list(c(1,2)), step_increase = .1, color="black", textsize = 1.5)+
  theme(axis.text=element_text(size=5, hjust=c(.75,.5)),axis.title=element_text(size=10,face="bold"), legend.position="none", strip.background = element_blank(), strip.text.x = element_blank(),panel.border = element_blank())+
  #theme(panel.background = element_rect(fill = "transparent", colour = "black"), plot.background = element_rect(fill = "transparent", colour = NA))+
  scale_x_discrete(labels=c("Intact","Lesioned"))+
  scale_y_continuous(expand = c(0.1,0), labels = scaleFUN,breaks = pretty_breaks(n = 2))+
  labs(x='',y="")+
  theme(legend.position="none")+
  scale_color_manual(values=color_pal[c(3,1)])+scale_fill_manual(values=color_pal[c(3,1)])+
  facet_wrap(~as.factor(lab), scales = "free", labeller=as_labeller(WS.names))


p.WS
pg<-ggplot_build(p.WS)

pg$data[[4]]<-pg$data[[4]][as.numeric(as.character(pg$data[[4]]$annotation))<.05,]
pg$data[[4]]$annotation<-unlist(lapply(as.numeric(as.character(pg$data[[4]]$annotation)), starsfcn))

#pg$data[[4]]$annotation<-paste("$\\num{",pg$data[[4]]$annotation,"}$", sep = "")
q1<-ggplot_gtable(pg)
grid.draw(q1)



ggsave(file.path(OUTPUT_DIR,"final","Figures","WSGGP2.pdf"), width=10.5, height = 5.25, units = 'in')
  
tikz(file = file.path(OUTPUT_DIR,"final","Figures","WSGGP-ls.tex"),width=3.54331,height=2, standAlone = TRUE);
grid.draw(q1);
dev.off();
