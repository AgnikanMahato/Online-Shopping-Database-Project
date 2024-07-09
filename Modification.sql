-- Query the address, starttime, and endtime of service points in the same city as userid 5
SELECT sp.streetaddr, sp.starttime, sp.endtime
FROM ServicePoint sp
JOIN Address a ON sp.city = a.city
WHERE a.userid = 5;

-- Query the information of laptops
SELECT *
FROM Product
WHERE type = 'laptop';

-- Query the total quantity of products from store with storeid 8 in the shopping cart
SELECT SUM(sc.quantity) AS totalQuantity
FROM Save_to_Shopping_Cart sc
JOIN Product p ON sc.pid = p.pid
WHERE p.sid = 8;

-- Query the name and address of orders delivered on 2017-02-17
SELECT a.name, a.streetaddr, a.city
FROM Address a
JOIN Deliver_To dt ON a.addrid = dt.addrid
WHERE dt.TimeDelivered = '2017-02-17';

-- Query the comments of product 12345678
SELECT *
FROM Comments
WHERE pid = 12345678;

-- Insert the user id of sellers whose name starts with A into buyer
INSERT INTO buyer
SELECT *
FROM seller
WHERE userid IN (SELECT userid FROM users WHERE name LIKE 'A%');

-- Update the payment state of orders to unpaid which were created after 2017 and have a total amount greater than 50
UPDATE Orders
SET paymentState = 'Unpaid'
WHERE creationTime > '2017-01-01' AND totalAmount > 50;

-- Update the name and contact phone number of addresses where the province is Quebec and city is Montreal
UPDATE Address
SET name = 'Awesome Lady', contactPhoneNumber = '1234567'
WHERE province = 'Quebec' AND city = 'Montreal';

-- Delete stores that opened before 2017
DELETE FROM save_to_shopping_cart
WHERE addTime < '2017-01-01';

-- Create a view of all products whose price is above average price
CREATE VIEW Products_Above_Average_Price AS
SELECT pid, name, price
FROM Product
WHERE price > (SELECT AVG(price) FROM Product);

-- Update the view
UPDATE Products_Above_Average_Price
SET price = 1
WHERE name = 'GoPro HERO5';

-- Create a view of all products sold in 2016
CREATE VIEW Product_Sales_For_2016 AS
SELECT p.pid, p.name, p.price
FROM Product p
WHERE p.pid IN (
    SELECT oi.pid
    FROM OrderItem oi
    JOIN Contain c ON oi.itemid = c.itemid
    JOIN Payment pm ON c.orderNumber = pm.orderNumber
    WHERE pm.payTime >= '2016-01-01' AND pm.payTime <= '2016-12-31'
);

-- Update the view
UPDATE Product_Sales_For_2016
SET price = 2
WHERE name = 'GoPro HERO5';

-- Check constraints

-- Check whether products saved to the shopping cart after 2017 have quantities smaller than 10
DROP TABLE IF EXISTS Save_to_Shopping_Cart;
CREATE TABLE Save_to_Shopping_Cart (
    userid INT NOT NULL,
    pid INT NOT NULL,
    addTime DATE,
    quantity INT,
    PRIMARY KEY (userid, pid),
    FOREIGN KEY (userid) REFERENCES Buyer(userid),
    FOREIGN KEY (pid) REFERENCES Product(pid),
    CHECK (quantity <= 10 OR addTime > '2017-01-01')
);

-- Sample data insertions
INSERT INTO Save_to_Shopping_Cart VALUES (18, 67890123, '2016-11-23', 9);
INSERT INTO Save_to_Shopping_Cart VALUES (24, 67890123, '2017-02-22', 8);
-- INSERT INTO Save_to_Shopping_Cart VALUES (5, 56789012, '2016-10-17', 11); -- This would cause an error due to quantity constraint

-- Check whether ordered items have quantities between 1 and 10
DROP TABLE IF EXISTS Contain;
CREATE TABLE Contain (
    orderNumber INT NOT NULL,
    itemid INT NOT NULL,
    quantity INT CHECK (quantity > 0 AND quantity <= 10),
    PRIMARY KEY (orderNumber, itemid),
    FOREIGN KEY (orderNumber) REFERENCES Orders(orderNumber),
    FOREIGN KEY (itemid) REFERENCES OrderItem(itemid)
);

-- Sample data insertions
-- INSERT INTO Contain VALUES (76023921, 23543245, 11); -- This would cause an error due to quantity constraint
INSERT INTO Contain VALUES (23924831, 65738929, 8);
