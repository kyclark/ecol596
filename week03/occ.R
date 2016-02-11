paper <- c(60, 70, 80, 60, 80, 80, 60, 80, 80, 80, 60)
computer <- c(50, 70, 60, 70, 60, 70, 70, 60, 60, 80, 90)
hist(paper, probability = T)
lines(density(paper))



t.test(paper, computer)
library(ggplot2)

df <- data.frame(paper, computer)
ggplot(df, aes(paper, computer)) + geom_histogram()
sort(paper)
plot(df)
hist(df)
