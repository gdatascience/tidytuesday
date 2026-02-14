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

## Project Configuration
- Encoding: UTF-8
- Indentation: 2 spaces (no tabs)
- RStudio settings stored in `.Rproj.user/`
