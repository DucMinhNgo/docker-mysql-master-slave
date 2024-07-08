-- Employees 
CREATE TABLE Employees (
    ID INT AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Age INT,
    PRIMARY KEY (ID)
);

-- Index
CREATE TABLE test_table_001 (
	id INT PRIMARY KEY,
	a INT,
	b INT,
	c INT,
	d INT,
	INDEX idx_abc (a, b, c) -- composite index
);
-- Trường hợp nào nhiều trùng lặp trong database để sau, ít xuất hiện trùng lặp thì để đằng trước
SHOW INDEX FROM test_table_001
-- Quy tắc ngoài cùng bên trai
EXPLAIN SELECT * FROM test_table_001 WHERE a = 1 -- OK
EXPLAIN SELECT * FROM test_table_001 WHERE a = 1 AND b = 1 -- OK
EXPLAIN SELECT * FROM test_table_001 WHERE b = 1 AND a = 1 -- OK (mysql 8 sẽ phân biệt đc)
EXPLAIN SELECT * FROM test_table_001 WHERE b = 1 AND c = 1 -- Not OK
EXPLAIN SELECT * FROM test_table_001 WHERE a = 1 AND c = 1 -- chỉ sử dụn mỗi index a
EXPLAIN SELECT a FROM test_table_001 WHERE a = 1 AND b = 1 -- OK

SELECT count(DISTINCT a)/count(1) as ca, count(DISTINCT b)/count(1) as cb FROM test_table_001
-- count lớn hơn sẽ xếp bên trái

CREATE TABLE `customers_custom` (
  `customerNumber` int(11) NOT NULL,
  `customerName` varchar(50) NOT NULL,
  `contactLastName` varchar(50) NOT NULL,
  `contactFirstName` varchar(50) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `addressLine1` varchar(50) NOT NULL,
  `addressLine2` varchar(50) DEFAULT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) DEFAULT NULL,
  `postalCode` varchar(15) DEFAULT NULL,
  `country` varchar(50) NOT NULL,
  `salesRepEmployeeNumber` int(11) DEFAULT NULL,
  `creditLimit` decimal(10,2) DEFAULT NULL
)

-- Create Procedure
CREATE PROCEDURE SelectAllCustomers()
BEGIN
    SELECT * FROM customers_custom;
END;

-- Exec
CALL SelectAllCustomers
