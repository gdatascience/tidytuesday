# Bridges Across Borders: The Hidden Diplomacy of Sister Cities

**[Source Code](2026_05_12_tidy_tuesday_twinned_cities.Rmd)** | Data from the [TidyTuesday project](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-05-12) (Week 19, 2026-05-12)

![Sister city links reveal hidden diplomatic blocs shaped by colonial history, Cold War alliances, and linguistic kinship](outputs/2026_05_12_tidy_tuesday_twinned_cities.png)

10,596 twin city links connect 5,470 cities across 191 countries. Using Louvain community detection on the country-level network, the algorithm independently rediscovered colonial ties, Cold War alliances, and post-WWII reconciliation blocs -- all encoded in which cities chose to become siblings.

---

Sister cities — also called twin towns — are one of the quietest forms
of international diplomacy. Two cities in different countries agree to a
cultural and commercial partnership, and over decades these links
accumulate into a sprawling global network. This week’s TidyTuesday
dataset maps **10,596 twin city links** connecting **5,470 cities**
across **191 countries**.

What happens when you treat this as a network and ask: *who clusters
with whom?* The answer reveals the fingerprints of history — colonial
ties, Cold War alliances, and linguistic kinship — all encoded in which
cities chose to become siblings.

## Libraries

``` r
library(tidyverse)
library(scales)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(geosphere)
library(igraph)
library(showtext)
library(ggtext)

# Fonts
font_add_google("Source Sans 3", "source_sans")
font_add(family = "fa-brands",
         regular = "~/Library/Fonts/Font Awesome 6 Brands-Regular-400.otf")
font_add(family = "fa-solid",
         regular = "~/Library/Fonts/Font Awesome 6 Free-Solid-900.otf")
showtext_auto()
showtext_opts(dpi = 300)

theme_set(theme_light(base_family = "source_sans"))
```

## Load Data

``` r
cities <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-05-12/cities.csv')
links <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-05-12/links.csv')
```

## A First Look at the Data

Let’s peek at what we’re working with. The `cities` table has one row
per city with its geographic coordinates and country:

``` r
glimpse(cities)
```

    ## Rows: 5,470
    ## Columns: 7
    ## $ id        <chr> "Q734532", "Q838366", "Q747362", "Q836836", "Q823988", "Q820…
    ## $ name      <chr> "Fukaya", "Ishigaki", "Tsuru", "Koga", "Kakegawa", "Konan", …
    ## $ lng       <dbl> 139.2815, 124.1852, 138.9054, 139.7554, 137.9984, 136.8707, …
    ## $ lat       <dbl> 36.19747, 24.34450, 35.55153, 36.17825, 34.76875, 35.33208, …
    ## $ country   <chr> "Japan", "Japan", "Japan", "Japan", "Japan", "Japan", "Japan…
    ## $ countrycd <chr> "JP", "JP", "JP", "JP", "JP", "JP", "JP", "JP", "JP", "JP", …
    ## $ continent <chr> "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asi…

And the `links` table is a simple edge list — each row is a twinning
agreement between two cities, identified by their Wikidata IDs:

``` r
glimpse(links)
```

    ## Rows: 10,596
    ## Columns: 2
    ## $ source <chr> "Q734532", "Q838366", "Q747362", "Q836836", "Q823988", "Q820496…
    ## $ target <chr> "Q873835", "Q242783", "Q271917", "Q385684", "Q386052", "Q386661…

Here’s a sample of what the cities look like:

``` r
cities |>
  select(name, country, continent, lng, lat) |>
  slice_sample(n = 10) |>
  knitr::kable()
```

| name            | country                  | continent     |         lng |      lat |
|:----------------|:-------------------------|:--------------|------------:|---------:|
| Mělník          | Czechia                  | Europe        |   14.474194 | 50.35057 |
| Spremberg       | Germany                  | Europe        |   14.379444 | 51.57167 |
| Burglengenfeld  | Germany                  | Europe        |   12.040900 | 49.20610 |
| Navi Mumbai     | India                    | Asia          |   73.010000 | 19.03000 |
| Baunatal        | Germany                  | Europe        |    9.418333 | 51.25889 |
| Pleasant Hill   | United States of America | North America | -122.052500 | 37.94806 |
| Hama            | Syria                    | Asia          |   36.750000 | 35.13500 |
| Ventspils       | Latvia                   | Europe        |   21.564444 | 57.38972 |
| Borsec          | Romania                  | Europe        |   25.570000 | 46.96667 |
| Hajdúböszörmény | Hungary                  | Europe        |   21.516667 | 47.66667 |

We have **5,470 cities** across **191 countries** and **6 continents**,
connected by **10,596 twin city links**.

## The Global Landscape

``` r
# Top countries by number of cities in the network
cities |>
  count(country, sort = TRUE) |>
  head(15) |>
  ggplot(aes(x = n, y = reorder(country, n))) +
  geom_col(fill = "#2E86AB") +
  labs(
    title = "Germany Dominates the Twin City Network",
    subtitle = "Countries with the most cities participating in twinning agreements",
    x = "Number of cities", y = NULL
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank()
  )
```

![](outputs/eda-countries-1.png)

**Germany has 1,086 cities** in the network — nearly twice as many as
the United States (603). This reflects Germany’s strong tradition of
*Städtepartnerschaften* (city partnerships), many forged after WWII as
tools of reconciliation with Poland, France, and Israel.

## How Connected Are Cities?

Not all cities are equally social. Let’s look at the degree distribution
— how many twin links each city has:

``` r
degree_df <- bind_rows(
  links |> select(city = source),
  links |> select(city = target)
) |>
  count(city, name = "degree") |>
  left_join(cities |> select(id, name, country, continent), by = c("city" = "id"))

degree_df |>
  ggplot(aes(x = degree)) +
  geom_histogram(binwidth = 1, fill = "#2E86AB", color = "white", linewidth = 0.2) +
  scale_x_continuous(breaks = seq(0, 100, 10)) +
  labs(
    title = "Most Cities Have Just 1–3 Twin Links",
    subtitle = "But a few global hubs have 50+ connections",
    x = "Number of twin city links", y = "Number of cities"
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank()
  )
```

![](outputs/eda-degree-1.png)

The median city has just **2 twin links**, but the distribution has a
long tail. The most connected cities are global capitals and cultural
hubs:

``` r
degree_df |>
  slice_max(degree, n = 15) |>
  ggplot(aes(x = degree, y = reorder(paste0(name, " (", country, ")"), degree))) +
  geom_col(fill = "#E69F00") +
  labs(
    title = "Saint Petersburg: The World's Most Twinned City",
    subtitle = "Top 15 cities by number of sister city connections",
    x = "Number of twin city links", y = NULL
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank()
  )
```

![](outputs/eda-top-cities-1.png)

**Saint Petersburg** leads with **96 twin city links**, followed closely
by **Rio de Janeiro** (94). These are cities with outsized diplomatic
ambitions — they’ve built relationships across every continent.

## Continental Connections

Are sister cities mostly local (same continent) or do they bridge
oceans?

``` r
links_enriched <- links |>
  left_join(cities |> select(id, country_s = country, continent_s = continent,
                             lng_s = lng, lat_s = lat), 
            by = c("source" = "id")) |>
  left_join(cities |> select(id, country_t = country, continent_t = continent,
                             lng_t = lng, lat_t = lat), 
            by = c("target" = "id"))

cross_continent <- links_enriched |>
  mutate(type = if_else(continent_s == continent_t, "Same continent", "Cross-continent")) |>
  count(type) |>
  mutate(pct = n / sum(n))

cross_continent |>
  ggplot(aes(x = pct, y = reorder(type, pct), fill = type)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(round(pct * 100, 1), "%")), 
            hjust = -0.1, size = 5, family = "source_sans") +
  scale_x_continuous(labels = percent, limits = c(0, 0.7)) +
  scale_fill_manual(values = c("Cross-continent" = "#009E73", "Same continent" = "#0072B2")) +
  labs(
    title = "45% of Twin City Links Cross Continents",
    subtitle = "Sister cities are truly global bridges, not just regional neighbors",
    x = NULL, y = NULL
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank()
  )
```

![](outputs/eda-cross-continent-1.png)

Nearly **half of all twin city links (45%)** cross continental
boundaries. These aren’t just neighboring towns shaking hands — they’re
genuine bridges across oceans.

## Who Twins With Whom?

``` r
# Top international country pairs
top_pairs <- links_enriched |>
  filter(country_s != country_t) |>
  mutate(
    c1 = pmin(country_s, country_t),
    c2 = pmax(country_s, country_t)
  ) |>
  count(c1, c2, sort = TRUE, name = "n_links") |>
  head(15) |>
  mutate(pair = paste(c1, "–", c2))

top_pairs |>
  ggplot(aes(x = n_links, y = reorder(pair, n_links))) +
  geom_col(fill = "#A23B72") +
  labs(
    title = "Germany–Poland: The Strongest Twin City Bond",
    subtitle = "Top 15 country pairs by number of sister city links",
    x = "Number of twin city links", y = NULL
  ) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_blank()
  )
```

![](outputs/country-pairs-1.png)

The **Germany–Poland** corridor has **344 twin city links** — more than
any other international pair. This is the legacy of post-WWII
reconciliation, where hundreds of German and Polish cities formalized
partnerships to rebuild trust across a border that had been a site of
immense suffering.

**Japan–USA** (213 links) is the second strongest, reflecting decades of
post-war alliance and cultural exchange. **Mexico–USA** (150) shows the
deep ties along the world’s most-crossed border.

## Community Detection: Finding the Blocs

Here’s where it gets interesting. If we build a network where countries
are nodes and twin city links are weighted edges, we can use the
**Louvain algorithm** to detect communities.

### What is the Louvain Algorithm?

The [Louvain method](https://en.wikipedia.org/wiki/Louvain_method) is a
greedy optimization algorithm for community detection in networks. It
works in two phases:

1.  **Local optimization:** Each node starts in its own community. The
    algorithm iterates through every node and moves it to the
    neighboring community that produces the largest increase in
    **modularity** (or leaves it in place if no move improves
    modularity).
2.  **Aggregation:** Once no single move improves modularity, the
    algorithm builds a new network where each community becomes a single
    node, and repeats phase 1 on this coarser network.

This repeats until modularity can’t be improved further. It’s fast (runs
in near-linear time) and produces high-quality partitions, which is why
it’s one of the most popular community detection methods.

### What is Modularity?

**Modularity** (Q) measures how much more densely connected the nodes
within communities are compared to what you’d expect by random chance.
It ranges from -0.5 to 1.0:

- **Q ≈ 0** means the network’s community structure is no better than
  random
- **Q \> 0.3** is generally considered strong community structure
- **Q = 1** would mean perfectly separated communities with no
  cross-community edges

Our modularity of **0.276** is meaningful — it says these 5 clusters
capture real structure in the data, though there are still plenty of
cross-cluster links (which makes sense — diplomacy doesn’t respect neat
boundaries).

``` r
# Build country-level network
country_edges <- links_enriched |>
  filter(country_s != country_t) |>
  mutate(c1 = pmin(country_s, country_t), c2 = pmax(country_s, country_t)) |>
  count(c1, c2, name = "weight")

g <- graph_from_data_frame(country_edges, directed = FALSE)
E(g)$weight <- country_edges$weight

# Louvain community detection
set.seed(42)
comm <- cluster_louvain(g, weights = E(g)$weight)

membership_df <- tibble(
  country = V(g)$name,
  community = membership(comm)
)

cat("Communities found:", max(membership_df$community), "\n")
```

    ## Communities found: 5

``` r
cat("Modularity:", round(modularity(comm), 3), "\n")
```

    ## Modularity: 0.276

### How I Labeled the Communities

The algorithm assigns numeric IDs (1–5) to each community — it doesn’t
know what they “mean.” I labeled them by examining which countries ended
up together and identifying the common thread:

``` r
# Label communities based on their composition
community_labels <- c(
  "1" = "Russia & Eastern Mediterranean",
  "2" = "Francophone World",
  "3" = "Anglophone & Pacific Rim",
  "4" = "Latin America & Iberian",
  "5" = "Central & Northern Europe"
)

membership_df <- membership_df |>
  mutate(community_label = community_labels[as.character(community)])

# Show the full membership for each community
membership_df |>
  group_by(community_label) |>
  summarise(
    n_countries = n(),
    sample_countries = paste(head(sort(country), 8), collapse = ", ")
  ) |>
  arrange(desc(n_countries)) |>
  knitr::kable(col.names = c("Community", "Countries", "Sample Members"))
```

| Community | Countries | Sample Members |
|:---|---:|:---|
| Anglophone & Pacific Rim | 59 | Andorra, Australia, Bahamas, Barbados, Belize, Botswana, Brunei, Burundi |
| Russia & Eastern Mediterranean | 49 | Afghanistan, Albania, Armenia, Azerbaijan, Bahrain, Bangladesh, Belarus, Bosnia and Herz. |
| Latin America & Iberian | 35 | Angola, Argentina, Bolivia, Brazil, Cabo Verde, Chile, Colombia, Costa Rica |
| Central & Northern Europe | 26 | Austria, Belgium, Curaçao, Czechia, Denmark, Estonia, Finland, Georgia |
| Francophone World | 22 | Algeria, Antigua and Barb., Benin, Burkina Faso, Cameroon, Chad, Congo, Côte d’Ivoire |

The labels come from recognizing patterns:

- **Community 5** contains Germany, Poland, UK, Nordics, Israel,
  Hungary, Czechia — all countries with dense post-WWII reconciliation
  twinning. I called it “Central & Northern Europe.”
- **Community 2** contains France, Algeria, Morocco, Senegal, Cameroon,
  Tunisia — France and its former colonies. “Francophone World.”
- **Community 1** contains Russia, Turkey, Iran, Iraq, the Gulf states,
  Central Asia — Soviet-era and Middle Eastern ties. “Russia & Eastern
  Mediterranean.”
- **Community 3** contains USA, Japan, China, Canada, Australia,
  Philippines, Mexico — the Pacific Rim trading partners. “Anglophone &
  Pacific Rim.”
- **Community 4** contains Spain, Portugal, Brazil, Argentina, Colombia,
  Chile — the Iberian colonial legacy. “Latin America & Iberian.”

These clusters are **not geographic** — they’re **historical and
linguistic**. The algorithm independently rediscovered:

- **Colonial ties** (France clusters with West Africa; Spain/Portugal
  with Latin America)
- **Cold War alliances** (Russia clusters with the Middle East and
  Central Asia)
- **Post-WWII reconciliation** (Germany, Poland, Israel, and the Nordics
  form a tight bloc)
- **Anglophone networks** (US, UK… wait, UK is in the European bloc — it
  twins more with Germany and Scandinavia than with its former colonies)

## The World Map: Arcs of Connection

Now let’s visualize the strongest connections on a world map, colored by
which community cluster they belong to. We’ll use country centroids as
arc endpoints to keep the map readable.

``` r
# For the map, use the top connections (weight >= 5 links between countries)
strong_edges <- country_edges |> filter(weight >= 5)

# Get country centroids for arc endpoints
world <- ne_countries(scale = "medium", returnclass = "sf")

country_centroids <- world |>

  st_centroid() |>
  st_coordinates() |>
  as_tibble() |>
  bind_cols(world |> st_drop_geometry() |> select(name)) |>
  rename(lng = X, lat = Y, country = name)

# Join centroids to edges
arcs <- strong_edges |>
  left_join(country_centroids |> rename(lng_s = lng, lat_s = lat), 
            by = c("c1" = "country")) |>
  left_join(country_centroids |> rename(lng_t = lng, lat_t = lat), 
            by = c("c2" = "country")) |>
  filter(!is.na(lng_s) & !is.na(lng_t))

# Assign community color based on the source country
arcs <- arcs |>
  left_join(membership_df |> select(country, community, community_label), 
            by = c("c1" = "country"))

cat("Arcs with coordinates:", nrow(arcs), "of", nrow(strong_edges), "strong edges\n")
```

    ## Arcs with coordinates: 409 of 409 strong edges

``` r
# Community colors - distinct, colorblind-friendly
community_colors <- c(
  "Russia & Eastern Mediterranean" = "#E69F00",
  "Francophone World" = "#56B4E9",
  "Anglophone & Pacific Rim" = "#009E73",
  "Latin America & Iberian" = "#CC79A7",
  "Central & Northern Europe" = "#0072B2"
)

# Caption
bg_color <- "#1a1a2e"
tt_source <- "Wikidata Twin Cities"

tt_caption <- paste0(
  "DataViz: Tony Galvan #TidyTuesday",
  "<span style='color:", bg_color, ";'>..</span>",
  "<span style='font-family:fa-solid;'>&#xf0ce;</span>",
  "<span style='color:", bg_color, ";'>.</span>",
  tt_source,
  "<span style='color:", bg_color, ";'>..</span>",
  "<span style='font-family:fa-brands;'>&#xf09b;</span>",
  "<span style='color:", bg_color, ";'>.</span>",
  "gdatascience",
  "<span style='color:", bg_color, ";'>..</span>",
  "<span style='font-family:fa-brands;'>&#xe61b;</span>",
  "<span style='color:", bg_color, ";'>.</span>",
  "@GDataScience1"
)

# Build the map
p <- ggplot() +
  # World background
  geom_sf(data = world, fill = "#2d2d44", color = "#4a4a6a", linewidth = 0.15) +
  # Arcs colored by community
  geom_curve(
    data = arcs |> filter(!is.na(community_label)),
    aes(x = lng_s, y = lat_s, xend = lng_t, yend = lat_t,
        color = community_label, linewidth = weight),
    alpha = 0.4, curvature = 0.2
  ) +
  scale_color_manual(values = community_colors, name = "Diplomatic Cluster") +
  scale_linewidth_continuous(range = c(0.2, 2.5), guide = "none") +
  coord_sf(ylim = c(-90, 90)) +
  labs(
    title = "Bridges Across Borders",
    subtitle = "Sister city links reveal hidden diplomatic blocs shaped by\ncolonial history, Cold War alliances, and linguistic kinship",
    caption = tt_caption
  ) +
  theme_void(base_family = "source_sans") +
  theme(
    plot.background = element_rect(fill = bg_color, color = NA),
    plot.title = element_text(
      color = "white", size = 64, face = "bold", hjust = 0.5,
      margin = margin(t = 10, b = 8)
    ),
    plot.title.position = "plot",
    plot.subtitle = element_text(
      color = "gray80", size = 24, hjust = 0.5,
      margin = margin(b = 5), lineheight = 1.2
    ),
    plot.caption = element_markdown(
      color = "gray60", size = 9, hjust = 0.5,
      margin = margin(t = 5, b = 5)
    ),
    plot.caption.position = "plot",
    legend.position = c(0.15, 0.40),
    legend.direction = "vertical",
    legend.background = element_rect(fill = alpha(bg_color, 0.7), color = NA),
    legend.title = element_text(color = "gray80", size = 11, face = "bold"),
    legend.text = element_text(color = "gray80", size = 9),
    legend.key.height = unit(0.4, "cm"),
    legend.key.width = unit(0.8, "cm"),
    plot.margin = margin(5, 5, 5, 5)
  ) +
  guides(color = guide_legend(ncol = 1, override.aes = list(linewidth = 2, alpha = 0.8)))

ggsave(
  filename = "outputs/2026_05_12_tidy_tuesday_twinned_cities.png",
  plot = p,
  device = "png",
  width = 10,
  height = 7,
  dpi = 300,
  bg = bg_color
)

showtext_auto(FALSE)
```

## Zooming In: Each Cluster’s Footprint

The combined map shows all five clusters at once, but it’s hard to see
the geographic reach of each one individually. Let’s facet by community
to see where each bloc’s arcs actually go:

``` r
showtext_auto()

# For the faceted version, use city-level coordinates for richer detail per panel
arcs_city <- links_enriched |>
  filter(country_s != country_t) |>
  left_join(membership_df |> select(country, community_label), 
            by = c("country_s" = "country")) |>
  filter(!is.na(community_label))

# Sample within each community to keep it readable
set.seed(42)
arcs_facet <- arcs_city |>
  group_by(community_label) |>
  slice_sample(n = 400) |>
  ungroup()

ggplot() +
  geom_sf(data = world, fill = "#2d2d44", color = "#4a4a6a", linewidth = 0.1) +
  geom_curve(
    data = arcs_facet,
    aes(x = lng_s, y = lat_s, xend = lng_t, yend = lat_t,
        color = community_label),
    alpha = 0.3, curvature = 0.2, linewidth = 0.3
  ) +
  scale_color_manual(values = community_colors) +
  coord_sf(ylim = c(-60, 80)) +
  facet_wrap(~ community_label, ncol = 1) +
  labs(
    title = "Each Diplomatic Cluster Has a Distinct Geographic Signature",
    subtitle = "City-level twin links faceted by community — each panel shows one cluster's connections"
  ) +
  theme_void(base_family = "source_sans") +
  theme(
    plot.background = element_rect(fill = bg_color, color = NA),
    plot.title = element_text(color = "white", size = 20, face = "bold", hjust = 0.5,
                              margin = margin(t = 10, b = 5)),
    plot.title.position = "plot",
    plot.subtitle = element_text(color = "gray80", size = 13, hjust = 0.5,
                                 margin = margin(b = 10)),
    strip.text = element_text(color = "white", size = 14, face = "bold",
                              margin = margin(b = 3, t = 5)),
    legend.position = "none",
    plot.margin = margin(10, 10, 10, 10)
  )
```

![](outputs/facet-map-1.png)

``` r
showtext_auto(FALSE)
```

Now you can clearly see each cluster’s geographic footprint:

- **Central & Northern Europe** is a dense web concentrated in Europe
  with tendrils reaching to Israel and the Americas
- **Francophone World** radiates from France down into West and North
  Africa
- **Russia & Eastern Mediterranean** fans out from Russia/Turkey across
  the Middle East and Central Asia
- **Anglophone & Pacific Rim** spans the Pacific — heavy arcs between
  Japan, the US, China, and Australia
- **Latin America & Iberian** connects Spain and Portugal to every
  corner of Central and South America

## What the Clusters Reveal

The five communities the algorithm discovered tell a story of **history
encoded in municipal diplomacy**:

- **Central & Northern Europe** (blue): Germany, Poland, UK, Nordics,
  Israel — the post-WWII reconciliation network. Germany alone has 344
  links to Poland and 58 to Israel.
- **Francophone World** (light blue): France and its former colonies in
  West Africa form a tight cluster, with Algeria, Morocco, and Tunisia
  as key nodes.
- **Russia & Eastern Mediterranean** (gold): Russia, Turkey, the Middle
  East, and Central Asia — reflecting both Soviet-era ties and Turkey’s
  bridge role between Europe and Asia.
- **Anglophone & Pacific Rim** (green): The US, Japan, China, Canada,
  Australia, and much of East/Southeast Asia. Japan-US alone has 213
  links.
- **Latin America & Iberian** (pink): Spain, Portugal, and all of Latin
  America — 500 years of colonial linguistic ties still visible in
  municipal diplomacy.

## What’s Next?

Some open questions this data raises:

- **Is every country reachable** through a chain of twin city links?
  (Yes — all 191 countries are connected.)
- **Do these clusters predict trade flows?** Countries that twin
  together likely trade together.
- **How has the network grown over time?** The dataset doesn’t include
  dates, but Wikidata might.
- **Which cities are the “bridges”** — connecting communities that
  otherwise wouldn’t link?

The quiet diplomacy of sister cities turns out to be a remarkably
faithful mirror of geopolitical history.
