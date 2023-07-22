-- 1. Создайте таблицу с мобильными телефонами, используя графический интерфейс.
-- Заполните БД данными (можно взять за образец таблицу из презентации)

USE myfirstdb;

CREATE TABLE Products
(
Id INT AUTO_INCREMENT PRIMARY KEY,
ProductName VARCHAR(30) NOT NULL,
Manufacturer VARCHAR(20) NOT NULL,
ProductCount INT DEFAULT 0,
Price DECIMAL
);

INSERT INTO Products (ProductName, Manufacturer, ProductCount, Price)
VALUES
('iPhone X', 'Apple', 3, 76000),
('iPhone 8', 'Apple', 2, 51000),
('iPhone 7', 'Apple', 5, 32000),
('Galaxy S9', 'Samsung', 2, 56000),
('Galaxy S8', 'Samsung', 1, 46000),
('Honor 10', 'Huawei', 5, 28000),
('Nokia 8', 'HMD Global', 6, 38000);

-- 2. Выведите название, производителя и цену для товаров,
-- количество которых превышает 2

SELECT ProductName, Manufacturer, Price
FROM Products
WHERE ProductCount > 2;

-- 3. Выведите весь ассортимент товаров марки “Samsung”

SELECT * FROM Products
WHERE Manufacturer = 'Samsung';
