# Big Data Real Estate Analytics System

1.Dự án xây dựng hệ thống thu thập, xử lý và phân tích dữ liệu bất động sản TP.HCM theo kiến trúc Data Lake.

2.Hệ thống sử dụng:
- Python để Crawl dữ liệu
- MinIO làm Data Lake
- Apache Spark để ETL
- SQL Server làm Data Warehouse
- Power BI trực quan hóa dữ liệu
- ML

3. Kiến trúc hệ thống
 Crawler
    │
    ▼
MinIO (Bronze)
    │
    ▼
Spark ETL
    │
    ▼
Silver
    │
    ▼
Spark ETL
    │
    ▼
Gold
    │
    ▼
SQL Server
    │
    ▼
Power BI
    │
    ▼
Train

4.
Layer	Công nghệ
Data Source	Mogi, Nhà Tốt, Kaggle
Data Ingestion	Python Crawlers
Data Lake	MinIO
Storage Format	Parquet
ETL Engine	Apache Spark
Metadata	Parquet Schema
Data Warehouse	SQL Server
BI Tool	Power BI

