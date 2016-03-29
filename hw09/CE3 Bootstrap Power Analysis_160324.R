#=========================================================================================
# R class exercise 3: bootstrap power analysis with custom functions
#=========================================================================================

# << OBJECTIVES >>
# In Part 1, we'll build a manual t-test function. This will return the p-value from a
# t-test comparison of means (testing whether two collections of numerical data differ
# from each other). R has a built-in t-test function, but since we only want the p-value,
# our manual version will be faster for iteration in Part 2.

# In Part 2, we'll build a function for a bootstrap power analysis. A power analysis
# generates artificial datasets with distributions similar to your observed data, and 
# tests for statistical significance. By iterating this process, you can see what
# proportion of the time significance is found. By repeating this with increasing
# artificial sample sizes, you can estimate how many more samples you should collect in
# order to have enough statistical power to detect significance.

# << DATASET >>
# We'll use the 'sla' dataset provided with the tutorials. This is a dataset of specific-
# leaf-area (SLA = fresh leaf area / dry leaf mass) measurements from trees in
# two different soil types. SLA was calculated from different leaf components. The
# objective was to see whether the ability to distinguish tree strategies between
# environments depended on the leaf structural components included in SLA measurements.

# We predicted that laminar SLA (no midvein or petiole) would have lower variance and
# result in better statistical power to differentiate environments. However, t-tests
# comparing SLA between clay and sandy soils were not significant for any SLA type. If
# there really is a difference in the world, how many more samples would we need to detect
# it? Does the number of samples needed to find significance differ between SLA types?
# We'll use the boostrap power analysis to find out.

# Columns of interest:
# - 'l' = laminar SLA
# - 'lv' = lamina plus midvein SLA
# - 'whole' = whole leaf SLA
# - 'soil' = soil type, C is clay, S is sand.

#-----------------------------------------------------------------------------------------
# Intro code
#-----------------------------------------------------------------------------------------

# << DIRECTORIES >>
#--Make a 'dat.dir' object containing the directory path to your tutorial datasets as a
# character string ending with a forward slash "/".
dat.dir = "~/work/ecol596/data"

# << DATASETS >>
#--Call in the sla data into a data frame called 'sla'.
sla = read.csv(file.path(dat.dir, "sla.csv"))

#=========================================================================================
# Instructions: Part 1
#=========================================================================================

# In the first part, we'll make a custom function that calculates the significance (p)
# value from a t-test. This will be used later inside a separate custom function that will
# iterate the calculation of p-values on randomized null datasets for a bootstrap power
# analysis.

# 1) Make your directory object and call in the "sla.csv" dataset.

# 2) The 'sig_t' custom function is started and outlined for you below. Read the
# INFORMATION and ARGUMENTS sections. Skim through the commented outline of the function.
# "#*" indicates lines of code for you to fill in or complete.

# 3) Make a complete set of temporary arguments in the TEMPORARY ARGUMENTS section so you
# can test the function's code as you work through it. We want to group the analysis by
# soil type, and analyze the more complete columns like 'l', 'lv', 'whole', or 'whole2'.

# 4) Fill in the arguments in the function's definition, and complete the lines of code
# marked by #* in the function.

# 5) Create the function (execute its whole definition) and use it to get p-values for the
# comparison of means between clay and sand soils for leaf columns 'l', 'lv', and 'whole'.

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

#* Fill in temporary arguments here so you can execute code inside of the function as you
# work.

data = sla
data.col = "l"
group.col = "soil"
group.1 = "C"
group.2 = "S"

sig_t(sla, "l", "soil", "C", "S")

# << FUNCTION >> -------------------------------------------------------------------------
sig_t <- function (data, data.col, group.col, group.1, group.2) {

  #--Eliminate rows with NAs in the 'data.col'.
  data = data[!is.na(data[[data.col]]),]

  #--Make row-indexing objects containing the ROW NUMBERS for the two groups.
  grp1.rows = which(data[[group.col]] == group.1)
  grp2.rows = which(data[[group.col]] == group.2)

  #--Calculate the sample size in each group.
  n1 = length(grp1.rows)
  n2 = length(grp2.rows)

  #--Get the mean value for each group.
  mean1 = mean(data[grp1.rows, data.col])
  mean2 = mean(data[grp2.rows, data.col])

  #--Calculate the degrees of freedom (total sample size minus one for each mean
  # estimated).
  df = n1 + n2 - 2

  #--Calculate the pooled variance of the data.
  # First, get the sum of squares for each group (sum of the squared deviations from the
  # group mean).
  ss1 = sum((data[grp1.rows, data.col] - mean1) ^ 2)
  ss2 = sum((data[grp2.rows, data.col] - mean2) ^ 2)
  
  # Now, get the pooled variance = sum of sums of squares divided by degrees of freedom.
  pooled.var = (ss1 + ss2) / df

  #--Calculate the t statistic. The order of the means, i.e. which mean is subtracted from
  # which in the numerator, doesn't matter since this is a two-tailed test.
  t = (mean1 - mean2) / sqrt(pooled.var * (1/n1 + 1/n2))

  #--Calculate the p value from the cumulative distribution function for the
  # t-distribution. I.e., where does your t value sit in the t-distribution for the number
  # of degrees of freedom you have? This is done with function pt(q, df). Put our t value
  # in the first argument, and degrees of freedom in the second.
  p = pt(t, df)
  
  # Convert the p value to a two-tailed p.
  if (p >= 0.5) { p = (1-p) * 2 } else { p = p*2 }

  # Return the p value with return().
  return(p)
}

#=========================================================================================
# Instructions: Part 2
#=========================================================================================

# Now, the bootstrap power analysis.

# Stay tuned for an updated version while I decide how much to have you figure out on your
# own.

#-----------------------------------------------------------------------------------------
# Function: boot_power
#-----------------------------------------------------------------------------------------








