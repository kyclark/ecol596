dat.dir = "~/work/ecol596w/project/data"
setwd(dat.dir)

for (fname in list.files(dat.dir, pattern="*.fa$")) {
  print(fname)
  dat = read.delim(file.path(dat.dir, fname), sep=" ", header=F)
  colnames(dat) = c("freq", "count")
  dat.long = numeric()
  for (i in 1:nrow(dat)) {
    freq = dat$freq[i]
    count = dat$count[i]
    dat.long = append(dat.long, rep(freq, count))
  }
  
  png(filename = paste0(fname, '.png'))
  h = hist(dat.long, plot=F)
  plot(h$counts, type="l", main=fname)
  dev.off()
}

file = "Ra2.fa"
dat = read.delim(file, sep=" ", header=F)
colnames(dat) = c("freq", "count")
plot(dat, type="l", main=file)

dat.long = numeric()
for (i in 1:nrow(dat)) {
  freq = dat$freq[i]
  count = dat$count[i]
  dat.long = append(dat.long, rep(freq, count))
}

plot(table(dat.long))

#hist(dat.long, breaks=seq(dat.long[1], dat.long[length(dat.long)], 5))
h = hist(dat.long, plot=F) 
plot(h$counts, type="l", main="Ac2")
upside = h$counts[sign(diff(h$counts)) == 1]
turning.point = upside[1]
h$counts[h$count >= turning.point]
c = h$counts
s = sign(diff(c))
first = head(c[ s > 0 ], n=1)
b = c[ s > 0 & c >= first ]
sorted = rev(sort(c))
l1 = sorted[1]
l2 = sorted[2]

find_peaks <- function (x, m = 3){
  shape <- diff(sign(diff(x, na.pad = FALSE)))
  pks <- sapply(which(shape < 0), FUN = function(i){
    z <- i - m + 1
    z <- ifelse(z > 0, z, 1)
    w <- i + m + 1
    w <- ifelse(w < length(x), w, length(x))
    if(all(x[c(z : i, (i + 2) : w)] <= x[i + 1])) return(i + 1) else return(numeric(0))
  })
  pks <- unlist(pks)
  pks
}


library(ggplot2)
ggplot(data=dat, aes(kmer, count)) + geom_smooth(se=F) 

plot(density(dat[['count']]))

peakfinder(dat[["count"]])

findpeaks <- function(vec,bw=1,x.coo=c(1:length(vec)))
{
  pos.x.max <- NULL
  pos.y.max <- NULL
  pos.x.min <- NULL
  pos.y.min <- NULL 	
  for(i in 1:(length(vec)-1)) 	{ 		
    if((i+1+bw)>length(vec)){
      sup.stop <- length(vec)}
    else{
      sup.stop <- i+1+bw
    }
    if((i-bw)<1){inf.stop <- 1}else{inf.stop <- i-bw}
    subset.sup <- vec[(i+1):sup.stop]
    subset.inf <- vec[inf.stop:(i-1)]
    
    is.max   <- sum(subset.inf > vec[i]) == 0
    is.nomin <- sum(subset.sup > vec[i]) == 0
    
    no.max   <- sum(subset.inf > vec[i]) == length(subset.inf)
    no.nomin <- sum(subset.sup > vec[i]) == length(subset.sup)
    
    if(is.max & is.nomin){
      pos.x.max <- c(pos.x.max,x.coo[i])
      pos.y.max <- c(pos.y.max,vec[i])
    }
    if(no.max & no.nomin){
      pos.x.min <- c(pos.x.min,x.coo[i])
      pos.y.min <- c(pos.y.min,vec[i])
    }
  }
  return(list(pos.x.max,pos.y.max,pos.x.min,pos.y.min))
}

data <- c(rnorm(100,mean=20),rnorm(100,mean=12))
peakfinder <- function(d){
  dh <- hist(dat,plot=FALSE)
  ins <- dh[["intensities"]]
  nbins <- length(ins)
  ss <- which(rank(ins)%in%seq(from=nbins-2,to=nbins)) ## pick the top 3 intensities
  dh[["mids"]][ss]
}

argmax <- function(x, y, w=1, ...) {
  require(zoo)
  n <- length(y)
  y.smooth <- loess(y ~ x, ...)$fitted
  y.max <- rollapply(zoo(y.smooth), 2*w+1, max, align="center")
  delta <- y.max - y.smooth[-c(1:w, n+1-1:w)]
  i.max <- which(delta <= 0) + w
  list(x=x[i.max], i=i.max, y.hat=y.smooth)
}

test <- function(w, span, x, y) {
  peaks <- argmax(x, y, w=w, span=span)
  
  plot(x, y, cex=0.75, col="Gray", main=paste("w = ", w, ", span = ", span, sep=""))
  lines(x, peaks$y.hat,  lwd=2) #$
  y.min <- min(y)
  sapply(peaks$i, function(i) lines(c(x[i],x[i]), c(y.min, peaks$y.hat[i]),
                                    col="Red", lty=2))
  points(x[peaks$i], peaks$y.hat[peaks$i], col="Red", pch=19, cex=1.25)
}

x <- 1:1000 / 100 - 5
y <- exp(abs(x)/20) * sin(2 * x + (x/5)^2) + cos(10*x) / 5 + rnorm(length(x), sd=0.05)
par(mfrow=c(3,1))
test(2, 0.05)
test(30, 0.05)
test(2, 0.2)
test(2, .6, dat$freq, dat$count)
