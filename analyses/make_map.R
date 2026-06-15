library("tidyverse")
library("sf")
library("tigris")

# remove non US points
pts_sf <- st_as_sf(predicted_df, coords = c("x", "y"), crs = 4326)
states_sf <- states(cb = TRUE, resolution = "20m") %>%
  filter(!STUSPS %in% c("AK", "HI", "PR")) %>%
  st_transform(4326)
pts_joined <- st_join(pts_sf, states_sf, join = st_within)


mean_plot <- ggplot(predicted_df %>% filter(!is.na(mean),
                                            !is.na(pts_joined$STUSPS),
                                            x > min(lilac_fbloom$longitude),
                                            x < max(lilac_fbloom$longitude),
                                            y > min(lilac_fbloom$latitude),
                                            y < max(lilac_fbloom$latitude)), 
                    aes(x, y, fill = mean)) +
  geom_raster() +
  geom_path(
    data = states,
    aes(long, lat, group = group),
    inherit.aes = FALSE,
    color = "grey75",
    linewidth = 0.15
  ) +
  coord_quickmap(
    xlim = range(lilac_fbloom$longitude),
    ylim = range(lilac_fbloom$latitude), 
    #xlim = c(-125, -66.5),
    #ylim = c(24, 49.5),
    expand = FALSE
  ) +
  facet_grid(scenario ~ year, switch = "y",
             labeller = labeller(
               year = function(x) paste("Year", x),
               scenario = c(
                 ssp245 = "Scenario SSP2-4.5",
                 ssp585 = "Scenario SSP5-8.5"
               )
             )) +
  scale_fill_viridis_c(name = "mean", option = "rocket", direction = -1) +
  # scale_fill_gradient(
  #   low = "red",
  #   high = "white",
  #   name = "sd / mean"
  # ) +
  theme_void() +
  theme(legend.position = "bottom",
        legend.box.margin = margin(t = 50),
        panel.spacing = unit(0.1, "lines"),
        strip.switch.pad.grid = unit(0.05, "lines"),
        plot.margin = margin(2, 2, 2, 2),
        strip.text = element_text(size = 11))


ggsave("forecast_mean.pdf", plot = mean_plot,  height = 5, width = 10)

var_plot <- ggplot(predicted_df %>% 
                     filter(!is.na(var),
                            !is.na(pts_joined$STUSPS),
                            x > min(lilac_fbloom$longitude),
                            x < max(lilac_fbloom$longitude),
                            y > min(lilac_fbloom$latitude),
                            y < max(lilac_fbloom$latitude)
                     ), 
                   aes(x, y, fill = log(sqrt(var)))) +
  geom_raster() +
  geom_path(
    data = states,
    aes(long, lat, group = group),
    inherit.aes = FALSE,
    color = "grey75",
    linewidth = 0.15
  ) +
  coord_quickmap(
    xlim = range(lilac_fbloom$longitude),
    ylim = range(lilac_fbloom$latitude), 
    #xlim = c(-125, -66.5),
    #ylim = c(24, 49.5),
    expand = FALSE
  ) +
  facet_grid(scenario ~ year, switch = "y",
             labeller = labeller(
               year = function(x) paste("Year", x),
               scenario = c(
                 ssp245 = "Scenario SSP2-4.5",
                 ssp585 = "Scenario SSP5-8.5"
               )
             )) +
  scale_fill_viridis_c(name = "standard deviation", option = "rocket", #direction = -1,
                       breaks = log(c(10, 20, 30, 40)),
                       labels = c(10, 20, 30, 40)) +
  # scale_fill_gradient(
  #   low = "white",
  #   high = "red",
  #   name = "standard deviation",
  #   breaks = log(c(10, 20, 30, 40)),
  #   labels = c(10, 20, 30, 40)) +
  theme_void() +
  theme(legend.position = "bottom",
        legend.box.margin = margin(t = 50),
        panel.spacing = unit(0.1, "lines"),
        strip.switch.pad.grid = unit(0.05, "lines"),
        plot.margin = margin(2, 2, 2, 2),
        strip.text = element_text(size = 11))

ggsave("forecast_var.pdf", plot = var_plot,  height = 5, width = 10)


# remove non US south points
library("sf")
library("tigris")
south_states <- c("AL", "AR", "AZ", "CA", "FL", "GA", "KY", "LA", "MS", 
                  "NC", "NM", "NV", "OK", "SC", "TN", "TX", "UT", "VA", "WV")
states_sf_south <- states(cb = TRUE, resolution = "20m") %>%
  filter(STUSPS %in% south_states) %>%
  st_transform(4326)
pts_joined_south <- st_join(pts_sf, states_sf_south, join = st_within)


mean_plot_south <- ggplot(predicted_df %>% filter(
  scenario == "ssp585",
  year %in% c(2050, 2100),
  !is.na(mean),
  !is.na(pts_joined_south$STUSPS),
  x > min(lilac_fbloom$longitude),
  x < max(lilac_fbloom$longitude),
  y > min(lilac_fbloom$latitude),
  y < max(lilac_fbloom$latitude)), 
  aes(x, y, fill = mean)) +
  geom_raster() +
  geom_path(
    data = states,
    aes(long, lat, group = group),
    inherit.aes = FALSE,
    color = "grey75",
    linewidth = 0.15
  ) +
  coord_quickmap(
    xlim = range(lilac_fbloom[lilac_fbloom$state %in% south_states,]$longitude),
    ylim = c(NA, max(lilac_fbloom[lilac_fbloom$state %in% south_states,]$latitude)), 
    #ylim = range(lilac_fbloom[lilac_fbloom$state %in% south_states,]$latitude), 
    #xlim = c(-125, -66.5),
    #ylim = c(29.88, 40),
    expand = FALSE
  ) +
  facet_grid(scenario ~ year, switch = "y",
             labeller = labeller(
               year = function(x) paste("Year", x),
               scenario = c(
                 ssp245 = "Scenario SSP2-4.5",
                 ssp585 = "Scenario SSP5-8.5"
               )
             )) +
  scale_fill_viridis_c(name = "mean", option = "rocket", direction = -1) +
  # scale_fill_gradient(
  #   low = "red",
  #   high = "white",
  #   name = "sd / mean"
  # ) +
  theme_void() +
  theme(legend.position = "bottom",
        legend.box.margin = margin(t = 50),
        panel.spacing = unit(0.1, "lines"),
        strip.switch.pad.grid = unit(0.05, "lines"),
        plot.margin = margin(2, 2, 2, 2),
        strip.text = element_text(size = 11))

ggsave("forecast_mean_south.pdf", plot = mean_plot_south,  height = 5, width = 10)

var_plot_south <- ggplot(predicted_df %>% 
                           filter(!is.na(var),
                                  scenario == "ssp585",
                                  year %in% c(2050, 2100),
                                  !is.na(mean),
                                  !is.na(pts_joined_south$STUSPS),
                                  x > min(lilac_fbloom$longitude),
                                  x < max(lilac_fbloom$longitude),
                                  y > min(lilac_fbloom$latitude),
                                  y < max(lilac_fbloom$latitude)
                           ), 
                         aes(x, y, fill = log(sqrt(var)))) +
  geom_raster() +
  geom_path(
    data = states,
    aes(long, lat, group = group),
    inherit.aes = FALSE,
    color = "grey75",
    linewidth = 0.15
  ) +
  coord_quickmap(
    xlim = range(lilac_fbloom[lilac_fbloom$state %in% south_states,]$longitude),
    ylim = c(NA, max(lilac_fbloom[lilac_fbloom$state %in% south_states,]$latitude)), 
    #ylim = range(lilac_fbloom[lilac_fbloom$state %in% south_states,]$latitude), 
    #xlim = c(-125, -66.5),
    #ylim = c(24, 49.5),
    expand = FALSE
  ) +
  facet_grid(scenario ~ year, switch = "y",
             labeller = labeller(
               year = function(x) paste("Year", x),
               scenario = c(
                 ssp245 = "Scenario SSP2-4.5",
                 ssp585 = "Scenario SSP5-8.5"
               )
             )) +
  scale_fill_viridis_c(name = "standard deviation", option = "rocket", #direction = -1,
                       breaks = log(c(10, 20, 30, 40)),
                       labels = c(10, 20, 30, 40)) +
  # scale_fill_gradient(
  #   low = "white",
  #   high = "red",
  #   name = "standard deviation",
  #   breaks = log(c(10, 20, 30, 40)),
  #   labels = c(10, 20, 30, 40)) +
  theme_void() +
  theme(legend.position = "bottom",
        legend.box.margin = margin(t = 50),
        panel.spacing = unit(0.1, "lines"),
        strip.switch.pad.grid = unit(0.05, "lines"),
        plot.margin = margin(2, 2, 2, 2),
        strip.text = element_text(size = 11))

ggsave("forecast_var_south.pdf", plot = var_plot_south,  height = 5, width = 10)