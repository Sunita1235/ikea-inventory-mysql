CREATE TABLE Customers
(Customer_ID INT PRIMARY KEY AUTO_INCREMENT,Customer_Name VARCHAR(100) NOT NULL,
Age INT NOT NULL CHECK(Age BETWEEN 18 AND 70),
Gender ENUM('Male','Female','Other') NOT NULL,
City VARCHAR(50) NOT NULL,
State VARCHAR(50) NOT NULL,
Membership_Type ENUM('Regular','Silver','Gold','Platinum') DEFAULT 'Regular',
Join_Date DATE NOT NULL
);
