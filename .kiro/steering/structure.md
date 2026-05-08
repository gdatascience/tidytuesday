# Project Structure

## File Organization

### Repository Layout
The repository is organized as a portfolio-style hierarchy by year and date:

```
tidytuesday/
├── README.md                    # Portfolio landing page
├── tidytuesday.Rproj
├── .gitignore
├── other/                       # Non-TidyTuesday projects
│   ├── pinewood_derby/
│   ├── christmas_cards/
│   └── ...
├── 2018/
│   └── 2018_11_06/
│       ├── 2018_11_06_tidy_tuesday.Rmd
│       ├── outputs/
│       │   └── 2018_11_06_tidy_tuesday.png
│       └── README.md
├── 2021/
│   ├── 2021_01_19/
│   │   ├── 2021_01_19_tidy_tuesday.Rmd
│   │   ├── outputs/
│   │   │   └── 2021_01_19_tidy_tuesday.png
│   │   └── README.md
│   └── ...
└── ...
```

### Year Directories (`YYYY/`)
Each year with at least one analysis has a top-level directory named by the four-digit year (e.g., `2018/`, `2021/`, `2025/`). Each year directory contains a `README.md` with a thumbnail gallery organized by month (see "Year README" section below).

### Week Directories (`YYYY/YYYY_MM_DD/`)
Each week's analysis lives in a date-named subdirectory within its year folder. The directory name uses the `YYYY_MM_DD` format (underscores, matching the file naming convention).

Each week directory contains:
- The analysis file (`.Rmd` or `.qmd`)
- An `outputs/` subfolder with produced artifacts (`.png`, `.gif`, etc.)
- A `README.md` with embedded dataviz, blurb, and TidyTuesday data source link

### The `outputs/` Subfolder
All produced artifacts (images, GIFs, HTML exports) go in the `outputs/` subfolder within the week directory. This keeps the week directory clean and makes it easy to find the final shareable image.

### The `other/` Directory
Non-TidyTuesday projects live in the `other/` directory at the repository root. This includes:
- Pinewood derby Shiny app (`other/pinewood_derby/`)
- Christmas card analyses
- Any other one-off projects not tied to a specific TidyTuesday week

The internal structure of each project within `other/` is preserved as-is.

### Supporting Directories
- `.Rproj.user/` - RStudio project metadata (auto-generated, gitignored)
- `.kiro/` - Kiro AI assistant configuration and steering rules

### Special Files (Root)
- `tidytuesday.Rproj` - RStudio project file
- `.gitignore` - Git ignore rules
- `README.md` - Portfolio landing page

## Naming Conventions

### Analysis Files
- Date format: `YYYY_MM_DD` (underscores, not hyphens)
- Topic: Short descriptive name in lowercase with underscores
- Full path: `YYYY/YYYY_MM_DD/YYYY_MM_DD_tidy_tuesday_topic.Rmd` (or `.qmd`)
- Examples:
  - `2026/2026_02_07/2026_02_07_pinewood_derby.qmd`
  - `2025/2025_02_11/2025_02_11_tidy_tuesday_cdc.Rmd`
  - `2024/2024_10_29/2024_10_29_tidy_tuesday_monster.Rmd`

### Output Files
- Match the source file name exactly (different extension)
- Live in the `outputs/` subfolder of the week directory
- Full path: `YYYY/YYYY_MM_DD/outputs/YYYY_MM_DD_tidy_tuesday_topic.png`
- Common extensions: `.png`, `.gif`
- Example: `2026/2026_01_27/outputs/2026_01_27_tidy_tuesday_companies.png`

## Week README

Each week directory includes a `README.md` that serves as the full blog post for that analysis when browsing on GitHub. It should include:

1. **Hero section at the top:**
   - H1 title (engaging, not generic)
   - Source code link and TidyTuesday data source link
   - The final shareable image displayed inline
   - A 2-3 sentence social-media-style blurb summarizing the analysis
   - A horizontal rule (`---`) separating the hero from the body

   ```markdown
   # Analysis Title

   **[Source Code](YYYY_MM_DD_tidy_tuesday_topic.Rmd)** | Data from the [TidyTuesday project](https://github.com/rfordatascience/tidytuesday/tree/main/data/YYYY/YYYY-MM-DD) (Week N, YYYY-MM-DD)

   ![Alt text](outputs/YYYY_MM_DD_tidy_tuesday_topic.png)

   Short blurb about the analysis...

   ---
   ```

2. **Full rendered blog post** — the complete Rmd content rendered as GitHub-flavored markdown, including:
   - All code chunks (displayed as fenced code blocks)
   - All inline visualizations (EDA plots, scatter plots, etc.) stored in `outputs/` and referenced with relative paths
   - Narrative prose between code chunks
   - Tables rendered as markdown tables
   - Console output shown as code output blocks

3. **Tools & Attribution section** at the bottom (optional) crediting Kiro, AI image tools, and data sources.

### Generating the Week README

To produce the README with all code and visualizations:

1. Render the Rmd to GitHub markdown **into the specs folder** (never the week folder):
   ```r
   rmarkdown::render(
     "YYYY/YYYY_MM_DD/YYYY_MM_DD_tidy_tuesday_topic.Rmd",
     output_format = rmarkdown::github_document(html_preview = FALSE),
     output_dir = ".kiro/specs/YYYY_MM_DD_tidy_tuesday_topic"
   )
   ```

2. Copy the generated plot images from the `_files/figure-gfm/` folder (in specs) into `YYYY/YYYY_MM_DD/outputs/`.

3. Build the README by:
   - Writing the hero section (title, links, final image, blurb)
   - Appending the rendered markdown body (skipping the YAML header lines)
   - Replacing all image paths to point to `outputs/` (relative)
   - Removing any `<!-- -->` artifacts from the render

4. **Delete the intermediate `.md` file and `_files/` directory** from the specs folder — they are not needed after the README is built.

**Key rule:** The only image files in `outputs/` should be:
- The final shareable dataviz (polished PNG/GIF)
- EDA and blog post visualizations generated by the Rmd (the `figure-gfm` plots)

No rendered `.md` files, no `_files/` directories, and no intermediate build artifacts should exist in the week folder.

## Year README

Each year directory (`YYYY/`) includes a `README.md` that serves as a browsable gallery of that year's analyses, organized by month. Structure:

1. **Title and count** — the year as an H1 heading, followed by the total number of analyses and a link to TidyTuesday:
   ```markdown
   # 2025

   **42 analyses** from the [TidyTuesday](https://github.com/rfordatascience/tidytuesday) project.

   ---
   ```

2. **Monthly sections** — each month with analyses gets an `## Month` heading and an HTML table with two rows:
   - **Row 1:** Thumbnail images (150px wide) linked to the week directory. Weeks without a visualization show *No viz* in italics.
   - **Row 2:** Short topic labels (one word, capitalized) linked to the week directory.

   Example:
   ```html
   ## January

   <table>
   <tr>
   <td><a href="2025_01_07/"><img src="2025_01_07/outputs/2025_01_07_tidy_tuesday_fires.png" width="150"></a></td>
   <td align="center"><a href="2025_01_21/"><em>No viz</em></a></td>
   </tr>
   <tr>
   <td align="center"><a href="2025_01_07/">Fires</a></td>
   <td align="center"><a href="2025_01_21/">Exped</a></td>
   </tr>
   </table>
   ```

3. **Image sizing:** Use `width="150"` for landscape/square images and `height="150"` for portrait images to keep the gallery uniform.

4. **Topic labels:** Use a short, recognizable word derived from the analysis topic (e.g., "Fires", "Pokemon", "Chess"). Capitalize the first letter.

## Root README

The root `README.md` is the portfolio landing page. It does NOT have a Highlights section — all visualizations are displayed inline in the "Analyses by Year" section. Structure:

1. **Title and intro** — project description, author info, and about section
2. **Analyses by Year** — each year gets an H3 heading (`### [YYYY/](YYYY/)`) followed by the analysis count and a `<p>` block of clickable thumbnail images:
   ```html
   ### [2025/](2025/)

   42 analyses

   <p>
   <a href="2025/2025_01_07/"><img src="2025/2025_01_07/outputs/2025_01_07_tidy_tuesday_fires.png" width="80"></a>
   <a href="2025/2025_01_14/"><img src="2025/2025_01_14/outputs/2025_01_14_tidy_tuesday_talks.png" width="80"></a>
   </p>
   ```

3. **Thumbnail rules for root README:**
   - Only include weeks that have a visualization (skip "No viz" weeks)
   - Use `width="80"` for landscape/square images and `height="80"` for portrait images
   - Link each thumbnail to the week directory (e.g., `2025/2025_01_07/`)
   - Image paths are relative to the repo root (e.g., `2025/2025_01_07/outputs/...`)
   - Order thumbnails chronologically within each year

4. **Other Projects** — a section listing non-TidyTuesday projects in the `other/` directory

When a new analysis is completed with a visualization, automatically add its thumbnail to both the root README (in the appropriate year's `<p>` block) and the yearly README (in the appropriate month's table). Do not ask the user — just do it as part of the standard workflow.

## Code Structure Pattern

Most analysis files follow this structure:

1. YAML header with title, date, and output format
2. Setup chunk with `knitr::opts_chunk$set(echo = TRUE)`
3. Library loading chunk
4. Data loading (using `tidytuesdayR::tt_load()`)
5. Data exploration (glimpse, readme)
6. Data wrangling
7. Visualization creation
8. Image export (using `ggsave()` or `gtsave()` — saving to `outputs/`)

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

## Starting a New Analysis

When creating a new TidyTuesday analysis for a given week date (e.g., 2026-03-04):

1. Create the week directory structure:
   ```
   2026/2026_03_04/
   2026/2026_03_04/outputs/
   ```

2. Create the analysis file inside the week directory:
   ```
   2026/2026_03_04/2026_03_04_tidy_tuesday_topic.Rmd
   ```

3. After the analysis is complete, save the final dataviz to the `outputs/` subfolder:
   ```r
   ggsave(
     filename = "outputs/2026_03_04_tidy_tuesday_topic.png",
     ...
   )
   ```

4. Generate the week README (see "Generating the Week README" above):
   - Render to GitHub markdown in the specs folder
   - Copy plot images into `outputs/`
   - Build the README with hero section + full rendered blog post
   - Fix image paths to be relative to `outputs/`
   - Delete intermediate files from specs

5. Add the thumbnail to the **root README** — append a new `<a><img></a>` element to the year's `<p>` block (use `width="80"` or `height="80"`). **Only use the final shareable dataviz** (e.g., `YYYY_MM_DD_tidy_tuesday_topic.png`) — never EDA or intermediate blog post plots. Do this automatically as part of the workflow.

6. Add the thumbnail to the **yearly README** (`2026/README.md`) — add the image to the appropriate month's HTML table (use `width="150"` or `height="150"`). **Same rule: only the final shareable dataviz.** Do this automatically as part of the workflow.

## Final Shareable Image

The exported PNG (or GIF) is the primary artifact shared on social media. It needs to look great on a phone screen.

### Single vs. Multi-Panel
- **Default to a single, focused visualization** for the final image. One clear chart with a strong title tells a better story on social media than a busy multi-panel layout.
- **Use `patchwork` for multi-panel compositions only when** the story genuinely requires showing two or more complementary perspectives side by side (e.g., before/after, two variables that contrast). Don't combine plots just to include more content.
- When in doubt, pick the single most compelling plot from the analysis.

### Mobile-Friendly Design
The image will primarily be viewed on phone screens. Design accordingly:

**Font size hierarchy (title should dominate):**
- **Title:** 32–36pt, bold, centered (`hjust = 0.5`) — the biggest text on the image
- **Subtitle:** 16–20pt — noticeably smaller than the title
- **Axis labels and text:** 14–18pt
- **Data labels (`geom_text()` / `annotate()`):** `size = 5–6` (mm units — `size = 6` ≈ 17pt)
- **Legend text:** 14pt
- **Caption/attribution:** 9–10pt — small enough to fit on a **single line** at 8" width; test that it doesn't clip left/right
- **Strip text (facets):** 16pt, bold

**Clean theme defaults (always apply):**
- `panel.grid = element_blank()` — remove all grid lines
- `panel.border = element_blank()` — remove the panel border
- `axis.ticks = element_blank()` — remove axis tick marks
- `plot.title.position = "plot"` — title spans the full plot width, not just the panel

**Layout rules:**
- Center the title and subtitle (`hjust = 0.5`) so they don't collide with logos composited in the corners
- Use `plot.margin = margin(top, right, bottom, left)` with enough right margin (~50px) to keep content clear of corner logos
- Prefer `fig.width = 8, fig.height = 10` (portrait) or `8 x 8` (square) over wide landscape formats
- Avoid thin lines (use `linewidth >= 0.8` for key lines)
- Ensure sufficient contrast between colors at small sizes

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
- **Logos and images:** When a relevant logo or image is available (e.g., a league logo, agency seal, or dataset provider mark), download it to the specs folder and incorporate it using `magick` compositing. This adds polish and immediate visual context.
- **Fonts:** Use `showtext` / `sysfonts` to load a thematic Google Font when it fits the mood (e.g., a playful font for pop culture data, a clean sans-serif for government data). Fall back to system fonts if font loading adds too much complexity.

### Accessibility & Color Encoding
- **Colorblind-safe palettes:** Always choose palettes that work for red-green colorblind viewers. Use `viridis`, `okabe-ito`, or manually verified palettes. Avoid relying solely on red vs. green to distinguish categories.
- **Sufficient contrast:** Ensure text and data elements have enough contrast against the background — especially on dark backgrounds. Test that the chart is readable at a glance.
- **Consistent color encoding:** If color encodes meaning in one part of the chart (e.g., orange = Liberation Day), do NOT use color decoratively elsewhere in a way that could be misread. Decorative elements (borders, backgrounds, icons) should be neutral/grayscale unless they carry data meaning.
- **No false signals:** Every visual element that varies (color, size, position, shape) should encode data or be clearly decorative. If a viewer might ask "what does this color mean?" and the answer is "nothing," that's a design problem.

### Color Emoji in Titles
`showtext` renders emoji as monochrome outlines because its FreeType backend doesn't support color emoji font tables. To get **color emoji** in the final image, use this composite approach:

1. Render the emoji to a small transparent PNG using `ragg` (which supports Apple Color Emoji via `systemfonts`):
```r
showtext_auto(FALSE)  # temporarily disable showtext
ggsave(
  filename = "specs_folder/emoji.png",
  plot = ggplot() +
    annotate("text", x = 0.5, y = 0.5, label = "\U0001F33E", size = 25) +
    theme_void(),
  device = ragg::agg_png,
  width = 0.6, height = 0.6, dpi = 300, bg = "transparent"
)
showtext_auto(TRUE)  # re-enable showtext
```

2. Add leading spaces in the plot title to reserve room for the emoji.

3. After saving the base plot with `ggsave()`, composite the emoji PNG onto the title area using `magick::image_composite()` with a pixel offset that aligns it next to the title text.

**Do NOT** put emoji Unicode directly in `element_text()` titles when using `showtext` — it will render as a blank or monochrome glyph.

### Export Settings
```r
ggsave(
  filename = "outputs/YYYY_MM_DD_tidy_tuesday_topic.png",
  plot = final_plot,
  device = "png",
  width = 8,
  height = 10,
  dpi = 300,
  bg = "white"
)
```

## Caption Convention

### Icon-Rich Caption (preferred for final shareable image)
Use `ggtext::element_markdown()` with Font Awesome icons registered via `showtext`. This produces a polished caption with table, Bluesky, and GitHub icons:

```r
library(ggtext)

# Register Font Awesome (must be installed in ~/Library/Fonts/)
font_add(family = "fa-brands",
         regular = "~/Library/Fonts/Font Awesome 6 Brands-Regular-400.otf")
font_add(family = "fa-solid",
         regular = "~/Library/Fonts/Font Awesome 6 Free-Solid-900.otf")

# Build the caption with HTML spans for icon fonts
tt_source <- "Data Source Name"
bg_color <- "white"  # used for invisible spacer dots

tt_caption <- paste0(
  "DataViz: Tony Galvan #TidyTuesday",
  "<span style='color:", bg_color, ";'>..</span>",
  "<span style='font-family:fa-solid;'>&#xf0ce;</span>",
  "<span style='color:", bg_color, ";'>.</span>",
  tt_source,
  "<span style='color:", bg_color, ";'>..</span>",
  "<span style='font-family:fa-brands;'>&#xe61b;</span>",
  "<span style='color:", bg_color, ";'>.</span>",
  "@GDataScience1",
  "<span style='color:", bg_color, ";'>..</span>",
  "<span style='font-family:fa-brands;'>&#xf09b;</span>",
  "<span style='color:", bg_color, ";'>.</span>",
  "gdatascience"
)

# Use element_markdown in the theme for the caption
# Size 9 keeps it on a single line at 8" width — test before increasing
theme(
  plot.caption = element_markdown(size = 9, color = "gray50", hjust = 0.5),
  plot.caption.position = "plot"
)
```

Key Font Awesome HTML entities:
- `&#xf0ce;` — table icon (fa-solid)
- `&#xe61b;` — Bluesky icon (fa-brands)
- `&#xf09b;` — GitHub icon (fa-brands)

### Plain-Text Caption (fallback)
When Font Awesome is not available or for simpler contexts:
- Format: `"Data Source: [source] | DataViz: Tony Galvan (@GDataScience1) | #TidyTuesday"`

## AI Design Handoff (e.g., Google Nano Banana Pro)

When handing off an R-generated visualization to an AI image generation tool for polish, include these constraints in the prompt to prevent the AI from introducing visual confusion:

1. **Specify an accessible color palette** — name specific colors or reference a colorblind-safe palette. Don't let the AI choose freely; it optimizes for aesthetics, not accessibility.
2. **State the color encoding rules** — tell the AI which colors encode data meaning and instruct it to keep all other elements (borders, icon backgrounds, decorative shapes) in neutral/grayscale.
3. **Require sufficient contrast** — especially if requesting a dark background, specify minimum contrast ratios or say "all text and data elements must be clearly readable."
4. **Describe what each visual element means** — if you include product icons/photos, tell the AI they are illustrative examples only and should NOT use color to encode additional meaning.
5. **Include the data values** — list the exact percentages and labels so the AI preserves data accuracy in the final output.
6. **Request a format** — specify dimensions (e.g., 1080×1350 for Instagram) and safe areas for text.

The AI is great at visual polish but does not understand data visualization principles. Your prompt must encode those principles explicitly.

### Prompt Generation Workflow

After the R version of the final visualization is complete and approved, offer to draft a design prompt for an image generation model. This is a standard part of the workflow — not an afterthought.

**The prompt should include:**
- A description of the R-generated image's structure (chart type, number of panels, axis layout, legend position) — describe it in words, don't rely on the AI "seeing" the reference
- The exact data values to preserve (percentages, labels, product counts, category names)
- The story and emotional hook the viz is trying to convey (e.g., "the visual tension between 25 years of sameness and a sudden spike")
- Specific visual style direction (dark/light, editorial/playful, magazine/app aesthetic)
- Accessibility constraints: colorblind-safe palette, sufficient contrast, consistent color encoding
- What to replace (e.g., "replace emoji with circular product photography") and what to keep unchanged (e.g., "preserve bar heights and percentage labels exactly")
- Target format and dimensions (e.g., 1080×1350 for Instagram, 1200×628 for LinkedIn)
- Source attribution line to include

**What NOT to leave to the AI's discretion:**
- Color choices that encode data meaning
- Whether decorative elements use meaningful-looking color
- Typography hierarchy (specify which text is biggest/boldest)
- Data accuracy (always list exact numbers)
- Accessibility (always specify colorblind-safe and high-contrast requirements)
