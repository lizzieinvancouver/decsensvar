## Started 28 September 2025 ##
## By Lizzie ## 

## Trying to look for OSPREE studies that examine effects of constant vs variable temperatures ##
## Cribbing from decsenseOspree.R and ...

# housekeeping
rm(list=ls())
options(stringsAsFactors=FALSE)

# Load libraries
library(ggplot2)

# Setting working directory
setwd("~/Documents/git/projects/treegarden/budreview/ospree/analyses")

# get the data (take from ospree repo)
osp <- read.csv("output/ospree_clean_withchill_BB.csv", header = TRUE)

unique(osp$other.treatment)
checkme  <- subset(osp, other.treatment=="diurnally fluctuating temperature with mean of 15")

## Side note, should review the Ramos papers!
checkme  <- subset(osp, other.treatment=="low crop year, Leafy")
# and see also the 1999 paper I think 