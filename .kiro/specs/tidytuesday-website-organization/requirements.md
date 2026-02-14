# Requirements Document

## Introduction

This feature enables organization of a TidyTuesday repository containing R analysis files spanning from 2018 to 2026, and creates a GitHub Pages website to showcase the work. The system will reorganize files from a flat root directory structure into year-based folders and generate a website with a grid display of visualization outputs that link to rendered analysis documents.

## Glossary

- **TidyTuesday_Repository**: The Git repository containing R Markdown and Quarto analysis files
- **Analysis_File**: An R Markdown (.Rmd) or Quarto (.qmd) file containing data analysis code
- **Output_Image**: A PNG, GIF, or HTML file generated from an Analysis_File
- **Year_Folder**: A directory named with a four-digit year (e.g., "2018", "2019") containing Analysis_Files and Output_Images from that year
- **Website_Generator**: The system component that creates the GitHub Pages website
- **Image_Grid**: A visual layout displaying Output_Images in a grid format on the website
- **Rendered_Document**: The HTML output generated from an Analysis_File when processed by R Markdown or Quarto
- **File_Organizer**: The system component that moves files from root directory to Year_Folders
- **GitHub_Pages_Site**: The static website hosted at gdatascience.github.io

## Requirements

### Requirement 1: Organize Files by Year

**User Story:** As a repository maintainer, I want to organize analysis files into year-based folders, so that the repository structure is more manageable and navigable.

#### Acceptance Criteria

1. THE File_Organizer SHALL create Year_Folders for each unique year found in file names (2018-2026)
2. WHEN an Analysis_File follows the naming pattern YYYY_MM_DD_tidy_tuesday_*.Rmd or YYYY_MM_DD_tidy_tuesday_*.qmd, THE File_Organizer SHALL move it to the corresponding Year_Folder
3. WHEN an Output_Image follows the naming pattern YYYY_MM_DD_tidy_tuesday_*.png, YYYY_MM_DD_tidy_tuesday_*.gif, or YYYY_MM_DD_tidy_tuesday_*.html, THE File_Organizer SHALL move it to the corresponding Year_Folder
4. WHEN multiple files share the same date prefix (YYYY_MM_DD), THE File_Organizer SHALL move all related files to the same Year_Folder
5. THE File_Organizer SHALL preserve the original file names when moving files
6. WHEN a file does not match the expected naming pattern, THE File_Organizer SHALL leave it in the root directory

### Requirement 2: Generate GitHub Pages Website

**User Story:** As a data scientist, I want to create a GitHub Pages website that showcases my TidyTuesday visualizations, so that others can easily view and access my work.

#### Acceptance Criteria

1. THE Website_Generator SHALL create a static website compatible with GitHub Pages
2. THE Website_Generator SHALL configure the website to be hosted on the existing GitHub Pages site (gdatascience.github.io)
3. THE Website_Generator SHALL use Quarto or R Markdown to generate the website structure
4. THE Website_Generator SHALL create an index page that serves as the main landing page
5. WHEN the website is built, THE Website_Generator SHALL include all Year_Folders in the site structure

### Requirement 3: Display Images in Grid Format

**User Story:** As a website visitor, I want to see TidyTuesday visualizations displayed in a grid layout, so that I can quickly browse through multiple visualizations.

#### Acceptance Criteria

1. THE Website_Generator SHALL display Output_Images in an Image_Grid on the index page
2. THE Image_Grid SHALL show PNG files as the primary display format
3. WHEN a GIF file exists for an analysis, THE Image_Grid SHALL display the GIF instead of the PNG
4. THE Image_Grid SHALL arrange images in a responsive grid layout that adapts to different screen sizes
5. THE Image_Grid SHALL display images in reverse chronological order (newest first)
6. WHEN an Analysis_File has no corresponding Output_Image, THE Website_Generator SHALL exclude it from the Image_Grid

### Requirement 4: Link Images to Rendered Documents

**User Story:** As a website visitor, I want to click on visualization images to view the full analysis, so that I can understand the code and methodology behind each visualization.

#### Acceptance Criteria

1. WHEN a visitor clicks on an image in the Image_Grid, THE Website_Generator SHALL navigate to the corresponding Rendered_Document
2. THE Website_Generator SHALL render each Analysis_File to HTML format for web viewing
3. THE Website_Generator SHALL preserve code chunks, outputs, and formatting from the original Analysis_File in the Rendered_Document
4. THE Website_Generator SHALL create a unique URL for each Rendered_Document based on its file name
5. WHEN an Analysis_File is in Quarto format (.qmd), THE Website_Generator SHALL use Quarto to render it
6. WHEN an Analysis_File is in R Markdown format (.Rmd), THE Website_Generator SHALL use R Markdown to render it

### Requirement 5: Maintain Repository Integrity

**User Story:** As a repository maintainer, I want to ensure that the reorganization process does not lose or corrupt any files, so that all historical work is preserved.

#### Acceptance Criteria

1. THE File_Organizer SHALL verify that each file exists in its new location after moving
2. WHEN a file move operation fails, THE File_Organizer SHALL report the error and halt the reorganization process
3. THE File_Organizer SHALL create a backup or use Git version control to enable rollback if needed
4. THE File_Organizer SHALL preserve file metadata (creation date, modification date) when moving files
5. WHEN files are moved, THE File_Organizer SHALL update any relative path references in configuration files

### Requirement 6: Handle Special Files and Directories

**User Story:** As a repository maintainer, I want special files and directories to remain in their current locations, so that project configuration and supporting files are not disrupted.

#### Acceptance Criteria

1. THE File_Organizer SHALL exclude the .Rproj.user/ directory from reorganization
2. THE File_Organizer SHALL exclude the .kiro/ directory from reorganization
3. THE File_Organizer SHALL exclude the rsconnect/ directory from reorganization
4. THE File_Organizer SHALL exclude project configuration files (.Rproj, .gitignore, _publish.yml) from reorganization
5. THE File_Organizer SHALL exclude supporting directories (e.g., *_files/, nybb_22c/, pinewood_derby/) from reorganization
6. THE File_Organizer SHALL exclude non-TidyTuesday analysis files from reorganization

### Requirement 7: Generate Website Navigation

**User Story:** As a website visitor, I want to navigate between different years of TidyTuesday analyses, so that I can explore work from specific time periods.

#### Acceptance Criteria

1. THE Website_Generator SHALL create a navigation menu that lists all available years
2. WHEN a visitor selects a year from the navigation menu, THE Website_Generator SHALL display only visualizations from that year
3. THE Website_Generator SHALL indicate the currently selected year in the navigation menu
4. THE Website_Generator SHALL provide a link to return to the main page showing all visualizations
5. THE Website_Generator SHALL display the count of visualizations for each year in the navigation menu

### Requirement 8: Configure Website Metadata

**User Story:** As a repository maintainer, I want to configure website metadata and styling, so that the site reflects my personal brand and is discoverable.

#### Acceptance Criteria

1. THE Website_Generator SHALL allow configuration of the website title
2. THE Website_Generator SHALL allow configuration of the website description for SEO purposes
3. THE Website_Generator SHALL allow configuration of author information (name, social media handles)
4. THE Website_Generator SHALL support custom CSS styling for the website
5. THE Website_Generator SHALL generate appropriate meta tags for social media sharing (Open Graph, Twitter Cards)

### Requirement 9: Apply Notre Dame Theme

**User Story:** As a repository maintainer, I want the website to reflect my University of Notre Dame affiliation with a professional and modern design, so that the site expresses my personality and institutional pride.

#### Acceptance Criteria

1. THE Website_Generator SHALL use Kelly Green as the primary color throughout the website
2. THE Website_Generator SHALL implement a color scheme inspired by University of Notre Dame branding (Kelly Green, Gold, Navy Blue)
3. THE Website_Generator SHALL create a modern and professional visual design
4. THE Website_Generator SHALL use typography that is clean and readable
5. THE Website_Generator SHALL incorporate subtle Notre Dame-themed design elements without overwhelming the content
6. THE Website_Generator SHALL ensure the theme maintains good contrast and accessibility standards


### Requirement 10: Promote Golden Dome Data Tuesday Sessions

**User Story:** As a repository maintainer, I want to promote my weekly Golden Dome Data Tuesday sessions on the website, so that visitors can join the live sessions and add them to their calendars.

#### Acceptance Criteria

1. THE Website_Generator SHALL display information about Golden Dome Data Tuesday sessions on the website
2. THE Website_Generator SHALL show the session schedule (11am PT every Tuesday except major holidays)
3. THE Website_Generator SHALL display the Zoom meeting link (https://notredame.zoom.us/j/93246968828?pwd=T2k0QUFKNkxvMkV2ekZrejdpdTJIdz09)
4. THE Website_Generator SHALL provide a way for visitors to subscribe to the calendar series
5. THE Website_Generator SHALL support multiple calendar formats (Google Calendar, iCal, Outlook)
6. THE Website_Generator SHALL allow visitors to add individual session events to their calendar
7. THE Website_Generator SHALL make the session information prominent and easily discoverable on the website
