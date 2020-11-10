source('./Various scripts/loadpackages.r')
source('./Various scripts/auxiliaryfunctions.r')
source('./Various scripts/loaddata.r')

# Global graph parameters
source("./GGP/GGPintraload.r")
source("./GGP/GGPintraplots.r")
source("./GGP/GGPinterload.r")
source("./GGP/GGPinterplots.r")

require(tikzDevice)
options(tikzLatex = "/usr/local/texlive/2017/bin/x86_64-linux/pdflatex",
        tikzDocumentDeclaration = c(
  "\\documentclass[a4paper]{article}",
  "\\renewcommand{\\familydefault}{\\sfdefault}",
  "\\usepackage{siunitx}",
  "\\usepackage{tikz}",
  "\\sisetup{scientific-notation=true, round-mode=places, round-precision=4}"
) )

leg1<-get_legend(p.whole + labs(fill="", shape="", color="") + 
                   theme(legend.position = "bottom", legend.direction = "horizontal",legend.justification="center", 
                         legend.box.just = "bottom", legend.margin=margin(b=0, unit = "cm"), legend.text = element_text(size=6)))
leg2<- get_legend(p.hemi.combined + labs(fill="", shape="", color="") 
                  + theme(legend.position = "bottom", legend.direction = "horizontal",legend.justification="center" ,
                          legend.box.just = "bottom", legend.margin=margin(b=0, unit = "cm"), legend.text = element_text(size=6)))

labs<-c("Whole brain","Indivual hemispheres","Residuals")
prow<-plot_grid(p.whole + theme(plot.margin = unit(c(2,0,0,0), "lines")),
          p.hemi.sep + theme(plot.margin = unit(c(2,0,0,0), "lines")), 
          p.hemi.combined + theme(plot.margin = unit(c(2,0,0,0), "lines")),
          ncol=3, align = "h", axis="t")

prow

pg<-plot_grid(prow, plot_grid(leg1, leg2, ncol=2, rel_heights = c(1,1)), ncol=1)
pdf(file = file.path(OUTPUT_DIR,"final","Figures","GGP.pdf"),width=10,height=5);
#png(file = "GlobalGraphParameters_ESOC.png",width=600,height=400, units = 'px');
print(prow);
dev.off()

ggsave(file.path(OUTPUT_DIR,"final","Figures","GGP.png"), plot=prow, width=10, height = 5, units = 'in')

tikz(file = file.path(OUTPUT_DIR,"final","Figures","GGP-raw.tex"),width=7.28346,height=4, standAlone = TRUE);
print(prow)
dev.off()


# relation to clinical
dd<-merge(data.GGP,data.subjects)
dd<-merge(dd,data.conn)
dd$relpos <- as.factor(mapply(relposfcn, dd$region, dd$group))
dd<-merge(dd,data.patients)
dd<-merge(dd,data.subjects)

ggplot(subset(dd, threshold==0.8), aes(x=GGP, y=gripU, color=relpos))+
         geom_point()+
         geom_smooth(aes(group=relpos), method = "lm", se=T)+
         facet_wrap(.~lab, scales = "free", ncol = 1)
summary(lm(GGP~age, data=subset(dd,lab=="Clustering" & threshold==.8 & relpos=="ipsi")))
       

summary(lm(I(gripU)~GGP+age+sex, data=subset(dd, threshold==0.8 & lab=="Modularity")))

        