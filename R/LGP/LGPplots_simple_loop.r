source('./Various scripts/loadpackages.r')
source('./Various scripts/auxiliaryfunctions.r')
source('./Various scripts/loaddata.r')

## Local graph parameters
source("./LGP/LGPload_loop.r")
source("./LGP/LGPstats_loop.r")

require(tikzDevice)
options( tikzDocumentDeclaration = c(
  "\\documentclass[a4paper]{article}",
  "\\renewcommand{\\familydefault}{\\sfdefault}",
  "\\usepackage{siunitx}",
  "\\usepackage{standalone}",
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
        \\OldNum[scientific-notation=true,round-precision=1,#1]{#2}%
    }{%
        \\fpcmpTF{abs(#2)>=\\ThresholdHigh}{%
            \\OldNum[scientific-notation=true,#1]{#2}%
        }{%
            \\OldNum[scientific-notation=false,#1]{#2}%
        }%
    }%
}%"
) )

for(plot.LGP in levels(as.factor(stats.LGP$LGP))){
print(plot.LGP);
data.LGP <- merge(data.hemispheres,data.LGP)

d<-data.LGP[data.LGP$node %in% nodes.LGP[[plot.LGP]],]

x.list<-c(1,3,4.1)
d$x<-x.list[as.numeric(d$relpos)]
d$relposjitter <- jitter(d$x,2)
#d$relposjitter <- jitter(as.numeric(d$relpos),1)



d.sort <- stats.LGP[stats.LGP$LGP==plot.LGP,]

d$facet<-factor(d$node, levels=d.sort[order(d.sort$pval),"node"])

ddd<-d.sort[order(d.sort$pval),][d.sort[order(d.sort$pval),]$node %in% nodes.LGP[[plot.LGP]],]
#LGP.names<-setNames(paste(ddd$node,"\n($p=\\num{",ddd$pval, "}$, $p^*=\\num{",ddd$pvaladjust, "}$)", sep = ""),ddd$node)

p1<-ggplot(d,aes(x=x, y=get(plot.LGP), color=as.factor(x), fill=as.factor(x)))+
  geom_boxplot(alpha=.5, outlier.shape = NA, width = 1)+
  #geom_line(data=subset(d,x != x.list[1]), aes(x=relposjitter, group=ID), col="darkgray", alpha=.5)+
  geom_point(aes(x=relposjitter, shape=region), size=.5, colour="black")+
  stat_signif(annotations = c("ipsi.vs.contra","contra.vs.control","ipsi.vs.control"), comparisons = list(x.list[c(2,3)],x.list[c(1,2)],x.list[c(1,3)]),
               step_increase = 0.15, color="black", textsize = 2)+
  theme_pubr(base_size = 5)+
  stat_summary(fun.y=mean, fill="darkgray", colour="black", geom="point", shape=23, size=1)+
  theme(panel.background = element_rect(fill = "transparent", colour = "black"), 
        plot.background = element_rect(fill = "transparent", colour = NA),
        legend.direction = "horizontal", legend.position = "none",
          axis.text=element_text(size=4, hjust=c(.9,.8,.3)),strip.text.x = element_text(size = 6, colour = "black"))+
  scale_color_manual(values=color_pal[c(2,3,1)])+scale_fill_manual(values=color_pal[c(2,3,1)])+
  scale_shape_manual(name="", values=c("LH"=24,"RH"=21))+
  scale_x_discrete("", limits=x.list, labels=c("Controls","Contralesional","Ipsilesional"))+scale_y_continuous(plot.LGP, expand = c(0.2,0))+
  facet_wrap(~facet, nrow = 2, scales = "free") #, labeller = as_labeller(LGP.names)

p1
pg<-ggplot_build(p1)
pg$data[[3]]$annotation<-as.character(pg$data[[3]]$annotation)
pg$data[[3]]$annotation[pg$data[[3]]$annotation=="ipsi.vs.control"]<-rep(ddd$p.ipsi.vs.control,each=3)
pg$data[[3]]$annotation[pg$data[[3]]$annotation=="contra.vs.control"]<-rep(ddd$p.contra.vs.control,each=3)
pg$data[[3]]$annotation[pg$data[[3]]$annotation=="ipsi.vs.contra"]<-rep(ddd$p.ipsi.vs.contra,each=3)

pg$data[[3]]<-pg$data[[3]][as.numeric(pg$data[[3]]$annotation)<.05,]

starsfcn<-function(p){return(strrep("*",floor(-log10(as.numeric(p)/5))-1))}
pg$data[[3]]$annotation<-unlist(lapply(pg$data[[3]]$annotation, starsfcn))

#pg$data[[3]]$annotation<-paste("$\\num{",pg$data[[3]]$annotation,"}$", sep = "")
q1<-ggplot_gtable(pg)
grid.draw(q1)



stats.LGP$logpval <- -log(stats.LGP$pval)
p.holm<-unlist(lapply(1:41,function(k){-log(0.05/(41-k+1))}))
stats.LGP$p.holm<-rep(p.holm[order(order(-stats.LGP[stats.LGP$LGP==plot.LGP,"logpval"]))],1)

dollarify <- function(){
  function(x) gsub("_", "\\_", x, fixed=TRUE)
}

p2<-ggplot(stats.LGP[stats.LGP$LGP==plot.LGP,],aes(x=reorder(node,-logpval),logpval, color=reorder(col,-logpval), shape=reorder(col,-logpval), fill=reorder(col,-logpval)))+
  geom_hline(yintercept = -log(0.05), color="lightgray")+
  geom_hline(yintercept = -log(0.05/41), color="lightgray")+
  geom_linerange(aes(ymin=0,ymax=logpval), alpha=.5, size=2, stat = "identity")+
  geom_point(stat="identity", size=1, color="black")+
  scale_color_manual(values=color_pal[7:9])+
  theme_pubr(base_size = 6)+theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1, size = 8),axis.text.y=element_text(size = 8), axis.title = element_text(size=12), legend.position = "bottom")+
  #scale_fill_jco(guide=FALSE)+scale_color_jco(name="SigLevel")+scale_shape_manual(values = c(21,22,24),name="LGP")+
  scale_x_discrete("", labels=dollarify())+  scale_y_continuous("Significance of main effect of lesion status ($-\\log p$)")+
  annotate("text",x=41,y=-log(0.05/41), label="$p=0.05/41$", vjust = -.5, hjust=1, size=3)+
  annotate("text",x=41,y=-log(0.05), label="$p=0.05$", vjust = -.5, hjust=1, size=3)
p2

vp <- viewport(width = 0.75, height = 0.55, x = 0.2, y = 1,just=c("left","top"))
p2+theme(legend.position = "none")+annotation_custom(grob=ggplot_gtable(pg), xmin=6, ymin=7)
ggsave(file.path(OUTPUT_DIR,"final","Figures",paste("LGP_",plot.LGP, prop,".png",sep = "")), width=10, height = 7, units = 'in')

tikz(file = file.path(OUTPUT_DIR,"final","Figures",paste("LGP_",plot.LGP, prop,".tex",sep = "")),width=7.28346,height=6, standAlone = TRUE);
print(p2+theme(legend.position = "none")+annotation_custom(grob=ggplot_gtable(pg), xmin=6, ymin=7));
dev.off();
}

file.copy(file.path(OUTPUT_DIR,"final","Figures",paste("LGP_","efficiency", prop, ".png",sep = "")),file.path(OUTPUT_DIR,"final","Figures","LGP.png"), overwrite = TRUE)
file.copy(file.path(OUTPUT_DIR,"final","Figures",paste("LGP_","efficiency", prop,".tex",sep = "")),file.path(OUTPUT_DIR,"final","Figures","LGP.tex"), overwrite = TRUE)
