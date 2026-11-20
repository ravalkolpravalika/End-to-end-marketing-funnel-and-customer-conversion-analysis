# Marketing Funnel & Customer Conversion Analysis

An end-to-end data analytics project using **Python, PostgreSQL and Power BI** to find where customers drop off between viewing a product and buying it.

![Funnel dashboard](images/funnel_dashboard.png)

## Problem Statement

A business wants to know which marketing channels attract customers, which customer groups drive revenue, which products perform well, and where users leave the purchase journey. This project answers those questions using five related datasets.

## Dataset

Source: [Marketing & E-Commerce Analytics Dataset (Kaggle)](https://www.kaggle.com/datasets/geethasagarbonthu/marketing-and-e-commerce-analytics-dataset)

The dataset is tagged as synthetic on Kaggle, so the findings describe patterns in this data and not a real company.

| File | Rows | Description |
|---|---|---|
| campaigns | 50 | Channel, objective, dates, target segment, expected uplift |
| customers | 100,000 | Signup date, country, age, gender, loyalty tier, acquisition channel |
| events | 2,000,000 | Views, clicks, add-to-cart, purchases and bounces with device, traffic source, experiment group |
| products | 2,000 | Category, brand, base price, launch date, premium flag |
| transactions | 103,127 | Quantity, discount, gross revenue, campaign, refund flag |

Data covers 2021-2023.

## Tools

- **Python (Pandas, Matplotlib, Seaborn)** for EDA and data quality checks
- **PostgreSQL / pgAdmin** for analysis with SQL (joins, CTEs, window functions, date functions)
- **Power BI** for 6 interactive dashboards
- **Microsoft Word** for the project report

## Workflow

1. **EDA in Python:** inspected structure, nulls, duplicates, outliers and category values for all five files.
2. **Load into PostgreSQL:** created tables, imported the cleaned CSVs and checked row counts.
3. **SQL analysis:** answered business questions for each table, plus combined (join) and funnel questions.
4. **Dashboards in Power BI:** one page each for campaigns, customers, events, products, transactions and the funnel.
5. **Report:** documented methods, findings, recommendations and limitations.

## Data Quality Notes

- `traffic_source` had inconsistent casing (10 values), standardised to 5.
- `device_type` had 40,300 nulls in events, filled with `Unknown`.
- 10,449 transactions have no `product_id` and no `gross_revenue`. They could not be matched to a purchase event, so they were kept and not imputed. They are excluded from product and revenue analysis only.
- Negative `gross_revenue` values are refunds (`refund_flag = 1`). Revenue totals are therefore **net revenue**.
- `campaign_id = 0` means no campaign. A placeholder row was added to the campaigns table, and it is excluded from campaign-level comparisons.

## Metric Definitions

- **Conversion rate** = purchase events / view events
- **View to cart** = add-to-cart events / view events
- **Cart to purchase** = purchase events / add-to-cart events
- **Cart abandonment** = 1 - cart to purchase
- **Bounce rate** = bounce events / view events

Session-level funnel (distinct sessions): 526,902 views, 231,525 carts, 95,539 purchases (43.94% view to cart, 41.27% cart to purchase).

## Key Findings

| Metric | Value |
|---|---|
| Conversion rate (view to purchase) | 9.88% |
| Cart abandonment | 63.73% |
| Bounce rate | 18.20% |
| Net revenue | $8.37M |
| Transactions / refund rate | 103K / 2.94% |

- **Campaign traffic converts about 4x better:** 16.27% with a campaign vs 3.89% without.
- **Traffic source matters:** Email (17.73%) and Paid Search (16.71%) lead, while Direct (3.90%) and Organic (3.89%) are lowest.
- **Experiment:** Variant_B converted best (12.23%), then Variant_A (10.09%) and Control (9.04%).
- **Loyalty tier:** Gold (13.17%) and Platinum (12.81%) convert better than Bronze (8.73%). Bronze is about 60% of customers.
- **Device, country and product category** showed very little difference (about 9-10%).

## Dashboards

| Page | Focus |
|---|---|
| Campaigns | Expected uplift by channel, objective and segment |
| Customers | Countries, acquisition channels, loyalty tiers, age groups |
| Events | Event volume, devices, traffic sources, experiment groups |
| Products | Pricing, categories, premium products, top brands |
| Transactions | Revenue, discounts, refunds, top products |
| Funnel | Funnel stages, drop-off, conversion by segment |

![Transactions dashboard](images/transactions_dashboard.png)

## Repository Structure

Adjust the names below to match your folders.

```
.
├── data/                 # source CSV files
├── notebooks/
│   └── EDA.ipynb
├── sql/
│   ├── campaigns.sql
│   ├── customers.sql
│   ├── events.sql
│   ├── products.sql
│   ├── transactions.sql
│   ├── joins.sql
│   └── funnel.sql
├── dashboard/            # Power BI file (.pbix)
├── images/               # dashboard screenshots
├── report/
│   └── Marketing_Funnel_Project_Report.docx
└── README.md
```

## How to Reproduce

1. Download the dataset from Kaggle and place the CSVs in `data/`.
2. Run `notebooks/EDA.ipynb` and save the cleaned CSVs.
3. In PostgreSQL, create a database, create the five tables and load the CSVs with `\copy`.
4. Run the queries in `sql/`.
5. Open the `.pbix` file in Power BI and point it to your PostgreSQL database.

## Limitations

- Historical, synthetic Kaggle data, so recommendations are analytical suggestions and not verified business outcomes.
- There is no cost data, so profit cannot be calculated.
- Expected campaign uplift is a forecast and not realised uplift.
- Event-level rates divide event counts, not distinct customers.
- The results show associations, not causation.

## Author

**[Your name]**
LinkedIn: [your profile link]
