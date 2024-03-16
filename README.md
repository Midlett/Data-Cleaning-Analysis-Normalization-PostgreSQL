# Data Cleaning, Analysis, and Normalization in PostgreSQL: Vehicle Sales Project

![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?logo=postgresql&logoColor=white)

The primary objective of the project is to clean, analyze, and normalize the vehicle sales dataset to derive meaningful insights and facilitate efficient data management. By employing SQL queries, the project aims to address inconsistencies, identify patterns, and structure the data for further analysis.

## Dataset Description
The ["Vehicle Sales and Market Trends Dataset"](https://www.kaggle.com/datasets/syedanwarafridi/vehicle-sales-data/data) encompasses details such as the year, make, model, trim, body type, transmission type, VIN (Vehicle Identification Number), state of registration, condition rating, odometer reading, exterior and interior colors, seller information, Manheim Market Report (MMR) values, selling prices, and sale dates.

## Description of columns
- `Year`: The manufacturing year of the vehicle (e.g., 2015)
- `Make`: The brand or manufacturer of the vehicle (e.g., Kia, BMW, Volvo)
- `Model`: The specific model of the vehicle (e.g., Sorento, 3 Series, S60, 6 Series Gran Coupe)
- `Trim`: Additional designation for a particular version or option package of the model (e.g., LX, 328i SULEV, T5, 650i)
- `Body`: The type of vehicle body (e.g., SUV, Sedan)
- `Transmission`: The type of transmission in the vehicle (e.g., automatic)
- `VIN`: The Vehicle Identification Number, a unique code used to identify individual motor vehicles
- `State`: The state in which the vehicle is located or registered (e.g., CA for California)
- `Condition`: A numerical representation of the condition of the vehicle (e.g., 5.0)
- `Odometer`: The mileage or distance traveled by the vehicle
- `Color`: The exterior color of the vehicle
- `Interior`: The interior color of the vehicle
- `Seller`: The entity or company selling the vehicle (e.g., Kia Motors America Inc, Financial Services Remarketing)
- `MMR`: Manheim Market Report, a pricing tool used in the automotive industry
- `Selling Price`: The price at which the vehicle was sold
- `Sale Date`: The date and time when the vehicle was sold

## Data Cleaning
The data cleaning process involves identifying and correcting errors or inconsistencies in the dataset. This includes handling missing values, removing duplicates, standardizing formats, and resolving discrepancies.

## Data Analysis
Data analysis aims to gain insights and extract valuable information from the dataset. This involves exploring relationships between variables, identifying trends or patterns, and performing statistical analyses to uncover meaningful findings.

## Dataset Normalization
Dataset normalization involves organizing and structuring the dataset in a standardized format to facilitate efficient storage, retrieval, and analysis. This includes splitting data into separate tables, establishing relationships between tables, and reducing data redundancy.

## Implementation
The SQL script provided in this repository (car project.sql) contains the necessary queries and commands to perform data cleaning, analysis, and normalization tasks on the "Vehicle Sales and Market Trends Dataset" within a PostgreSQL environment.

## Usage
To use this project:

1. Download or clone the repository to your local machine.
2. Ensure you have PostgreSQL installed and running.
3. Execute the SQL script (car project.sql) within your PostgreSQL environment to perform data cleaning, analysis, and normalization tasks on the dataset.
## Contribution
Contributions to this project are welcome. If you have any suggestions, improvements, or additional features to add, feel free to open an issue or submit a pull request.

## License
This project is licensed under the MIT License.
