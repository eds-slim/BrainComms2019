palette("default")
scatterplotMatrix(~deltagrip+deltapinch+UEFM+log(volume)+log(fuperiod)+age,data=data.patients, diagonal="none", smooth=F, reg.line=F, by.groups=T, ellipse=T, levels=c(0.95))


plot(deltagrip ~log(volume), col="lightblue", pch=19, cex=2,data=data.patients)
abline(lm(deltagrip ~log(volume), data=data.patients), col="red", lwd=3)
text(deltagrip ~log(volume), labels=ID,data=data.patients, cex=0.9, font=2)
