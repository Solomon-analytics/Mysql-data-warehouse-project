## Data Dictionary for Gold Layer 

The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension
tables and fact tables for specific business metrics.

----------------------------------------------------------------------------------------------------------------------------------------------------

## 1. gold.dim_customers
Purpose: Stores customer details enriched with demographic and geographic data.


Columns:

|   Column Name         |    Data Type              |                                     Description                                        |
|-----------------------|---------------------------|----------------------------------------------------------------------------------------|
|  Customer_key         |   INT                     |  Surrogate key uniquely identifying each customer record in the dimension table.       |
|  Customer_id          |   INT                     |  Unique numerical identifier assigned to each customer.                                |                       
|  Customer_number      |   NVARCHAR(50)            |  Alphanumeric identifier representing the customer, used for tracking and refrencing   |
|  First_name           |   NVARCHAR(50)            |  The customer's first name, as recorded in the system.                                 |
|  Last_name            |   NVARCHAR(50)            |  The customer's last name.                                                             |
|  Country              |   NVARCHAR(50)            |  The country of residence for the customer.                                            |
|  Marital_status       |   NVARCHAR(50)            |  The marital status of the customer.                                                   |
|  gender               |   NVARCHAR(50)            |  The gender of the customer.                                                           |
|  Birth_date           |   DATE                    |  The date of birth of the customer.                                                    |
|  Create_date          |   DATE                    |  The date and time when the customer record was created in the system.                 |                   
