## Started 25 August 2025 ##
## By Lizzie ##

# housekeeping
rm(list=ls()) 
options(stringsAsFactors = FALSE)

setwd('/Users/lizzie/Documents/git/projects/treegarden/decsensvar/analyses')

d <- read.csv("input/lilacdataphen.csv")
dsubset <- subset(d, select=c("Site_ID", "Latitude", "Longitude", "Onset_Year"))
dlatlon <- dsubset[!duplicated(dsubset),]

dim(dlatlon)

# Now, start on getting the data from PRISM 
# (This seems the best, summary of many options here: https://climexp.knmi.nl/selectdailyfield2.cgi?id=someone@somewhere)
# https://docs.ropensci.org/prism/

library("prism")
prism_set_dl_dir('/Users/lizzie/Documents/git/projects/treegarden/decsensvar/analyses/prismdat')

get_prism_dailys(
  type = "tmean", 
  minDate = "2013-06-01", 
  maxDate = "2013-06-14", 
  keepZip = FALSE
)