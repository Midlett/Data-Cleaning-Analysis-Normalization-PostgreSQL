-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DATA CLEANING PART.

-- Creating a table in order to insert data in it.

CREATE TABLE cars (
	year         	INT,         
	make        	VARCHAR(50),
	model       	VARCHAR(50),
	trim        	VARCHAR(50),
	body        	VARCHAR(50),
	transmission	VARCHAR(50),
	vin         	VARCHAR(50),
	state       	VARCHAR(50),
	condition   	real,		
	odometer  	real,			
	color       	VARCHAR(50),
	interior    	VARCHAR(50),
	seller      	VARCHAR(50),
	mmr         	real,
	sellingprice	real,
	saledate  	VARCHAR(100)
);

-- Looking on a table.

SELECT
	* 
FROM cars;

-- Inserting data into table 'cars'.

COPY cars 
FROM 'C:\Users\midle\Desktop\sql server projects\car prices\car_prices.csv' 
DELIMITER ',' 
CSV HEADER;

-- Adding id column in order to create unique identificator for all records it will help me to find records that are inconsistent.

ALTER TABLE cars
ADD COLUMN id SERIAL PRIMARY KEY;

-- Checking table schema.

SELECT 
	* 
FROM information_schema.columns 
WHERE 
table_name = 'cars';

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking into each column in order to verify data.

SELECT
	* 
FROM cars; -- Data set have 558837 rows in 17 column that were previously described. Last column "id" was added manually to create unique identificator for all records.

SELECT
	year,
	COUNT(*)
FROM cars
GROUP BY year; -- We can see that values of year column are starting from 1982 - 2015. I don't see any inconvenience with that data.

SELECT
	make,
	COUNT(*)
FROM cars
GROUP BY make;-- We can see that column make have 10301 NULL values, and pretty big inconsistencies when it comes to names of individual vehicles. We should use one of most common imputation techniques and replace NULL values with 'Other' category in order to make analised data clearer.

SELECT
	model,
	COUNT(*)
FROM cars
GROUP BY model; -- We can see that column model have 10399 NULL values, and pretty big inconsistencies when it comes to names of individual vehicles. Writing all names in uppercase should solve the problem, because I don't see any additional inconsistencies. We should use one of most common imputation techniques and replace NULL values with 'Other' category in order to make analised data clearer.

SELECT
	trim,
	COUNT(*)
FROM cars
GROUP BY trim; -- We can see that column trim have 10651 NULL values, and pretty big inconsistencies when it comes to names of individual vehicles. Writing all names in uppercase should solve the problem, because I don't see any additional inconsistencies. We should use one of most common imputation techniques and replace NULL values with 'Other' category in order to make analised data clearer.

SELECT
	body,
	COUNT(*)
FROM cars
GROUP BY body; -- We can see that column body have 13195 NULL values, and pretty big inconsistencies when it comes to names of individual vehicles. Writing all names with a capital letter at start of word will solve the problem. To make my future analysis easier to understand I will use imputation technique and replace NULL values with mode of body column.

SELECT
	transmission,
	COUNT(*)
FROM cars
GROUP BY transmission; -- We can see that column transmission have 65352 NULL values, and pretty big inconsistencies when it comes to names of individual vehicles. Writing all names with a capital letter at start of word will solve the problem. I also see few values with names 'sedan', 'Sedan' their values should be changed to NULL. To make my future analysis easier to understand I will use imputation technique and replace NULL values with mode of transmission column.
SELECT
	vin,
	COUNT(*)
FROM cars
GROUP BY vin
HAVING COUNT(*) > 1; -- We can see that vin column have 8328 values that are not unique. Vin value must be unique. Founded records should be removed from data set because we couldn't be sure about their reliability.

SELECT
	vin,
	COUNT(*)
FROM cars
WHERE VIN IS NULL
GROUP BY vin; -- We can see that vin column have 4 NULL values. These records should be removed from data set as we could not verify them.

SELECT
	state,
	COUNT(*)
FROM cars
GROUP BY state; -- We can see that state column have 26 values (e.g. "3vwd............") that doesn't match with U.S. state and territory abbreviations. These records should be removed from data set as we could not verify them. I would also recommend changing state abbreviations to full names.

SELECT
	odometer,
	COUNT(*)
FROM cars
WHERE odometer IS NULL; -- We can see that odometer column have 94 NULL values. 

SELECT
	condition,
	COUNT(*)
FROM cars
GROUP BY condition 
ORDER BY condition DESC; -- We can see that condition column have 11820 NULL values. It starts from value 1 to 49. I decided that I will use median of condition column in order to replace it will null values.

SELECT
	color,
	COUNT(*)
FROM cars
GROUP BY color; -- We can see that color column have 749 NULL values, 24685 values with "—" sign and 26 numerical values. We should use one of most common imputation techniques and replace NULL values (and non null values that aren't refering to color) with 'Other' category in order to make analised data clearer.

SELECT
	interior,
	COUNT(*)
FROM cars
GROUP BY interior; -- We can see that interior column have 749 NULL values and 17077 values with "—" sign. We should apply same procedure as in color column. To make my future analysis easier to understand I will use imputation technique and replace NULL values with 'Other' category.

SELECT
	seller,
	COUNT(*)
FROM cars
GROUP BY seller
ORDER BY COUNT(*) DESC, seller ASC;  -- We can see that seller column don't have any NULL values, and it structure is really chaotic. We see that same values are written down in multiple ways like "nissan-infiniti lt", "nissan infiniti lt". When I grouped it by seller categories I get 14263 differrent ouptputs and it will be too hard to develop some similar categories for all data. I also can't tell if similar named sellers are same entities or not. I could use it in future analysis but I will have in mind that this column have many inconsistents.   

SELECT
	COUNT(*)
FROM cars
WHERE mmr IS NULL; -- We can see that mmr column have 38 NULL values. In my opinion we can leave NULL values, because they don't have any impact on our analysis.

SELECT
	COUNT(*)
FROM cars
WHERE sellingprice IS NULL; -- We can see that sellingprice column have 12 NULL values. We should leave it as it is, because it wouldn't have any impact on our analysis. It ranges from 1 to 230000.

SELECT
	COUNT(*),
	saledate
FROM cars
GROUP BY saledate
ORDER BY saledate DESC; -- We can see that saledate column have 12 NULL values and 26 number values. We should remove NULL and number values in order to make our data consitant. 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Checking for informataion that we will be needed in our clean data query.

SELECT 
	body,
	COUNT(*)
FROM cars
GROUP BY body
ORDER BY COUNT(*) DESC
LIMIT 1; -- Mode for body column.

SELECT 
	MODE() WITHIN GROUP (ORDER BY body) AS mode_body
FROM cars; -- Mode for body column, second method.

SELECT 
	transmission,
	COUNT(*)
FROM cars
GROUP BY transmission
ORDER BY COUNT(*) DESC
LIMIT 1; -- Mode for transmission column.

SELECT
	percentile_disc(0.5) WITHIN GROUP (ORDER BY condition) as condition_median
FROM cars; -- Median for column condition.

-- Deleting id column from dataset

ALTER TABLE cars DROP CONSTRAINT cars_pkey;

ALTER TABLE cars DROP COLUMN id;

-- Creating view with original data in order to compare it in future. 

CREATE VIEW original_cars_view AS
SELECT 
	*
FROM cars;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creating view with a clean and structurized data.

CREATE VIEW clean_cars_view AS 
WITH ct AS (
	SELECT
		year,
		TRIM(INITCAP(
			CASE WHEN make ILIKE 'Vw' THEN 'Volkswagen'
			WHEN make ILIKE 'Mercedes%' THEN 'Mercedes-Benz'
			WHEN make ILIKE 'Mazda%' THEN 'Mazda'
			WHEN make ILIKE 'Land%' THEN 'Land Rover'
			WHEN make ILIKE 'Hyundai%' THEN 'Hyundai'
			WHEN make ILIKE 'Gmc%' THEN 'Gmc'
			WHEN make ILIKE 'Ford%' THEN 'Ford'
			WHEN make ILIKE 'Chev%' THEN 'Chevrolet'
			WHEN make ILIKE 'Dodge%' THEN 'Dodge'
			WHEN make IS NULL THEN 'Other'
			ELSE make END)) AS make,
		TRIM(UPPER(
			CASE WHEN model IS NULL THEN 'Other'
			ELSE model END)) AS model,
		TRIM(UPPER(
			CASE WHEN trim IS NULL THEN 'Other'
			ELSE trim END)) AS trim,
		TRIM(INITCAP(
			CASE WHEN body IS NULL THEN 'Sedan'
			ELSE body END)) AS body,
		TRIM(INITCAP(
			CASE WHEN transmission IS NULL THEN 'Automatic'
			WHEN transmission ILIKE '%sedan%' THEN 'Automatic'
			ELSE transmission END)) AS transmission,
		vin,
		TRIM(CASE WHEN state = 'ab' THEN 'Alabama'
			WHEN state = 'al' THEN 'Alaska'
			WHEN state = 'az' THEN 'Arizona'
			WHEN state = 'ca' THEN 'California'
			WHEN state = 'co' THEN 'Colorado'
			WHEN state = 'fl' THEN 'Florida'
			WHEN state = 'ga' THEN 'Georgia'
			WHEN state = 'hi' THEN 'Hawaii'
			WHEN state = 'il' THEN 'Illinois'
			WHEN state = 'in' THEN 'Indiana'
			WHEN state = 'la' THEN 'Louisiana'
			WHEN state = 'ma' THEN 'Massachusetts'
			WHEN state = 'md' THEN 'Maryland'
			WHEN state = 'mi' THEN 'Michigan'
			WHEN state = 'mn' THEN 'Minnesota'
			WHEN state = 'mo' THEN 'Missouri'
			WHEN state = 'ms' THEN 'Mississippi'
			WHEN state = 'nc' THEN 'North Carolina'
			WHEN state = 'ne' THEN 'Nebraska'
			WHEN state = 'nj' THEN 'New Jersey'
			WHEN state = 'nm' THEN 'New Mexico'
			WHEN state = 'ns' THEN 'Nova Scotia'
			WHEN state = 'nv' THEN 'Nevada'
			WHEN state = 'ny' THEN 'New York'
			WHEN state = 'oh' THEN 'Ohio'
			WHEN state = 'ok' THEN 'Oklahoma'
			WHEN state = 'on' THEN 'Ontario'
			WHEN state = 'or' THEN 'Oregon'
			WHEN state = 'pa' THEN 'Pennsylvania'
			WHEN state = 'pr' THEN 'Puerto Rico'
			WHEN state = 'qc' THEN 'Quebec'
			WHEN state = 'sc' THEN 'South Carolina'
			WHEN state = 'tn' THEN 'Tennessee'
			WHEN state = 'tx' THEN 'Texas'
			WHEN state = 'ut' THEN 'Utah'
			WHEN state = 'va' THEN 'Virginia'
			WHEN state = 'wa' THEN 'Washington'
			WHEN state = 'wi' THEN 'Wisconsin'
			END) AS state,
		COALESCE(condition, 35) AS condition,
		odometer,
		TRIM(INITCAP(
			CASE WHEN color IS NULL OR color = '—' THEN 'Other'
			ELSE color END)) AS color,
		TRIM(INITCAP(
			CASE WHEN interior IS NULL OR interior = '—' THEN 'Other'
			ELSE interior END)) AS interior,
		INITCAP(seller) AS seller,
		mmr,
		sellingprice AS selling_price,
		CAST(TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS GMT') AS timestamp with time zone) as sale_date
	FROM cars
	WHERE saledate LIKE '%(%)%'
		AND saledate IS NOT NULL
)
SELECT
	ROW_NUMBER() OVER(ORDER BY sale_date ASC) AS id,
	year,
	make,
	model,
	trim,
	body,
	transmission,
	vin,
	state,
	condition, 
	odometer,
	color,
	interior,
	seller,
	mmr,
	selling_price,
	sale_date
FROM ct
WHERE vin IN (
		SELECT
			vin
		FROM cars
		GROUP BY vin
		HAVING vin IS NOT NULL 
		AND COUNT(*) = 1)
	AND state NOT LIKE '3%'
	AND odometer IS NOT NULL
	AND mmr IS NOT NULL
	AND selling_price IS NOT NULL
	ORDER BY id ASC; 

-- We end up with 541881 records in our clean data set. That means we removed 16956 records (~ 0,03) from our original cars data set [558837], and achieve higher cohesion.

SELECT 
	*
FROM clean_cars_view;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creating clean cars table.

CREATE TABLE clean_cars (
	id				INT PRIMARY KEY,
	year         	INT,         
	make        	VARCHAR(50),
	model       	VARCHAR(50),
	trim        	VARCHAR(50),
	body        	VARCHAR(50),
	transmission	VARCHAR(50),
	vin         	VARCHAR(50),
	state       	VARCHAR(50),
	condition   	real,		
	odometer  	 	real,			
	color       	VARCHAR(50),
	interior    	VARCHAR(50),
	seller      	VARCHAR(50),
	mmr         	real,
	selling_price	real,
	sale_date  		timestamp with time zone
);

-- Inserting data from view into clean_cars table.

INSERT INTO clean_cars (
	id,
	year,
	make,
	model,
	trim,
	body,
	transmission,
	vin,
	state,
	condition, 
	odometer,
	color,
	interior,
	seller,
	mmr,
	selling_price,
	sale_date
)
SELECT
	id,
	year,
	make,
	model,
	trim,
	body,
	transmission,
	vin,
	state,
	condition, 
	odometer,
	color,
	interior,
	seller,
	mmr,
	selling_price,
	sale_date
FROM clean_cars_view;

-- Clean cars table with id as primary key (clean_cars Query complete ~ 00:00:00.845 VS clean_cars_view Query complete ~ 00:00:07.118).

SELECT 
	*
FROM clean_cars;
	
SELECT 
	*
FROM cars; -- Original dataset for comparison.

-- Now we can remove existing views as we won't need them.

DROP VIEW IF EXISTS clean_cars_view;

DROP VIEW IF EXISTS original_cars_view;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DATA ANALYSIS PART.

-- Looking at clean_cars table.

SELECT
	*
FROM clean_cars;

-- Looking at top 10 car producers, and their percentage share in market.

SELECT
	make,
	COUNT(*),
	ROUND(COUNT(*) :: NUMERIC / (SELECT COUNT(*) :: NUMERIC FROM clean_cars) * 100.0, 2) AS percentage_share
FROM clean_cars
GROUP BY make
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Looking at top 50 car models, with their percentage share in market and some additional informations.

SELECT
	model,
	make,
	body,
	COUNT(*),
	MODE() WITHIN GROUP (ORDER BY color) AS most_frequent_color,
	MODE() WITHIN GROUP (ORDER BY interior) AS most_frequent_interior_color,
	MODE() WITHIN GROUP (ORDER BY state) AS most_frequent_registration,
	ROUND(AVG(condition)) AS avg_condition,
	ROUND(AVG(odometer)) AS avg_mileage_dist,
	ROUND(AVG(mmr)) AS avg_mmr,
	ROUND(AVG(selling_price)) AS avg_selling_price,
	ROUND((AVG(mmr) - AVG(selling_price)) :: NUMERIC, 2) AS avg_price_difference,
	ROUND((AVG(mmr) - AVG(selling_price)) :: NUMERIC, 2) / AVG(selling_price) * 100.0 AS avg_percentage_price_difference,
	ROUND(COUNT(*) :: NUMERIC / (SELECT COUNT(*) :: NUMERIC FROM clean_cars) * 100.0, 2) AS percentage_share
FROM clean_cars
GROUP BY model, make, body
ORDER BY COUNT(*) DESC
LIMIT 50;

-- Looking at transmissions distribution in dataset.

SELECT
	transmission,
	COUNT(*)
FROM clean_cars
GROUP BY transmission
ORDER BY COUNT(*) DESC;

-- Looking at average year of top 10 models in market.

SELECT
	model,
	ROUND(AVG(year)) AS avg_year
FROM clean_cars
GROUP BY model 
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Looking at 5 most common types of vehicles bodies distribution in dataset and their percentage share.

SELECT
	body,
	COUNT(*),
	ROUND(COUNT(*) :: NUMERIC / (SELECT COUNT(*) :: NUMERIC FROM clean_cars) * 100.0, 2) AS percentage_share
FROM clean_cars
GROUP BY body 
ORDER BY COUNT(*) DESC
LIMIT 5;

-- Looking at 10 most common states in which cars were registered (and their percentage share).

SELECT
	state,
	COUNT(*),
	ROUND(COUNT(*) :: NUMERIC / (SELECT COUNT(*) :: NUMERIC FROM clean_cars) * 100.0, 2) AS percentage_share
FROM clean_cars
GROUP BY state
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Correlation between manheim market report and selling price variables. We can see that mmr tool is predicting prices really accurate (0.9839805518173019).

SELECT
	CORR(selling_price, mmr)
FROM clean_cars;

-- Looking at 5 most common sellers and their percentage share in market.

SELECT
	seller,
	COUNT(*),
	ROUND(COUNT(*) :: NUMERIC / (SELECT COUNT(*) :: NUMERIC FROM clean_cars) * 100.0, 2) AS percentage_share
FROM clean_cars
GROUP BY seller
ORDER BY COUNT(*) DESC
LIMIT 5;

SELECT
	*
FROM clean_cars;

-- Year to year comparision between total sales in recent years.

WITH sale AS (
SELECT
	year,
	total_sale,
	LAG(total_sale) OVER(ORDER BY year) AS last_year_total_sale
FROM (
	SELECT
		year,
		SUM(selling_price)  AS total_sale
	FROM clean_cars
	GROUP BY year
	ORDER BY year DESC) AS cc
GROUP BY year, total_sale
ORDER BY year DESC
)
SELECT
	year,
	total_sale,
	COALESCE(last_year_total_sale, 0) AS last_year_total_sale,
	COALESCE(total_sale - last_year_total_sale, 0) AS difference_between_years
FROM sale
GROUP BY year, total_sale, last_year_total_sale
ORDER BY year DESC;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DATA NORMALIZATION PART.

-- Creating tables for data normalization.

-- Fact table.

CREATE TABLE sales (
    sales_id 		INT PRIMARY KEY,
    vin 			VARCHAR(50),
    seller	 		VARCHAR(50),
    mmr 			REAL,
    selling_price 	REAL,
    sale_date 		TIMESTAMP,
    FOREIGN KEY (vin) REFERENCES Vehicles(vin)
);

-- Dimension table.

CREATE TABLE vehicles (
    vin 			VARCHAR(50) PRIMARY KEY,
    year 			INT,
    state			VARCHAR(50),
    make			VARCHAR(50),
    model 			VARCHAR(50),
    trim 			VARCHAR(50),
    body 			VARCHAR(50),
    transmission 		VARCHAR(50),
    condition 			REAL,
    odometer 			REAL,
    color 			VARCHAR(50),
    interior 			VARCHAR(50)
);

-- Inserting data into dimension table.

INSERT INTO vehicles (
	vin,		
	year,		
	state,		
	make,		
	model, 		
	trim, 		
	body, 		
	transmission,
	condition, 	
	odometer, 	
	color, 		
	interior 			
)
SELECT
	vin,		
	year,		
	state,		
	make,		
	model, 		
	trim, 		
	body, 		
	transmission,
	condition, 	
	odometer, 	
	color, 		
	interior	
FROM clean_cars;

-- Inserting data into fact table.

INSERT INTO Sales (
	sales_id, 		
	vin, 			
	seller,	 		
	mmr, 			
	selling_price, 	
	sale_date 		
)
SELECT
	id,
	vin, 			
	seller,	 		
	mmr, 			
	selling_price, 	
	sale_date 		
FROM clean_cars
ORDER BY id ASC;

-- Checking if everything is good with both datasets.

SELECT
	*	
FROM vehicles;

SELECT
	*	
FROM sales;

-- Looking on datasets constrains.

SELECT conname AS constraint_name,
       contype AS constraint_type,
       conrelid::regclass AS table_name,
       pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'vehicles'::regclass;

SELECT conname AS constraint_name,
       contype AS constraint_type,
       conrelid::regclass AS table_name,
       pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'sales'::regclass;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creating two tables vehicles_surr and sales_surr with surrogate keys.

-- Creating new table with surrogate key id for sales_surr column.

CREATE TABLE sellers (
	seller			VARCHAR(50),
	seller_id		SERIAL PRIMARY KEY 
);

-- Creating new tables with surrogate keys id's for vehicles_surr column.

CREATE TABLE manufacturers (
	make			VARCHAR(50),
	make_id			SERIAL PRIMARY KEY
);

CREATE TABLE models (
	model			VARCHAR(50),
	model_id		SERIAL PRIMARY KEY 
);

CREATE TABLE packages (
	trim			VARCHAR(50),
	trim_id			SERIAL PRIMARY KEY  
);

CREATE TABLE types (
	body			VARCHAR(50),
	body_id			SERIAL PRIMARY KEY 
);

CREATE TABLE transmissions (
	transmission	VARCHAR(50),
	transmission_id	SERIAL PRIMARY KEY 
);

CREATE TABLE states (
	state			VARCHAR(50),
	state_id		SERIAL PRIMARY KEY 
);

CREATE TABLE colors (
	color			VARCHAR(50),
	color_id		SERIAL PRIMARY KEY 
);

CREATE TABLE interiors (
	interior		VARCHAR(50),
	interior_id		SERIAL PRIMARY KEY 
);

-- Inserting data into new tables.

INSERT INTO manufacturers (
	make
)
SELECT
	DISTINCT make
FROM clean_cars
ORDER BY make ASC;

INSERT INTO models (
	model
)
SELECT
	DISTINCT model
FROM clean_cars
ORDER BY model ASC;

INSERT INTO packages (
	trim
)
SELECT
	DISTINCT trim
FROM clean_cars
ORDER BY trim ASC;

INSERT INTO types (
	body
)
SELECT
	DISTINCT body
FROM clean_cars
ORDER BY body ASC;

INSERT INTO transmissions (
	transmission
)
SELECT
	DISTINCT transmission
FROM clean_cars
ORDER BY transmission ASC;

INSERT INTO states (
	state
)
SELECT
	DISTINCT state
FROM clean_cars
ORDER BY state ASC;

INSERT INTO colors (
	color
)
SELECT
	DISTINCT color
FROM clean_cars
ORDER BY color ASC;

INSERT INTO interiors (
	interior
)
SELECT
	DISTINCT interior
FROM clean_cars
ORDER BY interior ASC;

INSERT INTO sellers (
	seller
)
SELECT
	DISTINCT seller
FROM clean_cars
ORDER BY seller ASC;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creating vehicle_surr table.

CREATE TABLE vehicles_surr (
    vin 				VARCHAR(50) PRIMARY KEY,
    year 				INT,
	state_id			INT,
    make_id				INT,
    model_id 			INT,
    trim_id 			INT,
    body_id 			INT,
    transmission_id 	INT,
    condition 			REAL,
    odometer 			REAL,
    color_id 			INT,
    interior_id 		INT,
	FOREIGN KEY (state_id) REFERENCES states(state_id),
	FOREIGN KEY (make_id) REFERENCES manufacturers(make_id),
	FOREIGN KEY (model_id) REFERENCES models(model_id),
	FOREIGN KEY (trim_id) REFERENCES packages(trim_id),
	FOREIGN KEY (body_id) REFERENCES types(body_id),
	FOREIGN KEY (transmission_id) REFERENCES transmissions(transmission_id),
	FOREIGN KEY (color_id) REFERENCES colors(color_id),
	FOREIGN KEY (interior_id) REFERENCES interiors(interior_id)
);

-- Creating sales_surr table.

CREATE TABLE sales_surr (
	sales_id 		INT PRIMARY KEY,
    vin 			VARCHAR(50),
    seller_id	 	INT,
    mmr 			REAL,
    selling_price 	REAL,
    sale_date 		TIMESTAMP,
    FOREIGN KEY (vin) REFERENCES vehicles(vin),
	FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creating view as an insert fort sales_surr and vehicle_surr.

CREATE VIEW insert_surr AS
WITH v AS (
	SELECT
	*
	FROM clean_cars AS cc
	INNER JOIN manufacturers AS man
	USING (make)
	INNER JOIN models AS m
	USING (model)
	INNER JOIN packages AS tr
	USING (trim)
	INNER JOIN types AS b
	USING (body)
	INNER JOIN transmissions AS t
	USING (transmission)
	INNER JOIN states AS st
	USING (state)
	INNER JOIN colors AS c
	USING (color)
	INNER JOIN interiors AS i
	USING (interior)
	INNER JOIN sellers AS s
	USING (seller)
)
SELECT
	id,
	year,
	make_id,
	model_id,
	trim_id,
	body_id,
	transmission_id,
	vin,
	state_id,
	condition, 
	odometer,
	color_id,
	interior_id,
	seller_id,
	mmr,
	selling_price,
	sale_date
FROM v;

-- Inserting data from view to vehicles_surr table.

INSERT INTO vehicles_surr (
	vin, 			
	year, 			
	state_id,		
	make_id,			
	model_id, 		
	trim_id, 		
	body_id, 		
	transmission_id, 
	condition, 		
	odometer, 		
	color_id, 		
	interior_id 	
)
SELECT
	vin, 			
	year, 			
	state_id,		
	make_id,			
	model_id, 		
	trim_id, 		
	body_id, 		
	transmission_id, 
	condition, 		
	odometer, 		
	color_id, 		
	interior_id 
FROM insert_surr;

-- Looking on vehicles_surr constrains.

SELECT conname AS constraint_name,
       contype AS constraint_type,
       conrelid::regclass AS table_name,
       pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'vehicles_surr'::regclass;

-- Inserting data from view to sales_surr table.

INSERT INTO sales_surr (
	sales_id, 		
	vin, 			
	seller_id,	 	
	mmr, 			
	selling_price, 	
	sale_date 			
)
SELECT
	id, 		
	vin, 			
	seller_id,	 	
	mmr, 			
	selling_price, 	
	sale_date 		 
FROM insert_surr;

-- Looking on sales_surr constrains.

SELECT conname AS constraint_name,
       contype AS constraint_type,
       conrelid::regclass AS table_name,
       pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'sales_surr'::regclass;

-- Joining data in order to achieve same (as in one clean_cars table) outcome with normalized dataset.

SELECT
	sales_id,
	vin,
	year,
	make,
	model,
	trim,
	body,
	transmission,
	state,
	condition, 
	odometer,
	color,
	interior,
	seller,
	mmr,
	selling_price,
	sale_date
FROM vehicles_surr AS cc
INNER JOIN manufacturers AS man
USING (make_id)
INNER JOIN models AS m
USING (model_id)
INNER JOIN packages AS tr
USING (trim_id)
INNER JOIN types AS b
USING (body_id)
INNER JOIN transmissions AS t
USING (transmission_id)
INNER JOIN states AS st
USING (state_id)
INNER JOIN colors AS c
USING (color_id)
INNER JOIN interiors AS i
USING (interior_id)
INNER JOIN sales_surr AS ss
USING (vin)
INNER JOIN sellers AS s
USING (seller_id);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
