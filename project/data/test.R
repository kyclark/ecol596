require(zoo)
require(R.utils)

argmax = function(x, y, w=1, ...) {
  n         = length(y)
  y.smooth  = loess(y ~ x, ...)$fitted
  y.max     = rollapply(zoo(y.smooth), 2*w+1, max, align="center")
  y.min     = rollapply(zoo(y.smooth), 2*w+1, min, align="center")

  delta.max = y.max - y.smooth[-c(1:w, n+1-1:w)]
  delta.min = y.min - y.smooth[-c(1:w, n+1-1:w)]
  
  i.max     = which(delta.max <= 0) + w
  i.min     = which(delta.min >= 0) + w
  print(paste("i.min =", i.min))
  
  list(x=x[i.max], i=i.max, y.hat=y.smooth, y.min=i.min)
}

dat.dir = "~/work/ecol596/project/data"
setwd(dat.dir)
dat = read.delim(file.path(dat.dir, "Ac2.fa"), sep=" ", header=F)
colnames(dat) = c("freq", "count")
x     = dat$freq
y     = dat$count
w=1
span=.6

peaks = argmax(x=x, y=y, w=w, span=span)
y.smooth = loess(y ~ x)$fitted


main = function() {
  dat.dir = "~/work/ecol596/project/data"
  setwd(dat.dir)
  w    = 1
  span = .4
  i    = 0
  
  for (fname in list.files(dat.dir, pattern="*.fa$")) {
    
    dat = read.delim(file.path(dat.dir, fname), sep=" ", header=F)
    colnames(dat) = c("freq", "count")
    
    x     = dat$freq
    y     = dat$count
    peaks = argmax(x=x, y=y, w=w, span=span)
    
    first.trough.y  = peaks$y.min[1]
    first.trough.x  = x[first.trough.y][1]
    first.peak.x    = x[peaks$i][1]
    first.peak.y    = peaks$y.hat[peaks$i][1]
    dist.to.mid     = first.peak.x - first.trough.x
    second.trough.x = first.trough.x + dist.to.mid * 2
    
    #png(filename = paste0(fname, '.png'))
    plot(x, y, cex=0.75, col="Gray", main=fname, xlab="count", ylab="frequency")
    lines(x, peaks$y.hat,  lwd=2) 
    y.min = min(y)

    mins = data.frame(x = x[peaks$y.min], y = peaks$y.hat[peaks$y.min])
    
    #dev.off()

    points(x = first.peak.x, y = first.peak.y, col="Red", pch=19, cex=1.25)    
    segments(first.trough.x, y.min, first.trough.x, first.peak.y, col="Purple") 
    segments(second.trough.x, y.min, second.trough.x, first.peak.y, col="Purple")

    i = i + 1
    
    printf("%5d: %s (%s - %s)\n", i, fname, first.trough.x, first.trough.x + dist.to.mid * 2)
  }
  printf("Finished, processed %s file%s.\n", i, ifelse(i==1, '', 's'))
}

main()
