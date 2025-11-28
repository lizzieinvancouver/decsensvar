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

fstib <- fagsyl %>% group_by(quantile) %>% 
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
uktib <- uk %>%
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
# dc_temp["tempMaxC"] <- (dc_temp["TMAX"]-32)*(5/9)
# dc_temp["tempMinC"] <- (dc_temp["TMIN"]-32)*(5/9)

dc_temp <-
	dc_temp %>%
	mutate(temp = TMAX / 2 + TMIN / 2,
		temp = ifelse(temp < 0, 0, temp),
		month = format(DATE, "%B"),
		doy = as.numeric(format(DATE, "%j")),
		year = as.numeric(format(DATE, "%Y")))%>%
	group_by(year) %>% 
	replace_na(list(temp = 0))


dctib <- tibble(year = 1959:2024) %>% 
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

## Try to make some plots ...

pdf("figures/quantileplotDC.pdf", height=5, width=4)
par(mfrow=c(2,1))
par(oma=c(0,3,1,1))
par(mar=c(0.5,5,1,1))
layout(matrix(c(1, 2), nrow = 2, byrow = TRUE), heights = c(1, 3))
## Start with DC, super annoying since it's in F 
xhereinF <- c(mean(c(28.4,34.8)), mean(c(34.8,41.3)), mean(c(41.3,47.7)))
xhere  <- (xhereinF-32)*(5/9) # close enough 
colhere <- "maroon3"
plot(xlim=c(-2,10), ylim=c(72,90), x=c(1:3), y=c(1:3), type="n", xaxt = "n",
	xlab="", ylab="Mean event date")
axis(1, labels = FALSE)
points(x=xhere, 
	y=dctib["mean bloom date"][[1]], pch=16, col=colhere)

par(mar=c(4,5,1,1))
plot(xlim=c(-2,10), ylim=c(2,4.5), x=c(1:3), y=c(1:3), type="n",
	xlab="February temperatures", ylab="SD(mean event date)")
points(x=xhere, 
	y=dctib["standard deviation"][[1]], 
	pch=16, col=colhere)
y0 <- dctib["standard deviation"][[1]]-dctib["standard error of standard deviation"][[1]]
y1 <- dctib["standard deviation"][[1]]+dctib["standard error of standard deviation"][[1]]
arrows(x0=xhere, y0=y0, x1=xhere, y1=y1, 
  length=0, col=colhere)
dev.off()

## UK
pdf("figures/quantileplotUK.pdf", height=5, width=4)
par(mfrow=c(2,1))
par(oma=c(0,3,1,1))
par(mar=c(0.5,5,1,1))
layout(matrix(c(1, 2), nrow = 2, byrow = TRUE), heights = c(1, 3))
colhere <- "dodgerblue"
xhere <- c(mean(c(-1.9,2.8)), mean(c(2.8,5.3)), mean(c(5.3,7.9)))
plot(xlim=c(-2,9), ylim=c(100,130), x=c(1:3), y=c(1:3), type="n", xaxt = "n",
	xlab="February temperatures", ylab="Mean event date")
axis(1, labels = FALSE)
points(x=xhere, 
	y=uktib["mean"][[1]],
	pch=16, col=colhere)

par(mar=c(4,5,1,1))
plot(xlim=c(-2,9), ylim=c(7,11.5), x=c(1:3), y=c(1:3), type="n", 
	xlab="February temperatures", ylab="SD(mean event date)")
points(x=xhere, 
	y=uktib["sd"][[1]],
	pch=16, col=colhere)
y0 <- uktib["sd"][[1]]-uktib["se_sd"][[1]]
y1 <- uktib["sd"][[1]]+uktib["se_sd"][[1]]
arrows(x0=xhere, y0=y0, x1=xhere, y1=y1, 
  length=0, col=colhere)
dev.off()


## FS from PEP725
pdf("figures/quantileplotfagusPEP.pdf", height=5, width=4)
par(mfrow=c(2,1))
par(oma=c(0,3,1,1))
par(mar=c(0.5,5,1,1))
layout(matrix(c(1, 2), nrow = 2, byrow = TRUE), heights = c(1, 3))
colhere <- "orange"
xhere <- c(mean(c(-12.3,-1.31)), mean(c(-1.31,2.91)), mean(c(2.91,7.31)))
plot(xlim=c(-10,9), ylim=c(110,130), x=c(1:3), y=c(1:3), type="n", xaxt = "n",
	xlab="February temperatures", ylab="Mean event date")
axis(1, labels = FALSE)
points(x=xhere, 
	y=fstib["mean"][[1]],
	pch=16, col=colhere)

par(mar=c(4,5,1,1))
plot(xlim=c(-10,9), ylim=c(7,9.5), x=c(1:3), y=c(1:3), type="n",
	xlab="February temperatures", ylab="SD(mean event date)")
points(x=xhere, 
	y=fstib["sd"][[1]],
	pch=16, col=colhere)
y0 <- fstib["sd"][[1]]-fstib["se_sd"][[1]]
y1 <- fstib["sd"][[1]]+fstib["se_sd"][[1]]
arrows(x0=xhere, y0=y0, x1=xhere, y1=y1, 
  length=0, col=colhere)
dev.off()

