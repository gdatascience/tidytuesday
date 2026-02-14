# Project Structure

## File Organization

### Root Directory
All analysis files are stored in the root directory with a consistent naming convention:
- Format: `YYYY_MM_DD_tidy_tuesday_topic.Rmd` or `.qmd`
- Output images: `YYYY_MM_DD_tidy_tuesday_topic.png` or `.gif`
- Some analyses produce HTML output: `YYYY_MM_DD_tidy_tuesday_topic.html`

### Supporting Directories
- `.Rproj.user/` - RStudio project metadata (auto-generated, gitignored)
- `rsconnect/` - RStudio Connect deployment metadata
- `*_files/` - Supporting files for specific analyses (e.g., `horror_movies_files/`, `2024_10_22_cbp_files/`)
- `.kiro/` - Kiro AI assistant configuration and steering rules

### Special Files
- `tidytuesday.Rproj` - RStudio project file
- `.gitignore` - Git ignore rules (excludes `.Rhistory` and `.Rproj.user/`)
- `_publish.yml` - Quarto publishing configuration

## Naming Conventions

### Analysis Files
- Date format: `YYYY_MM_DD` (underscores, not hyphens)
- Topic: Short descriptive name in lowercase with underscores
- Examples:
  - `2026_02_07_pinewood_derby.qmd`
  - `2025_02_11_tidy_tuesday_cdc.Rmd`
  - `2024_10_29_tidy_tuesday_monster.Rmd`

### Output Files
- Match the source file name exactly
- Common extensions: `.png`, `.gif`, `.html`
- Example: `2026_01_27_tidy_tuesday_companies.png`

## Code Structure Pattern

Most analysis files follow this structure:

1. YAML header with title, date, and output format
2. Setup chunk with `knitr::opts_chunk$set(echo = TRUE)`
3. Library loading chunk
4. Data loading (using `tidytuesdayR::tt_load()`)
5. Data exploration (glimpse, readme)
6. Data wrangling
7. Visualization creation
8. Image export (using `ggsave()` or `gtsave()`)

## Caption Convention
Visualizations typically include attribution in captions:
- Format: `"Data Source: [source] | DataViz: Tony Galvan (@GDataScience1) | #TidyTuesday"`
- Variations: `"Analysis: Tony Galvan (@GDataScience1)"` or `"Created by Anthony Galvan"`
