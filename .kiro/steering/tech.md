# Technology Stack

## Language & Environment
- R (primary language)
- RStudio project (`.Rproj` file)

## Core Libraries

### Data Manipulation
- `tidyverse` - Core data science packages (dplyr, tidyr, ggplot2, etc.)
- `tidytuesdayR` - Package for loading TidyTuesday datasets
- `lubridate` - Date/time manipulation
- `janitor` - Data cleaning utilities
- `tidytext` - Text mining and analysis

### Visualization
- `ggplot2` - Primary plotting library (part of tidyverse)
- `scales` - Scale functions for ggplot2
- `gt` - Grammar of tables for creating publication-quality tables
- `gtExtras` - Extensions for gt package
- `gtsummary` - Summary tables with gt

### Data Import
- `readr` - Reading CSV files (part of tidyverse)
- `readxl` - Reading Excel files

## Document Formats
- R Markdown (`.Rmd`) - Primary format for most analyses
- Quarto (`.qmd`) - Newer format being adopted for some analyses
- HTML output - Default rendering format

## Common Workflows

### Starting a New Analysis
```r
library(tidyverse)
library(tidytuesdayR)
library(scales)
theme_set(theme_light())

# Load data
tt <- tt_load("YYYY-MM-DD")
```

### Saving Visualizations
```r
ggsave(
  filename = "YYYY_MM_DD_tidy_tuesday_topic.png",
  device = "png"
)
```

### Saving gt Tables
```r
gtsave(table_object, "filename.png")
```

## Console/Terminal R Execution

Each `Rscript -e '...'` call starts a fresh R process — packages, data, and objects do not persist between calls. To avoid redundant work:

### Cache Data Locally
On the first run, save downloaded data to a local `.rds` file. On subsequent runs, read from the cache instead of re-downloading.

**IMPORTANT**: Always store cache files in the week's specs folder (`.kiro/specs/YYYY_MM_DD_tidy_tuesday_topic/`), never in the repo root. This keeps temporary data out of the git repository.

```r
# Define cache path in the specs folder
cache_dir <- ".kiro/specs/YYYY_MM_DD_tidy_tuesday_topic"
cache_path <- file.path(cache_dir, "tt_cache.rds")

# First run: download and cache
tt <- tt_load("YYYY-MM-DD")
if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
saveRDS(tt, cache_path)

# Subsequent runs: load from cache
tt <- readRDS(cache_path)
```

### Minimize Repeated Setup
- Only load the packages you actually need for each exploratory command
- If a script only needs `dplyr` and `readr`, don't load all of `tidyverse`
- Group related exploratory queries into a single `Rscript -e '...'` call rather than running many small ones
- Clean up cache files (e.g., `tt_cache.rds`) when the analysis is complete
- Never leave `.rds` cache files in the repo root — always use the specs folder

## Project Configuration
- Encoding: UTF-8
- Indentation: 2 spaces (no tabs)
- RStudio settings stored in `.Rproj.user/`
