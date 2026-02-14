# Implementation Plan: TidyTuesday Website Organization

## Overview

This implementation plan breaks down the TidyTuesday repository organization and website generation into discrete coding tasks. The approach follows a phased implementation: (1) file organization script, (2) Quarto website structure, (3) image grid generation, (4) Notre Dame theming, and (5) calendar integration.

## Tasks

- [ ] 1. Create file organization script
  - [ ] 1.1 Implement year extraction function
    - Write `extract_year()` function to parse YYYY from filenames
    - Handle edge cases (invalid formats, missing year)
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [ ]* 1.2 Write property test for year extraction
    - **Property 1: Year folder creation completeness**
    - **Validates: Requirements 1.1**
  
  - [ ] 1.3 Implement file discovery function
    - Write `get_tidytuesday_files()` to find files matching pattern
    - Use regex pattern: `^\\d{4}_\\d{2}_\\d{2}_.*\\.(Rmd|qmd|png|gif|html)$`
    - _Requirements: 1.2, 1.3, 1.6_
  
  - [ ]* 1.4 Write property test for pattern matching
    - **Property 2: Pattern-matching files moved to correct year folders**
    - **Property 5: Non-matching files remain in root**
    - **Validates: Requirements 1.2, 1.3, 1.6, 6.6**
  
  - [ ] 1.5 Implement safe file move function
    - Write `move_file_safely()` with validation
    - Verify destination exists before removing source
    - Preserve file metadata (modification time)
    - _Requirements: 5.1, 5.2, 5.4_
  
  - [ ]* 1.6 Write property tests for file moving
    - **Property 4: Filename preservation during move**
    - **Property 11: File existence verification after move**
    - **Property 12: Metadata preservation during move**
    - **Validates: Requirements 1.5, 5.1, 5.4**
  
  - [ ] 1.7 Implement main organization function
    - Write `organize_tidytuesday_files()` orchestration function
    - Create year folders as needed
    - Move files with error handling
    - Generate summary report
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  
  - [ ]* 1.8 Write property test for related files
    - **Property 3: Related files stay together**
    - **Validates: Requirements 1.4**
  
  - [ ]* 1.9 Write unit tests for error handling
    - Test missing source file error
    - Test permission denied error
    - Test destination already exists scenario
    - _Requirements: 5.2_

- [ ] 2. Checkpoint - Test file organization script
  - Run script on test data
  - Verify files moved correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 3. Set up Quarto website structure
  - [ ] 3.1 Create _quarto.yml configuration file
    - Define project type as website
    - Configure output directory (_site)
    - Set up navbar with Notre Dame Kelly Green background (#00843D)
    - Add GitHub and Twitter links to navbar
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 8.1, 8.2, 8.3, 9.1_
  
  - [ ] 3.2 Create sidebar navigation with year links
    - Add sidebar configuration to _quarto.yml
    - List years 2018-2026 with links to year pages
    - _Requirements: 2.5, 7.1_
  
  - [ ]* 3.3 Write unit test for configuration
    - Verify _quarto.yml is valid YAML
    - Verify site-url points to gdatascience.github.io
    - _Requirements: 2.2_
  
  - [ ] 3.4 Create main index.qmd file
    - Add YAML header with title and description
    - Create placeholder content structure
    - _Requirements: 2.4, 8.1, 8.2_
  
  - [ ] 3.5 Create about.qmd page
    - Add information about TidyTuesday project
    - Include author bio and social links
    - _Requirements: 8.3_

- [ ] 4. Implement Notre Dame theme styling
  - [ ] 4.1 Create custom.scss file
    - Define Notre Dame color variables (Kelly Green, Gold, Navy)
    - Style navbar with Kelly Green background
    - Style headings with primary color
    - Style links with hover effects
    - _Requirements: 9.1, 9.2_
  
  - [ ] 4.2 Create styles.css file
    - Define image grid layout (CSS Grid)
    - Style grid items with hover effects
    - Add responsive breakpoints for mobile
    - Style grid captions
    - _Requirements: 3.4, 9.1, 9.2_
  
  - [ ] 4.3 Update _quarto.yml to use custom theme
    - Add custom.scss to theme array
    - Add styles.css to format configuration
    - _Requirements: 8.4, 9.1, 9.2_

- [ ] 5. Implement image grid generation
  - [ ] 5.1 Create visualization discovery function
    - Write `get_visualizations()` to find images and analysis files
    - Match PNG/GIF files with corresponding Rmd/qmd files
    - Implement GIF priority logic
    - Sort by date descending
    - _Requirements: 3.1, 3.2, 3.3, 3.5, 3.6_
  
  - [ ]* 5.2 Write property tests for visualization discovery
    - **Property 7: Image display logic with GIF priority**
    - **Property 8: Chronological ordering of images**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.5, 3.6**
  
  - [ ] 5.3 Create HTML grid generation function
    - Write `generate_image_grid()` to create HTML
    - Generate grid-item divs with images and links
    - Format dates for captions
    - _Requirements: 3.1, 4.1_
  
  - [ ]* 5.4 Write property test for image links
    - **Property 9: Image links to correct rendered document**
    - **Validates: Requirements 4.1, 4.4**
  
  - [ ] 5.5 Integrate grid generation into index.qmd
    - Add R code chunk to generate visualization data
    - Call `generate_image_grid()` and output HTML
    - Use `results='asis'` for raw HTML output
    - _Requirements: 3.1, 4.1_

- [ ] 6. Create year-specific pages
  - [ ] 6.1 Generate index.qmd for each year folder
    - Create template for year page
    - Filter visualizations by year
    - Generate image grid for year
    - _Requirements: 7.2_
  
  - [ ]* 6.2 Write property test for year filtering
    - **Property 14: Year page filtering**
    - **Validates: Requirements 7.2**
  
  - [ ] 6.3 Add visualization counts to navigation
    - Calculate count of visualizations per year
    - Update sidebar configuration with counts
    - _Requirements: 7.5_
  
  - [ ]* 6.4 Write property test for visualization counts
    - **Property 15: Visualization count accuracy**
    - **Validates: Requirements 7.5**

- [ ] 7. Checkpoint - Test website generation
  - Build website with `quarto render`
  - Verify all pages generate correctly
  - Check image grid displays properly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Implement calendar integration
  - [ ] 8.1 Create ICS file generation function
    - Write `generate_calendar_ics()` function
    - Generate RFC 5545 compliant ICS content
    - Include recurring rule for weekly Tuesdays
    - Add Zoom link to description and location
    - Save to golden-dome-data-tuesday.ics
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
  
  - [ ]* 8.2 Write property test for ICS validity
    - **Property 16: Calendar ICS file validity**
    - **Validates: Requirements 10.4, 10.5**
  
  - [ ] 8.3 Create Google Calendar URL generation function
    - Write `generate_google_calendar_url()` function
    - Build URL with proper parameters
    - URL encode all parameters
    - _Requirements: 10.5, 10.6_
  
  - [ ] 8.4 Create calendar widget HTML component
    - Design calendar widget with session info
    - Add Zoom link button
    - Add "Subscribe to Series" button (downloads ICS)
    - Add "Add to Google Calendar" button
    - Style with Notre Dame theme colors
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7_
  
  - [ ]* 8.5 Write property test for calendar information
    - **Property 17: Calendar information completeness**
    - **Validates: Requirements 10.1, 10.2, 10.3, 10.7**
  
  - [ ] 8.6 Integrate calendar widget into website
    - Add calendar widget to index.qmd (prominent placement)
    - Add calendar widget to about.qmd
    - Generate ICS file during website build
    - _Requirements: 10.7_

- [ ] 9. Configure website metadata and SEO
  - [ ] 9.1 Add Open Graph meta tags
    - Add og:title, og:description, og:image tags
    - Add og:url pointing to site URL
    - _Requirements: 8.5_
  
  - [ ] 9.2 Add Twitter Card meta tags
    - Add twitter:card, twitter:title, twitter:description
    - Add twitter:creator with @GDataScience1
    - _Requirements: 8.3, 8.5_
  
  - [ ] 9.3 Create social media preview image
    - Design preview image with Notre Dame branding
    - Save as og-image.png in root
    - Reference in meta tags
    - _Requirements: 8.5, 9.1, 9.2_

- [ ] 10. Set up GitHub Pages deployment
  - [ ] 10.1 Create .github/workflows/publish.yml
    - Configure GitHub Actions workflow
    - Install R and Quarto
    - Run file organization script (if needed)
    - Build Quarto website
    - Deploy to gh-pages branch
    - _Requirements: 2.1, 2.2_
  
  - [ ] 10.2 Configure repository settings
    - Enable GitHub Pages
    - Set source to gh-pages branch
    - Configure custom domain if needed
    - _Requirements: 2.2_
  
  - [ ]* 10.3 Write integration test for deployment
    - Test complete workflow: organize → build → verify output
    - Verify all expected files exist in _site directory
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 11. Create documentation
  - [ ] 11.1 Write README.md
    - Document repository structure
    - Explain file organization script usage
    - Explain website build process
    - Add instructions for adding new analyses
    - _Requirements: 1.1, 2.1_
  
  - [ ] 11.2 Add comments to organize_files.R
    - Document each function with roxygen2 style comments
    - Add usage examples
    - _Requirements: 1.1_
  
  - [ ] 11.3 Create CONTRIBUTING.md
    - Explain how to contribute new TidyTuesday analyses
    - Document naming conventions
    - Explain Golden Dome Data Tuesday sessions
    - _Requirements: 10.1_

- [ ] 12. Final checkpoint - End-to-end testing
  - Run file organization on actual repository
  - Build complete website
  - Test all links and navigation
  - Verify calendar integration works
  - Test on mobile devices
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- The file organization script (Task 1) should be run once to reorganize existing files
- After initial organization, new files can be added directly to year folders
- The website build process (Tasks 3-9) can be automated with GitHub Actions
- Property tests use the `hedgehog` package for R
- Each property test should run minimum 100 iterations
- Calendar ICS file should be regenerated on each website build to stay current
