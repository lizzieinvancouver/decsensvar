rm(list = ls())
library(terra)
library(rnaturalearth)

setwd("/home/victor/projects/decsensvar/analyses/figures")
# setwd("~/Documents/git/projects/treegarden/decsensvar/analyses/figures")
load("..//input/make_map.RData")

# prepare rasters of predictions
predicted_df <- predicted_df[predicted_df$scenario == 'ssp585',]
bg <- rast(predicted_df[predicted_df$year == '2050',c('x', 'y','mean')])
# rm locations where there is no lilac data ... Lizzie added, but could be better I suspect
predicted_df <- predicted_df[predicted_df$x < max(lilac_fbloom$longitude),]
predicted_df <- predicted_df[predicted_df$y > min(lilac_fbloom$latitude),]

predicted_df$sd <- (sqrt(predicted_df$var))
pred_mean <- rast(lapply(c(2050, 2100), function(y) {rast(predicted_df[predicted_df$year == y,c('x', 'y','mean')])}))
names(pred_mean) <- c(2050, 2100)
pred_sd <- rast(lapply(c(2050, 2100), function(y) {rast(predicted_df[predicted_df$year == y,c('x', 'y','sd')])}))
names(pred_sd) <- c(2050, 2100)
pred_logsd <- log(pred_sd)

# us! or... conus (that's how you call it right?)
us <- vect(ne_states(country = "United States of America"))
conus <- us[!us$name %in% c("Alaska", "Hawaii",
                            "Puerto Rico", "United States Virgin Islands",
                            "Commonwealth of the Northern Mariana Islands",
                            "Guam", "American Samoa"), ]

# to keep only lines 'inside'
state_lines <- as.lines(conus)
state_lines <- erase(state_lines, as.lines(aggregate(conus)))

extent <- as.polygons(ext(pred_mean)+10)
outside_mask <- erase(extent, aggregate(conus))

crs(bg) <- crs(conus)
crs(pred_mean) <- crs(conus)
crs(pred_sd) <- crs(conus)
bg <- mask(bg, conus)
pred_mean <- mask(pred_mean, conus)
pred_sd <- mask(pred_sd, conus)

pdf("plotterra_mean.pdf", height = 3, width = 10)
par(mfrow = c(1,2), oma = c(0,0,0,4))
limits <- range(values(pred_mean), na.rm = TRUE)
plot(bg, zlim = limits, mar = c(0, 0.5, 0, 0.5),
     legend = FALSE, box = FALSE, axes = FALSE, 
     col = 'grey90', main = '2050' , cex.main = 0.9)
plot(pred_mean[[1]], zlim = limits, legend = FALSE, add = T)
plot(outside_mask, border = NA, col = 'white',
     legend = FALSE, box = FALSE, axes = FALSE, 
     add = TRUE)
plot(bg, zlim = limits, mar = c(0, 0.5, 0, 0.5),
     legend = FALSE, box = FALSE, axes = FALSE, 
     col = 'grey90', main = '2100' , cex.main = 0.9)
plot(pred_mean[[2]], zlim = limits, legend = FALSE, add = T)
plot(outside_mask, border = NA, col = 'white',
     legend = FALSE, box = FALSE, axes = FALSE, 
     add = TRUE)
plot(pred_mean[[1]], zlim = limits, plg = list(x = -62.5, size = 2),
     legend.only = TRUE, box = FALSE)
par(xpd = NA)
text(x = -64, y = 35.75, "Mean blooming date (DOY)", srt = 90, adj = 0.5, cex = 0.9)
dev.off()


pdf("plotterra_sd.pdf", height = 3, width = 10)
par(mfrow = c(1,2), oma = c(0,0,0,4))
limits <- log(range(values(pred_sd), na.rm = TRUE))
plot(bg, zlim = limits, mar = c(0, 0.5, 0, 0.5),
     legend = FALSE, box = FALSE, axes = FALSE, 
     col = 'grey90', main = '2050' , cex.main = 0.9)
plot(pred_logsd[[1]], zlim = limits, legend = FALSE, add = T, box = FALSE)
plot(outside_mask, border = NA, col = 'white',
     legend = FALSE, box = FALSE, axes = FALSE,
     add = TRUE)
plot(bg, zlim = limits, mar = c(0, 0.5, 0, 0.5),
     legend = FALSE, box = FALSE, axes = FALSE, 
     col = 'grey90', main = '2100' , cex.main = 0.9)
plot(pred_logsd[[2]], zlim = limits, legend = FALSE, add = T, box = FALSE)
plot(outside_mask, border = NA, col = 'white',
     legend = FALSE, box = FALSE, axes = FALSE,
     add = TRUE)
plot(pred_logsd[[1]], zlim = limits, 
     plg = list(x = -62.5, size = 2, 
                at = log(c(1, 5, 10, 20, 30)),
                labels = c(1, 5, 10, 20, 30)),
     legend.only = TRUE, box = FALSE)
par(xpd = NA)
text(x = -64, y = 35.75, "Standard deviation (DOY)", srt = 90, adj = 0.5, cex = 0.9)
dev.off()


