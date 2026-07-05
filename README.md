# Big Data Real Estate Analytics System

Python Crawler (Bất động sản)
               │
               ▼
               
   MinIO - Bronze Layer ()
               │
               ▼
               
         Apache Spark ETL ()
               │
               ▼
               
   MinIO - Silver Layer ()
               │
               ▼

               
         Apache Spark ETL ()
               │
               ▼

               
   MinIO - Gold Layer () ──► [Export CSV cho Team ML]
               │
               ▼

               
      (Spark JDBC Write)
               │
               ▼

               
   SQL Server (Data Warehouse)
               │
               ▼

               
         Power BI (Dashboard)
4.
Layer	Công nghệ

Data Source:	Mogi, Nhà Tốt, Kaggle

Data Ingestion	Python : Crawlers

Data Lake: 	MinIO

Storage Format: 	Parquet

ETL Engine: 	Apache Spark

Metadata: 	Parquet Schema

Data Warehouse:	SQL Server

BI Tool:	Power BI
ML : Collab

Link dataset: https://drive.google.com/drive/folders/1JdPn7S0hUTdzLlXIZCuEFO-bJpZFHr61
