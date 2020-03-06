/* 
 * MySQL Script - initializeDataBase.sql.
 * Create EMPLOYEE_RECORDS database and EMPLOYEES table.
 */
 
-- Create EMPLOYEE_RECORDS database
CREATE DATABASE IF NOT EXISTS EMPLOYEE_RECORDS;     

-- Switch to EMPLOYEE_RECORDS database
USE EMPLOYEE_RECORDS;

-- create EMPLOYEES table in the database
CREATE TABLE IF NOT EXISTS EMPLOYEES (EmployeeID int NOT NULL AUTO_INCREMENT , Name VARCHAR(50), Age INT, SSN INT, PRIMARY KEY (EmployeeID))