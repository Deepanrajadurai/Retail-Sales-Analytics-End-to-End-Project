USE ecommers ;

CREATE TABLE sales (
		transaction_id	varchar(50),
        customer_id	varchar(50),
        customer_name	varchar(50),
        age	varchar(50),
        gender	varchar(50),
        product_id	varchar(50),
        product_name	varchar(50),
        product_category	varchar(50),
        quantity varchar(50),
        price	varchar(50),
        payment_mode	varchar(50),
        order_date	varchar(50),
        order_time	varchar(50),
        status varchar(50)
) ;


DESC sales ;
/* DATA CLEANING */
/* 
Step 1  : Create sales_clean table
Step 2  : Check row count
Step 3  : Check duplicates
Step 4  : Check NULL & empty values
Step 5  : Trim leading/trailing spaces
Step 6  : Standardize text values
Step 7  : Handle missing values
Step 8  : Validate numeric columns
Step 9  : Convert numeric data types
Step 10 : Convert date & time
Step 11 : Validate dates
Step 12 : Detect outliers
Step 13 : Add calculated columns
Step 14 : Final validation
*/

-- Step 1 Create Clean Table
CREATE TABLE sales_clean AS
SELECT DISTINCT *
FROM sales;

-- Step 2 Check Total Rows
SELECT COUNT(*) AS total_rows
FROM sales_clean;

-- Step 3 Check Duplicate Transaction IDs
WITH duplicate_records AS
(
SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY transaction_id
ORDER BY transaction_id
) AS rn
FROM sales_clean
)
SELECT *
FROM duplicate_records
WHERE rn > 1;

-- Step 4 Check Missing Values
SELECT
	SUM(CASE WHEN transaction_id IS NULL OR TRIM(transaction_id)='' THEN 1 ELSE 0 END) transaction_id,
	SUM(CASE WHEN customer_id IS NULL OR TRIM(customer_id)='' THEN 1 ELSE 0 END) customer_id,
	SUM(CASE WHEN customer_name IS NULL OR TRIM(customer_name)='' THEN 1 ELSE 0 END) customer_name,
	SUM(CASE WHEN age IS NULL OR TRIM(age)='' THEN 1 ELSE 0 END) age,
	SUM(CASE WHEN gender IS NULL OR TRIM(gender)='' THEN 1 ELSE 0 END) gender,
	SUM(CASE WHEN product_id IS NULL OR TRIM(product_id)='' THEN 1 ELSE 0 END) product_id,
	SUM(CASE WHEN product_name IS NULL OR TRIM(product_name)='' THEN 1 ELSE 0 END) product_name,
	SUM(CASE WHEN product_category IS NULL OR TRIM(product_category)='' THEN 1 ELSE 0 END) product_category,
	SUM(CASE WHEN quantity IS NULL OR TRIM(quantity)='' THEN 1 ELSE 0 END) quantity,
	SUM(CASE WHEN price IS NULL OR TRIM(price)='' THEN 1 ELSE 0 END) price,
	SUM(CASE WHEN payment_mode IS NULL OR TRIM(payment_mode)='' THEN 1 ELSE 0 END) payment_mode,
	SUM(CASE WHEN order_date IS NULL OR TRIM(order_date)='' THEN 1 ELSE 0 END) order_date,
	SUM(CASE WHEN status IS NULL OR TRIM(status)='' THEN 1 ELSE 0 END) status

FROM sales_clean;

-- Step 5 Remove Leading and Trailing Spaces
SET SQL_SAFE_UPDATES=0;

UPDATE sales_clean
SET
	transaction_id = TRIM(transaction_id),
	customer_id = TRIM(customer_id),
	customer_name = TRIM(customer_name),
	age = TRIM(age),
	gender = TRIM(gender),
	product_id = TRIM(product_id),
	product_name =  TRIM(product_name),
	product_category = TRIM(product_category),
	quantity = TRIM(quantity),
	price = TRIM(price),
	payment_mode = TRIM(payment_mode),
	order_date = TRIM(order_date),
	order_time = TRIM(order_time),
	status = TRIM(status) ;

-- Step 6 Standardize Text Values
-- gender
UPDATE sales_clean
SET gender='Unknown'
WHERE gender IS NULL OR gender='';

UPDATE sales_clean
SET gender='Male'
WHERE LOWER(gender) IN ('m','male');

UPDATE sales_clean
SET gender='Female'
WHERE LOWER(gender) IN ('f','female');

-- Payment Mode
UPDATE sales_clean
SET payment_mode='Unknown'
WHERE payment_mode IS NULL OR payment_mode='';

UPDATE sales_clean
SET payment_mode='Credit Card'
WHERE payment_mode='CC';

-- Status
UPDATE sales_clean
SET status='Unknown'
WHERE status IS NULL OR status='';

-- Customer Name 
UPDATE sales_clean
SET customer_name='Unknown'
WHERE customer_name IS NULL
OR customer_name='';

-- Customer ID
UPDATE sales_clean
SET customer_id='Unknown'
WHERE customer_id IS NULL
OR customer_id='';

-- Step 7 Handle Missing Numeric Values
-- Age
UPDATE sales_clean
SET age=NULL
WHERE age='';

UPDATE sales_clean
SET age=
(
SELECT avg_age
FROM
(
	SELECT ROUND(AVG(age),0) avg_age
	FROM sales_clean
	WHERE age IS NOT NULL
	AND age REGEXP '^[0-9]+$'
) a
)
WHERE age IS NULL;

-- Quantity
UPDATE sales_clean
SET quantity=NULL
WHERE quantity='';

-- Price
UPDATE sales_clean
SET price=NULL
WHERE price='';

-- Step 8 Validate Numeric Values
SELECT *
FROM sales_clean
WHERE   age NOT REGEXP '^[0-9]+$'
		OR quantity NOT REGEXP '^[0-9]+$'
		OR price NOT REGEXP '^[0-9]+$';

-- Step 9 Convert Data Types
ALTER TABLE sales_clean
MODIFY age INT,
MODIFY quantity INT,
MODIFY price DECIMAL(10,2);

-- Step 10 Check Invalid Numeric Values
SELECT *
FROM sales_clean
WHERE   age<=0
		OR quantity<=0
		OR price<=0;

-- Step 11 Convert Date
UPDATE sales_clean
SET order_date =
	CASE
		WHEN order_date LIKE '%/%'
		THEN DATE_FORMAT ( STR_TO_DATE(order_date,'%d/%m/%Y'),'%Y-%m-%d')

		WHEN order_date LIKE '%-%'
		THEN DATE_FORMAT( STR_TO_DATE(order_date,'%d-%m-%Y'), '%Y-%m-%d')
		ELSE NULL
END;

-- Convert Date & Time
ALTER TABLE sales_clean
MODIFY order_date DATE,
MODIFY order_time TIME;

-- Step 12 Validate Dates
-- Future Date
SELECT *
FROM sales_clean
WHERE order_date>CURDATE();

-- Old dates
SELECT *
FROM sales_clean
WHERE order_date<'2020-01-01';

-- Step 13 Check Outliers
-- Highest Price
SELECT *
FROM sales_clean
ORDER BY price DESC;

-- Lowest Price
SELECT *
FROM sales_clean
ORDER BY price ASC;

-- Step 14 Add Calculated Columns
ALTER TABLE sales_clean
ADD COLUMN cost DECIMAL(10,2),
ADD COLUMN total_cost DECIMAL(10,2),
ADD COLUMN total_price DECIMAL(10,2);

UPDATE sales_clean
SET
cost = ROUND(price*0.84,2),
total_cost = ROUND(cost*quantity,2),
total_price = ROUND(price*quantity,2);

-- Step 15 Final Validation
-- Check Row Count
SELECT COUNT(*) AS total_rows
FROM sales_clean;

-- Check Duplicate Transactions
SELECT transaction_id,
COUNT(*)
FROM sales_clean
GROUP BY transaction_id
HAVING COUNT(*)>1;
-- Check NULL Values
SELECT
SUM(transaction_id IS NULL) transaction_id,
SUM(customer_id IS NULL) customer_id,
SUM(customer_name IS NULL) customer_name,
SUM(age IS NULL) age,
SUM(quantity IS NULL) quantity,
SUM(price IS NULL) price,
SUM(order_date IS NULL) order_date,
SUM(order_time IS NULL) order_time
FROM sales_clean;

-- Check Data Types
DESC sales_clean;
