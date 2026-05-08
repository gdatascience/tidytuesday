library(tidyverse)

theme_set(theme_light())

sst <- read_csv("https://raw.githubusercontent.com/littlepictures/datasets/main/sst/monthly_global_sst_mean.csv") |>
  janitor::clean_names() |>
  transmute(
    date = dmy(paste0("1/", month)),
    month = month(date, label = TRUE),
    year = year(date),
    temp = sea_surface_temperature
  )

glimpse(sst)

sst |>
  ggplot(aes(date, temp)) +
  geom_point() +
  geom_smooth(
    method = "loess",
    se = FALSE
  )

sst |>
  ggplot(aes(month, temp, fill = year, group = year)) +
  geom_col(
    position = "dodge",
    width = 1
  ) +
  scale_fill_viridis_c() +
  coord_polar() +
  labs(
    fill = "Year"
  ) +
  theme(
    panel.background = element_rect(fill = "black"),
    plot.background = element_rect(fill = "black"),
    legend.background = element_rect(fill = "black"),
    legend.key = element_rect(fill = "black"),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.text.y = element_blank(),
    axis.text.x = element_text(color = "white"),
    legend.title = element_text(color = "white"),
    legend.text = element_text(color = "white"),
    legend.position = "bottom"
  )

ggsave(
  filename = "~/Downloads/ESAlittlePic_Galvan.png",
  device = "png", 
  dpi = 300,
  height = 8,
  width = 8)
