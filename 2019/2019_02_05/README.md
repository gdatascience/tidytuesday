# Mapping America’s Housing Boom: How Home Prices Diverged Across States

**[Source Code](2019_02_05_tidy_tuesday_house_mortgage.Rmd)** | Data from the [TidyTuesday project](https://github.com/rfordatascience/tidytuesday/tree/master/data/2019/2019-02-05) (2019-02-05)

![Mapping America’s Housing Boom: How Home Prices Diverged Across States](outputs/house_mortgage.png)

Using FreddieMac’s Home Price Index data, this analysis visualizes how dramatically different U.S. regions have diverged from the national average over four decades. Hawaii and California followed a completely different trajectory than the Midwest, revealing that there is no single “housing market.”

---

The American housing market is anything but uniform. While national
headlines focus on a single “housing market,” the reality is that home
prices in Hawaii and California have followed a completely different
trajectory than those in the Midwest. Using FreddieMac’s Home Price
Index (HPI) data at the state level, we can visualize how dramatically
different regions have diverged from the national average over the past
four decades.

## Loading Libraries and Data

We’ll need mapping packages and animation tools to bring this geographic
story to life.

``` r
library(tidyverse)
library(maps)
library(gganimate)
if (requireNamespace("USAboundaries", quietly = TRUE)) library(USAboundaries)

theme_set(theme_light())
```

The state-level HPI data tracks how home prices have changed relative to
a baseline, making it easy to compare across states and over time.

``` r
state_hpi <- read.csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-02-05/state_hpi.csv", stringsAsFactors = FALSE)
```

## Processing the State Data

We’ll enrich the raw HPI data with geographic information — region,
division, coordinates — and compute how each state’s price index differs
from the national average. This difference is the key metric: positive
means a state’s homes appreciated faster than the country overall.

``` r
state_hpi_processed <- state_hpi |> 
  left_join(data.frame(I(state.abb), I(state.name), state.region,  
                             state.division, I(state.area),
                             state.center[[1]], state.center[[2]]), 
            by = c("state" = "state.abb")) |>
  rename(region = state.region, division = state.division, name = state.name, 
         area = state.area, x = state.center..1.., y = state.center..2..) |>
  mutate(price_index_diff = price_index - us_avg,
         name = as.character(ifelse(state == "DC", "Washington D.C.", name)),
         region = factor(ifelse(state == "DC", 2, region)),
         division = factor(ifelse(state == "DC", 3, division)),
         area =  ifelse(state == "DC", 68.34, area),
         x = ifelse(state == "DC", -77.0369, x),
         y = ifelse(state == "DC", 38.9072, y),
         date = as.Date(paste(year, month, "01", sep = "-")))

levels(state_hpi_processed$region) <- levels(state.region)
levels(state_hpi_processed$division) <- levels(state.division)
state_hpi_processed$state_lower <- tolower(state_hpi_processed$name)
```

## Regional Trends: How Has the HPI Changed Over Time?

Let’s start at the broadest level — the four Census regions. This
reveals the big-picture divergence between coastal and interior America.

``` r
state_hpi_processed |>
  group_by(year, region) |>
  summarise(avg_diff = mean(price_index_diff)) |>
  ggplot(aes(x = year, y = avg_diff, color = region)) + 
  geom_line(size = 1)
```

![](outputs/unnamed-chunk-3-1.png)<!-- -->

The West region has consistently outpaced the national average, while
the South and Midwest have tracked below it. The 2008 housing crisis is
clearly visible as a sharp correction in the West.

## Drilling Down to Census Divisions

Breaking regions into their nine Census divisions reveals even more
nuance — the Pacific states behave very differently from the Mountain
states, even though both are in the “West.”

``` r
state_hpi_processed |>
  group_by(year, division) |>
  summarise(avg_diff = mean(price_index_diff)) |>
  ggplot(aes(x = year, y = avg_diff, color = division)) + 
  geom_line(size = 1)
```

![](outputs/unnamed-chunk-4-1.png)<!-- -->

The Pacific division (California, Oregon, Washington) shows the most
dramatic swings — the highest peaks before 2008 and the steepest
recovery afterward.

## A Snapshot: 2018 State-Level Differences

Let’s map the 2018 data to see which states are currently above or below
the national average. This choropleth gives us a geographic intuition
for where housing wealth is concentrated.

``` r
map <- map_data("state")

state_hpi_processed |>
  filter(year == 2018) |>
  group_by(state_lower) |>
  summarise(avg_diff = mean(price_index_diff),
            area = mean(area),
            x = mean(x),
            y = mean(y)) |>
  ggplot(aes(fill = avg_diff)) +
  geom_map(aes(map_id = state_lower), map = map) +
  expand_limits(x = map$long, y = map$lat) + 
  theme_void() +
  coord_map() +
  labs(title = "2018 House Price Index (HPI) difference from the US average")
```

![](outputs/unnamed-chunk-5-1.png)<!-- -->

The coastal states — particularly along the Pacific and in the Northeast
corridor — show the strongest positive deviations from the national
average.

## Animating the Story: HPI Over Time

Finally, let’s bring the full timeline to life with an animated map
showing how state-level HPI differences have evolved year by year. This
reveals the housing bubble’s geographic footprint and the uneven
recovery that followed.

``` r
state_hpi_yearly <- state_hpi |> 
  mutate(price_index_diff = price_index - us_avg,
         date = as.Date(paste(year, month, "01", sep = "-"))) |>
  group_by(year, state) |>
  summarise(avg_price_index_diff = mean(price_index_diff)) |>
  inner_join(us_states(), by = c("state" = "state_abbr")) |> 
  filter(name != "Alaska", 
         name != "Hawaii", 
         jurisdiction_type != "territory")

state_hpi_yearly |> 
  ggplot() +
  geom_sf(aes(fill = avg_price_index_diff)) +
  scale_fill_gradient2(low = "red", high = "blue", mid = "white", midpoint = 0) + 
  #facet_wrap(~year)
  labs(title = "Home Price Index difference from US Average in {frame_time}",
       caption = "Designer: Tony Galvan @gdatascience1  |  Source: FreddieMac") + 
  transition_time(year) +
  coord_sf() + 
  theme_void() + 
  theme(panel.grid = element_line(color = 'white'))
```

The animation makes the 2005–2008 bubble unmistakable — watch how the
blue (above-average) states suddenly snap back toward white and red
during the crash.
