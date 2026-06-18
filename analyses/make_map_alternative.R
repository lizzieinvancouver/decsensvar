
library(terra)
library(rnaturalearth)

setwd("/home/victor/projects/decsensvar/analyses/figures")
# setwd("~/Documents/git/projects/treegarden/decsensvar/analyses/figures")
load("..//input/make_map.RData")

# prepare rasters of predictions
predicted_df <- predicted_df[predicted_df$scenario == 'ssp585',]
# rm locations where there is no lilac data 
predicted_df <- predicted_df[predicted_df$x < max(lilac_fbloom$longitude),]
predicted_df <- predicted_df[predicted_df$y > min(lilac_fbloom$latitude),]
predicted_df$sd <- (sqrt(predicted_df$var))
pred_mean <- rast(lapply(c(2050, 2100), function(y) {rast(predicted_df[predicted_df$year == y,c('x', 'y','mean')])}))
names(pred_mean) <- c(2050, 2100)
pred_sd <- rast(lapply(c(2050, 2100), function(y) {rast(predicted_df[predicted_df$year == y,c('x', 'y','sd')])}))
names(pred_sd) <- c(2050, 2100)

# us! or... conus (that's how you call it right?)
us <- vect(ne_states(country = "United States of America"))
conus <- us[!us$name %in% c("Alaska", "Hawaii",
                            "Puerto Rico", "United States Virgin Islands",
                            "Commonwealth of the Northern Mariana Islands",
                            "Guam", "American Samoa"), ]
conus <- simplifyGeom(conus, tolerance = 0.1)

# to keep only lines 'inside'
state_lines <- as.lines(conus)
state_lines <- erase(state_lines, as.lines(aggregate(conus)))

extent <- as.polygons(ext(pred_mean))
outside_mask <- erase(extent, aggregate(conus))


crs(pred_mean) <- crs(conus)
crs(pred_sd) <- crs(conus)
pred_mean <- mask(pred_mean, conus)
pred_sd <- mask(pred_sd, conus)

par(mfrow = c(1,2), oma = c(0,0,0,4))
limits <- range(values(pred_mean), na.rm = TRUE)
plot(pred_mean[[1]], zlim = limits, mar = c(0, 0.5, 0, 0.5),
     legend = FALSE, box = FALSE, axes = FALSE, 
     main = '2050' , cex.main = 0.9)
plot(outside_mask, border = NA, col = 'white',
     legend = FALSE, box = FALSE, axes = FALSE, 
     add = TRUE)
plot(pred_mean[[2]], zlim = limits, mar = c(0, 0.5, 0, 0.5),
     legend = FALSE, box = FALSE, axes = FALSE,
     main = '2100' , cex.main = 0.9)
plot(outside_mask, border = NA, col = 'white',
     legend = FALSE, box = FALSE, axes = FALSE, 
     add = TRUE)
plot(pred_mean[[1]], zlim = limits, plg = list(x = -62.5),
     legend.only = TRUE, box = FALSE)
mtext("Mean blooming date (DOY)", side = 4, line = 0.25, cex = 1)

par(mfrow = c(1,2), oma = c(0,0,0,4))
limits <- log(range(values(pred_sd), na.rm = TRUE))
plot(log(pred_sd[[1]]), zlim = limits,  mar = c(0, 0.5, 0, 0.5),
     legend = FALSE, box = FALSE, axes = FALSE,
     main = '2050' , cex.main = 0.9)
plot(outside_mask, border = NA, col = 'white',
     legend = FALSE, box = FALSE, axes = FALSE, 
     add = TRUE)
lines(state_lines, col = 'white')
plot(log(pred_logsd[[2]]), zlim = limits, mar = c(0, 0.5, 0, 0.5),
     legend = FALSE, box = FALSE, axes = FALSE,
     main = '2100' , cex.main = 0.9)
plot(outside_mask, border = NA, col = 'white',
     legend = FALSE, box = FALSE, axes = FALSE, 
     add = TRUE)
lines(state_lines, col = 'white')
plot(pred_logsd[[1]], zlim = limits, 
     plg = list(x = -62.5,
                at = log(c(1, 5, 10, 20, 30, 40, 50)),
                labels = c(1, 5, 10, 20, 30, 40, 50)),
     legend.only = TRUE, box = FALSE)
mtext("Standard deviation (DOY)", side = 4, line = 0.25, cex = 1)



