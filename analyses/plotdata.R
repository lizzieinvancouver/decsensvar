## Started 23 September 2025 ##
## By Lizzie ##
## Cribbing off increaseVarJA.R ##

setwd("~/Documents/git/projects/treegarden/decsensvar/analyses")

library("tidyverse")

## PEP725 (Germany)
climate <- read_csv("input/germany/dailytemps_jantoapr.csv") 
climate_feb <-
	climate %>%
	mutate(month = format(Date, "%m")) %>% 
	filter(month == "02") %>%
	group_by(lat, long, year) %>% 
	summarize(Tavg = mean(Tavg))

fagsyl <- read_csv("input/germany/fagsyl_decsens_1950-2010.csv")

# Better version ...
get_climate <- function(i, dfphen) {
	yi <- dfphen[["year"]][i]
	idx <- climate_feb$year == yi
	if (!any(idx)) return(NA_real_)
	d2 <- (climate_feb$lat[idx] - dfphen[["lat"]][i])^2 +
		(climate_feb$long[idx] - dfphen[["long"]][i])^2 
	j <- which.min(d2)
	climate_feb$Tavg[idx][j]
}

fagsyl$Tavg <- vapply(seq_len(nrow(fagsyl)), get_climate, numeric(1), dfphen=fagsyl) 
fagsyl$quantile <- cut(fagsyl$Tavg, quantile(fagsyl$Tavg, probs = c(0, .25, .75, 1)),
	include.lowest = TRUE, right = TRUE)

c4 <- function(n) sqrt(2/(n-1)) * exp(lgamma(n/2) - lgamma((n-1)/2))

fagsyl %>% group_by(quantile) %>% 
	summarize(
	n = n(),
	mean = mean(lo),
	sd = sd(lo),
	se_sd = sd * sqrt(1 - c4(n)^2))

# Repeat for betpen
betpen <- read_csv("input/germany/betpen_decsens_1950-2010.csv")
betpen$Tavg <- vapply(seq_len(nrow(betpen)), get_climate, numeric(1), dfphen=betpen) 
betpen$quantile <- cut(betpen$Tavg, quantile(betpen$Tavg, probs = c(0, .25, .75, 1)),
	include.lowest = TRUE, right = TRUE)

c4 <- function(n) sqrt(2/(n-1)) * exp(lgamma(n/2) - lgamma((n-1)/2))

betpen %>% group_by(quantile) %>% 
	summarize(
	n = n(),
	mean = mean(lo),
	sd = sd(lo),
	se_sd = sd * sqrt(1 - c4(n)^2))

# UK

uk <- read_csv("input/ukoak/Marsham-Combes_UK.csv")

uk_temp <- read_csv("input/ukoak/meantemp_monthly_totals.csv")
uk %>%
	dplyr::select(year, oak) %>%
	na.omit() %>%
	left_join(uk_temp %>% dplyr::select(year, Feb)) %>% 
	mutate(quantile = cut(.$Feb, quantile(.$Feb, probs = c(0, .25, .75, 1)),
		include.lowest = TRUE, right = TRUE)) %>% 
	group_by(quantile) %>%
	summarize(
		n = n(),
	mean = mean(oak),
	sd = sd(oak),
	se_sd = sd * sqrt(1 - c4(n)^2))

# WASHINGTON DC
dc_temp <- read_csv("input/cherry/3664654.csv") 

dc_temp <-
	dc_temp %>%
	mutate(temp = TMAX / 2 + TMIN / 2,
		temp = ifelse(temp < 32, 0, temp),
		month = format(DATE, "%B"),
		doy = as.numeric(format(DATE, "%j")),
		year = as.numeric(format(DATE, "%Y")))%>%
	group_by(year) %>% 
	replace_na(list(temp = 0))

tibble(year = 1959:2024) %>% 
	left_join(aggregate(temp ~ year,
		data = dc_temp[dc_temp$month == "February",], mean)) %>% 
	mutate(winter_temp = cut(temp, 3,
		include.lowest = TRUE), 
		bdoy = sapply( 1959:2024,
		function(year)
		which.max(cumsum(dc_temp$temp[dc_temp$year == year]) > 3200))) %>%
group_by(`February tempreature` = winter_temp) %>% 
summarize(`number of years` = n(),
	`mean bloom date` = mean(bdoy), 
	`standard deviation` = sd(bdoy), 
	`standard error of standard deviation` =
	`standard deviation` * sqrt(1 - c4(`number of years`)^2)) %>% 
arrange(desc(`mean bloom date`))