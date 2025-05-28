/*
===========================================================================================================
Stored procedure: Load bronze layer (source -> bronze)
===========================================================================================================
Script Purpose:
This stored procedure loads data into the 'bronze' schema from external csv files.
It performs the following actions:
- Truncate the bronze tables before loading data.
- Uses the 'Bulk INSERT' command to load data from csv files to bronze tables.

Parameters:
None.
This stored procedure does not accept any parameters or return any values.

Usage exaple:
Exec bronze.load_bronze;
============================================================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
BEGIN TRY
SET @batch_start_time = GETDATE();
SET @start_time = GETDATE();
TRUNCATE TABLE bronze.crm_cust_info;
BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\Yakub\Downloads/cust_info.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> --------------------';

SET @start_time = GETDATE();
TRUNCATE TABLE bronze.crm_prd_info;
BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\Yakub\Downloads\prd_info.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> --------------------';


SET @start_time = GETDATE();
TRUNCATE TABLE bronze.crm_sales_details;
BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\Yakub\Downloads\sales_details.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> --------------------';


SET @start_time = GETDATE();
TRUNCATE TABLE bronze.erp_1oc_a101;
BULK INSERT bronze.erp_1oc_a101
FROM 'C:\Users\Yakub\Downloads\1oc_a101.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> --------------------';


SET @start_time = GETDATE();
TRUNCATE TABLE bronze.erp_cust_az12;
BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\Yakub\Downloads\cust_az12.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> --------------------';


SET @start_time = GETDATE();
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\Users\Yakub\Downloads\px_cat_g1v2.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT '>> --------------------';
SET @batch_end_time = GETDATE();
PRINT '===================================================='
PRINT 'Loading Bronze Layer is completed';
PRINT ' - Total Load Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
PRINT '================================================='
END TRY
BEGIN CATCH
     PRINT '==========================================================================='
     PRINT 'Error Occured During Loading Broze Layer'
     PRINT 'Error Message' + Error_Message();
     PRINT 'Error Message' + CAST(Error_Number() AS NVARCHAR);
     PRINT 'Error Message' + CAST(Error_State() AS NVARCHAR);
     PRINT '==========================================================================='
END CATCH
END;
