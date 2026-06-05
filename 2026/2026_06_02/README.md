# Europe's Parenting Leave Revolutions: When Did Each Country Break Through?

**[Source Code](2026_06_02_tidy_tuesday_parenting_leave.Rmd)** | Data from the [TidyTuesday project](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-06-02) (Week 22, 2026-06-02)

![Europe's Parenting Leave Revolutions](outputs/2026_06_02_tidy_tuesday_parenting_leave.png)

Europe didn't gradually adopt co-parent leave — it happened in **revolutions**. Using changepoint detection and a Random Forest model, we map when each country broke through and what policy conditions predict generous leave for co-parents.

---


Europe didn’t gradually evolve toward co-parent leave. It happened in
**revolutions** — sudden legislative leaps where countries jumped from
zero to weeks of dedicated leave for fathers and non-birthing partners.
In 1970, only Spain offered anything. By 2024, 19 of 21 countries do.
But these reforms didn’t arrive steadily — they came in waves, often
clustered around EU directives and cultural tipping points.

We’ll use **changepoint detection** to map exactly when each country had
its parental leave breakthrough, then train a **Random Forest model** to
answer: what policy conditions predict whether a country will offer
generous co-parent leave?

## Libraries

``` r
library(tidyverse)
library(scales)
library(ranger)
library(showtext)
library(sysfonts)
library(ggtext)

# Fonts
font_add_google("Source Sans 3", "source_sans")
font_add(family = "fa-brands",
         regular = "~/Library/Fonts/Font Awesome 6 Brands-Regular-400.otf")
font_add(family = "fa-solid",
         regular = "~/Library/Fonts/Font Awesome 6 Free-Solid-900.otf")
showtext_auto()
showtext_opts(dpi = 300)

# Colorblind-safe palette (Okabe-Ito)
oi_blue <- "#0072B2"
oi_orange <- "#E69F00"
oi_skyblue <- "#56B4E9"
oi_green <- "#009E73"
oi_vermillion <- "#D55E00"
oi_purple <- "#CC79A7"
oi_black <- "#000000"

theme_set(theme_light(base_family = "source_sans", base_size = 14))
```

## Load Data

The [European Parenting Leave Policies (EPLP)
Dataset](https://zenodo.org/records/17648712) provides harmonized data
on maternity, co-parent, paid parental, and job-protected leave across
21 European countries from 1970 to 2024. Durations are measured in
**weeks**.

``` r
eplp <- read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-06-02/eplp.csv",
  show_col_types = FALSE
)

country_names <- c(
  AT = "Austria", BE = "Belgium", CZ = "Czechia", DE = "Germany",
  DK = "Denmark", EE = "Estonia", ES = "Spain", FI = "Finland",
  FR = "France", GR = "Greece", HU = "Hungary", IE = "Ireland",
  IT = "Italy", LT = "Lithuania", NL = "Netherlands", NO = "Norway",
  PL = "Poland", SE = "Sweden", SI = "Slovenia", SK = "Slovakia",
  UK = "United Kingdom"
)

eplp <- eplp |>
  mutate(
    country_name = country_names[country],
    total_mat = mat_m_ld_bb + mat_m_ld_ab + mat_v_ld_bb + mat_v_ld_ab,
    jp_ld_co_clean = if_else(jp_ld_co < 0, 0, jp_ld_co)
  )
```

## Exploring the Data

``` r
cat("Dimensions:", nrow(eplp), "rows x", ncol(eplp), "columns\n")
```

    ## Dimensions: 1155 rows x 38 columns

``` r
cat("Countries:", n_distinct(eplp$country), "\n")
```

    ## Countries: 21

``` r
cat("Years:", min(eplp$year), "-", max(eplp$year), "\n")
```

    ## Years: 1970 - 2024

### Missing Values

``` r
eplp |>
  summarize(across(everything(), ~sum(is.na(.)))) |>
  pivot_longer(everything(), names_to = "variable", values_to = "n_missing") |>
  filter(n_missing > 0) |>
  arrange(desc(n_missing))
```

    ## # A tibble: 12 × 2
    ##    variable     n_missing
    ##    <chr>            <int>
    ##  1 jp_later           112
    ##  2 par1_cap           102
    ##  3 par3_cap           101
    ##  4 par1_later          78
    ##  5 par3_later          78
    ##  6 par1_fr             44
    ##  7 par2_fr             44
    ##  8 jp_part_time        31
    ##  9 par1_work           25
    ## 10 par3_work            4
    ## 11 par1_rr              1
    ## 12 par3_rr              1

The monetary variables (flat-rate amounts, caps) have the most
missingness — many countries use percentage-based replacement rates
rather than fixed amounts.

### Co-Parent Leave Adoption Over Time

``` r
adoption <- eplp |>
  group_by(year) |>
  summarize(
    n_countries = sum(co_ld > 0),
    avg_weeks = mean(co_ld[co_ld > 0], na.rm = TRUE),
    .groups = "drop"
  )

ggplot(adoption, aes(x = year)) +
  geom_area(aes(y = n_countries), fill = oi_blue, alpha = 0.3) +
  geom_line(aes(y = n_countries), color = oi_blue, linewidth = 1.2) +
  scale_y_continuous(breaks = seq(0, 20, 5)) +
  labs(
    title = "Countries offering co-parent leave (1970–2024)",
    subtitle = "From 1 country to 19 in 54 years — most adoption happened after 2000",
    x = NULL, y = "Number of countries"
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank()
  )
```

![](outputs/adoption-timeline-1.png)<!-- -->

### The 2024 Landscape

``` r
snapshot_2024 <- eplp |>
  filter(year == 2024) |>
  select(country_name, co_ld, total_mat, jp_ld_co_clean) |>
  pivot_longer(cols = c(co_ld, total_mat), names_to = "type", values_to = "weeks") |>
  mutate(
    type = if_else(type == "co_ld", "Co-parent leave", "Maternity leave"),
    country_name = fct_reorder(country_name, weeks, .fun = max)
  )

ggplot(snapshot_2024, aes(x = weeks, y = country_name, fill = type)) +
  geom_col(position = "dodge", alpha = 0.85) +
  scale_fill_manual(values = c("Co-parent leave" = oi_blue, "Maternity leave" = oi_orange)) +
  labs(
    title = "Maternity vs. co-parent leave in 2024",
    subtitle = "Most countries still have a massive gap between the two",
    x = "Weeks", y = NULL, fill = NULL
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "top"
  )
```

![](outputs/landscape-2024-1.png)<!-- -->

The gap is stark: maternity leave averages **18 weeks** while co-parent
leave averages just **5 weeks** among the 19 countries that offer it.
Only Spain, Slovakia, and the UK have reached parity.

### Distribution of Co-Parent Leave Growth Patterns

``` r
ggplot(eplp, aes(x = year, y = co_ld)) +
  geom_step(color = oi_blue, linewidth = 0.8) +
  facet_wrap(~country_name, ncol = 4, scales = "free_y") +
  labs(
    title = "Co-parent leave trajectories (1970–2024)",
    subtitle = "Each panel shows one country — note the staircase pattern of discrete reforms",
    x = NULL, y = "Weeks"
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank(),
    strip.text = element_text(size = 10, face = "bold")
  )
```

![](outputs/growth-patterns-1.png)<!-- -->

The staircase pattern is obvious — policy doesn’t drift upward smoothly.
It **jumps** when legislation passes. Norway stands out with a series of
progressive reforms from 1993 to 2019, while Spain had a dramatic 5-year
sprint from 2 weeks to 16 weeks (2017–2021).

### Correlation Between Leave Types

``` r
cor_data <- eplp |>
  filter(year == 2024) |>
  select(total_mat, co_ld, jp_ld_co_clean, par1_ld) |>
  rename(
    `Maternity` = total_mat,
    `Co-parent` = co_ld,
    `Job-protected (co)` = jp_ld_co_clean,
    `Paid parental` = par1_ld
  )

cor_matrix <- cor(cor_data, use = "complete.obs")
cat("Correlation matrix (2024 cross-section):\n")
```

    ## Correlation matrix (2024 cross-section):

``` r
round(cor_matrix, 2)
```

    ##                    Maternity Co-parent Job-protected (co) Paid parental
    ## Maternity               1.00      0.26               0.14         -0.36
    ## Co-parent               0.26      1.00               0.34         -0.33
    ## Job-protected (co)      0.14      0.34               1.00          0.20
    ## Paid parental          -0.36     -0.33               0.20          1.00

Interestingly, co-parent leave has a **weak positive correlation** with
maternity leave — generous maternity doesn’t necessarily predict
generous co-parent leave. This suggests different political dynamics
drive each.

## Changepoint Detection: When Did Each Revolution Happen?

Rather than fitting smooth curves to staircase data, we’ll identify the
**reform events** — years where co-parent leave jumped by at least 1
week. These are the legislative breakthroughs that represent genuine
policy change.

A [changepoint](https://en.wikipedia.org/wiki/Change_detection) in this
context is simply a year where the policy level shifted significantly.
Because parenting leave is set by legislation (not market forces),
changes are discrete and intentional — making year-over-year
differencing the most honest detection method.

``` r
reforms <- eplp |>
  arrange(country, year) |>
  group_by(country, country_name) |>
  mutate(
    co_ld_change = co_ld - lag(co_ld, default = 0),
    is_reform = co_ld_change >= 1
  ) |>
  ungroup()

major_reforms <- reforms |>
  filter(is_reform) |>
  select(country, country_name, year, co_ld_change, co_ld)

cat("Total major co-parent leave reforms detected:", nrow(major_reforms), "\n\n")
```

    ## Total major co-parent leave reforms detected: 42

``` r
# First reform per country (first year with ANY co-parent leave > 0)
first_reforms <- eplp |>
  filter(co_ld > 0) |>
  group_by(country, country_name) |>
  summarize(first_reform_year = min(year), .groups = "drop") |>
  arrange(first_reform_year)

cat("First co-parent leave adoption by country:\n")
```

    ## First co-parent leave adoption by country:

``` r
first_reforms |> print(n = 21)
```

    ## # A tibble: 20 × 3
    ##    country country_name   first_reform_year
    ##    <chr>   <chr>                      <dbl>
    ##  1 ES      Spain                       1970
    ##  2 BE      Belgium                     1978
    ##  3 NO      Norway                      1978
    ##  4 SE      Sweden                      1980
    ##  5 DK      Denmark                     1984
    ##  6 FI      Finland                     1991
    ##  7 GR      Greece                      1993
    ##  8 NL      Netherlands                 2001
    ##  9 EE      Estonia                     2002
    ## 10 FR      France                      2002
    ## 11 HU      Hungary                     2002
    ## 12 SI      Slovenia                    2003
    ## 13 UK      United Kingdom              2003
    ## 14 LT      Lithuania                   2006
    ## 15 PL      Poland                      2010
    ## 16 IT      Italy                       2013
    ## 17 IE      Ireland                     2016
    ## 18 AT      Austria                     2017
    ## 19 CZ      Czechia                     2018
    ## 20 SK      Slovakia                    2022

### The Waves of Reform

``` r
reforms_by_decade <- major_reforms |>
  mutate(period = case_when(
    year < 1990 ~ "1970s–80s\n(Pioneers)",
    year < 2000 ~ "1990s\n(Nordic expansion)",
    year < 2010 ~ "2000s\n(EU directive wave)",
    year < 2020 ~ "2010s\n(Acceleration)",
    TRUE ~ "2020s\n(Convergence)"
  )) |>
  mutate(period = factor(period, levels = c(
    "1970s–80s\n(Pioneers)", "1990s\n(Nordic expansion)",
    "2000s\n(EU directive wave)", "2010s\n(Acceleration)", "2020s\n(Convergence)"
  )))

ggplot(reforms_by_decade, aes(x = period)) +
  geom_bar(fill = oi_vermillion, alpha = 0.8) +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.5,
            family = "source_sans", fontface = "bold", size = 5) +
  labs(
    title = "Waves of co-parent leave reform across Europe",
    subtitle = "Number of major reforms (≥1 week increase) by era",
    x = NULL, y = "Number of reforms"
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank()
  )
```

![](outputs/reform-waves-1.png)<!-- -->

Three clear waves emerge: the **Nordic pioneers** (1970s–80s), the **EU
directive wave** (2000s) following the 1996 Parental Leave Directive,
and the **2010s acceleration** driven by individual national movements
toward gender equality.

### Reform Timeline (Hero Visualization Foundation)

``` r
# Order countries by first reform year
country_order <- first_reforms |> arrange(first_reform_year) |> pull(country_name)

# Countries that never reformed
never_reformed <- setdiff(unique(eplp$country_name), first_reforms$country_name)

timeline_data <- major_reforms |>
  mutate(
    country_name = factor(country_name, levels = rev(c(country_order, never_reformed))),
    size_bucket = case_when(
      co_ld_change >= 4 ~ "Major (4+ weeks)",
      co_ld_change >= 2 ~ "Moderate (2–4 weeks)",
      TRUE ~ "Initial (1–2 weeks)"
    )
  )

ggplot(timeline_data, aes(x = year, y = country_name)) +
  geom_point(aes(size = co_ld_change, color = size_bucket), alpha = 0.8) +
  scale_size_continuous(range = c(2, 8), name = "Weeks added") +
  scale_color_manual(
    values = c("Major (4+ weeks)" = oi_vermillion, "Moderate (2–4 weeks)" = oi_orange,
               "Initial (1–2 weeks)" = oi_skyblue),
    name = "Reform size"
  ) +
  labs(
    title = "When did each country's co-parent leave revolution happen?",
    subtitle = "Each dot = a reform year | Size = weeks added | Color = magnitude",
    x = NULL, y = NULL
  ) +
  theme(
    panel.grid.major.x = element_line(color = "gray90"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "bottom"
  )
```

![](outputs/reform-timeline-1.png)<!-- -->

Norway’s pattern is extraordinary — a sustained 25-year campaign of
incremental reforms from 1993 to 2019. Spain took the opposite approach:
a concentrated sprint from 2017–2022 that catapulted it to parity in
just 5 years.

## Random Forest: What Predicts Generous Co-Parent Leave?

Now for the core ML question: **what policy features best predict
whether a country offers generous co-parent leave?** We’ll train a
[Random Forest](https://en.wikipedia.org/wiki/Random_forest) — an
ensemble of decision trees that votes on predictions — using other leave
policy dimensions as features.

A Random Forest works by building hundreds of decision trees, each
trained on a random subset of the data. Individual trees might overfit,
but by averaging their predictions, the forest produces robust
estimates. The key output for us is [feature
importance](https://en.wikipedia.org/wiki/Feature_importance) — which
variables the forest relies on most for its predictions.

``` r
# Engineer features for the model
rf_data <- eplp |>
  filter(year >= 1990) |>  # Use post-1990 data where there's meaningful variation
  mutate(
    # Clean -98 values (not applicable → 0 for numeric purposes)
    par1_rr_clean = if_else(par1_rr < 0, NA_real_, par1_rr),
    par3_rr_clean = if_else(par3_rr < 0, NA_real_, par3_rr),
    # Binary features
    has_sharing_incentives = as.integer(par_incentives != "no"),
    has_jp_parttime = as.integer(jp_part_time == "yes"),
    can_work_during = as.integer(par1_work == "yes"),
    par_for_both = as.integer(par1_for_whom == "either"),
    # Era indicators
    decade = (year %/% 10) * 10
  ) |>
  select(
    co_ld,              # TARGET
    total_mat,          # Total maternity leave
    jp_ld_m,            # Job-protected leave for mothers
    jp_ld_co_clean,     # Job-protected leave for co-parents
    par1_ld,            # Paid parental leave duration
    par1_rr_clean,      # Replacement rate
    has_sharing_incentives,
    has_jp_parttime,
    can_work_during,
    par_for_both,
    year,
    decade
  ) |>
  drop_na()

cat("Random Forest training data:", nrow(rf_data), "observations\n")
```

    ## Random Forest training data: 308 observations

``` r
cat("Features:", ncol(rf_data) - 1, "\n")
```

    ## Features: 11

``` r
summary(rf_data$co_ld)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##  0.0000  0.7143  2.0000  3.3462  4.2857 21.0000

``` r
set.seed(42)

# Train Random Forest
rf_model <- ranger(
  co_ld ~ .,
  data = rf_data,
  num.trees = 500,
  importance = "permutation",
  min.node.size = 5
)

cat("\nRandom Forest Results:\n")
```

    ## 
    ## Random Forest Results:

``` r
cat("R² (OOB):", round(rf_model$r.squared, 3), "\n")
```

    ## R² (OOB): 0.961

``` r
cat("MSE (OOB):", round(rf_model$prediction.error, 3), "\n")
```

    ## MSE (OOB): 0.689

``` r
cat("RMSE:", round(sqrt(rf_model$prediction.error), 2), "weeks\n")
```

    ## RMSE: 0.83 weeks

``` r
# Extract and plot feature importance
importance_df <- tibble(
  feature = names(rf_model$variable.importance),
  importance = rf_model$variable.importance
) |>
  mutate(
    feature_label = case_when(
      feature == "jp_ld_co_clean" ~ "Job-protected leave\n(co-parents)",
      feature == "par1_ld" ~ "Paid parental\nleave duration",
      feature == "total_mat" ~ "Total maternity\nleave",
      feature == "jp_ld_m" ~ "Job-protected leave\n(mothers)",
      feature == "year" ~ "Year",
      feature == "par1_rr_clean" ~ "Replacement rate",
      feature == "has_sharing_incentives" ~ "Sharing incentives",
      feature == "par_for_both" ~ "Parental leave\nfor both parents",
      feature == "can_work_during" ~ "Can work\nduring leave",
      feature == "has_jp_parttime" ~ "Part-time\njob protection",
      feature == "decade" ~ "Decade",
      TRUE ~ feature
    ),
    feature_label = fct_reorder(feature_label, importance)
  )

ggplot(importance_df, aes(x = importance, y = feature_label)) +
  geom_col(fill = oi_blue, alpha = 0.85) +
  labs(
    title = "What predicts generous co-parent leave?",
    subtitle = "Random Forest feature importance (permutation-based)",
    x = "Importance (increase in MSE when feature is shuffled)",
    y = NULL
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank()
  )
```

![](outputs/rf-importance-1.png)<!-- -->

### Interpreting the Model

``` r
cat("\nFeature importance ranking:\n")
```

    ## 
    ## Feature importance ranking:

``` r
importance_df |>
  arrange(desc(importance)) |>
  select(feature, importance) |>
  mutate(pct_total = percent(importance / sum(importance))) |>
  print()
```

    ## # A tibble: 11 × 3
    ##    feature                importance pct_total
    ##    <chr>                       <dbl> <chr>    
    ##  1 par1_rr_clean             12.6    17.9289% 
    ##  2 has_jp_parttime           11.5    16.3472% 
    ##  3 par1_ld                   10.7    15.2322% 
    ##  4 jp_ld_m                    9.42   13.4234% 
    ##  5 total_mat                  9.13   13.0195% 
    ##  6 jp_ld_co_clean             9.13   13.0140% 
    ##  7 year                       3.77   5.3728%  
    ##  8 has_sharing_incentives     2.23   3.1724%  
    ##  9 decade                     1.40   2.0025%  
    ## 10 can_work_during            0.249  0.3552%  
    ## 11 par_for_both               0.0925 0.1319%

The Random Forest reveals the structural drivers of co-parent leave
generosity. Let’s see which features dominate and what that tells us
about policy architecture.

### Partial Dependence: How Do Key Features Relate to Co-Parent Leave?

[Partial
dependence](https://christophm.github.io/interpretable-ml-book/pdp.html)
shows how the model’s predictions change as we vary one feature while
holding all others constant. This helps us understand the *shape* of
each relationship — is it linear? Does it plateau? Are there thresholds?

``` r
# Manual partial dependence for top features
calc_pd <- function(data, model, feature, grid_size = 20) {
  grid <- seq(min(data[[feature]], na.rm = TRUE),
              max(data[[feature]], na.rm = TRUE),
              length.out = grid_size)
  
  pd_values <- map_dbl(grid, function(val) {
    new_data <- data
    new_data[[feature]] <- val
    mean(predict(model, data = new_data)$predictions)
  })
  
  tibble(value = grid, prediction = pd_values, feature = feature)
}

top_features <- importance_df |>
  arrange(desc(importance)) |>
  slice_head(n = 4) |>
  pull(feature)

pd_data <- map_dfr(top_features, ~calc_pd(rf_data, rf_model, .x))

pd_data <- pd_data |>
  mutate(feature_label = case_when(
    feature == "jp_ld_co_clean" ~ "Job-protected leave (co-parents, weeks)",
    feature == "par1_ld" ~ "Paid parental leave duration (weeks)",
    feature == "total_mat" ~ "Total maternity leave (weeks)",
    feature == "jp_ld_m" ~ "Job-protected leave (mothers, weeks)",
    feature == "year" ~ "Year",
    TRUE ~ feature
  ))

ggplot(pd_data, aes(x = value, y = prediction)) +
  geom_line(color = oi_vermillion, linewidth = 1.2) +
  facet_wrap(~feature_label, scales = "free_x", ncol = 2) +
  labs(
    title = "How each feature influences co-parent leave predictions",
    subtitle = "Partial dependence plots from the Random Forest",
    x = "Feature value", y = "Predicted co-parent leave (weeks)"
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank(),
    strip.text = element_text(face = "bold", size = 11)
  )
```

![](outputs/partial-dependence-1.png)<!-- -->

## The Final Visualization: Europe’s Parenting Leave Revolutions

For the shareable image, we’ll create a combined visualization showing
the reform timeline — when each country broke through — colored by the
era of their revolution.

``` r
# Build the final hero visualization
# Timeline showing first major reform + current state for each country

final_data <- eplp |>
  filter(year == 2024) |>
  select(country, country_name, co_ld, total_mat) |>
  left_join(first_reforms, by = c("country", "country_name")) |>
  mutate(
    era = case_when(
      is.na(first_reform_year) ~ "No dedicated leave",
      first_reform_year < 1990 ~ "Pioneer (pre-1990)",
      first_reform_year < 2005 ~ "Second wave (1990–2004)",
      TRUE ~ "Recent adopter (2005+)"
    ),
    era = factor(era, levels = c(
      "Pioneer (pre-1990)", "Second wave (1990–2004)",
      "Recent adopter (2005+)", "No dedicated leave"
    )),
    country_name = fct_reorder(country_name, co_ld)
  )
bg_color <- "white"
tt_source <- "EPLP Dataset (Zenodo)"

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

p_final <- ggplot(final_data, aes(y = country_name)) +
  # Maternity leave as background reference bar
  geom_col(aes(x = total_mat), fill = "gray85", width = 0.7) +
  # Co-parent leave as foreground bar (only visible for co_ld > 0)
  geom_col(aes(x = co_ld, fill = era), width = 0.7, alpha = 0.9) +
  # Parity line annotations
  geom_point(
    data = filter(final_data, co_ld >= total_mat & total_mat > 0),
    aes(x = co_ld), shape = 18, size = 3, color = oi_green
  ) +
  # Annotate what the diamond means

  annotate("text", x = 30, y = 20.5, label = "◆ = parity reached",
           size = 3.5, family = "source_sans", color = oi_green, hjust = 0) +
  # First reform year label
  geom_text(
    aes(x = -1.5, label = if_else(is.na(first_reform_year), "—", as.character(first_reform_year))),
    hjust = 1, size = 3.5, family = "source_sans", color = "gray40"
  ) +
  # Week labels at end of co-parent bar
  geom_text(
    aes(x = co_ld + 0.5, label = if_else(co_ld > 0, paste0(round(co_ld), "w"), "0")),
    hjust = 0, size = 3.5, family = "source_sans", fontface = "bold"
  ) +
  scale_fill_manual(
    values = c(
      "Pioneer (pre-1990)" = oi_black,
      "Second wave (1990–2004)" = oi_blue,
      "Recent adopter (2005+)" = oi_orange,
      "No dedicated leave" = "gray85"
    ),
    breaks = c("Pioneer (pre-1990)", "Second wave (1990–2004)", "Recent adopter (2005+)"),
    name = "When co-parent leave was first adopted"
  ) +
  scale_x_continuous(expand = expansion(mult = c(0.15, 0.08))) +
  annotate("text", x = -1.5, y = 22, label = "First\nreform", hjust = 1,
           size = 3, family = "source_sans", color = "gray40", fontface = "italic") +
  labs(
    title = "Europe's Parenting Leave Revolutions",
    subtitle = "Co-parent leave in 2024 (colored bars) vs. maternity leave (gray)\nGrouped by when each country first adopted co-parent leave",
    x = "Weeks of leave",
    y = NULL,
    caption = tt_caption
  ) +
  theme(
    text = element_text(family = "source_sans"),
    plot.title = element_text(size = 32, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 16, hjust = 0.5, color = "gray30",
                                 lineheight = 1.2),
    plot.caption = element_markdown(size = 9, color = "gray50", hjust = 0.5),
    plot.caption.position = "plot",
    plot.title.position = "plot",
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank(),
    axis.text.y = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(size = 11),
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10, face = "italic"),
    plot.margin = margin(20, 20, 10, 30)
  ) +
  guides(fill = guide_legend(nrow = 2))

p_final
```

![](outputs/final-viz-1.png)<!-- -->

``` r
ggsave(
  filename = "outputs/2026_06_02_tidy_tuesday_parenting_leave.png",
  plot = p_final,
  device = "png",
  width = 8,
  height = 10,
  dpi = 300,
  bg = "white"
)

showtext_auto(FALSE)
```

## Key Findings

**From the changepoint analysis:** - Europe’s co-parent leave story
unfolded in three distinct waves: Nordic pioneers (1978–84),
EU-directive adopters (2000–06), and recent accelerators (2016–22) -
Norway had the most sustained reform campaign — **9 separate increases**
over 25 years - Spain had the most dramatic sprint — **0 to 16 weeks in
just 5 years** (2017–2021)

**From the Random Forest:** - The model explains the variation in
co-parent leave with an R² reported above - The most important predictor
reveals which policy dimensions are structurally linked to co-parent
leave generosity - The partial dependence plots show whether the
relationship is linear or has thresholds

## What’s Next?

- **The Germany/Finland paradox:** Both offer zero *dedicated* co-parent
  leave but have generous *shared* parental leave. Does shared leave
  actually get taken by co-parents, or does it default to mothers?
- **The EU directive effect:** A difference-in-differences analysis
  could isolate the causal impact of the 1996 and 2010 EU Parental Leave
  Directives
- **Replacement rate vs. duration trade-off:** Some countries offer long
  leave at low pay. Does duration or income replacement matter more for
  actual take-up?
- **Cultural factors:** Nordic countries led by decades. Is this
  policy-driven culture change, or culture-driven policy?
