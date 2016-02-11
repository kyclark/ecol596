speed <- c(100, 102, 103, 101, 105, 100, 99, 105)
distance <- c(257, 264, 274, 266, 277, 263, 258, 275)

plot(speed, distance)
abline(lm(speed ~ distance))
?abline

lm(speed ~ distance)

shutter <- c(1/1000, 1/500, 1/250, 1/125, 1/60, 1/30, 1/15, 1/8)
fstop <- c(2.8, 4, 5.6, 8, 11, 16, 22, 32)

plot(shutter, fstop)
