# Can Italian Factories Predict Wall Street?

Data comes from the [TidyTuesday project](https://github.com/rfordatascience/tidytuesday/tree/master/data/2026/2026-05-05).

Italian beer production tracks the S&P 500 almost perfectly over 100 years — when beer goes up, stocks go up. Time to trade based on Italian brewery output? Not so fast. This week's dataset covers 120+ years of Italian industrial production (silk, ships, beer, cars) from ISTAT. I paired it with Shiller's S&P 500 data and ran Lasso regression, Random Forest, and time-series cross-validation. The result: both just happen to grow over time. Once you look at whether a *good year* for Italian beer means a *good year* for stocks, the relationship completely disappears. Every ML model explains nothing. A textbook lesson in spurious correlation.

Kiro handled the heavy lifting — EDA across all three datasets, the ML pipeline, blog post narrative, and visualization iteration. I steered the story and design. The final image was polished with Google Nano Banana Pro.

![](outputs/2026_05_06_italian_industry.png)

## Source Code

- [2026_05_06_italian_industry.Rmd](2026_05_06_italian_industry.Rmd)

