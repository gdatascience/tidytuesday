# Design Document: TidyTuesday Website Organization

## Overview

This design implements a two-phase solution: (1) reorganizing a flat TidyTuesday repository into year-based folders, and (2) generating a GitHub Pages website using Quarto to showcase visualizations in a grid layout with Notre Dame theming.

The solution leverages R scripting for file organization and Quarto's website generation capabilities for creating a modern, responsive site. The design prioritizes data integrity during reorganization and creates an engaging user experience for browsing TidyTuesday visualizations.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    TidyTuesday Repository                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │  File Organizer  │────────▶│  Year Folders    │          │
│  │   (R Script)     │         │  (2018-2026)     │          │
│  └──────────────────┘         └──────────────────┘          │
│           │                            │                     │
│           │                            │                     │
│           ▼                            ▼                     │
│  ┌──────────────────────────────────────────────┐           │
│  │         Quarto Website Generator              │           │
│  │  (_quarto.yml + index.qmd + year pages)      │           │
│  └──────────────────────────────────────────────┘           │
│                       │                                      │
│                       ▼                                      │
│  ┌──────────────────────────────────────────────┐           │
│  │         GitHub Pages Website                  │           │
│  │  (Static HTML + CSS + Images)                │           │
│  └──────────────────────────────────────────────┘           │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

1. **File Organization Phase**:
   - R script scans root directory for files matching pattern `YYYY_MM_DD_*`
   - Creates year folders if they don't exist
   - Moves files to appropriate year folders
   - Validates successful moves

2. **Website Generation Phase**:
   - Quarto scans year folders for analysis files and images
   - Generates index page with image grid
   - Renders individual analysis files to HTML
   - Applies Notre Dame theme via custom CSS
   - Builds static site for GitHub Pages deployment

## Components and Interfaces

### Component 1: File Organizer Script

**Purpose**: Reorganize files from root directory into year-based folders

**Implementation**: R script (`organize_files.R`)

**Key Functions**:

```r
# Extract year from filename
extract_year <- function(filename) {
  # Pattern: YYYY_MM_DD_*
  year <- str_extract(filename, "^\\d{4}")
  return(year)
}

# Get all TidyTuesday files
get_tidytuesday_files <- function(root_dir) {
  # Find all files matching pattern
  files <- list.files(
    root_dir, 
    pattern = "^\\d{4}_\\d{2}_\\d{2}_.*\\.(Rmd|qmd|png|gif|html)$",
    full.names = FALSE
  )
  return(files)
}

# Create year folders
create_year_folders <- function(years, root_dir) {
  for (year in unique(years)) {
    year_path <- file.path(root_dir, year)
    if (!dir.exists(year_path)) {
      dir.create(year_path)
    }
  }
}

# Move file with validation
move_file_safely <- function(source, destination) {
  # Check source exists
  if (!file.exists(source)) {
    stop(paste("Source file does not exist:", source))
  }
  
  # Move file
  file.copy(source, destination)
  
  # Verify destination exists
  if (!file.exists(destination)) {
    stop(paste("Failed to copy file to:", destination))
  }
  
  # Remove source only after verification
  file.remove(source)
  
  # Final verification
  if (file.exists(source)) {
    stop(paste("Failed to remove source file:", source))
  }
  
  return(TRUE)
}

# Main organization function
organize_tidytuesday_files <- function(root_dir = ".") {
  # Get all TidyTuesday files
  files <- get_tidytuesday_files(root_dir)
  
  # Extract years
  years <- sapply(files, extract_year)
  
  # Create year folders
  create_year_folders(years, root_dir)
  
  # Move files
  results <- data.frame(
    file = character(),
    year = character(),
    status = character(),
    stringsAsFactors = FALSE
  )
  
  for (i in seq_along(files)) {
    file <- files[i]
    year <- years[i]
    
    if (is.na(year)) {
      results <- rbind(results, data.frame(
        file = file,
        year = NA,
        status = "skipped - no year found"
      ))
      next
    }
    
    source_path <- file.path(root_dir, file)
    dest_path <- file.path(root_dir, year, file)
    
    tryCatch({
      move_file_safely(source_path, dest_path)
      results <- rbind(results, data.frame(
        file = file,
        year = year,
        status = "success"
      ))
    }, error = function(e) {
      results <<- rbind(results, data.frame(
        file = file,
        year = year,
        status = paste("error:", e$message)
      ))
    })
  }
  
  return(results)
}
```

**Interface**:
- Input: Root directory path (default: current directory)
- Output: Data frame with file move results (file, year, status)
- Side effects: Creates year folders, moves files

### Component 2: Quarto Website Configuration

**Purpose**: Configure Quarto website structure and behavior

**Implementation**: `_quarto.yml` configuration file

**Configuration Structure**:

```yaml
project:
  type: website
  output-dir: _site

website:
  title: "TidyTuesday Visualizations"
  description: "Weekly data visualization exercises using R and the tidyverse"
  site-url: "https://gdatascience.github.io/tidytuesday"
  repo-url: "https://github.com/gdatascience/tidytuesday"
  
  navbar:
    background: "#00843D"  # Kelly Green
    foreground: "#FFFFFF"
    title: "TidyTuesday"
    left:
      - text: "Home"
        href: index.qmd
      - text: "About"
        href: about.qmd
    right:
      - icon: github
        href: "https://github.com/gdatascience"
      - icon: twitter
        href: "https://twitter.com/GDataScience1"
  
  sidebar:
    style: "floating"
    contents:
      - section: "Years"
        contents:
          - text: "2026"
            href: 2026/index.qmd
          - text: "2025"
            href: 2025/index.qmd
          - text: "2024"
            href: 2024/index.qmd
          - text: "2023"
            href: 2023/index.qmd
          - text: "2022"
            href: 2022/index.qmd
          - text: "2021"
            href: 2021/index.qmd
          - text: "2020"
            href: 2020/index.qmd
          - text: "2018"
            href: 2018/index.qmd

format:
  html:
    theme: 
      - cosmo
      - custom.scss
    css: styles.css
    toc: true
    code-fold: true
    code-tools: true
```

**Interface**:
- Input: YAML configuration
- Output: Website structure and navigation
- Dependencies: Quarto CLI

### Component 3: Image Grid Generator

**Purpose**: Create responsive grid layout displaying TidyTuesday visualizations

**Implementation**: R code in `index.qmd` and year-specific `index.qmd` files

**Key Functions**:

```r
# Get all visualization files for a year
get_visualizations <- function(year_dir) {
  # Get all PNG files (primary)
  png_files <- list.files(
    year_dir,
    pattern = "\\.png$",
    full.names = TRUE
  )
  
  # Get all GIF files
  gif_files <- list.files(
    year_dir,
    pattern = "\\.gif$",
    full.names = TRUE
  )
  
  # Create data frame of visualizations
  viz_data <- data.frame(
    date = character(),
    image_path = character(),
    analysis_path = character(),
    stringsAsFactors = FALSE
  )
  
  # Process PNG files
  for (png in png_files) {
    base_name <- str_remove(basename(png), "\\.png$")
    date <- str_extract(base_name, "^\\d{4}_\\d{2}_\\d{2}")
    
    # Check if corresponding GIF exists
    gif_path <- str_replace(png, "\\.png$", ".gif")
    image_path <- if (file.exists(gif_path)) gif_path else png
    
    # Find corresponding analysis file
    rmd_path <- str_replace(png, "\\.png$", ".Rmd")
    qmd_path <- str_replace(png, "\\.png$", ".qmd")
    analysis_path <- if (file.exists(qmd_path)) qmd_path else rmd_path
    
    if (file.exists(analysis_path)) {
      viz_data <- rbind(viz_data, data.frame(
        date = date,
        image_path = image_path,
        analysis_path = analysis_path
      ))
    }
  }
  
  # Sort by date descending
  viz_data <- viz_data %>%
    arrange(desc(date))
  
  return(viz_data)
}

# Generate HTML for image grid
generate_image_grid <- function(viz_data) {
  html_parts <- c('<div class="image-grid">')
  
  for (i in 1:nrow(viz_data)) {
    row <- viz_data[i, ]
    
    # Generate HTML link to rendered analysis
    analysis_html <- str_replace(basename(row$analysis_path), "\\.(Rmd|qmd)$", ".html")
    
    html_parts <- c(html_parts, sprintf(
      '<div class="grid-item">
        <a href="%s">
          <img src="%s" alt="TidyTuesday %s" loading="lazy">
        </a>
        <div class="grid-caption">%s</div>
      </div>',
      analysis_html,
      basename(row$image_path),
      row$date,
      format(as.Date(gsub("_", "-", row$date)), "%B %d, %Y")
    ))
  }
  
  html_parts <- c(html_parts, '</div>')
  
  return(paste(html_parts, collapse = "\n"))
}
```

**Interface**:
- Input: Year directory path
- Output: HTML string with image grid
- Dependencies: tidyverse, stringr

### Component 4: Notre Dame Theme Styling

**Purpose**: Apply Notre Dame-inspired visual theme to website

**Implementation**: Custom SCSS (`custom.scss`) and CSS (`styles.css`)

**Color Palette**:
```scss
// Notre Dame Colors
$kelly-green: #00843D;
$nd-gold: #C99700;
$nd-navy: #0C2340;
$nd-white: #FFFFFF;

// Semantic colors
$primary: $kelly-green;
$secondary: $nd-gold;
$accent: $nd-navy;
```

**Key Styles**:

```scss
// custom.scss
/*-- scss:defaults --*/
$primary: #00843D;
$secondary: #C99700;
$link-color: #00843D;
$navbar-bg: #00843D;
$navbar-fg: #FFFFFF;

/*-- scss:rules --*/
.navbar {
  background-color: $primary !important;
  border-bottom: 3px solid $secondary;
}

h1, h2, h3 {
  color: $primary;
  font-weight: 600;
}

a {
  color: $primary;
  text-decoration: none;
  
  &:hover {
    color: darken($primary, 10%);
    text-decoration: underline;
  }
}
```

```css
/* styles.css */
.image-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 2rem;
  padding: 2rem 0;
}

.grid-item {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.grid-item:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0, 132, 61, 0.2);
}

.grid-item img {
  width: 100%;
  height: auto;
  display: block;
}

.grid-caption {
  padding: 1rem;
  text-align: center;
  color: #0C2340;
  font-weight: 500;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .image-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1rem;
  }
}
```

**Interface**:
- Input: SCSS/CSS files
- Output: Compiled CSS applied to website
- Dependencies: Quarto's SCSS compiler

### Component 5: Analysis File Renderer

**Purpose**: Render R Markdown and Quarto files to HTML for web viewing

**Implementation**: Quarto's built-in rendering engine

**Configuration**:
- Quarto automatically discovers and renders `.Rmd` and `.qmd` files
- Each file is rendered to HTML with the same base name
- Code folding enabled for cleaner presentation
- Syntax highlighting applied

**Rendering Process**:
1. Quarto scans year folders for `.Rmd` and `.qmd` files
2. Executes R code chunks (if `freeze: auto` not set)
3. Generates HTML output with embedded images and results
4. Applies website theme and styling
5. Creates navigation links

**Interface**:
- Input: `.Rmd` or `.qmd` files
- Output: `.html` files
- Dependencies: R, knitr, Quarto

### Component 6: Calendar Integration

**Purpose**: Promote Golden Dome Data Tuesday sessions and enable calendar subscriptions

**Implementation**: HTML/JavaScript calendar widget with ICS file generation

**Session Details**:
- Event: Golden Dome Data Tuesday
- Schedule: Every Tuesday at 11:00 AM PT (except major holidays)
- Zoom Link: https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09
- Duration: 1 hour (assumed)

**Calendar Integration Methods**:

1. **ICS File Generation** (for recurring series):
```ics
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//TidyTuesday//Golden Dome Data Tuesday//EN
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:Golden Dome Data Tuesday
X-WR-TIMEZONE:America/Los_Angeles
X-WR-CALDESC:Weekly TidyTuesday data visualization sessions

BEGIN:VEVENT
DTSTART;TZID=America/Los_Angeles:20250101T110000
DTEND;TZID=America/Los_Angeles:20250101T120000
RRULE:FREQ=WEEKLY;BYDAY=TU
SUMMARY:Golden Dome Data Tuesday
DESCRIPTION:Join us for weekly TidyTuesday data visualization sessions!\n\nZoom: https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09
LOCATION:https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09
URL:https://gdatascience.github.io/tidytuesday
STATUS:CONFIRMED
SEQUENCE:0
END:VEVENT

END:VCALENDAR
```

2. **Google Calendar Link**:
```
https://calendar.google.com/calendar/render?action=TEMPLATE&text=Golden+Dome+Data+Tuesday&details=Join+us+for+weekly+TidyTuesday+data+visualization+sessions!%0A%0AZoom:+https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09&location=https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09&recur=RRULE:FREQ=WEEKLY;BYDAY=TU&dates=20250101T190000Z/20250101T200000Z
```

3. **Add to Calendar Widget**:
```html
<div class="calendar-widget">
  <h3>Join Golden Dome Data Tuesday</h3>
  <p class="session-info">
    <strong>Every Tuesday at 11:00 AM PT</strong><br>
    (except major holidays)
  </p>
  <p class="zoom-link">
    <a href="https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09" 
       target="_blank" 
       rel="noopener">
      Join Zoom Meeting
    </a>
  </p>
  <div class="calendar-buttons">
    <a href="golden-dome-data-tuesday.ics" download class="btn btn-primary">
      📅 Subscribe to Series
    </a>
    <a href="https://calendar.google.com/calendar/render?action=TEMPLATE&..." 
       target="_blank" 
       class="btn btn-secondary">
      Add to Google Calendar
    </a>
  </div>
</div>
```

**Key Functions**:

```r
# Generate ICS file for recurring event
generate_calendar_ics <- function(output_file = "golden-dome-data-tuesday.ics") {
  ics_content <- '
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//TidyTuesday//Golden Dome Data Tuesday//EN
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:Golden Dome Data Tuesday
X-WR-TIMEZONE:America/Los_Angeles

BEGIN:VTIMEZONE
TZID:America/Los_Angeles
BEGIN:STANDARD
DTSTART:19701101T020000
RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU
TZOFFSETFROM:-0700
TZOFFSETTO:-0800
END:STANDARD
BEGIN:DAYLIGHT
DTSTART:19700308T020000
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
TZOFFSETFROM:-0800
TZOFFSETTO:-0700
END:DAYLIGHT
END:VTIMEZONE

BEGIN:VEVENT
UID:golden-dome-data-tuesday@gdatascience.github.io
DTSTART;TZID=America/Los_Angeles:20250107T110000
DTEND;TZID=America/Los_Angeles:20250107T120000
RRULE:FREQ=WEEKLY;BYDAY=TU
SUMMARY:Golden Dome Data Tuesday
DESCRIPTION:Join us for weekly TidyTuesday data visualization sessions!\\n\\nZoom: https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09
LOCATION:https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09
URL:https://gdatascience.github.io/tidytuesday
STATUS:CONFIRMED
END:VEVENT

END:VCALENDAR
'
  
  writeLines(ics_content, output_file)
  return(output_file)
}

# Generate Google Calendar URL
generate_google_calendar_url <- function() {
  base_url <- "https://calendar.google.com/calendar/render"
  
  params <- list(
    action = "TEMPLATE",
    text = "Golden Dome Data Tuesday",
    details = paste(
      "Join us for weekly TidyTuesday data visualization sessions!",
      "",
      "Zoom: https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09",
      sep = "\n"
    ),
    location = "https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09",
    recur = "RRULE:FREQ=WEEKLY;BYDAY=TU",
    dates = "20250107T190000Z/20250107T200000Z"  # First Tuesday in 2025, UTC
  )
  
  query_string <- paste(
    names(params),
    sapply(params, URLencode, reserved = TRUE),
    sep = "=",
    collapse = "&"
  )
  
  return(paste0(base_url, "?", query_string))
}
```

**Interface**:
- Input: Session details (schedule, Zoom link)
- Output: ICS file, calendar URLs, HTML widget
- Dependencies: None (pure HTML/CSS/JavaScript)

## Data Models

### File Metadata Model

```r
# Represents a TidyTuesday file
TidyTuesdayFile <- list(
  filename = character(),      # Original filename
  year = character(),          # Extracted year (YYYY)
  month = character(),         # Extracted month (MM)
  day = character(),           # Extracted day (DD)
  topic = character(),         # Topic extracted from filename
  file_type = character(),     # Extension: Rmd, qmd, png, gif, html
  original_path = character(), # Original file path
  new_path = character(),      # Destination path after organization
  has_image = logical(),       # Whether visualization exists
  has_analysis = logical()     # Whether analysis file exists
)
```

### Visualization Model

```r
# Represents a TidyTuesday visualization for display
Visualization <- list(
  date = Date(),               # Date of analysis
  year = character(),          # Year (YYYY)
  image_path = character(),    # Path to image file (PNG or GIF)
  image_type = character(),    # "png" or "gif"
  analysis_path = character(), # Path to analysis file (.Rmd or .qmd)
  analysis_html = character(), # Path to rendered HTML
  title = character(),         # Display title
  topic = character()          # Topic name
)
```

### Website Configuration Model

```yaml
# Quarto website configuration structure
WebsiteConfig:
  project:
    type: string              # "website"
    output_dir: string        # "_site"
  
  website:
    title: string
    description: string
    site_url: string
    repo_url: string
    
    navbar:
      background: string      # Kelly Green hex
      foreground: string      # White hex
      title: string
      left: array             # Navigation items
      right: array            # Social links
    
    sidebar:
      style: string           # "floating"
      contents: array         # Year navigation
  
  format:
    html:
      theme: array            # Base theme + custom SCSS
      css: string             # Additional CSS file
      toc: boolean
      code_fold: boolean
      code_tools: boolean
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: Year folder creation completeness
*For any* set of TidyTuesday files with valid year prefixes (YYYY_MM_DD_*), running the File_Organizer should create year folders for all unique years found in the filenames.
**Validates: Requirements 1.1**

### Property 2: Pattern-matching files moved to correct year folders
*For any* file matching the TidyTuesday naming pattern (YYYY_MM_DD_tidy_tuesday_*.[Rmd|qmd|png|gif|html]), the File_Organizer should move it to the folder named with the extracted year (YYYY).
**Validates: Requirements 1.2, 1.3**

### Property 3: Related files stay together
*For any* set of files sharing the same date prefix (YYYY_MM_DD), all files should be moved to the same year folder.
**Validates: Requirements 1.4**

### Property 4: Filename preservation during move
*For any* file moved by the File_Organizer, the basename of the file should remain unchanged after the move operation.
**Validates: Requirements 1.5**

### Property 5: Non-matching files remain in root
*For any* file that does not match the TidyTuesday naming pattern (YYYY_MM_DD_tidy_tuesday_*), the File_Organizer should leave it in the root directory.
**Validates: Requirements 1.6, 6.6**

### Property 6: All year folders included in site structure
*For any* set of year folders present in the repository, the Website_Generator should include all of them in the generated website navigation.
**Validates: Requirements 2.5**

### Property 7: Image display logic with GIF priority
*For any* analysis with output images, the Image_Grid should display the GIF if it exists, otherwise display the PNG if it exists, and exclude the analysis if neither exists.
**Validates: Requirements 3.1, 3.2, 3.3, 3.6**

### Property 8: Chronological ordering of images
*For any* set of images in the Image_Grid, they should be ordered by date in descending order (newest first).
**Validates: Requirements 3.5**

### Property 9: Image links to correct rendered document
*For any* image displayed in the Image_Grid, clicking it should navigate to the HTML file with the same base name as the corresponding analysis file.
**Validates: Requirements 4.1, 4.4**

### Property 10: Analysis files rendered to HTML
*For any* analysis file (.Rmd or .qmd) in a year folder, the Website_Generator should produce a corresponding .html file with the same base name.
**Validates: Requirements 4.2**

### Property 11: File existence verification after move
*For any* file that the File_Organizer attempts to move, the file should exist at the destination path after the move operation completes.
**Validates: Requirements 5.1**

### Property 12: Metadata preservation during move
*For any* file moved by the File_Organizer, the file's modification timestamp should be preserved (within filesystem precision limits).
**Validates: Requirements 5.4**

### Property 13: Year navigation completeness
*For any* set of year folders with visualizations, all years should appear in the website navigation menu.
**Validates: Requirements 7.1**

### Property 14: Year page filtering
*For any* year-specific page, only visualizations with dates matching that year should be displayed in the Image_Grid.
**Validates: Requirements 7.2**

### Property 15: Visualization count accuracy
*For any* year in the navigation menu, the displayed count should equal the number of visualizations (analysis files with corresponding images) in that year folder.
**Validates: Requirements 7.5**

### Property 16: Calendar ICS file validity
*For any* generated ICS file for Golden Dome Data Tuesday, it should be valid according to RFC 5545 iCalendar specification and parseable by standard calendar applications.
**Validates: Requirements 10.4, 10.5**

### Property 17: Calendar information completeness
*For any* page displaying the Golden Dome Data Tuesday information, it should include the schedule (11am PT every Tuesday), the Zoom link, and calendar subscription options.
**Validates: Requirements 10.1, 10.2, 10.3, 10.7**

## Error Handling

### File Organization Errors

**Missing Source File**:
- Detection: Check file existence before move operation
- Response: Log error with filename, skip file, continue with remaining files
- Recovery: User can re-run script after fixing issue

**Permission Denied**:
- Detection: Catch file system permission errors during move
- Response: Log error with filename and permission details, halt process
- Recovery: User fixes permissions and re-runs script

**Destination Already Exists**:
- Detection: Check if destination file exists before move
- Response: Log warning, skip file (assume already organized)
- Recovery: User can manually resolve conflicts

**Invalid Year Extraction**:
- Detection: Year extraction returns NA or invalid value
- Response: Log warning with filename, skip file
- Recovery: User can manually move file or fix filename

### Website Generation Errors

**Missing Year Folder**:
- Detection: Check year folder existence before generating year page
- Response: Log warning, skip year in navigation
- Recovery: Automatic on next build after folder is created

**Rendering Failure**:
- Detection: Quarto/R Markdown returns non-zero exit code
- Response: Log error with filename and error message, continue with other files
- Recovery: User fixes analysis file and rebuilds

**Missing Image File**:
- Detection: Image path in visualization data doesn't exist
- Response: Skip visualization in grid, log warning
- Recovery: Automatic on next build after image is created

**Invalid Configuration**:
- Detection: YAML parsing errors in _quarto.yml
- Response: Quarto reports error and halts build
- Recovery: User fixes YAML syntax and rebuilds

### Data Integrity Errors

**File Copy Failure**:
- Detection: Destination file doesn't exist after copy operation
- Response: Halt process, report error, do not delete source
- Recovery: User investigates disk space/permissions and re-runs

**Incomplete Move**:
- Detection: Source file still exists after move should be complete
- Response: Halt process, report error
- Recovery: User manually completes or reverts move

## Testing Strategy

### Dual Testing Approach

This feature requires both unit tests and property-based tests for comprehensive coverage:

**Unit Tests**: Focus on specific examples, edge cases, and error conditions
- Test specific file patterns (e.g., "2024_01_15_tidy_tuesday_test.Rmd")
- Test error conditions (missing files, permission errors)
- Test configuration file parsing
- Test HTML generation for specific inputs

**Property Tests**: Verify universal properties across all inputs
- Test file organization with randomly generated filenames
- Test image grid generation with random sets of visualizations
- Test year extraction with random valid dates
- Test sorting and filtering with random data sets

### Property-Based Testing Configuration

**Testing Library**: Use the `hedgehog` package for R property-based testing

**Test Configuration**:
- Minimum 100 iterations per property test
- Each test tagged with: **Feature: tidytuesday-website-organization, Property {number}: {property_text}**

**Example Property Test Structure**:
```r
library(hedgehog)

test_that("Property 2: Pattern-matching files moved to correct year folders", {
  # Feature: tidytuesday-website-organization, Property 2
  
  forall(
    gen.sample(gen.element(2018:2026), of = 10),  # Random years
    gen.sample(gen.int(12), of = 10),              # Random months
    gen.sample(gen.int(28), of = 10),              # Random days
    function(years, months, days) {
      # Generate random filenames
      filenames <- sprintf(
        "%04d_%02d_%02d_tidy_tuesday_test.Rmd",
        years, months, days
      )
      
      # Create temp directory and files
      temp_dir <- tempdir()
      for (f in filenames) {
        file.create(file.path(temp_dir, f))
      }
      
      # Run organizer
      organize_tidytuesday_files(temp_dir)
      
      # Verify each file is in correct year folder
      for (i in seq_along(filenames)) {
        expected_path <- file.path(
          temp_dir,
          as.character(years[i]),
          filenames[i]
        )
        expect_true(file.exists(expected_path))
      }
      
      TRUE
    }
  )
})
```

### Unit Test Coverage

**File Organizer Tests**:
- Test year extraction from valid filenames
- Test year extraction from invalid filenames
- Test folder creation
- Test file moving with validation
- Test exclusion of special files/directories
- Test error handling for missing files
- Test error handling for permission errors

**Website Generator Tests**:
- Test visualization data extraction from year folder
- Test image grid HTML generation
- Test GIF priority over PNG
- Test chronological sorting
- Test filtering by year
- Test navigation menu generation
- Test configuration file creation
- Test ICS file generation for calendar
- Test Google Calendar URL generation
- Test calendar widget HTML generation

**Integration Tests**:
- Test complete file organization workflow
- Test complete website generation workflow
- Test end-to-end: organize files → generate website → verify output
- Test calendar ICS file can be imported into calendar applications

### Test Data

**Sample File Structure for Testing**:
```
test_repo/
├── 2024_01_15_tidy_tuesday_test.Rmd
├── 2024_01_15_tidy_tuesday_test.png
├── 2024_01_15_tidy_tuesday_test.gif
├── 2023_12_20_tidy_tuesday_example.qmd
├── 2023_12_20_tidy_tuesday_example.png
├── invalid_filename.Rmd
├── .Rproj.user/
├── tidytuesday.Rproj
└── _publish.yml
```

**Expected Output After Organization**:
```
test_repo/
├── 2024/
│   ├── 2024_01_15_tidy_tuesday_test.Rmd
│   ├── 2024_01_15_tidy_tuesday_test.png
│   └── 2024_01_15_tidy_tuesday_test.gif
├── 2023/
│   ├── 2023_12_20_tidy_tuesday_example.qmd
│   └── 2023_12_20_tidy_tuesday_example.png
├── invalid_filename.Rmd
├── .Rproj.user/
├── tidytuesday.Rproj
└── _publish.yml
```

## Implementation Notes

### File Organization Considerations

1. **Dry Run Mode**: Implement a `dry_run` parameter that logs what would be moved without actually moving files
2. **Progress Reporting**: Log progress for large repositories (e.g., "Moved 50/200 files")
3. **Summary Report**: Generate a summary showing files moved, skipped, and any errors
4. **Idempotency**: Script should be safe to run multiple times (skip already-organized files)

### Website Generation Considerations

1. **Incremental Builds**: Use Quarto's `freeze` feature to avoid re-rendering unchanged analysis files
2. **Image Optimization**: Consider adding image optimization step for faster page loads
3. **Lazy Loading**: Implement lazy loading for images in the grid
4. **Search Functionality**: Consider adding search/filter functionality for large numbers of visualizations
5. **RSS Feed**: Consider generating an RSS feed for new visualizations

### Performance Considerations

1. **File Operations**: Use batch operations where possible
2. **Parallel Rendering**: Quarto can render files in parallel for faster builds
3. **Caching**: Cache visualization metadata to speed up grid generation
4. **CDN**: Consider using GitHub's CDN for faster image delivery

### Deployment Workflow

1. **GitHub Actions**: Set up automated workflow to build and deploy site on push
2. **Branch Strategy**: Use separate branch for generated site (e.g., `gh-pages`)
3. **Build Artifacts**: Store build logs and reports as artifacts
4. **Deployment Verification**: Add checks to verify successful deployment

### Future Enhancements

1. **Tags/Categories**: Add tagging system for visualizations by topic
2. **Search**: Full-text search across analyses
3. **Analytics**: Add privacy-respecting analytics
4. **Comments**: Consider adding comment system (e.g., utterances)
5. **Dark Mode**: Add dark mode toggle
6. **Mobile App**: Progressive Web App (PWA) support
