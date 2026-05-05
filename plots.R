# plots

library(ggplot2)

cycle %>%
  mutate(maturity_label = paste0(maturity, "Y")) %>%
  ggplot(aes(x = date.x, y = cycle, colour = maturity_label)) +
  geom_line(linewidth = 0.4) +
  facet_wrap(~ country, scales = "free_y", ncol = 3) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  scale_colour_manual(
    values = c("1Y" = "#2166ac", "2Y" = "#4dac26", "5Y" = "#d6604d", "10Y" = "#762a83"),
    name   = "Maturity"
  ) +
  labs(
    title    = "Cycle Component by Country and Maturity",
    subtitle = "Residual from yield ~ trend inflation regression (Cieslak-Povala eq. 1-2)",
    x        = NULL,
    y        = "Cycle (pp)"
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "grey92"),
    strip.text       = element_text(face = "bold"),
    legend.position  = "bottom",
    panel.grid.minor = element_blank()
  )


cycle_avg %>%
  ggplot(aes(x = date, y = c_bar, colour = country)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  labs(title = "Average Cycle Factor by Country", x = NULL, y = "c̄ (pp)", colour = "Country") +
  theme_bw() +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())


local_cf %>%
  ggplot(aes(x = date, y = CF, colour = country)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  labs(
    title    = "Local Cycle Factor (CF) by Country",
    subtitle = "CF_{i,t} = γ̂_{i,1} · c_{i,t}^{(1)} + γ̂_{i,2} · c̄_{i,t}",
    x        = NULL,
    y        = "CF",
    colour   = "Country"
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "grey92"),
    strip.text       = element_text(face = "bold"),
    legend.position  = "none",       # redundant with facet labels
    panel.grid.minor = element_blank()
  )

# Faceted
p_facet <- local_cf %>%
  ggplot(aes(x = date, y = CF, colour = country)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  labs(title = "Local Cycle Factor by Country (Faceted)",
       x = NULL, y = "CF") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "grey92"),
        strip.text = element_text(face = "bold"),
        legend.position = "none",
        panel.grid.minor = element_blank())

# Single panel
local_cf %>%
  ggplot(aes(x = date, y = CF, colour = country)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  labs(title = "Local Cycle Factor by Country",
       x = NULL, y = "CF", colour = "Country") +
  theme_bw() +
  theme(legend.position = "bottom",
        panel.grid.minor = element_blank())
