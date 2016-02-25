require(zoo)
require(R.utils)

argmax = function(x, y, w=1, ...) {
  n        = length(y)
  y.smooth = loess(y ~ x, ...)$fitted
  y.max    = rollapply(zoo(y.smooth), 2*w+1, max, align="center")
  delta    = y.max - y.smooth[-c(1:w, n+1-1:w)]
  i.max    = which(delta <= 0) + w
  list(x=x[i.max], i=i.max, y.hat=y.smooth)
}

main = function() {
  dat.dir = "~/work/ecol596/project/data"
  setwd(dat.dir)
  w    = 1
  span = .4
  i    = 0

  for (fname in list.files(dat.dir, pattern="*.fa$")) {
    i = i + 1
    printf("%5d: %s\n", i, fname)
    dat = read.delim(file.path(dat.dir, fname), sep=" ", header=F)
    colnames(dat) = c("freq", "count")
    
    x     = dat$freq
    y     = dat$count
    peaks = argmax(x=x, y=y, w=w, span=span)
    
    png(filename = paste0(fname, '.png'))
    plot(x, y, cex=0.75, col="Gray", main=fname, xlab="count", ylab="frequency")
    lines(x, peaks$y.hat,  lwd=2) 
    y.min = min(y)
    sapply(peaks$i, function(i) lines(c(x[i],x[i]), c(y.min, peaks$y.hat[i]),
                                      col="Red", lty=2))
    points(x[peaks$i], peaks$y.hat[peaks$i], col="Red", pch=19, cex=1.25)
    dev.off()
  }
  printf("Finished, processed %s file%s.\n", i, ifelse(i==1, '', 's'))
}

main()