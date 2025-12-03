## Started 2 Dec 2025 ##
## But all from 29 Nov 2025 email from Auerbach, really ##

# Discussing my BES poster GAM ...
# The increased variance (as february temperatures increase) that you show in the poster is due to locations 
# with warm decembers. But you can recreate something similar with cold decembers if you look at the change 
# in the variance with average march or april temperatures. See code below and figures attached. 

# Figure 2 shows that as temperatures warm, the variance can increase, 
# which is consistent with our model. 
# While this could also be an artifact—I assume not one caused by insufficient chilling.

# The challenge here is that the variance in the bloom date is determined by the trend around
#  the time of the bloom—so it's hard to isolate without filtering based on the bloom date. 
# (I think the issue with filtering on the bloom date is that it assumes the model we're trying to validate.)

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
  

## Email from Auerbach on 29 Nov 2025 
lilac_fbloom <-
  lilac %>%
  filter(Phenophase_Group == "Full bloom") %>%
  mutate(
    apr_mean = map2_dbl(Temperature, Onset_Year, ~{
      df <- .x
      if (is.null(df) || nrow(df) == 0) return(NA_real_)
      apr <- dplyr::filter(df, month(Date) == 4, year(Date) == .y)
      if (nrow(apr) == 0) return(NA_real_)
      mean(pmax((apr$TMIN + apr$TMAX)/2, 0), na.rm = TRUE)}),
      dec_mean = map2_dbl(Temperature, Onset_Year, ~{
        df <- .x
        if (is.null(df) || nrow(df) == 0) return(NA_real_)
        dec <- dplyr::filter(df, month(Date) == 12, year(Date) == .y - 1)
        if (nrow(dec) == 0) return(NA_real_)
        mean(pmax((dec$TMIN + dec$TMAX)/2, -10), na.rm = TRUE) #0 thresholded average temperature
    })) %>%
  filter(apr_mean > .1,
         dec_mean < 5)

lilac_fbloom <- lilac_fbloom[!is.na(lilac_fbloom$apr_mean),]
lilac_fbloom <- lilac_fbloom[!is.na(lilac_fbloom$dec_mean),]

# Estimate Variance with a GAM

library("mgcv")

# Predict μ and σ, then compute Var = σ^2
new <- data.frame(apr_mean = seq(1, 15, length.out = 100))

fit_mu  <- gam(Onset_DOY ~ s(apr_mean), family = inverse.gaussian(link = "inverse"),
               data = lilac_fbloom, method = "REML")
# fit_mu  <- glm(Onset_DOY ~ apr_mean, data = lilac_fbloom,
#                family = gaussian(link = "inverse"))
r2      <- residuals(fit_mu, type = "response")^2
fit_var <- gam(r2 ~ s(apr_mean), family = quasi(link = "log"),
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

# fig_1_lilacschillingGAMs.png
ggplot(new, aes(apr_mean, mu)) +
#  geom_point(data = df %>% sample_n(min(2000, nrow(df))), 
#             aes(x = apr_mean, y = Onset_DOY),
#             alpha = 0.15, size = 0.6, inherit.aes = FALSE) +  
  theme_bw() +
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

# fig_2_lilacschillingGAMs.png
ggplot(new, aes(apr_mean, sd)) +
  theme_bw() +
  geom_ribbon(aes(ymin = sd_lo, ymax = sd_hi), alpha = 0.2) +
  geom_line()