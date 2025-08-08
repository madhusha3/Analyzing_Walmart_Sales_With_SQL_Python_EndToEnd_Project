# Walmart Sales Data Analysis: SQL and Python Pipeline

## Overview
This project is an end-to-end data analysis pipeline built to extract insights from Walmart sales data. Using Python for data preprocessing and SQL for querying, I honed skills in data cleaning, database management, and business problem-solving. I wrote nine SQL queries to analyze sales trends, customer behavior, and profitability, applying advanced techniques like CTEs and window functions to address real-world retail challenges.

## Dataset
The dataset, sourced from Kaggle’s Walmart Sales Dataset, includes a `walmart` table with columns like `invoice_id`, `branch`, `category`, `unit_price`, `quantity`, `payment_method`, `rating`, and `date`. It captures retail transactions across multiple branches. I explored the schema and loaded the data into PostgreSQL for analysis.

## Objectives
- Clean and transform raw sales data using Python and Pandas.
- Write complex SQL queries to answer business questions, such as revenue trends and customer preferences.
- Build a reproducible pipeline integrating Python and PostgreSQL.
- Master advanced SQL techniques like CTEs and window functions.

## Skills Demonstrated
- **Python**: Data cleaning (removing duplicates, handling nulls), feature engineering (creating `total` column), and database integration with SQLAlchemy.
- **SQL**: Complex queries using JOINs, CTEs, window functions (`RANK()`), and date formatting (`TO_DATE`, `TO_CHAR`).
- **Data Analysis**: Translating business questions into actionable insights (e.g., busiest days, top categories).
- **Problem-Solving**: Optimizing queries and handling data inconsistencies.

## Setup Instructions
1. **Environment**: Install Python 3.8+, PostgreSQL, and a code editor (e.g., VS Code).
2. **Kaggle API**:
   - Download `kaggle.json` from your Kaggle profile.
   - Place it in `~/.kaggle/` (Linux/Mac) or `C:\Users\<YourUsername>\.kaggle\` (Windows).
   - Run `kaggle datasets download -d [dataset-path]` to fetch the Walmart Sales Dataset.
3. **Install Libraries**:
   ```bash
   pip install pandas numpy sqlalchemy psycopg2
   ```
4. **Load Data**:
   - Save the dataset as `Walmart.csv` in the `data/` folder.
   - Run `main.py` to clean data and load it into PostgreSQL.
5. **Run Queries**: Execute scripts in `sql_queries/` using a SQL client (e.g., DBeaver).

## Project Workflow
1. **Data Cleaning**:
   - Removed duplicates using `df.duplicated().sum()` and `df.drop_duplicates()`.
   - Dropped 31 rows with missing values using `df.dropna()`.
   - Converted `unit_price` from object to float by removing `$` symbols (`df['unit_price'].str.replace('$', '')`).
   - Created a `total` column (`quantity * unit_price`) for revenue calculations.
2. **Database Setup**:
   - Connected to PostgreSQL using SQLAlchemy (`create_engine`).
   - Loaded cleaned data into the `walmart` table and verified integrity.
3. **SQL Analysis**:
   - Developed nine queries to analyze payment methods, busiest days, profit margins, and more.
   - Used CTEs, window functions, and date formatting to derive insights.

## Sample SQL Queries
Below are three sample queries demonstrating my SQL skills. Additional queries are in the `sql_queries/` folder.

1. **Busiest Day per Branch**  
   _Purpose_: Identifies the day with the highest transaction volume per branch to optimize staffing.  
   ```sql
   WITH counts AS (
       SELECT branch, day_name, COUNT(invoice_id) AS transaction_count
       FROM walmart
       GROUP BY branch, day_name
   ),
   ranked AS (
       SELECT branch, day_name, transaction_count,
              RANK() OVER(PARTITION BY branch ORDER BY transaction_count DESC) rnk
       FROM counts
   )
   SELECT branch, day_name, transaction_count
   FROM ranked
   WHERE rnk = 1;
   ```

2. **Payment Method Analysis**  
   _Purpose_: Analyzes transaction counts and items sold by payment method to understand customer preferences.  
   ```sql
   SELECT 
       payment_method,
       COUNT(*) AS total_transactions,
       SUM(quantity) AS total_items_sold
   FROM walmart
   GROUP BY payment_method
   ORDER BY total_items_sold DESC, total_transactions DESC;
   ```

3. **Total Profit by Category**  
   _Purpose_: Calculates profit per category to identify high-margin products.  
   ```sql
   SELECT 
       category,
       SUM(CAST(REPLACE(unit_price, '$', '') AS DOUBLE PRECISION) * quantity * profit_margin) AS total_profit
   FROM walmart
   GROUP BY category
   ORDER BY total_profit DESC;
   ```

## Key Insights
- **Payment Methods**: [e.g., Cash dominates with 60% of transactions, indicating strong customer preference].
- **Busiest Days**: [e.g., Saturdays are busiest in Branch A with 150 transactions, aiding staffing plans].
- **Profitability**: [e.g., Electronics yield the highest profit margins, guiding inventory focus].

## Challenges and Learnings
- **Challenge**: Converting `unit_price` from text with `$` symbols to float for calculations.
- **Solution**: Used Pandas’ string methods and type casting.
- **Takeaway**: Gained proficiency in CTEs and window functions (e.g., `RANK()`) for ranking-based analyses, enhancing query efficiency.

## Future Enhancements
- Visualize insights using Python (e.g., Matplotlib for sales trends).
- Explore cohort analysis with advanced SQL queries.
- Automate data pipeline with scheduled updates.

## Project Structure
```
├── data/                 # Walmart.csv dataset
├── sql_queries/          # SQL analysis scripts
├── main.py               # Data cleaning and loading script
├── requirements.txt      # Python dependencies
├── README.md             # This file
```

## Acknowledgments
- Dataset: Kaggle’s Walmart Sales Dataset.

## Contact
Explore my other projects on [Follow me for Real World Projects!](https://github.com/madhusha3) or connect via [Connect with me professionally](https://www.linkedin.com/in/madhusudann5397/).

## License
MIT License
