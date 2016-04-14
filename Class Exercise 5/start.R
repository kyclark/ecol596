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