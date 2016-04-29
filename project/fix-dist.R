fix_dist = function (file) {
  lines = readLines(file)
  n = length(lines)
  delim = "\t"
  fixed = file.path(dirname(file), paste0(file, '.fixed'))
  sink(fixed)
  for (i in 1:n) {
    flds = strsplit(lines[i], delim)[[1]]
    
    # the header line has a comment char "#" we need to strip
    # also, the fields are full paths we need to reduce to basenames
    if (i == 1) {
      header = flds[2:n]
      basenames = unlist(lapply(header, basename))
      cat(paste(c("", basenames), collapse=delim), sep="\n")
    }
    # the first column has full path, so convert to basename
    else {
      cat(paste(c(basename(flds[1]), flds[2:n]), collapse=delim), sep="\n")
    }
  }
  sink()
  return(read.table(fixed))
}

setwd("~/work/ecol596/project")
file = "dist.tab"
dist = fix_dist(file)
dist = fix_dist("pov.dist.tab")
dist = fix_dist("foo.tab")
png('dendrogram.png', width=max(300, ncol(dist) * 20))
hc = hclust(as.dist(as.matrix(dist)))
plot(hc, xlab="Samples", main="MASH distances")
dev.off()

# heatmap
heatmap(as.matrix(dist))

# vegan tree
library(vegan)
tree = spantree(as.dist(as.matrix(dist)))
plot(tree, type="t")

# igraph tree
library(igraph)
g = graph.adjacency(as.matrix(dist), weighted=TRUE)
g_mst <- mst(g)
plot(g_mst, vertex.color=NA, vertex.size=10, edge.arrow.size=0.5)
plot_dendrogram(g_mst)

# D3 viz
library('networkD3')
radialNetwork(as.radialNetwork(hc))
chordNetwork(as.matrix(g_mst))
dendroNetwork(hc)

library(reshape2)
nodes = colnames(dist)
links = melt(data.matrix(dist))
colnames(links) = c("source", "target", "value")
links$source = as.character(links$source)
links$target = as.character(links$target)
links = links[links$value > 0.7,]

for (i in 1:length(nodes)) {
  node = nodes[i]
  for (f in c("source", "target")) {
    links[ links[[f]] == node, f] = i - 1
  }
}
links$source = as.integer(links$source)
links$target = as.integer(links$target)

mynodes = data.frame(name=nodes)
sankeyNetwork(Links = links, Nodes = mynodes, Source = 'source', Target = 'target', 
  Value = 'value', NodeID = 'name', fontSize = 12, 3nodeWidth = 30)

# create inverse (nearness) matrix for GBME
write.table(1 - dist, 'matrix.tab', quote=F, sep="\t")