# GET GHCND

setwd("/Users/jauerbach/Dropbox/Wolkovich/desynchronization/")

library("readxl")
library("tidyverse")

#LILAC DATA https://datadryad.org/dataset/doi:10.5061/dryad.0262m
# lilac <- 
#   read_excel("lilac/doi_10_5061_dryad_0262m__v20160714/Lilac+Honeysuckle+1956-2014+leafing+and+flowering+phenology+v13.xlsx") 
# 
# ghcnd_inventory <- read_table("ghcnd/ghcnd-inventory.txt", 
#                               col_names = c("station","lat","lon","element","firstyear","lastyear"))
#                               
# ghcnd_stations <- read_table("ghcnd/ghcnd-inventory.txt", 
#                              col_names = c("station","lat","lon","elev_m","state","name"))
# 
# 
# # helper function to read .dly files
# ghcnd_fwf_spec_full <- function() {
#   starts <- c(1,12,16,18); ends <- c(11,15,17,21)
#   names  <- c("station","year","month","element")
#   for (d in 1:31) {
#     s <- 22 + (d - 1) * 8
#     starts <- c(starts, s,   s+5,  s+6,  s+7)
#     ends   <- c(ends,   s+4, s+5,  s+6,  s+7)
#     names  <- c(names,
#                 sprintf("d%02d_value", d),
#                 sprintf("d%02d_mflag", d),
#                 sprintf("d%02d_qflag", d),
#                 sprintf("d%02d_sflag", d))
#   }
#   fwf_positions(starts, ends, col_names = names)
# }
# 
# spec_full <- ghcnd_fwf_spec_full()
# 
# 
# get_temp <- function(lilac_row,
#                      root_dir = "ghcnd/ghcnd_all",
#                      dly_subdir = "ghcnd_all",
#                      miles = 10) {
#   
#   # years needed & date window
#   years_needed <- c(lilac_row$Onset_Year - 1L, lilac_row$Onset_Year)
#   start_date   <- as.Date(sprintf("%d-07-01", lilac_row$Onset_Year - 1L))
#   end_date     <- as.Date(sprintf("%d-05-01", lilac_row$Onset_Year))
#   
#   # candidate stations: must have BOTH TMIN & TMAX and cover both years
#   phi <- lilac_row$Latitude * pi/180
#   candidates <- 
#     ghcnd_inventory %>%
#     filter(element %in% c("TMIN","TMAX"),
#            firstyear <= min(years_needed),
#            lastyear  >= max(years_needed)) %>%
#     distinct(station, element, lat, lon, firstyear, lastyear) %>%
#     add_count(station, name = "n_elem") %>%
#     filter(n_elem == 2) %>%                            # has both elements
#     distinct(station, .keep_all = TRUE) %>%
#     mutate(d_deg = sqrt( (lat - lilac_row$Latitude)^2 +
#                            ((lon - lilac_row$Longitude) * cos(phi))^2 )) %>%
#     arrange(d_deg)
#   
#   if (nrow(candidates) == 0) {
#     return(tibble::tibble(Date = as.Date(character()), TMIN = numeric(), TMAX = numeric()))
#   }
#   
#   # distance threshold in degrees
#   deg_thresh <- miles / 69
#   chosen <- candidates %>% filter(d_deg <= deg_thresh) %>% slice(1)
#   if (nrow(chosen) == 0) chosen <- candidates %>% slice(1)  # fallback to nearest
#   
#   station_id <- chosen$station[1]
#   path <- file.path(root_dir, dly_subdir, paste0(station_id, ".dly"))
#   if (!file.exists(path)) {
#     warning("Missing .dly for station: ", station_id, " at ", path)
#     return(tibble::tibble(Date = as.Date(character()), TMIN = numeric(), TMAX = numeric()))
#   }
#   
#   # read just the needed months/elements
#   temp_wide <- read_fwf(
#     file = path,
#     col_positions = spec_full,
#     col_types = cols(.default = col_character(),
#                      year = col_integer(), month = col_integer())
#   ) %>%
#     filter(year %in% years_needed, element %in% c("TMIN","TMAX"))
#   
#   if (nrow(temp_wide) == 0) {
#     return(tibble::tibble(Date = as.Date(character()), TMIN = numeric(), TMAX = numeric()))
#   }
#   
#   # reshape to daily & QA filter
#   daily <- 
#     temp_wide %>%
#     tidyr::pivot_longer(
#       cols = matches("^d\\d{2}_(value|qflag)$"),
#       names_to = c("day","field"),
#       names_pattern = "^d(\\d{2})_(value|qflag)$",
#       values_to = "val"
#     ) %>%
#     tidyr::pivot_wider(names_from = field, values_from = val) %>%
#     mutate(
#       day   = as.integer(day),
#       value = suppressWarnings(as.integer(value)),
#       qflag = dplyr::coalesce(trimws(qflag), ""),
#       date  = make_date(year, month, day),
#       okday = day <= days_in_month(make_date(year, month, 1)),
#       t_c   = dplyr::if_else(okday & qflag == "" &
#                                !is.na(value) & value != -9999,
#                              value / 10, NA_real_)
#     ) %>%
#     filter(okday) %>%
#     dplyr::select(station, date, element, t_c)
#   
#   # wide, restrict to requested window, and rename Date
#   out <- daily %>%
#     tidyr::pivot_wider(names_from = element, values_from = t_c) %>%
#     filter(date >= start_date, date <= end_date) %>%
#     arrange(date) %>%
#     rename(Date = date)
#   
#   out
# }
#   
# # lapply(1:2, function(i) get_temp(lilac[i,]))
# # 
# # lilac <- lilac %>%
# #   rowwise() %>%
# #   mutate(
# #     Temperature = list(
# #       get_temp(
# #         pick(Latitude, Longitude, Onset_Year),   # the current row as a tiny tibble
# #       )
# #     )
# #   ) %>%
# #   ungroup()
# 
# library("furrr")
# plan(multisession, workers = 10)  
# 
# lilac <- lilac %>%
#   mutate(
#     Temperature = future_pmap(
#       list(Latitude, Longitude, Onset_Year),
#       ~ get_temp(tibble(Latitude = ..1, Longitude = ..2, Onset_Year = ..3)),
#       .progress = TRUE
#     )
#   )

load("lilac_analysis.RData")

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

ggplot(new, aes(feb_mean, sd)) +
  theme_bw() +
  geom_ribbon(aes(ymin = sd_lo, ymax = sd_hi), alpha = 0.2) +
  geom_line()


# Quantiles
lilac_fbloom$quantile <- cut(lilac_fbloom$feb_mean, seq(.5, 18.5, length.out = 10),
                             #quantile(lilac_fbloom$feb_mean, 
                                              #probs = seq(0, 1, .01)),
                                              #probs = c(0, .25, .75, 1)), 
                        include.lowest = TRUE, right = TRUE)

lilac_fbloom$quantile2 <- cut(lilac_fbloom$dec_mean, quantile(lilac_fbloom$dec_mean, probs = seq(0, 1, .1)),
                      #probs = c(0, .25, .75, 1)), 
                      include.lowest = TRUE, right = TRUE)

c4 <- function(n) sqrt(2/(n-1)) * exp(lgamma(n/2) - lgamma((n-1)/2))

lilac_fbloom %>%
  group_by(quantile) %>%
  summarize(
    n = n(),
    mean = mean(Onset_DOY),
    sd = sd(Onset_DOY),
    se_sd = sd * sqrt(1 - c4(n)^2)) %>%
  tail()

lilac_fbloom %>%
  group_by(quantile) %>%
  summarize(
    n = n(),
    mean = mean(Onset_DOY),
    sd = sd(Onset_DOY),
    se_sd = sd * sqrt(1 - c4(n)^2)) %>%
  mutate(midpoint = str_remove_all(quantile, "[\\[\\(\\]\\)]")) %>%
  rowwise() %>%
  mutate(midpoint = as.numeric(str_split(midpoint, ",")[[1]][1]) / 2 + 
           as.numeric(str_split(midpoint, ",")[[1]][2]) / 2) %>%
  ungroup() %>%
  mutate(mean = 0) %>%
  ggplot() +
  theme_bw() +
  geom_linerange(
    aes(x = midpoint, y = mean, ymin = mean - 2 * sd, ymax = mean + 2 * sd)) +
  geom_errorbar(
    aes(x = midpoint, y = mean + 2 * sd, 
        ymin = mean + 2 * sd - 2 * se_sd, ymax = mean + 2 * sd + 2 * se_sd)) +
  geom_errorbar(
    aes(x = midpoint, y = mean - 2 * sd, 
        ymin = mean - 2 * sd - 2 * se_sd, ymax = mean - 2 * sd + 2 * se_sd))
  
bartlett.test(Onset_DOY ~ quantile, data = lilac_fbloom)
fligner.test(Onset_DOY ~ quantile, data = lilac_fbloom)