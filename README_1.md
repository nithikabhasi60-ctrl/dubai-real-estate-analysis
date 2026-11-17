# Dubai Real Estate Analysis: Sales, Off-Plan & Rentals

**Tools:** MySQL · SQL · Python (pandas) · Power BI (DAX, star schema)

An end-to-end analysis of Dubai property listings (2020 to 2026): which communities are most expensive, where rental yields are highest, how much more off-plan costs than resale, how prices moved as mortgage rates rose, and whether being close to a metro station raises prices.

## Dashboard preview

| Market Overview | Resale vs Off-plan vs Rent | Trends and Metro |
|---|---|---|
| ![Page 1](dashboard/screenshots/page1_market_overview.png) | ![Page 2](dashboard/screenshots/page2_sale_offplan_rent.png) | ![Page 3](dashboard/screenshots/page3_trends_metro.png) |

**Power BI file:** [Download the .pbix from Google Drive](https://drive.google.com/file/d/1DucT9pgrFcgkObgxpetrTaqC58HSYSvc/view?usp=sharing) (open it with Power BI Desktop).

## Business questions

1. Which communities are the most expensive per sq ft?
2. Where is the gross rental yield highest?
3. How much more does off-plan cost than resale?
4. How did prices move from 2020 to 2026, and how does that line up with mortgage rates?
5. Do properties close to a metro station sell for more?

## Dataset

**Source:** Kaggle, "Dubai Real Estate: Sales & Rentals (2020-2026)" (Apache 2.0 licence). [Add the dataset link here]

| File | Rows | Description |
|---|---|---|
| `secondary_sales.csv` | 50,000 | Resale apartment and villa listings |
| `off_plan.csv` | 12,000 | Off-plan listings (200 projects) |
| `rentals.csv` | 25,000 | Annual rental contracts |
| `area_prices_monthly.csv` | 6,384 | Monthly series: 84 communities x 76 months (Jan 2020 to Apr 2026) |
| `metro_stations.csv` | 55 | Dubai Metro stations (Red and Green lines) with coordinates |

> **Note on the data:** the source does not document how the data was collected, so the findings describe patterns in this dataset and should not be read as official market statistics. 2026 is a partial year (January to April).

## Process

1. **MySQL:** created the database and tables, loaded the five files, and checked row counts and duplicate IDs.
2. **SQL analysis:** aggregations, joins, `CASE WHEN` bucketing and `WITH` (CTE) queries for price, yield, off-plan premium, trends and metro distance.
3. **Python (pandas):** converted dates, removed repeated columns, checked duplicates, created metro distance buckets, and tested the metro effect *within* communities.
4. **Power BI:** built a star schema (4 fact tables, 3 dimensions: community, date, metro station), wrote DAX measures, and built a 3-page dashboard.

## Key findings

- **Prices:** the resale average is about $452 per sq ft. The most expensive communities are Bulgari Resort (about $2,266), Jumeirah Bay Island ($1,610) and Pearl Jumeira ($1,132), among communities with at least 50 listings.
- **Rental yield:** the average gross yield is about 8%. It is highest in lower-priced communities (Dubai South 11.2%, The Valley 10.9%, Sustainable City 10.5%) and about 6 to 7% in communities above $1,000 per sq ft. Yield tends to fall as price rises.
- **Off-plan premium:** off-plan listings average about 65% more per sq ft than resale listings across the dataset, with the largest premiums in Dubai South (+130%) and The Valley (+113%). This is partly a mix effect (the two tables contain different communities and property types). In the area-level monthly series the premium is steadier, at about 16 to 17% each year.
- **Trends:** comparing January to April of each year, resale prices rose from $338 per sq ft (2021) to $593 (2024), about +75%, then were roughly flat (2025: $578, 2026: $580). Growth slowed as the average mortgage rate rose from about 1.9% to 6.9%. This shows the two moving together, not that rates caused the slowdown.
- **Metro proximity:** raw averages suggest no premium (apartments within walking distance average $391 per sq ft versus $517 for drive-distance ones), but this reflects which communities have stations. Comparing listings **within the same community**, those within a 10-minute walk of a station were priced about **3.6% higher** (median across 8 communities; 7 of 8 showed a premium). The sample is small and the effect is modest.

## Challenges and decisions

- **Duplicate load:** an import through the MySQL Workbench wizard ran in the background while I loaded the same table with Python, giving 100,000 rows for 50,000 unique IDs. A `COUNT(*)` versus `COUNT(DISTINCT id)` check caught it. I emptied the table and reloaded it once.
- **Dropped rows:** the wizard silently skipped 760 monthly rows with a blank off-plan price. Those blanks mean "no off-plan listings that month", so I loaded them as `NULL` (not 0) to avoid pulling averages down.
- **Blank floor numbers:** 17,820 resale listings (mostly villas) have no floor, so `floor` and `total_floors` are `NULL`.
- **Metro comparison:** the first result (near-metro apartments are cheaper) was driven by community mix, so I compared near and far listings within each community. Walking and driving minutes are kept separate, and the 20+ minute walking bucket (89 listings) was left out as too small.
- **Two off-plan premium numbers:** about 65% (listing level) and about 16 to 17% (area-level series) come from different tables, so I report both with their source.
- **Partial year:** 2026 has four months of data, so year-on-year comparisons use January to April of each year.

## Limitations

- Provenance of the dataset is undocumented.
- Gross yield ignores service charges, fees and vacancy.
- Findings are associations, not causal effects.
- The within-community metro test covers only 8 communities and does not control for property size, age or type.

## Repository structure

```
dubai-real-estate-analysis/
├── README.md
├── sql/
│   ├── 01_create_tables.sql
│   └── 02_analysis_queries.sql
├── python/
│   └── dubai_real_estate_python.ipynb
└── dashboard/
    └── screenshots/
```

The raw data is not included. Download it from the Kaggle link above. The Power BI file (`.pbix`) is shared through the Google Drive link in the dashboard section.

## How to reproduce

1. Download the five CSV files from Kaggle.
2. Run `sql/01_create_tables.sql` in MySQL, then open `python/dubai_real_estate_python.ipynb`, set `DATA_FOLDER` and your MySQL username in section 1, and run sections 1 and 2 to load the CSVs (the notebook asks for your password when it runs).
3. Run the queries in `sql/02_analysis_queries.sql`.
4. Run sections 3 to 6 of the notebook to clean the data, test the metro effect and create the cleaned files.
5. Download the `.pbix` file from the Google Drive link above, open it in Power BI Desktop, and point the data sources at the cleaned files.
