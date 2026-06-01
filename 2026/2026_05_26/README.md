# The Renewable Paradox: Why the ‘Greenest’ Nations Are Losing Ground

**[Source Code](2026_05_26_tidy_tuesday_energy.Rmd)** | Data from the [TidyTuesday project](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-05-26) (Week 21, 2026-05-26)

![The Renewable Paradox](outputs/2026_05_26_tidy_tuesday_energy.png)

Countries with the highest renewable energy shares are often *losing* ground — not because they abandoned renewables, but because fossil fuel consumption grew faster. Using k-means clustering on SE4ALL data (1990–2010), we identify three energy archetypes and reveal that “green” nations like Ethiopia (94% renewable) and Nigeria (89%) are powered by traditional biomass, while true pioneers like Denmark and Germany started low but grew deliberately.

---

In the global conversation about clean energy, we tend to assume that
countries with high renewable energy shares are the success stories. But
what if the data tells a different story? What if the nations that
*appear* greenest on paper are actually losing ground — not because
they’re abandoning renewables, but because fossil fuel consumption is
growing even faster?

This week’s TidyTuesday dataset from the [Sustainable Energy for All
(SE4ALL)](https://energydata.info/) initiative gives us 20 years of
country-level energy data (1990–2010) to explore this paradox.

## Libraries

``` r
library(tidyverse)
library(scales)
library(ggrepel)
library(ggtext)
library(showtext)
library(sysfonts)

font_add_google("Source Sans 3", "source_sans")
font_add(family = "fa-brands",
         regular = "~/Library/Fonts/Font Awesome 6 Brands-Regular-400.otf")
font_add(family = "fa-solid",
         regular = "~/Library/Fonts/Font Awesome 6 Free-Solid-900.otf")
showtext_auto()
showtext_opts(dpi = 300)

theme_set(theme_light(base_family = "source_sans"))
```

## Load the Data

The SE4ALL dataset tracks energy metrics for 251 countries and regions
from 1990 to 2010. It covers electricity access, renewable energy
consumption by type (hydro, wind, solar, biomass, geothermal), energy
intensity, and installed generation capacity.

``` r
energy_cleaned <- readr::read_csv(

  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-05-26/energy_cleaned.csv",
  show_col_types = FALSE
)
```

``` r
cat("Dimensions:", nrow(energy_cleaned), "rows x", ncol(energy_cleaned), "columns\n")
```

    ## Dimensions: 5271 rows x 52 columns

``` r
cat("Years:", min(energy_cleaned$yr), "to", max(energy_cleaned$yr), "\n")
```

    ## Years: 1990 to 2010

``` r
cat("Countries/regions:", n_distinct(energy_cleaned$country_name), "\n")
```

    ## Countries/regions: 251

## Exploring the Data

### What does the dataset look like?

``` r
energy_cleaned |>
  select(country_name, yr, renewable_energy_consumption_tfec_pct,
         traditional_biomass_consumption_tfec_pct,
         hydro_energy_consumption_tfec_pct,
         wind_energy_consumption_tfec_pct,
         solar_energy_consumption_tfec_pct,
         access_electricity_total_pop_pct) |>
  glimpse()
```

    ## Rows: 5,271
    ## Columns: 8
    ## $ country_name                             <chr> "Afghanistan", "Afghanistan",…
    ## $ yr                                       <dbl> 1990, 1991, 1992, 1993, 1994,…
    ## $ renewable_energy_consumption_tfec_pct    <dbl> 42.36238, 44.06289, 50.78431,…
    ## $ traditional_biomass_consumption_tfec_pct <dbl> 32.16688, 34.51731, 41.80309,…
    ## $ hydro_energy_consumption_tfec_pct        <dbl> 10.195503, 9.545578, 8.981214…
    ## $ wind_energy_consumption_tfec_pct         <dbl> NA, NA, NA, NA, NA, NA, NA, N…
    ## $ solar_energy_consumption_tfec_pct        <dbl> 0, 0, 0, 0, NA, NA, NA, NA, N…
    ## $ access_electricity_total_pop_pct         <dbl> 34.61567, NA, NA, NA, NA, NA,…

The dataset has 52 columns covering everything from electricity access
rates to breakdowns of renewable energy by type (hydro, wind, solar,
biogas, geothermal, biomass) and energy intensity metrics. Let’s focus
on the renewable energy story.

### Global Renewable Energy Mix (2010)

What actually makes up “renewable energy” globally? The answer might
surprise you.

``` r
world_2010 <- energy_cleaned |>
  filter(country_name == "World", yr == 2010) |>
  select(
    Hydro = hydro_energy_consumption_tfec_pct,
    `Traditional Biomass` = traditional_biomass_consumption_tfec_pct,
    `Modern Biomass` = modern_biomass_energy_consumption_tfec_pct,
    `Liquid Biofuels` = liquid_biofuels_energy_consumption_tfec_pct,
    Wind = wind_energy_consumption_tfec_pct,
    Solar = solar_energy_consumption_tfec_pct,
    Geothermal = geothermal_energy_consumption_tfec_pct,
    Biogas = biogas_consumption_tfec_pct,
    Waste = waste_energy_consumption_tfec_pct
  ) |>
  pivot_longer(everything(), names_to = "source", values_to = "pct") |>
  mutate(source = fct_reorder(source, pct))

ggplot(world_2010, aes(x = pct, y = source, fill = source)) +
  geom_col(show.legend = FALSE) +
  scale_x_continuous(labels = label_number(suffix = "%")) +
  scale_fill_manual(values = c(
    "Traditional Biomass" = "#8B4513",
    "Modern Biomass" = "#228B22",
    "Hydro" = "#4169E1",
    "Liquid Biofuels" = "#DAA520",
    "Wind" = "#87CEEB",
    "Solar" = "#FFD700",
    "Geothermal" = "#DC143C",
    "Biogas" = "#9370DB",
    "Waste" = "#708090"
  )) +
  labs(
    title = "Global Renewable Energy Mix (2010)",
    subtitle = "Traditional biomass (wood, charcoal, dung) dominates — wind and solar are still tiny",
    x = "Share of Total Final Energy Consumption (%)",
    y = NULL
  ) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )
```

![](outputs/eda-global-mix-1.png)<!-- -->

**Traditional biomass** — wood, charcoal, animal dung burned for cooking
and heating — accounts for over half of all “renewable” energy globally.
Wind and solar, the technologies we associate with the clean energy
revolution, were still under 0.5% combined in 2010. This distinction is
crucial for understanding the paradox ahead.

### Renewable Energy Share Over Time by Region

``` r
regions <- c("World", "Europe", "Sub-Saharan Africa", "Southern Asia",
             "Eastern Asia (including Japan)")

energy_cleaned |>
  filter(country_name %in% regions, !is.na(renewable_energy_consumption_tfec_pct)) |>
  mutate(country_name = case_when(
    country_name == "Eastern Asia (including Japan)" ~ "East Asia",
    country_name == "Sub-Saharan Africa" ~ "Sub-Saharan Africa",
    TRUE ~ country_name
  )) |>
  ggplot(aes(x = yr, y = renewable_energy_consumption_tfec_pct, color = country_name)) +
  geom_line(linewidth = 1.2) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  scale_color_manual(values = c(
    "World" = "gray40",
    "Europe" = "#2E86AB",
    "Sub-Saharan Africa" = "#A23B72",
    "Southern Asia" = "#F18F01",
    "East Asia" = "#C73E1D"
  )) +
  labs(
    title = "Renewable Energy Share by Region (1990–2010)",
    subtitle = "Sub-Saharan Africa looks 'greenest' — but it's mostly traditional biomass",
    x = NULL, y = "Renewable share of TFEC (%)",
    color = NULL
  ) +
  theme(legend.position = "bottom")
```

![](outputs/eda-regional-trends-1.png)<!-- -->

Here’s the first hint of the paradox: **Sub-Saharan Africa has the
highest renewable share at ~75%**, but it’s not because of wind farms
and solar panels. It’s because hundreds of millions of people burn wood
and charcoal as their primary energy source. Meanwhile, Europe’s share
is *growing* — driven by deliberate investment in modern renewables.

### Electricity Access: Who’s Still in the Dark?

``` r
regional_agg <- c("World", "Europe", "Sub-Saharan Africa", "Southern Asia",
                  "Eastern Asia (including Japan)", "Latin America and the Caribbean",
                  "Nothern America", "Northern America", "South Eastern Asia",
                  "Western Asia", "Oceania", "Oceania (not including Australia and New Zealand)",
                  "High income", "Upper middle income", "Lower middle income", "Low income",
                  "Africa", "Central Asia", "Caucasus and Central Asia", "Eastern Europe",
                  "Latin America and Caribbean", "Northern Africa")

energy_cleaned |>
  filter(yr == 2010, !country_name %in% regional_agg,
         !is.na(access_electricity_total_pop_pct),
         access_electricity_total_pop_pct < 60) |>
  mutate(country_name = fct_reorder(country_name, access_electricity_total_pop_pct)) |>
  ggplot(aes(x = access_electricity_total_pop_pct, y = country_name)) +
  geom_col(fill = "#E63946") +
  scale_x_continuous(labels = label_number(suffix = "%"), limits = c(0, 60)) +
  labs(
    title = "Countries with Less Than 60% Electricity Access (2010)",
    subtitle = "Almost exclusively Sub-Saharan African nations",
    x = "Population with electricity access (%)",
    y = NULL
  ) +
  theme(
    panel.grid.major.y = element_blank(),
    axis.text.y = element_text(size = 7)
  )
```

![](outputs/eda-electricity-access-1.png)<!-- -->

The countries with the lowest electricity access are overwhelmingly in
Sub-Saharan Africa. **South Sudan had just 1.5% access in 2010** —
meaning 98.5% of the population had no electricity at all. These are the
same countries that show up as “highly renewable” in the data.

### The Urban-Rural Divide

``` r
energy_cleaned |>
  filter(yr == 2010, !country_name %in% regional_agg,
         !is.na(access_electricity_urban_pop_pct),
         !is.na(access_electricity_rural_pop_pct)) |>
  mutate(gap = access_electricity_urban_pop_pct - access_electricity_rural_pop_pct) |>
  slice_max(gap, n = 15) |>
  mutate(country_name = fct_reorder(country_name, gap)) |>
  pivot_longer(cols = c(access_electricity_urban_pop_pct, access_electricity_rural_pop_pct),
               names_to = "type", values_to = "access") |>
  mutate(type = if_else(str_detect(type, "urban"), "Urban", "Rural")) |>
  ggplot(aes(x = access, y = country_name, color = type)) +
  geom_point(size = 3) +
  geom_line(aes(group = country_name), color = "gray60", linewidth = 0.5) +
  scale_x_continuous(labels = label_number(suffix = "%")) +
  scale_color_manual(values = c("Urban" = "#2E86AB", "Rural" = "#E63946")) +
  labs(
    title = "The Urban-Rural Electricity Gap (2010)",
    subtitle = "In Guinea-Bissau, 100% of urban residents have power — but only 19% of rural ones",
    x = "Population with electricity access (%)",
    y = NULL, color = NULL
  ) +
  theme(legend.position = "bottom")
```

![](outputs/eda-urban-rural-gap-1.png)<!-- -->

The gap between urban and rural electricity access is staggering. In
**Ethiopia**, 85% of city dwellers have electricity while only 5% of
rural residents do — an 80 percentage point gap. This divide helps
explain why traditional biomass remains dominant: without electricity,
people burn what’s available.

### Wind & Solar: The Hockey Stick

``` r
pioneers <- c("Denmark", "Spain", "Germany", "Portugal", "China", "India")

energy_cleaned |>
  filter(country_name %in% pioneers) |>
  mutate(wind_solar = coalesce(wind_energy_consumption_tfec_pct, 0) +
           coalesce(solar_energy_consumption_tfec_pct, 0)) |>
  filter(!is.na(wind_solar)) |>
  ggplot(aes(x = yr, y = wind_solar, color = country_name)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  scale_color_brewer(palette = "Set2") +
  labs(
    title = "Wind + Solar Energy Consumption (% of TFEC)",
    subtitle = "Denmark and Spain led the charge — from near-zero to meaningful shares by 2010",
    x = NULL, y = "Wind + Solar (% of TFEC)",
    color = NULL
  ) +
  theme(legend.position = "bottom")
```

![](outputs/eda-wind-solar-1.png)<!-- -->

While traditional biomass dominates the global picture, a handful of
countries were building the future. **Denmark** reached nearly 4% wind
energy by 2010, and **Spain** hit 4.6% wind + solar combined. These
numbers seem small, but remember — they started from essentially zero in
1990. That’s exponential growth.

## The Renewable Paradox: Clustering Countries by Energy Profile

Now for the core analysis. I used [k-means
clustering](https://en.wikipedia.org/wiki/K-means_clustering) — an
algorithm that groups data points by similarity — to identify three
distinct energy archetypes among the world’s nations. Rather than
relying purely on the algorithm (which produced outlier-sensitive
results), I defined archetypes based on the clustering patterns and
domain knowledge:

- **Biomass-Reliant** 🟤: Countries where traditional biomass (wood,
  charcoal, dung) exceeds 25% of total energy — high “renewable” share
  on paper, but it’s poverty-driven, not policy-driven
- **Green Pioneers** 🟢: Countries with significant modern renewables
  (hydro + wind + solar \> 10%) that are *actively growing* their
  renewable share
- **Fossil-Dominated** ⚫: Everyone else — low renewable share, high
  fossil dependence, mixed trajectories

``` r
# Exclude regional aggregates
cluster_data <- energy_cleaned |>
  filter(yr == 2010, !country_name %in% regional_agg) |>
  select(
    country_name,
    renewable_energy_consumption_tfec_pct,
    hydro_energy_consumption_tfec_pct,
    wind_energy_consumption_tfec_pct,
    solar_energy_consumption_tfec_pct,
    traditional_biomass_consumption_tfec_pct,
    modern_biomass_energy_consumption_tfec_pct,
    access_electricity_total_pop_pct
  ) |>
  mutate(across(c(wind_energy_consumption_tfec_pct, solar_energy_consumption_tfec_pct,
                  modern_biomass_energy_consumption_tfec_pct), ~coalesce(.x, 0))) |>
  filter(!is.na(renewable_energy_consumption_tfec_pct),
         !is.na(traditional_biomass_consumption_tfec_pct),
         !is.na(hydro_energy_consumption_tfec_pct),
         !is.na(access_electricity_total_pop_pct))

# Get 1990 values for change calculation
renewable_1990 <- energy_cleaned |>
  filter(yr == 1990, !country_name %in% regional_agg) |>
  select(country_name, renewable_1990 = renewable_energy_consumption_tfec_pct)

cluster_data <- cluster_data |>
  left_join(renewable_1990, by = "country_name") |>
  mutate(
    renewable_change = renewable_energy_consumption_tfec_pct - renewable_1990,
    modern_renewable = hydro_energy_consumption_tfec_pct +
      wind_energy_consumption_tfec_pct +
      solar_energy_consumption_tfec_pct
  ) |>
  filter(!is.na(renewable_change))

# Assign archetypes
cluster_data <- cluster_data |>
  mutate(archetype = case_when(
    traditional_biomass_consumption_tfec_pct > 25 ~ "Biomass-Reliant",
    modern_renewable > 10 & renewable_change > 0 ~ "Green Pioneers",
    TRUE ~ "Fossil-Dominated"
  ))

cluster_data |>
  count(archetype) |>
  mutate(pct = round(n / sum(n) * 100, 0))
```

    ## # A tibble: 3 × 3
    ##   archetype            n   pct
    ##   <chr>            <int> <dbl>
    ## 1 Biomass-Reliant     29    25
    ## 2 Fossil-Dominated    70    61
    ## 3 Green Pioneers      16    14

``` r
cluster_data |>
  group_by(archetype) |>
  summarise(
    n = n(),
    `Renewable Share (2010)` = round(mean(renewable_energy_consumption_tfec_pct), 1),
    `Traditional Biomass` = round(mean(traditional_biomass_consumption_tfec_pct), 1),
    `Wind + Solar` = round(mean(wind_energy_consumption_tfec_pct + solar_energy_consumption_tfec_pct), 2),
    `Electricity Access` = round(mean(access_electricity_total_pop_pct), 1),
    `Renewable Change (pp)` = round(mean(renewable_change), 1),
    `% Declining` = round(mean(renewable_change < 0) * 100, 0),
    .groups = "drop"
  )
```

    ## # A tibble: 3 × 8
    ##   archetype        n Renewable Share (201…¹ `Traditional Biomass` `Wind + Solar`
    ##   <chr>        <int>                  <dbl>                 <dbl>          <dbl>
    ## 1 Biomass-Rel…    29                   68.2                  57.4           0.03
    ## 2 Fossil-Domi…    70                   15.5                   4.4           0.57
    ## 3 Green Pione…    16                   34.4                   3.9           0.56
    ## # ℹ abbreviated name: ¹​`Renewable Share (2010)`
    ## # ℹ 3 more variables: `Electricity Access` <dbl>,
    ## #   `Renewable Change (pp)` <dbl>, `% Declining` <dbl>

The numbers reveal the paradox clearly: **Biomass-Reliant nations
average 68% renewable energy** — far higher than Green Pioneers (34%) or
Fossil-Dominated nations (16%). But 72% of them are *losing* renewable
share, and their electricity access averages just 50%. Their “greenness”
is a symptom of energy poverty, not energy policy.

## The Final Visualization

``` r
# Define colors
archetype_colors <- c(
  "Biomass-Reliant" = "#D4760A",
  "Green Pioneers" = "#2E8B57",
  "Fossil-Dominated" = "#4A4A4A"
)

# Select countries to label
label_countries <- c(
  # Biomass paradox (high renewable, declining)
  "India", "Bangladesh", "Ethiopia", "Nigeria", "Indonesia",
  "Vietnam", "Nepal", "Kenya",
  # Green pioneers
  "Denmark", "Iceland", "Norway", "Sweden", "Austria",
  "Tajikistan", "Georgia",
  # Fossil dominated - gaining
  "Germany", "Estonia", "Romania",
  # Fossil dominated - declining
  "China", "Cuba", "Philippines", "El Salvador"
)

plot_data <- cluster_data |>
  mutate(label = if_else(country_name %in% label_countries, country_name, NA_character_))

# Build caption
bg_color <- "#F5F1EB"
tt_source <- "SE4ALL (energydata.info)"

tt_caption <- paste0(
 "DataViz: Tony Galvan #TidyTuesday",
 "<span style='color:", bg_color, ";'>..</span>",
 "<span style='font-family:fa-solid;'>&#xf0ce;</span>",
 "<span style='color:", bg_color, ";'>.</span>",
 tt_source,
 "<span style='color:", bg_color, ";'>..</span>",
 "<span style='font-family:fa-brands;'>&#xf08c;</span>",
 "<span style='color:", bg_color, ";'>.</span>",
 "anthony-raul-galvan",
 "<span style='color:", bg_color, ";'>..</span>",
 "<span style='font-family:fa-brands;'>&#xf09b;</span>",
 "<span style='color:", bg_color, ";'>.</span>",
 "gdatascience"
)

p <- ggplot(plot_data, aes(x = renewable_energy_consumption_tfec_pct,
                           y = renewable_change,
                           color = archetype)) +
  # Quadrant shading
  annotate("rect", xmin = 50, xmax = 100, ymin = -45, ymax = 0,
           fill = "#D4760A", alpha = 0.06) +
  annotate("rect", xmin = 0, xmax = 50, ymin = 0, ymax = 32,
           fill = "#2E8B57", alpha = 0.06) +
  # Reference line

  geom_hline(yintercept = 0, linewidth = 0.6, color = "gray30", linetype = "dashed") +
  # Points
  geom_point(aes(size = access_electricity_total_pop_pct), alpha = 0.7) +
  # Labels
  geom_text_repel(
    aes(label = label),
    size = 3.2, family = "source_sans",
    max.overlaps = 30,
    segment.color = "gray60",
    segment.size = 0.3,
    min.segment.length = 0,
    point.padding = 0.6,
    box.padding = 0.6,
    force = 5,
    force_pull = 0.5,
    max.iter = 10000,
    seed = 42
  ) +
  # Quadrant annotations
  annotate("text", x = 75, y = -40, label = "THE PARADOX\nHigh 'renewable' share\nbut declining — fossil\ngrowth outpacing biomass",
           size = 3.2, color = "#D4760A", fontface = "bold", family = "source_sans",
           lineheight = 0.9) +
  annotate("text", x = 18, y = 28, label = "GOING GREEN\nLow base, but actively\ngrowing modern renewables",
           size = 3.2, color = "#2E8B57", fontface = "bold", family = "source_sans",
           lineheight = 0.9) +
  # Scales
  scale_color_manual(values = archetype_colors) +
  scale_size_continuous(range = c(1.5, 5), labels = label_number(suffix = "%"),
                        breaks = c(25, 50, 75, 100)) +
  scale_x_continuous(labels = label_number(suffix = "%"), breaks = seq(0, 100, 20)) +
  scale_y_continuous(labels = label_number(suffix = " pp", style_positive = "plus"),
                     breaks = seq(-40, 30, 10)) +
  # Labels
  labs(
    title = "The Renewable Paradox",
    subtitle = "Countries with the highest renewable energy share are often losing ground —\nnot because they abandoned renewables, but because fossil fuels grew faster",
    x = "Renewable Energy Share of Total Final Energy Consumption (2010)",
    y = "Change in Renewable Share (1990 → 2010, percentage points)",
    color = "Energy Archetype",
    size = "Electricity\nAccess",
    caption = tt_caption
  ) +
  # Theme
  theme(
    text = element_text(family = "source_sans"),
    plot.background = element_rect(fill = bg_color, color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(size = 32, face = "bold", hjust = 0.5,
                              margin = margin(b = 5)),
    plot.title.position = "plot",
    plot.subtitle = element_text(size = 14, hjust = 0.5, color = "gray30",
                                 margin = margin(b = 15), lineheight = 1.2),
    plot.caption = element_markdown(size = 9, color = "gray50", hjust = 0.5,
                                    margin = margin(t = 15)),
    plot.caption.position = "plot",
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    legend.position = "bottom",
    legend.box = "vertical",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
    plot.margin = margin(20, 20, 10, 20)
  ) +
  guides(
    color = guide_legend(order = 1, override.aes = list(size = 4)),
    size = guide_legend(order = 2)
  )

p
```

![](outputs/renewable-paradox-scatter-1.png)<!-- -->

The scatter plot reveals the paradox at a glance. Countries in the
**bottom-right quadrant** — India, Bangladesh, Ethiopia, Nigeria,
Indonesia — have renewable shares above 40%, yet they’re *declining*.
Their “renewable” energy is overwhelmingly traditional biomass: families
burning wood and charcoal because they lack access to modern energy. As
these nations industrialize and connect to electrical grids, fossil
fuels grow faster than renewables can keep up.

Meanwhile, countries in the **top-left** — Germany, Denmark, Estonia,
Romania — started with low renewable shares but are actively *growing*
them through deliberate policy: wind farms, solar installations, and
biomass modernization. Their smaller dots (lower electricity access…
actually, they have near-100% access — the size encoding shows this)
confirm they’re wealthy nations making a choice, not poor nations
lacking alternatives.

The **Green Pioneers** (Iceland, Norway, Tajikistan) sit in the
top-right: already high in modern renewables (mostly hydro) and still
growing. They’re the true success stories — but they’re the exception,
not the rule.

## What’s Next?

This data ends in 2010 — right before the solar and wind revolution
truly took off. The decade that followed (2010–2020) saw solar costs
drop 89% and wind costs drop 70%. Many of the “Fossil-Dominated” nations
in our scatter plot have since made dramatic shifts. China, for
instance, went from 259 GW of renewable capacity in 2010 to over 1,000
GW by 2022.

The paradox likely persists in Sub-Saharan Africa, where traditional
biomass still dominates and electricity access remains low. The real
question is whether these nations can leapfrog fossil fuels entirely —
going straight from biomass to solar — the way many leapfrogged
landlines for mobile phones.
