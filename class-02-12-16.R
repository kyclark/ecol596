glop = read.csv("~/work/ecol596w/data/glopnet.csv")
colnames(glop) = tolower(colnames(glop))

sub.glop = glop[, c("genus", "epithet")]

sub.glop$genus = sapply(sub.glop$species, function (s) {
  strsplit(s, split="_") [[1]][1]
})