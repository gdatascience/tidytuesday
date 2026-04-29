# Product Overview

This is a TidyTuesday project repository containing weekly data visualization exercises and explorations. TidyTuesday is a weekly social data project in the R community where participants explore datasets, create visualizations, and share their work.

The repository contains individual analysis files for each week's challenge, spanning from 2018 to 2026. Each analysis typically includes data loading, wrangling, visualization, and image export. The project focuses on practicing R data science skills, particularly using the tidyverse ecosystem for data manipulation and ggplot2 for visualization.

Some analyses also include specialized visualizations using the gt package for creating publication-quality tables with images and custom styling.

## Analysis Workflow

When working on a new TidyTuesday analysis, follow this process:

### 1. Explore Data via Console/Terminal
Always run R commands in the console/terminal to explore the data before writing any visualization code. This means:
- Load the dataset and run `glimpse()`, `summary()`, `unique()`, etc. via `Rscript -e '...'`
- Examine distributions, missing values, and relationships interactively
- Try multiple groupings and aggregations to find interesting patterns
- Do NOT skip straight to plotting — understand the data first

### 2. Form a Story
After exploring, identify a compelling narrative thread in the data:
- Look for surprising trends, regional differences, temporal patterns, or anomalies
- Quantify the key findings (e.g., "doubled from 8% to 15%")
- Decide on 2-4 complementary perspectives that build on each other
- The story should have a hook, supporting evidence, and open questions

### 3. Propose Advanced Approaches (before building visualizations)
After exploring the data and forming a story, **pause and present any opportunities** for advanced work before writing visualization code. Actively look for:
- **Machine learning models** — classification, clustering, regression on the data
- **Forecasts** — time series predictions or structural break detection where temporal data exists
- **Shiny apps** — interactive dashboards for rich or multi-dimensional datasets
- **Animated GIFs** — `gganimate` for temporal or sequential stories
- **3D visualizations** — `rayshader`, `plotly` for spatial or multi-variable data
- **Other creative formats** — interactive tables, network graphs, maps, etc.

**When to ask:** Present these opportunities in a message to the user **after Step 2 (Form a Story) and before Step 4 (Build Visualizations)**. For each opportunity, briefly describe:
1. What you'd build (e.g., "k-means clustering on tariff rate vectors across 20 trade agreements")
2. Why it's interesting for this dataset
3. What the output would look like (a plot, a table, a Shiny app, etc.)

Then **wait for the user to decide** which (if any) to pursue before continuing. Do NOT implement these automatically — they add complexity and build time, so the decision should be collaborative.

### 4. Build Storytelling Visualizations
Create visualizations that serve the narrative:
- Each plot should make one clear point
- Use consistent color palettes across related plots
- Include informative titles, subtitles, and captions
- Always include the attribution caption convention
- See the "Final Shareable Image" section in `structure.md` for detailed guidance on the exported PNG/GIF

### 5. Write as a Blog Post
The final Rmd/qmd should read as a self-contained article, not a code notebook:
- Open with a hook that draws the reader in
- Weave narrative prose between code chunks
- Each section should flow naturally into the next
- End with open questions or forward-looking commentary
- See the "Blog Post Rmd Structure" section in `structure.md` for the template

## Data Analyst Role

When analyzing data, act as a professional data analyst:
- Identify all variables and their types (numerical, categorical, dates, etc.)
- Note missing, inconsistent, or unusual values
- Provide summary statistics (mean, median, min, max, distributions)
- Identify patterns, trends, correlations, and outliers
- Present 3-7 key insights that are meaningful and quantified
- Explain findings in plain language; avoid jargon unless defined
- State assumptions and limitations clearly
- Only use data that is provided — do NOT invent data
