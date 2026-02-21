/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'MyDataWareHouseTrainningProject' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'Bronze', 'Silver', and 'Gold'.
*/
-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;


-- Create the 'MyDataWareHouseTrainningProject' database

create database MyDataWareHouseTrainningProject;

use MyDataWareHouseTrainningProject;

-- Create Schemas
Go
create schema Bronze;
Go
create schema Silver;
GO

create schema Gold;
