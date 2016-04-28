#=========================================================================================
# R Class Exercise 3: manaual t-test and bootstrap power analysis custom functions.
#=========================================================================================

#-----------------------------------------------------------------------------------------
# Intro code
#-----------------------------------------------------------------------------------------

# << DIRECTORIES >>
dat.dir <- "~/work/ecol596/data/"

# << DATASETS >>
sla <- read.csv (paste0 (dat.dir, "sla.csv"))


#-----------------------------------------------------------------------------------------
# Function: sig_t
#-----------------------------------------------------------------------------------------

# << INFORMATION >> ----------------------------------------------------------------------
# This function is a manual t-test, returning a two-tailed significance value. This is
# faster for numerous iterations than the built-in t-test, since the only characteristic
# we are calculating and returning is the significance.

# << ARGUMENTS >> ------------------------------------------------------------------------
# < argument.name > (default.value) Description.

# < data > () A data frame containing the data to be tested.
# < data.col > () Character: the name of the column in 'data' containing the data for the
# comparison of means. Column should be numeric or integer, and data for all grouping
# variables should be contained in this one column.
# < group.col > () Character: the name of the column in 'data' containing the grouping
# variables.
# < group.1 > () The first grouping variable in 'group.column'. 'group.1' must be the same
# class as the 'group.column'. Or if 'group.column' is a factor, 'group.1' can be a
# character.
# < group.2 > () The second grouping variable in 'group.column' to compare against
# 'group.1'.

# << TEMPORARY ARGUMENTS >> --------------------------------------------------------------
# data = sla; data.col = 'l'; group.col = 'soil'; group.1 = 's'; group.2 = 'C'

# << FUNCTION >> -------------------------------------------------------------------------
sig_t <- function (data, data.col, group.col, group.1, group.2) {

  #--Eliminate rows with NAs in the 'data.col'.
  data <- data [! is.na (data [[data.col]]), ]

  #--Make row-indexing objects containing the ROW NUMBERS for the two groups.
  grp1.rows <- which (data [[group.col]] == group.1)
  grp2.rows <- which (data [[group.col]] == group.2)

  #--Calculate the sample size in each group.
  n1 <- length (grp1.rows)
  n2 <- length (grp2.rows)

  #--Get the mean value for each group.
  mean1 <- mean (data [grp1.rows, data.col])
  mean2 <- mean (data [grp2.rows, data.col])

  #--Calculate the degrees of freedom (total sample size minus one for each mean
  # estimated).
  df <- n1 + n2 - 2

  #--Calculate the pooled variance of the data.
  # First, get the sum of squares for each group (sum of the squared deviations from the
  # group mean).
  ss1 = sum ((data [grp1.rows, data.col] - mean1)^2 )
  ss2 = sum ((data [grp2.rows, data.col] - mean2)^2 )
  # Now, get the pooled variance = sum of sums of squares divided by degrees of freedom.
  pooled.var <- (ss1 + ss2) / df

  #--Calculate the t statistic. The order of the means, i.e. which mean is subtracted from
  # which in the numerator, doesn't matter since this is a two-tailed test.
  t <- (mean1 - mean2) / sqrt (pooled.var * (1/n1 + 1/n2))

  #--Calculate the p value from the cumulative distribution function for the
  # t-distribution. I.e., where does your t value sit in the t-distribution for the number
  # of degrees of freedom you have? This is done with function pt(q, df). Put our t value
  # in the first argument, and degrees of freedom in the second.
  p <- pt (t, df)
  # Convert the p value to a two-tailed p.
  if (p >= 0.5) { p = (1-p) * 2 } else { p = p*2 }

  #--Return the p value with return().
  return (p)
}

#-----------------------------------------------------------------------------------------
# Function: boot_power
#-----------------------------------------------------------------------------------------

# << INFORMATION >> ----------------------------------------------------------------------
# This function will take a dataset appropriate for comparison-of-means tests, and perform
# a boostrap power analysis to estimate the statistical power obtainable from any given 
# sample size.


# Bootstrap loop:
# - Define the number of bootstrap runs.
# - Define the data to use, the columns to test.
# - Define the sample size of each randomized group. (n1, n2)
# - Calculate the degrees of freedom
# - Calculate the means and pooled variance from the observed data.
# - Open the loop of n.boot iterations.
# - Generate random data for grp1 and grp2 from a normal distribution with
# the mean of each respective observed group and the pooled st.dev.
# - rnorm (n, mean, sd)
# - Put the data in a data frame.
# - Use sig_t to get the p value.
# - Deposit the p value in a vector of length n.boot.
# - Once the vector is complete, make another vector of the same length that indicates
# whether each p-value is significant.
# - Return: Power = the proportion of significant p-values.

# << ARGUMENTS >> ------------------------------------------------------------------------
# < argument.name > (default.value) Description.

# < data > () The dataframe containing the data of interest
#	< data.col > () The name of the column containing the data to analyze. (E.g., ‘l’, ‘lv’,
#	‘whole’.)
#	< group.col > () The name of the column containing the grouping variables (for our
#	dataset, “soil”).
#	< group1 > () The grouping variable in group.col for group1 (e.g., “S”).
#	< group2 > () The grouping variable in group.col for group2 (e.g., “C”).
#	< n.boot > (1000) The number of bootstrap iterations to run.
#	< n1 > ("obs") The sample size for the randomized sample for group1 (could be the actual
#	sample size, or an inflated sample size to test the hypothetical power with more
#	samples). The default "obs" sets n to the observed sample size from group1.
#	< n2 > ("obs") The sample size for the randomized sample for group2.
#	< alpha > (0.05) The significance threshold. Give it a default value of 0.05.

# << TEMPORARY ARGUMENTS >>
# data=sla; data.col = "l"; group.col = "soil"; group1 = "S"; group2 = "C"; n.boot=100;
# n1="obs"; n2="obs"; alpha=0.05

# << FUNCTION >> -------------------------------------------------------------------------

boot_power <- function (data, data.col, group.col, group1, group2, n.boot=1000, n1="obs",
                        n2="obs", alpha=0.05) {

  #--Make a subsetted data frame that contains only the grouping variables of interest,
  # and no NAs in the group column or the data column of interest.
  data <- data [data [[group.col]] %in% c(group1, group2), ]
  data <- data [complete.cases (data [ ,c(group.col, data.col)]), ]

  #--Make row indexing objects for each group to make things easier.
  grp1.rows <- which (data [[group.col]] == group1)
  grp2.rows <- which (data [[group.col]] == group2)

  #--Calculate the observed mean value for each group, store them as objects ‘m1’ and
  #	‘m2’.
  m1 <- mean (data [grp1.rows, data.col])
  m2 <- mean (data [grp2.rows, data.col])

  #--Determine n1 and n2 based on arguments.
  if (n1=="obs") { n1 = length (grp1.rows) }
  if (n2=="obs") { n2 = length (grp2.rows) }

  #--Calculate the degrees of freedom (= n1 + n2 – 2).
  df = n1 + n2 - 2

  #--Calculate the pooled variance (see equation in HW09) and store as object
  #	‘pooled.var’.
  # - Starting with the sum of squares for each group.
  ss1 = sum ((data [grp1.rows, data.col] - m1) ^2 )
  ss2 = sum ((data [grp2.rows, data.col] - m2) ^2 )
  # - Now calculating the pooled variance.
  pooled.var <- (ss1 + ss2) / df

  # Use a loop with ‘n.boot’ iterations to grow or fill a vector of p-values obtained
  #	from t-tests on randomly generated data. (See Part 3 of the For Loop tutorial for
  #	growing vectors.)

  #--Empty vector for p-values.
  p <- c()

  #--Start the loop, getting a p-value for each iteration of n.boot.
  for (i in 1:n.boot) {

    #--Use function rnorm() to generate a random sample of size = n1 from a normal
    # distribution with mean = m1 and sd = sqrt(pooled.var). Save as ‘rand1’.
    rand1 <- rnorm (n1, m1, sqrt(pooled.var))

    #--Do the same for a randomized version of group2 data and save as ‘rand2’.
    rand2 <- rnorm (n2, m2, sqrt(pooled.var))

    #--Make a data frame with a group column and a data column. The data column contains
    #	‘rand1’ on top of ‘rand2’ and the group column specifies their group association
    #	(mimicking the structure of the original dataset).
    boot.df <- data.frame (
      group = c(rep ("rand1", n1), rep ("rand2", n2)),
      data=c(rand1,rand2))

    #--Use the sig_t() function to return the p-value from a t-test on the two artificial
    #	groups.
    p.i <- sig_t (boot.df, "data", "group", "rand1", "rand2")

    #--Deposit that p-value into the growing vector of p-values.
    p <- c(p, p.i)
  }

  #--Determine what proportion of p-values in your vector are less than ‘alpha’. That
  #	proportion is your statistical power. Save that number as object ‘power’.
  power <- length (which (p < alpha)) / length (p)

  #--Return the ‘power’ object to the global environment.
  return (power)
}

for (alpha in c(0.01, 0.05, 0.1, 0.2)) {
  power = boot_power(data=sla, data.col="l", group.col="soil", group1="S", 
                     group2="C", n.boot=1000, n1=10, n2=10, alpha=alpha)
  
  printf("alpha = %.02f, power = %.02f\n", alpha, power)  
}


