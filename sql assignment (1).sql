 -------------------------------------------- Assignments All ---------------------------------------------------
--  Q1) SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
-- A) 

USE CLASSICMODELS;
SELECT employeeNumber, firstName, lastname
FROM employees 
WHERE jobTitle = 'Sales Rep'
AND reportsTo = 1102;

--  Q1) SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
-- B) 

select distinct productline
From products
WHERE productLine LIKE '% Cars';

-- Q2) CASE STATEMENTS for Segmentation

SELECT 
    customerNumber,
    customerName,
    CASE 
        WHEN country IN ('USA', 'Canada') THEN 'North America'
        WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
        ELSE 'Other'
    END AS CustomerSegment
FROM 
    customers;
    
-- Q3) Group By with Aggregation functions and Having clause, Date and Time functions
-- A) 	
  
  SELECT 
    productCode,
    SUM(quantityOrdered) AS TotalOrderQuantity
FROM 
    OrderDetails
GROUP BY 
    productCode
ORDER BY 
    TotalOrderQuantity DESC
LIMIT 10;

-- Q3) Group By with Aggregation functions and Having clause, Date and Time functions
-- B) 	

SELECT 
    MONTHNAME(paymentDate) AS MonthName,
    COUNT(*) AS TotalPayments
FROM 
    Payments
GROUP BY 
    MONTHNAME(paymentDate)
HAVING 
    TotalPayments > 20
ORDER BY 
    TotalPayments DESC;
    
-- Q4) CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- A)

CREATE DATABASE Customers_Orders;
use Customers_orders;
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);
-- Q4) CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- B)

CREATE TABLE Orders (
order_id INT PRIMARY KEY AUTO_INCREMENT,
customer_id INT,
order_date DATE,
total_amount DECIMAL(10,2),
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
CHECK (total_amount >= 0)
);

-- Q5) JOINS
-- A
Use classicmodels;
SELECT c.country, Count(o.orderNumber) AS OrderCount
From customers c Join orders o on c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY ordercount DESC
LIMIT 5;

-- Q6) SELF JOIN

CREATE TABLE Project (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female'),
    ManagerID INT
);
Desc project;
INSERT INTO project (EmployeeID, FullName, Gender, ManagerID)
VALUES
    (1, 'Pranaya', 'Male', 3),
    (2, 'Priyanka', 'Female', 1),
    (3, 'Preety', 'Female', NULL),
    (4, 'Anurag', 'Male', 1),
    (5, 'Sambit', 'Male', 1),
    (6, 'Rajesh', 'Male', 3),
    (7, 'Hina', 'Female', 3);
    
    
    SELECT 
        m.FullName AS ManagerName,
    e.FullName AS EmployeeName

FROM 
    project e
LEFT JOIN 
    project m ON e.ManagerID = m.EmployeeID;
    
-- Q7) DDL Commands: Create, Alter, Rename

CREATE TABLE facility (Facility_ID INT,Name VARCHAR(255),State VARCHAR(255),Country VARCHAR(255));

ALTER TABLE facility 
ADD COLUMN City VARCHAR(255) NOT NULL AFTER Name;

select * from facility;

-- Q8) Views in SQL

CREATE VIEW product_category_sales AS
SELECT pl.productLine,SUM(od.quantityOrdered * od.priceEach) AS total_sales,COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM Products p
JOIN ProductLines pl ON p.productLine = pl.productLine
JOIN OrderDetails od ON p.productCode = od.productCode
JOIN Orders o ON od.orderNumber = o.orderNumber
GROUP BY pl.productLine;

SELECT * FROM classicmodels.product_category_sales;

-- Q9) Stored Procedures in SQL with parameters

DELIMITER //
CREATE PROCEDURE Get_country_payments (IN input_year INT, IN input_country VARCHAR(255), OUT output_total_amount VARCHAR(255))
BEGIN
    DECLARE formatted_amount VARCHAR(255);
    SELECT CONCAT(input_year, ' - ', input_country) INTO output_total_amount;
    SELECT FORMAT(SUM(amount), 0) INTO formatted_amount
    FROM Payments
    WHERE YEAR(paymentDate) = input_year
    AND customerNumber IN (SELECT customerNumber FROM Customers WHERE country = input_country);
    SET output_total_amount = CONCAT(output_total_amount, '\nTOTAL AMOUNT - ', formatted_amount, 'K');
END //
DELIMITER ;

CALL Get_country_payments(2003, 'FRANCE', @total_amount);
SELECT @total_amount;

-- Q10) Window functions - Rank, dense_rank, lead and lag
-- A)

SELECT c.customerName,COUNT(o.orderNumber) AS orderFrequency,
RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS orderFrequencyrank
FROM Customers c
LEFT JOIN Orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY orderFrequency DESC;

-- Q10) Window functions - Rank, dense_rank, lead and lag
-- B)

SELECT YEAR(orderDate) AS orderYear,
MONTHNAME(orderDate) AS orderMonth,
COUNT(*) AS orderCount,
CONCAT(FORMAT((COUNT(*) - LAG(COUNT(*), 1) OVER (ORDER BY YEAR(orderDate), MONTH(orderDate))) / NULLIF(LAG(COUNT(*), 1) OVER (ORDER BY YEAR(orderDate), MONTH(orderDate)), 0) * 100, 0),'%') AS YoY_PercentageChange
FROM Orders
GROUP BY orderYear, orderMonth, MONTH(orderDate)
ORDER BY orderYear, MONTH(orderDate);

-- Q11) Subqueries and their applications

SELECT productLine,COUNT(*) AS Total
FROM Products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM Products)
GROUP BY productLine;

-- Q12) ERROR HANDLING in SQL

CREATE TABLE Emp_EH (EmpID INT PRIMARY KEY,EmpName VARCHAR(255),EmailAddress VARCHAR(255));

DELIMITER //
CREATE PROCEDURE Insert_Emp_EH (
    IN input_EmpID INT,
    IN input_EmpName VARCHAR(255),
    IN input_EmailAddress VARCHAR(255)
)
BEGIN
    DECLARE error_occurred BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
	SET error_occurred = TRUE;
    END;
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress) VALUES (input_EmpID, input_EmpName, input_EmailAddress);
    IF error_occurred THEN
	SELECT 'Error occurred' AS Message;
    ELSE
	SELECT 'Values inserted successfully' AS Message;
    END IF;
END //
DELIMITER ;

call Insert_Emp_EH(1, 'John Doe', 'john.doe@example.com');

-- Q13) TRIGGERS

CREATE table Emp_Bit(
					Name varchar(50),
                    Occupation varchar(50),
                    Working_date date,
                    Working_Hours int
					);
# inserting triggers

delimiter //
create trigger before_trigger
before insert on Emp_Bit for each row
begin
if new.Working_Hours < 0 then set new.Working_Hours = 0;
end if;
end//

insert into Emp_Bit (Name ,Occupation, Working_date, Working_Hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

Show triggers from classicmodels;