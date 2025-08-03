CREATE TABLE EcommerceCustomerBehavior (
    Customer_ID INT,
    Purchase_Date DATETIME, 
    Product_Category VARCHAR(100),
    Product_Price DECIMAL(10, 2),
    Quantity INT,
    Total_Purchase_Amount DECIMAL(12, 2),
    Payment_Method VARCHAR(50),
    Customer_Age INT,
    Returns BIT,
    Customer_Name VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    Churn BIT
);
BULK INSERT EcommerceCustomerBehavior
FROM 'C:\Users\HP\Downloads\ecommerce_customer_data_large.csv'
WITH (
    FORMAT = 'csv',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001' -- nếu là UTF-8
);
ALTER TABLE EcommerceCustomerBehavior
ALTER COLUMN Returns VARCHAR(10) NULL;

ALTER TABLE EcommerceCustomerBehavior
ALTER COLUMN churn int;

--1. Tổng số khách hàng (Customer ID duy nhất)
SELECT COUNT(DISTINCT [Customer_ID]) AS Total_Customers
FROM EcommerceCustomerBehavior

--2.Tổng doanh thu 
SELECT SUM(Total_Purchase_Amount) AS Tong_doanh_thu 
FROM EcommerceCustomerBehavior

--3.Doanh thu trung bình
SELECT AVG(Total_Purchase_Amount) AS Doanh_thu_tb
FROM EcommerceCustomerBehavior

--4.Tổng số lượng hoá đơn bị trả lại
SELECT COUNT(*) AS Hoa_don_tra_lai
FROM EcommerceCustomerBehavior
WHERE Returns = '1.0'

--5. Tổng số đơn hàng không bị trả lại
SELECT COUNT(*) AS Hoa_don_ko_tra_lai
FROM EcommerceCustomerBehavior
WHERE Returns = '0.0'

--6.Doanh thu theo phương thức thanh toán
SELECT Payment_Method, SUM(Total_Purchase_Amount) AS Doanh_thu_pt_thanh_toan
FROM EcommerceCustomerBehavior
GROUP BY Payment_Method
ORDER BY Doanh_thu_pt_thanh_toan ASC

--7.Doanh thu theo danh mục sản phẩm
SELECT Product_Category,SUM(Total_Purchase_Amount) AS Doanh_thu_danh_muc_sp
FROM EcommerceCustomerBehavior
GROUP BY Product_Category
ORDER BY Doanh_thu_danh_muc_sp 

--8.Doanh thu theo giới tính
SELECT Gender, SUM(Total_Purchase_Amount) AS Doanh_thu_theo_gioi_tinh
FROM EcommerceCustomerBehavior
GROUP BY Gender
ORDER BY Doanh_thu_theo_gioi_tinh

--9.Doanh thu theo tháng
SELECT FORMAT(Purchase_Date, 'yyyy-MM') as Thang, SUM(Total_Purchase_Amount) As Doanh_thu_theo_thang
FROM EcommerceCustomerBehavior
GROUP BY FORMAT(Purchase_Date, 'yyyy-MM')
ORDER BY Thang

--10.Tốc độ tăng trưởng tháng này so với tháng trước đó
SELECT 
    FORMAT(Purchase_Date, 'yyyy-MM') AS Thang,
    SUM(Total_Purchase_Amount) AS Doanh_thu_thang_nay,
    LAG(SUM(Total_Purchase_Amount)) OVER (ORDER BY FORMAT(Purchase_Date, 'yyyy-MM')) AS Doanh_thu_thang_truoc,
    ROUND(
        (SUM(Total_Purchase_Amount) - LAG(SUM(Total_Purchase_Amount)) OVER (ORDER BY FORMAT(Purchase_Date, 'yyyy-MM')))
        / NULLIF(LAG(SUM(Total_Purchase_Amount)) OVER (ORDER BY FORMAT(Purchase_Date, 'yyyy-MM')), 0) * 100, 2
    ) AS Toc_do_tang_truong
FROM EcommerceCustomerBehavior
GROUP BY FORMAT(Purchase_Date, 'yyyy-MM')
ORDER BY Thang;

--11.Top 2 danh mục sản phẩm có doanh thu cao nhất
SELECT TOP 2 Product_Category, SUM(Total_Purchase_Amount) AS Doanh_thu
FROM EcommerceCustomerBehavior
GROUP BY Product_Category
ORDER BY Doanh_thu ASC

--12.Tỷ lệ khách hàng rời bỏ theo tháng
SELECT 
  FORMAT([Purchase_Date], 'yyyy-MM') AS Thang,
  COUNT(*) AS Tong_so_luong_khach_hang,
  SUM(Churn) AS Khach_hang_roi_bo,
  CAST(SUM(Churn)*1.0 / COUNT(*) AS DECIMAL(5,2)) AS Ty_le_khach_hang_roi_bo
FROM EcommerceCustomerBehavior
GROUP BY FORMAT([Purchase_Date], 'yyyy-MM')
ORDER BY Thang

--13.Tỷ lệ rời bỏ theo giới tính
SELECT Gender,
  COUNT(*) AS Total,
  SUM(Churn) AS So_luong_roi_bo,
  CAST(SUM(Churn)*1.0 / COUNT(*) AS DECIMAL(5,2)) AS Ty_le_roi_bo_theo_gioi_tinh
FROM EcommerceCustomerBehavior
GROUP BY Gender