## Started 24 Nov 2025 ##
## By Lizzie ##

## Working on poster for BES ... ##

# housekeeping
rm(list=ls())
options(stringsAsFactors=FALSE)

# Load libraries
library(tidyverse)

# set wd
setwd("/Users/lizzie/Documents/git/projects/treegarden/decsensvar/analyses/")

# data
load("input/lilac_analysis.Rdata")

##
## Following along a little with fromAuerbach/get_ghcnd.R 
lilac %>%
  filter(Phenophase_Group == "Full bloom") %>%
  mutate(station = map_chr(Temperature, ~ pluck(.x$station, 1, .default = NA_character_))) %>%
  group_by(station, Onset_Year) %>%
  summarize(n = n(),
            med = median(Onset_DOY),
            low = min(Onset_DOY),
            upp = max(Onset_DOY),
            range = upp - low) %>%
  filter(n == 5) %>%
  ggplot() +
  theme_bw() +
  aes(x = med, ymin = low, ymax = upp) +
  geom_linerange()
  

# INCREASING VARIANCE
lilac_fbloom <-
  lilac %>%
  filter(Phenophase_Group == "Full bloom") %>%
  mutate(
    feb_mean = map2_dbl(Temperature, Onset_Year, ~{
      df <- .x
      if (is.null(df) || nrow(df) == 0) return(NA_real_)
      feb <- dplyr::filter(df, month(Date) == 2, year(Date) == .y)
      if (nrow(feb) == 0) return(NA_real_)
      mean(pmax((feb$TMIN + feb$TMAX)/2, 0), na.rm = TRUE)}),
      dec_mean = map2_dbl(Temperature, Onset_Year, ~{
        df <- .x
        if (is.null(df) || nrow(df) == 0) return(NA_real_)
        dec <- dplyr::filter(df, month(Date) == 12, year(Date) == .y - 1)
        if (nrow(dec) == 0) return(NA_real_)
        mean(pmax((dec$TMIN + dec$TMAX)/2, -10), na.rm = TRUE) #0 thresholded average temperature
    })) %>%
  filter(feb_mean > .1)

lilac_fbloom <- lilac_fbloom[!is.na(lilac_fbloom$feb_mean),]
lilac_fbloom <- lilac_fbloom[!is.na(lilac_fbloom$dec_mean),]

## Back to me coding ...
sitez <- as.data.frame(table(lilac_fbloom$Site_ID))
sitez40 <- subset(sitez, Freq>39)

lilac_wellsampled <- lilac_fbloom[which(lilac_fbloom$Site_ID %in% sitez40$Var1),]

## Make a map following genecology.R 
# libraries
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

sites <- data.frame(
  site = lilac_wellsampled$Site_ID,
  lat = lilac_wellsampled$Latitude,    
  lon = lilac_wellsampled$Longitude 
)

# Convert to sf object
sites_sf <- st_as_sf(sites, coords = c("lon", "lat"), crs = 4326)

# Get country and state/province borders
countries <- ne_countries(scale = "medium", returnclass = "sf")
na_countries <- countries[countries$name %in% c("Canada", "United States of America"), ]
states_provinces <- ne_states(country = c("United States of America", "Canada"), 
	returnclass = "sf")

# Plot the map
imadeamap <- ggplot() +
  # Map background
  geom_sf(data = na_countries, fill = "white", color = "black") +
  geom_sf(data = states_provinces, fill = NA, color = "gray60", size = 0.3) +
  geom_sf(data = sites_sf, color = "orange", alpha = 0.8, size = 3) +
  # Site labels
  geom_text(data = sites, aes(x = lon, y = lat, label = site),
            size = 3, hjust = -0.1, vjust = -0.5) +
  # Scale and theme
  scale_color_viridis_c(name = "MAT") +  # or use scale_color_gradient()
  coord_sf(xlim = c(-145, -50), ylim = c(30, 50), expand = FALSE) +
  theme_minimal() +
  labs(title = "Lilac sites with 40 years",
       x = "", y = "")

pdf("figures/mapof40yrssites.pdf", width=7.5, height=8)
imadeamap
dev.off()


## Pick northeastern sites 
nesites <- c(14732, 65, 1991, 1932, 1964)
lilac_ne <- lilac_wellsampled[which(lilac_wellsampled$Site_ID %in% nesites),]

ggplot(lilac_ne, aes(x=Onset_Year, y=Onset_DOY, color=as.factor(Site_ID))) +
	geom_point()

## Okay, time to give up on showing one or a couple sites ...
## What about maps of two years? 
yearz <- as.data.frame(table(lilac_fbloom$Onset_Year))
yearz400 <- subset(yearz, Freq>399) 
# If you ask fro 500, you end up with data that ends in 1983, 400 gives you ... 1984 also! So I give up ...
lil400yrz <- lilac_fbloom[which(lilac_fbloom$Onset_Year %in% yearz400$Var1),]

## Okay, let's give up and just get the bins by decade (maybe) and by mean temperature 
## Err... not finished, going back to get JA's GAM figure from get_ghcnd.R

# Estimate Variance with a GAM

library("mgcv")

# Predict μ and σ, then compute Var = σ^2
new <- data.frame(feb_mean = seq(1, 15, length.out = 100))

fit_mu  <- gam(Onset_DOY ~ s(feb_mean), family = inverse.gaussian(link = "inverse"),
               data = lilac_fbloom, method = "REML")
# fit_mu  <- glm(Onset_DOY ~ feb_mean, data = lilac_fbloom,
#                family = gaussian(link = "inverse"))
r2      <- residuals(fit_mu, type = "response")^2
fit_var <- gam(r2 ~ s(feb_mean), family = quasi(link = "log"),
               data = lilac_fbloom, method = "REML")

# Predict MEAN on the LINK scale to get se.fit, then transform
pr <- predict(fit_mu, newdata = new, type = "link", se.fit = TRUE,
              unconditional = TRUE)
k  <- qnorm(0.975)

new <- new %>%
  mutate(
    eta    = pr$fit,
    se_eta = pr$se.fit,
    mu     = 1/eta,
    mu_lo  = 1/(eta - k*se_eta),
    mu_hi  = 1/(eta + k*se_eta)
  )

ggplot(new, aes(feb_mean, mu)) +
  geom_point(data = df %>% sample_n(min(2000, nrow(df))), 
             aes(x = feb_mean, y = Onset_DOY),
             alpha = 0.15, size = 0.6, inherit.aes = FALSE) +  theme_bw() +
  geom_ribbon(aes(ymin = mu_lo, ymax = mu_hi), alpha = 0.2) +
  geom_line()

# Predict SD on the LINK scale to get se.fit, then transform
pr <- predict(fit_var, newdata = new, type = "link", se.fit = TRUE)
k  <- qnorm(0.975)

new <- new %>%
  mutate(
    eta    = pr$fit,
    se_eta = pr$se.fit,
    var    = exp(eta),
    var_lo = exp(eta - k*se_eta),
    var_hi = exp(eta + k*se_eta),
    sd     = sqrt(var),
    sd_lo  = sqrt(var_lo),
    sd_hi  = sqrt(var_hi)
  )

gammy <- ggplot(new, aes(feb_mean, sd)) +
  theme_bw( base_size = 16) +
  theme(panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()) +
  geom_ribbon(aes(ymin = sd_lo, ymax = sd_hi), alpha = 0.2) +
  geom_line() + 
  xlab("February temperatures") +
  ylab("SD of lilac bloom dates (GAM)") 

pdf("figures/lilacGAM.pdf", width=6, height=6)
gammy
dev.off()

