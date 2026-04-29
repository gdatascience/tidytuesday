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

## Blog Post Rmd Structure

The preferred format for analysis files is a narrative blog post that a reader can follow as an article. Structure it as:

1. YAML header with a descriptive, engaging title (not "TidyTemplate")
2. Setup chunk (hidden with `include=FALSE`, suppress messages/warnings globally)
3. Opening narrative hook — 1-2 paragraphs introducing the dataset and why it matters
4. Library loading chunk
5. Data loading chunk
6. Sections that alternate between prose and code:
   - Each section has a `##` heading that reads like a blog section title
   - Narrative text before each code chunk explains what we're about to look at and why
   - Narrative text after each plot interprets the results for the reader
   - Sections build on each other to tell a progressive story
7. A combined/summary visualization section
8. A closing "What's Next?" section with open questions
9. Image export chunk

Key principles:
- Remove all boilerplate template text (e.g., "Join the Data Science Learning Community...")
- The Rmd should read top-to-bottom as a coherent article
- Use bold text for key statistics in the prose
- Bullet points are fine for listing specific findings
- Every visualization should have a clear title, subtitle, and caption

## Final Shareable Image

The exported PNG (or GIF) is the primary artifact shared on social media. It needs to look great on a phone screen.

### Single vs. Multi-Panel
- **Default to a single, focused visualization** for the final image. One clear chart with a strong title tells a better story on social media than a busy multi-panel layout.
- **Use `patchwork` for multi-panel compositions only when** the story genuinely requires showing two or more complementary perspectives side by side (e.g., before/after, two variables that contrast). Don't combine plots just to include more content.
- When in doubt, pick the single most compelling plot from the analysis.

### Mobile-Friendly Design
The image will primarily be viewed on phone screens. Design accordingly:
- **Title:** 18–22pt, bold — readable at a glance
- **Subtitle:** 13–15pt — provides context without squinting
- **Axis labels and text:** 11–13pt minimum
- **Caption/attribution:** 9–11pt
- **Data labels on bars/points:** 9–11pt
- **Legend text:** 10–12pt
- **`geom_text()` / `annotate()` size:** 5–6 (these use mm, not pt — `size = 5` ≈ 14pt)
- Avoid thin lines (use `linewidth >= 0.8` for key lines)
- Ensure sufficient contrast between colors — test that the palette works at small sizes
- Prefer `fig.width = 8, fig.height = 10` (portrait) or `8 x 8` (square) over wide landscape formats for mobile

**CRITICAL — showtext DPI:** When using `showtext` for custom fonts, you **must** set `showtext_opts(dpi = 300)` immediately after `showtext_auto()`. The default is 96 DPI, which means all font sizes render at roughly 1/3 their intended size in a 300 DPI `ggsave()` output. This is the #1 cause of "fonts look tiny" in the final PNG.

```r
library(showtext)
font_add_google("Source Sans 3", "source_sans")
showtext_auto()
showtext_opts(dpi = 300)  # MUST match ggsave dpi
```

### Thematic Styling
Make the visualization feel connected to its subject matter:
- **Colors:** Choose palettes inspired by the data source or topic (e.g., ocean blues for marine data, earth tones for agriculture, team colors for sports). Don't default to generic palettes when a thematic one would be more engaging.
- **Logos and images:** When a relevant logo or image is available (e.g., a league logo, agency seal, or dataset provider mark), download it to the specs folder and incorporate it using `magick`, `cowplot::draw_image()`, or `ggimage`. This adds polish and immediate visual context.
- **Emojis:** Use `emoji` or Unicode characters in titles/subtitles when they reinforce the theme (e.g., 🌾 for agriculture, 🏈 for football). Keep it tasteful — one or two, not a wall of emoji.
- **Fonts:** Consider using `showtext` or `sysfonts` to load a thematic Google Font when it fits the mood (e.g., a playful font for pop culture data, a clean sans-serif for government data). Fall back to system fonts if font loading adds too much complexity.

### Export Settings
```r
ggsave(
  filename = "YYYY_MM_DD_tidy_tuesday_topic.png",
  plot = final_plot,
  device = "png",
  width = 8,
  height = 10,
  dpi = 300,
  bg = "white"
)
```

## Caption Convention
Visualizations typically include attribution in captions:
- Format: `"Data Source: [source] | DataViz: Tony Galvan (@GDataScience1) | #TidyTuesday"`
- Variations: `"Analysis: Tony Galvan (@GDataScience1)"` or `"Created by Anthony Galvan"`
