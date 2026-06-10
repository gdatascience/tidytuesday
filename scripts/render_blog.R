#!/usr/bin/env Rscript
# render_blog.R — Render an Rmd to README.md with hero section
#
# Usage:
#   Rscript scripts/render_blog.R \
#     --date "2026-06-09" \
#     --topic "game_films" \
#     --title "Press Start to Profit: Can Machine Learning Predict Video Game Movie Hits?" \
#     --blurb "Video game movies went from Hollywood's biggest joke to its most reliable investment." \
#     --week 23 \
#     --image "2026_06_09_tidy_tuesday_game_films.png"
#
# All arguments are optional — the script will infer them from the Rmd YAML
# and directory structure when possible.
#
# What this script does:
#   1. Renders the Rmd to README.md via github_document
#   2. Replaces the pandoc title block with the hero section
#   3. Cleans up any _files/ directories left behind

library(rmarkdown)

# ---------- Parse CLI arguments ----------
args <- commandArgs(trailingOnly = TRUE)

parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 1 && idx < length(args)) args[idx + 1] else default
}

date_str <- parse_arg("--date")
topic <- parse_arg("--topic")
title <- parse_arg("--title")
blurb <- parse_arg("--blurb")
week <- parse_arg("--week")
image <- parse_arg("--image")

# ---------- Infer missing values ----------

# Date: required (no sensible default)
if (is.null(date_str)) {
  stop("--date is required (format: YYYY-MM-DD)", call. = FALSE)
}

date_underscore <- gsub("-", "_", date_str)
year <- substr(date_str, 1, 4)

# Topic: infer from Rmd filename in the week directory
week_dir <- file.path(year, date_underscore)
if (!dir.exists(week_dir)) {
  stop("Week directory not found: ", week_dir, call. = FALSE)
}

rmd_files <- list.files(week_dir, pattern = "\\.Rmd$|\\.qmd$", full.names = FALSE)
if (length(rmd_files) == 0) {
  stop("No .Rmd or .qmd file found in ", week_dir, call. = FALSE)
}
rmd_file <- rmd_files[1]
rmd_path <- file.path(week_dir, rmd_file)

if (is.null(topic)) {
  # Extract topic from filename: YYYY_MM_DD_tidy_tuesday_TOPIC.Rmd
  topic <- sub("^\\d{4}_\\d{2}_\\d{2}_tidy_tuesday_", "", rmd_file)
  topic <- sub("\\.(Rmd|qmd)$", "", topic)
}

# Title: read from YAML front matter
if (is.null(title)) {
  yaml_lines <- readLines(rmd_path, n = 20)
  title_line <- grep("^title:", yaml_lines, value = TRUE)[1]
  if (!is.na(title_line)) {
    title <- sub('^title:\\s*["\']?(.+?)["\']?\\s*$', "\\1", title_line)
  } else {
    title <- paste("TidyTuesday:", date_str)
  }
}

# Image: default to the standard naming convention
if (is.null(image)) {
  image <- paste0(date_underscore, "_tidy_tuesday_", topic, ".png")
}

# Verify image exists (or will exist after render)
image_path <- file.path(week_dir, "outputs", image)

# Week number: infer from date if not provided
if (is.null(week)) {
  # Count weeks in the TidyTuesday year schedule (approximate: week of year - first TT week)
  week <- as.character(as.integer(format(as.Date(date_str), "%U")))
}

# ---------- Step 1: Render to README.md ----------
cat("Rendering", rmd_path, "to README.md...\n")

render(
  rmd_path,
  output_format = github_document(html_preview = FALSE),
  output_file = "README.md",
  output_dir = week_dir,
  quiet = TRUE
)

readme_path <- file.path(week_dir, "README.md")
cat("Rendered:", readme_path, "\n")

# ---------- Step 2: Replace pandoc title block with hero section ----------
readme <- readLines(readme_path, warn = FALSE)

# Pandoc title block is: Title line(s), ================, date, blank line
# Find the === line (it's always there for github_document)
sep_line <- grep("^={4,}$", readme)

if (length(sep_line) > 0) {
  sep_idx <- sep_line[1]

  # The title is everything before the === line
  # The date line is right after ===, then a blank line
  # Find where the body starts (first non-blank line after date)
  after_sep <- sep_idx + 1
  # Skip the date line
  if (after_sep <= length(readme) && grepl("^\\d{4}-\\d{2}-\\d{2}$", readme[after_sep])) {
    after_sep <- after_sep + 1
  }
  # Skip blank lines

  while (after_sep <= length(readme) && readme[after_sep] == "") {
    after_sep <- after_sep + 1
  }

  # Build hero section
  source_link <- paste0("[Source Code](", rmd_file, ")")
  data_link <- paste0(
    "[TidyTuesday project](https://github.com/rfordatascience/tidytuesday/tree/main/data/",
    year, "/", date_str, ")"
  )

  hero <- c(
    paste0("# ", title),
    "",
    paste0("**", source_link, "** | Data from the ", data_link, " (Week ", week, ", ", date_str, ")"),
    "",
    paste0("![", title, "](outputs/", image, ")"),
    ""
  )

  # Add blurb if provided

  if (!is.null(blurb) && nchar(blurb) > 0) {
    hero <- c(hero, blurb, "")
  }

  hero <- c(hero, "---", "")

  # Combine: hero + body (everything after the pandoc block)
  body <- readme[after_sep:length(readme)]
  final <- c(hero, body)

  writeLines(final, readme_path)
  cat("Hero section inserted.\n")
} else {
  cat("WARNING: Could not find pandoc title block (=== separator). README left as-is.\n")
}

# ---------- Step 3: Clean up _files/ directories ----------
files_dirs <- list.dirs(week_dir, recursive = FALSE)
files_dirs <- files_dirs[grepl("_files$", files_dirs)]
if (length(files_dirs) > 0) {
  unlink(files_dirs, recursive = TRUE)
  cat("Cleaned up:", paste(basename(files_dirs), collapse = ", "), "\n")
}

cat("Done! README ready at:", readme_path, "\n")
