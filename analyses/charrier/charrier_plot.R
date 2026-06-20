library("tidyverse")
library("readxl")

setwd("~/Documents/git/projects/treegarden/decsensvar/analyses/charrier")

charrier <- 
read_excel("Forcing_walnut_2008.xlsx") %>%
  mutate(response.time = as.numeric(`Time to break bud (BBCH 10)`),
         forceday = Temperature) %>%
  #filter(Bud_Type == "b") %>%
  mutate(Tree_number = as.numeric(as.factor(Tree)))

charrier %>%
  ggplot() +
  aes(forceday, response.time) +
  geom_point() +
  theme_bw() +
  theme(axis.line = element_line(linewidth = 0.5, colour = "darkgray")) +
  labs(x = "temperature", y = "response time") +
  ylim(0, 250) +
  geom_smooth(aes(weight = forceday^3), 
              method = "lm", formula = y ~ I(1/x), color = "red") +
  facet_wrap(~Tree_number)

make_pred_band <- function(df, x_min = 5, x_max = 25, n = 200) {
  fit <- lm(response.time ~ I(1/forceday),
            data = df,
            weights = forceday^3)
  
  pred_df <- tibble(forceday = seq(x_min, x_max, length.out = n))
  
  X0     <- cbind(`(Intercept)` = 1, 
                  `I(1/forceday)` = 1/pred_df$forceday)
  beta   <- coef(fit)
  Vb     <- vcov(fit)
  sigma2 <- summary(fit)$sigma^2
  dfree  <- df.residual(fit)
  
  pred_df <- pred_df %>%
    mutate(
      fit = as.vector(X0 %*% beta),
      mean_var = rowSums((X0 %*% Vb) * X0),
      w_new = forceday^3,
      pred_var = mean_var + sigma2 / w_new
    )
  
  crit <- qt(0.975, df = dfree)
  pred_df %>%
    mutate(
      lwr = fit - crit * sqrt(pred_var),
      upr = fit + crit * sqrt(pred_var)
    )
}

pred_df_facet <- charrier %>%
  group_by(Tree_number) %>%
  group_modify(~ make_pred_band(.x)) %>%
  ungroup()

ggplot(charrier, aes(forceday, response.time)) +
  geom_ribbon(data = pred_df_facet,
              aes(x = forceday, ymin = lwr, ymax = upr),
              inherit.aes = FALSE,
              alpha = 0.2,
              fill = "grey30") +
  geom_point() +
  # geom_line(data = pred_df_facet, aes(x = forceday, y = fit),
  #           inherit.aes = FALSE, color = "grey30", linewidth = 1) +
  geom_smooth(aes(weight = forceday^3), fullrange = TRUE,
              method = "lm", formula = y ~ I(1/x), 
              color = "black", fill = "grey10") +
  facet_wrap(~ Tree_number, scales = "free", nrow = 3) +
  theme_bw() +
  theme(axis.line = element_line(linewidth = 0.5, colour = "darkgray")) +
  labs(x = "temperature (\u00B0C)",
       y = "days until budburst") +
  xlim(5, 25)

# or by geno
pred_df_facet_g <- charrier %>%
  group_by(Genotype) %>%
  group_modify(~ make_pred_band(.x)) %>%
  ungroup()

ggplot(charrier, aes(forceday, response.time)) +
  geom_ribbon(data = pred_df_facet_g,
              aes(x = forceday, ymin = lwr, ymax = upr),
              inherit.aes = FALSE,
              alpha = 0.2,
              fill = "grey30") +
  geom_point() +
  # geom_line(data = pred_df_facet_g, aes(x = forceday, y = fit),
  #           inherit.aes = FALSE, color = "grey30", linewidth = 1) +
  geom_smooth(aes(weight = forceday^3), fullrange = TRUE,
              method = "lm", formula = y ~ I(1/x), 
              color = "black", fill = "grey10") +
  facet_wrap(~ Genotype, scales = "free", nrow = 3) +
  theme_bw() +
  theme(axis.line = element_line(linewidth = 0.5, colour = "darkgray")) +
  labs(x = "temperature (\u00B0C)",
       y = "days until budburst") +
  xlim(5, 25)