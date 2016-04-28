#=========================================================================================
# R Class HW11: Indexing with grep(); a simple custom function
#=========================================================================================

# (1) Call in the 'simulated big data' dataset (same one we used in Class Ex 5).
dat = read.csv("~/work/ecol596/data/simulated_big_data_131121.csv")

# (2) Using grep() and grepl() for partial matching. Generate indexing objects so we can
# have easy access to custom groups. (See ?grep)
# - (a): Use grepl() to make a LOGICAL vector for accessing the tropical (i.e not
# subtropical) life zone data. Store to object 'tropical'.
tropical = grepl("tropical", dat$life.zone)


# - (b) Make another one, 'lowland', by life zones that don't contain "montane".
lowland = !grepl("montane", dat$life.zone)

# - (c) How many Lowland Tropical entries are there in the dataset?
length(dat[tropical & lowland,])

# there are 7

# - (d) With ggplot2, make a boxplot of wood density (wd) values by life zone for lowland
# tropical sites. Use geom_boxplot().

library(ggplot2)
ggplot(dat[tropical & lowland,], aes(y=wd, x=life.zone)) + geom_boxplot()

# (2) grep() and grepl() can only find matches for a single 'pattern' in a vector. (See 
# help on ?grep for arguments 'x' and 'pattern'.)
# - (a) Write a custom function that acts like a %in% version of grep(), i.e. will return
# match positions in 'x' for a vector of multiple 'patterns'. Use grep() inside this
# function, and allow additional arguments to be passed to grep() from the outer function.
# (See the last section of the custom functions tutorial.)
multigrep = function (df, col, patterns, ...) {
  ind = c()
  for (pattern in patterns) {
    ind = c(ind, grep(pattern, df[[col]], ...))
  }
  return(df[ind,])
}

# - (b) Use your new function to index in the 'sp' column of 'big' and ask how much non-NA
# wood density (wd) data there is for the following genera: solanum, protium, eschweilera.
# Do not use a genus column; use your partial-matching function to get the indices where
# the genera occur in the 'sp' column.
d = multigrep(dat, "sp", c("solanum", "protium", "eschweilera"))
