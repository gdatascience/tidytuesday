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
- `ggtext` - Rich text (markdown/HTML) in ggplot labels; required for Font Awesome icon captions via `element_markdown()`
- `patchwork` - Combine multiple ggplots (use only when multi-panel is justified; see structure.md)
- `showtext` / `sysfonts` - Custom Google Fonts for thematic styling (**IMPORTANT:** always call `showtext_opts(dpi = 300)` after `showtext_auto()` to match `ggsave` DPI — without this, fonts render at ~1/3 size)
- `ragg` - Alternative graphics device with native color emoji support via `systemfonts`; use `ragg::agg_png` to render color emoji to a PNG, then composite with `magick` (see structure.md "Color Emoji in Titles")
- `magick` - Image processing, compositing logos/emoji onto plots
- `cowplot` - `draw_image()` for placing logos/images on ggplots
- `ggimage` - Embed images directly in ggplot geoms
- `gganimate` - Animated GIF output from ggplots
- `gt` - Grammar of tables for creating publication-quality tables
- `gtExtras` - Extensions for gt package
- `gtsummary` - Summary tables with gt

### Fonts & Icons
- Font Awesome 6 OTF files installed at `~/Library/Fonts/` — used for icon captions
  - `Font Awesome 6 Brands-Regular-400.otf` (Bluesky, GitHub, etc.)
  - `Font Awesome 6 Free-Solid-900.otf` (table icon, etc.)
- Register via `sysfonts::font_add()` for use with `showtext` + `ggtext::element_markdown()`

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

### Using showtext with ggsave
When using `showtext` for custom Google Fonts, **always set `showtext_opts(dpi = ...)` to match the `dpi` argument in `ggsave()`**. Without this, `showtext` defaults to 96 DPI internally while `ggsave` renders at 300 DPI, causing all fonts to render at roughly 1/3 their intended size.

```r
library(showtext)
font_add_google("Roboto Condensed", "roboto_cond")
showtext_auto()
showtext_opts(dpi = 300)  # MUST match ggsave dpi

# ... build your ggplot ...

ggsave("plot.png", plot = p, width = 10, height = 10, dpi = 300)
showtext_auto(FALSE)
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

### Temporary & Scratch Files
**NEVER use `.kiro_tmp/` or any other temp directory in the repo root.** All temporary files — build logs, intermediate images, render output, scratch data — must go in the week's specs folder:

```
.kiro/specs/YYYY_MM_DD_tidy_tuesday_topic/
```

This includes:
- Redirected command output (build logs, test results)
- Intermediate images used during compositing (e.g., `_base.png` before adding a logo)
- Any file that is not the final `.Rmd`, `.qmd`, or `.png` deliverable

The **only files that should be written to the repo root** for a given week are:
- The analysis file: `YYYY_MM_DD_tidy_tuesday_topic.Rmd` (or `.qmd`)
- The final output image: `YYYY_MM_DD_tidy_tuesday_topic.png` (or `.gif`)

Everything else stays in `.kiro/specs/`, including:
- Rendered HTML files (render to the specs folder using `output_dir` parameter)
- Shiny apps (store in `.kiro/specs/YYYY_MM_DD_tidy_tuesday_topic/app/`)
- Downloaded assets (logos, images, external data files)
- Redirected command output (build logs, test results)
- Intermediate images used during compositing

### Rendering Rmd/qmd Files
Always render HTML output into the specs folder, not the repo root:

```r
rmarkdown::render(
  "YYYY_MM_DD_tidy_tuesday_topic.Rmd",
  output_dir = ".kiro/specs/YYYY_MM_DD_tidy_tuesday_topic"
)
```

This keeps the repo root clean — only the `.Rmd` and final `.png` belong there.

## Project Configuration
- Encoding: UTF-8
- Indentation: 2 spaces (no tabs)
- RStudio settings stored in `.Rproj.user/`
