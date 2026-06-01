# The Truth Is Out There: Analyzing 80,000 UFO Sighting Reports

**[Source Code](2019_06_25_tidy_tuesday_ufo_sightings.Rmd)** | Data from the [TidyTuesday project](https://github.com/rfordatascience/tidytuesday/tree/master/data/2019/2019-06-25) (2019-06-25)

![The Truth Is Out There: Analyzing 80,000 UFO Sighting Reports](outputs/ufo_sightings.png)

The National UFO Reporting Center has collected over 80,000 sighting reports from around the world. This analysis explores what shapes people see, how they describe their encounters, and the fascinating patterns in human perception and reporting behavior.

---

The National UFO Reporting Center (NUFORC) has collected over 80,000
sighting reports from around the world. Whether you’re a believer or a
skeptic, the data itself tells a fascinating story about human
perception, reporting patterns, and the language people use to describe
the unexplained. Let’s explore what shapes people see, how they describe
their experiences, and whether sentiment varies by location.

## Loading and Preparing the Data

We’ll parse dates and create an ID column for joining with sentiment
analysis results later.

``` r
library(tidyverse)
library(lubridate)
library(tidytext)
library(sentimentr)
theme_set(theme_light())

ufo_sightings <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-06-25/ufo_sightings.csv") |>
  rownames_to_column(var = "id") |>
  mutate(id = as.numeric(id),
         date = mdy(date_documented),
         year = year(date))
```

## Date Range

``` r
summary(ufo_sightings$date)
```

    ##         Min.      1st Qu.       Median         Mean      3rd Qu.         Max. 
    ## "1998-03-07" "2003-11-26" "2007-11-28" "2007-07-28" "2011-10-10" "2014-05-08"

## What Shapes Do People Report?

The shape of a UFO is one of the most distinctive features witnesses
describe. Let’s see which shapes dominate the reports.

``` r
ufo_sightings |>
  mutate(ufo_shape = if_else(is.na(ufo_shape), "unknown", ufo_shape),
         ufo_shape = fct_lump(ufo_shape, 10, other_level = "other")) |>
  group_by(ufo_shape) |>
  summarise(n = n()) |>
  mutate(ufo_shape = fct_reorder(ufo_shape, n)) |>
  ggplot(aes(ufo_shape, n, fill = ufo_shape)) +
  geom_col(show.legend = FALSE) + 
  coord_flip() + 
  labs(x = "UFO shape",
       y = "# of sightings",
       title = "Top 10 UFO Shapes",
       caption = "Designer: Tony Galvan @gdatascience1  |  Source: NUFORC")
```

![](outputs/unnamed-chunk-3-1.png)<!-- -->

“Light” is the most commonly reported shape — which makes sense, as most
sightings occur at night when witnesses can see illumination but not
detailed structure. The classic “disk” shape ranks surprisingly low
compared to more ambiguous descriptions.

## Word Cloud from Sighting Descriptions

What words do witnesses use most frequently when describing their
encounters? Let’s mine the description text for common terms.

``` r
ufo_sightings |>
  unnest_tokens(tbl = ., output = word, input = description) |>
  count(word, sort = TRUE) |>
  filter(is.na(as.numeric(word))) |>
  anti_join(get_stopwords()) |>
  filter(n > 2000) |>
  na.omit() |>
  wordcloud2::wordcloud2(shape = "cardiod")
```

## Sentiment Analysis: How Do People Feel About Their Sightings?

Are UFO reports written with fear, excitement, or neutral observation?
Let’s apply sentiment analysis to the descriptions and see if the
emotional tone varies by country.

``` r
ufo_sentences <- ufo_sightings |>
  pull(description) |>
  get_sentences()
```

``` r
ufo_sentiment <- sentiment_by(ufo_sentences)
```

## Sentiment by Country

``` r
ufo_sightings |>
  inner_join(ufo_sentiment, by = c("id" = "element_id")) |>
  group_by(country) |>
  summarise(avg_sentiment = mean(ave_sentiment)) |>
  mutate(country = fct_reorder(country, avg_sentiment)) |>
  ggplot(aes(country, avg_sentiment, fill = country)) +
  geom_col(show.legend = FALSE) +
  coord_flip()
```

![](outputs/unnamed-chunk-7-1.png)<!-- -->

All countries show slightly positive average sentiment — people tend to
describe their sightings with more wonder than fear.

## Sentiment by US State

Within the United States, does sentiment vary by state? Perhaps cultural
differences or local attitudes toward the unexplained influence how
people write their reports.

``` r
ufo_sightings |>
  inner_join(ufo_sentiment, by = c("id" = "element_id")) |>
  filter(country == "us") |>
  group_by(state) |>
  summarise(avg_sentiment = mean(ave_sentiment)) |>
  mutate(state = fct_reorder(state, avg_sentiment)) |>
  ggplot(aes(state, avg_sentiment, fill = state)) +
  geom_col(show.legend = FALSE) +
  coord_flip()
```

![](outputs/unnamed-chunk-8-1.png)<!-- -->

## Animated Map: US Sightings Over Time

Finally, let’s visualize how UFO sightings have spread across the United
States over time. The animation reveals the dramatic increase in
reporting that coincides with the internet age.

``` r
ufo_sightings |>
  filter(country == "us" & state != "hi" & state != "ak" & state != "pr") |>
  ggplot() + 
  geom_map(data = map_data("state"), 
           map = map_data("state"), 
           aes(long, lat, map_id = region, group = group),
           fill = "white", color = "black", size = 0.1) + 
  geom_point(aes(longitude, latitude), 
             size = 0.75, alpha = 0.25, color = "blue") +
  theme_void() + 
  coord_map() +
  gganimate::transition_states(year) +
  #facet_wrap(~year) + 
  labs(title = "US UFO Sightings in {closest_state}",
       caption = "Designer: Tony Galvan @gdatascience1  |  Source: NUFORC")
```

![](outputs/unnamed-chunk-9-1.gif)<!-- -->

The explosion of sightings in the 1990s and 2000s likely reflects the
rise of online reporting platforms rather than an actual increase in
unexplained aerial phenomena. The internet made it easy for anyone to
file a report, dramatically lowering the barrier to participation.
