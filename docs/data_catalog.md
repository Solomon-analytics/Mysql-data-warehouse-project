## Data Dictionary for Gold Layer 

The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension
tables and fact tables for specific business metrics.

----------------------------------------------------------------------------------------------------------------------------------------------------

## 1. gold.dim_customers
- **purpose:** Stores customer details enriched with demographic and geographic data.


- **Columns:**

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

##

## 2. gold.product_dim
- **purpose:** Provides information about the products and their attributes.

- **Columns:**

|   Column Name         |    Data Type              |                                     Description                                            |
|-----------------------|---------------------------|--------------------------------------------------------------------------------------------|
|  product_key          |   INT                     |  Surrogate key uniquely identifying each product record in product dimension table.        |
|  product_id           |   INT                     |  A unique identifier assigned to the product for internal tracking and refrencing.         |            
|  product_number       |   NVARCHAR(50)            |  A structured alphanumeric code representing the product.                                  |
|  product_name         |   NVARCHAR(50)            |  Descriptive name of the product.                                                          |
|  category_id          |   NVARCHAR(50)            |  A unique identifier for the product's category, linking to its high level classification. |                 
|  category             |   NVARCHAR(50)            |  The broader classification of the product.                                                |
|  subcategory          |   NVARCHAR(50)            |  A more detailed classifciation of the product within the category.                        |
|  Maintenance          |   NVARCHAR(50)            |  Indicates whether the product requires maintenance                                        |
|  cost                 |   INT                     |  The cost or base price of the product, measured in monetary units.                        |
|  product_line         |   NVARCHAR(50)            |  The specific product line or series to which the product belongs.                         |  
|  start_date           |   DATE                    |  The date when the product became available for sale or use, stored in.                    |

##

## 3. gold.fact_sales
- **purpose:** stores transactional sales data for analytical purposes.

- **Columns:**

|   Column Name         |    Data Type              |                                     Description                                            |
|-----------------------|---------------------------|--------------------------------------------------------------------------------------------|
|  Order_number         |   NVARCHAR(50)            |  A unique alphanumeric identifier for each sales order.                                    |
|  product_key          |   INT                     |  Surrogate key linking the order to the product dimension table.                           |          
|  customer_key         |   INT                     |  Surrogate key linking the order to the customer dimension table.                          |
|  order_date           |   DATE                    |  The date when the order was placed.                                                       |
|  ship_date            |   DATE                    |  The date when the order was shipped to the customer.                                      |                 
|  due_date             |   DATE                    |  The date when the order payment was due.                                                  |
|  sales_amount         |   INT                     |  The total monetary value of the sale for the line item, in currency units.                |
|  quantity             |   INT                     |  The number of units of the product ordered for the line item.                             |
|  price                |   INT                     |  The price per unit of the product for the line item, in currency unit                     |

