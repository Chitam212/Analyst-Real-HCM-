--I. Tổng quan dữ liệu (Overview KPI)--

--1.  Số lượng bản tin đăng ( bds hiện có)
SELECT COUNT(property_id) AS total_properties 
FROM dbo.Real_estate
--1.  Số lượng bản tin đăng có trùng không ( bds hiện có)

SELECT COUNT(distinct (property_id)) AS total_properties 
FROM dbo.Real_estate
--2 Tổng số quận
SELECT COUNT(DISTINCT district) AS total_district 
From dbo.Real_estate
--3. Tổng số phường
SELECT COUNT(DISTINCT ward) AS total_ward
FROM dbo.Real_estate;
--4. Gía trung bình mỗi BDS
SELECT
    AVG(price) AS avg_price
FROM dbo.Real_estate;
--4.1 Gía trung vị mỗi BDS
SELECT DISTINCT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) OVER () AS MedianValue
FROM dbo.Real_estate;
--5. Giá cao nhất và thấp nhất
SELECT
    MAX(price) AS max_price,
    MIN(price) AS min_price
FROM dbo.Real_estate;


--II. Phân tích theo khu vực

--6.Giá trung bình từng quận
SELECT
    district,
    ROUND(AVG(price),0) avg_price
FROM dbo.Real_estate
GROUP BY district
ORDER BY avg_price DESC;
--7. Giá/m2 trung bình từng quận
SELECT
    district,
    ROUND(AVG(price_per_m2),2) avg_price_m2
FROM dbo.Real_estate
GROUP BY district
ORDER BY avg_price_m2 DESC;


--8. Top 10 quận nhiều tin đăng nhất
SELECT TOP 10
    district,
    COUNT(*) total_listing
FROM dbo.Real_estate
GROUP BY district
ORDER BY total_listing DESC
--Gía trung bình theo phường 
SELECT
    ward,
    ROUND(AVG(price),0) avg_price
FROM dbo.Real_estate
GROUP BY ward
ORDER BY avg_price DESC;
--III. Phân tích loại bất động sản
--10. Số lượng theo category
SELECT
    category,
    COUNT(*) total
FROM dbo.Real_estate
GROUP BY category
ORDER BY total DESC;
--11. Giá trung bình theo category
SELECT
    category,
    ROUND(AVG(price),0) avg_price
FROM dbo.Real_estate
GROUP BY category
ORDER BY avg_price DESC;
--12. Giá trung bình theo subcategory
SELECT
    subcategory,
    ROUND(AVG(price),0)
FROM dbo.Real_estate
GROUP BY subcategory;
--IV. Phân tích diện tích
--13. Diện tích trung bình
SELECT
    ROUND(AVG(area),2) avg_area
FROM dbo.Real_estate;
--14. Top 20 căn diện tích lớn nhất
SELECT TOP 20
    title,
    district,
    area
FROM dbo.Real_estate
ORDER BY area DESC;
--15. Giá trung bình theo nhóm diện tích
WITH AreaData AS
(
    SELECT
        CASE
            WHEN area < 50 THEN '<50'
            WHEN area BETWEEN 50 AND 100 THEN '50-100'
            WHEN area BETWEEN 100 AND 200 THEN '100-200'
            ELSE '>200'
        END AS Area_Group,
        price
    FROM dbo.Real_estate
)
SELECT
    Area_Group,
    COUNT(*) AS Total,
    AVG(price) AS Avg_Price
FROM AreaData
GROUP BY Area_Group;
--V. Phân tích giá
--16. Top 20 căn đắt nhất
SELECT TOP 20
    title,
    district,
    price
FROM dbo.Real_estate
ORDER BY price DESC;
--17. Top 20 giá/m2 cao nhất
SELECT TOP 20
    title,
    district,
    price_per_m2
FROM dbo.Real_estate
ORDER BY price_per_m2 DESC;
--18. Giá trung bình theo số phòng ngủ
SELECT
bedrooms,
COUNT(*) Total,
AVG(price) AvgPrice
FROM dbo.Real_estate
GROUP BY bedrooms
ORDER BY bedrooms;
--18. Giá trung bình theo số phòng tam
SELECT
bathrooms,
AVG(price)
FROM dbo.Real_estate
GROUP BY bathrooms;
--VI. Phân tích pháp lý
--20. Tỷ lệ pháp lý
SELECT
legal_status,
COUNT(*) Total,
ROUND(COUNT(*)*100.0/
(SELECT COUNT(*) FROM dbo.Real_estate),2)
Percentage
FROM dbo.Real_estate
GROUP BY legal_status;
--Gía trung bình theo pháp lý
SELECT
legal_status,
AVG(price)
FROM dbo.Real_estate
GROUP BY legal_status
order by AVG(price)
--21. Số tin đăng theo tháng
SELECT
YEAR(posted_date) Year,
MONTH(posted_date) Month,
COUNT(*) Total
FROM dbo.Real_estate
GROUP BY YEAR(posted_date),
MONTH(posted_date)
ORDER BY Year,Month;
--22. Giá trung bình theo tháng
SELECT
YEAR(posted_date) as 'Year',
MONTH(posted_date) as'Month',
AVG(price) as 'Gía TB'
FROM dbo.Real_estate
GROUP BY YEAR(posted_date),
MONTH(posted_date);

--Xóa các outlier khi trực quan dữ liệu phát hiẹn

DELETE FROM dbo.Real_estate
WHERE area > 200500

DELETE FROM dbo.Real_estate
WHERE price > 2300000000001
