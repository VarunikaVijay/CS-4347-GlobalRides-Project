CREATE DATABASE GlobalRides;
USE GlobalRides;

-- USERS and User Roles
CREATE TABLE USERS (
    User_ID INT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Middle_Name VARCHAR(50),
    Last_Name VARCHAR(50) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Date_of_Birth DATE NOT NULL,
    Gender CHAR(1) NOT NULL,
    CHECK (Gender IN ('M', 'F', 'O'))
);

CREATE TABLE CONTACT (
    Contact_Number CHAR(10),
    User_ID INT,
    CHECK (Contact_Number REGEXP '^[0-9]{10}$'),
    FOREIGN KEY (User_ID) REFERENCES USERS(User_ID) ON DELETE CASCADE,
    PRIMARY KEY (Contact_Number, User_ID)
);

CREATE TABLE RIDER (
    Rider_ID INT PRIMARY KEY,
    FOREIGN KEY (Rider_ID) REFERENCES USERS(User_ID) ON DELETE CASCADE
);

CREATE TABLE CUSTOMER (
    Customer_ID INT PRIMARY KEY,
    FOREIGN KEY (Customer_ID) REFERENCES USERS(User_ID) ON DELETE CASCADE
);

CREATE TABLE DRIVER (
    Driver_ID INT PRIMARY KEY,
    License VARCHAR(10) NOT NULL,
    Experience VARCHAR(255) NOT NULL,
    Vehicle VARCHAR(50) NOT NULL,
    CHECK (Vehicle IN ('Sedan', 'SUV', 'Truck', 'Minivan', 'Luxury', 'Electric', 'Motorcycle', 'Hybrid', 'Convertible')),
    FOREIGN KEY (Driver_ID) REFERENCES USERS(User_ID) ON DELETE CASCADE
);

CREATE TABLE RESTAURANT_OWNER (
    Owner_ID INT PRIMARY KEY,
    FOREIGN KEY (Owner_ID) REFERENCES USERS(User_ID) ON DELETE CASCADE
);

-- Rides and Restaurants

CREATE TABLE RIDES (
    Ride_ID INT PRIMARY KEY,
    Rider_ID INT NOT NULL,
    Driver_ID INT NOT NULL,
    Pickup_Location VARCHAR(255) NOT NULL,
    Drop_Off_Location VARCHAR(255) NOT NULL,
    Distance DECIMAL(6, 2) NOT NULL,
	Pickup_Time DATETIME NOT NULL,
    Fare DECIMAL(8, 2) NOT NULL,
    Payment_Status VARCHAR(20) NOT NULL,
    Payment_Method VARCHAR(50) NOT NULL,
    UNIQUE (Ride_ID, Rider_ID),
    CHECK (Payment_Status IN ('Paid', 'Not Paid')),
    CHECK (Payment_Method IN ('Cash', 'Credit', 'Debit', 'Check', 'Other')),
    FOREIGN KEY (Rider_ID) REFERENCES RIDER(Rider_ID),
    FOREIGN KEY (Driver_ID) REFERENCES DRIVER(Driver_ID)
);

CREATE TABLE RESTAURANT (
    Restaurant_ID INT PRIMARY KEY,
    Owner_ID INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Open_Time TIME NOT NULL, 
    Closing_Time TIME NOT NULL,
    Cuisine VARCHAR(255) NOT NULL,
    CHECK (Closing_Time > Open_Time),
    FOREIGN KEY (Owner_ID) REFERENCES RESTAURANT_OWNER(Owner_ID)
);

-- Menu and Promotions

CREATE TABLE MENU_ITEMS (
    Item_ID INT,
    Restaurant_ID INT,
    Name VARCHAR(50) NOT NULL,
    Description VARCHAR(255) NOT NULL,
    Price DECIMAL(8, 2) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    CHECK (Category IN ('Appetizer', 'Side', 'Main Course', 'Dessert', 'Beverage')),
    PRIMARY KEY (Item_ID, Restaurant_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES RESTAURANT(Restaurant_ID) ON DELETE CASCADE
);

CREATE TABLE PROMOTIONS (
    Promotion_ID INT,
    Item_ID INT NOT NULL,
    Restaurant_ID INT NOT NULL,
    Description VARCHAR(255) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    CHECK (End_Date >= Start_Date),
    PRIMARY KEY(Promotion_ID, Item_ID, Restaurant_ID),
    FOREIGN KEY (Item_ID, Restaurant_ID) REFERENCES MENU_ITEMS(Item_ID, Restaurant_ID)
);

-- Orders and Relationships
CREATE TABLE FOOD_ORDER (
    Order_ID INT PRIMARY KEY,
    Restaurant_ID INT NOT NULL,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Promised_Delivery_Time DATETIME NOT NULL,
    Actual_Delivery_Time DATETIME,
    Delivery_Status VARCHAR(50) NOT NULL,
    Total_Amount DECIMAL(8, 2) NOT NULL,
    Payment_Method VARCHAR(50) NOT NULL,
    UNIQUE (Order_ID, Restaurant_ID),
    CHECK (Delivery_Status IN ('Delivered', 'Canceled', 'In Progress', 'Not Started')),
    CHECK ((Delivery_Status IN ('In Progress', 'Not Started') AND Actual_Delivery_Time IS NULL) OR
		(Delivery_Status = 'Canceled' AND Actual_Delivery_Time IS NULL AND Total_Amount = 0) OR
		(Delivery_Status = 'Delivered' AND Actual_Delivery_Time IS NOT NULL)),
    CHECK (Payment_Method IN ('Cash', 'Credit', 'Debit', 'Check', 'Other')),
    FOREIGN KEY (Restaurant_ID) REFERENCES RESTAURANT(Restaurant_ID),
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(Customer_ID)
);

CREATE TABLE ITEM_ORDERS (
    Food_Order_ID INT,
    Promotion_ID INT DEFAULT NULL,
    Promo_Item_ID INT DEFAULT NULL,
    Promo_Restaurant_ID INT DEFAULT NULL,
    Menu_Item_ID INT NOT NULL,
    Restaurant_ID INT NOT NULL,
    CHECK (
		(Promotion_ID IS NULL AND Promo_Item_ID IS NULL AND Promo_Restaurant_ID IS NULL)
		OR
		(Promotion_ID IS NOT NULL AND Promo_Item_ID = Menu_Item_ID AND Promo_Restaurant_ID = Restaurant_ID)
	),
    PRIMARY KEY (Food_Order_ID, Menu_Item_ID, Restaurant_ID),
    FOREIGN KEY (Food_Order_ID, Restaurant_ID) REFERENCES FOOD_ORDER(Order_ID, Restaurant_ID) ON DELETE CASCADE,
    FOREIGN KEY (Menu_Item_ID, Restaurant_ID) REFERENCES MENU_ITEMS(Item_ID, Restaurant_ID),
    FOREIGN KEY (Promotion_ID, Promo_Item_ID, Promo_Restaurant_ID) REFERENCES PROMOTIONS(Promotion_ID, Item_ID, Restaurant_ID)
);

-- Reviews
CREATE TABLE REVIEW (
    Review_ID INT PRIMARY KEY,
    Review_Date DATE NOT NULL,
    Rating TINYINT NOT NULL,
    Feedback VARCHAR(255),
    CHECK (Rating BETWEEN 1 AND 5)
);

CREATE TABLE RIDE_REVIEW (
    Review_ID INT PRIMARY KEY,
    Ride_ID INT NOT NULL,
    Rider_ID INT NOT NULL,
    FOREIGN KEY (Review_ID) REFERENCES REVIEW(Review_ID) ON DELETE CASCADE,
    FOREIGN KEY (Ride_ID, Rider_ID) REFERENCES RIDES(Ride_ID, Rider_ID)
);

CREATE TABLE RESTAURANT_REVIEW (
    Review_ID INT PRIMARY KEY,
    Order_ID INT,
    Restaurant_ID INT NOT NULL,
    Customer_ID INT NOT NULL,
    FOREIGN KEY (Review_ID) REFERENCES REVIEW(Review_ID) ON DELETE CASCADE,
    FOREIGN KEY (Order_ID, Restaurant_ID) REFERENCES FOOD_ORDER(Order_ID, Restaurant_ID),
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(Customer_ID)
);

CREATE TABLE ITEM_REVIEW (
    Review_ID INT PRIMARY KEY,
    Order_ID INT,
    Customer_ID INT NOT NULL,
    Item_ID INT NOT NULL,
    Restaurant_ID INT NOT NULL,
    FOREIGN KEY (Review_ID) REFERENCES REVIEW(Review_ID) ON DELETE CASCADE,
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(Customer_ID),
    FOREIGN KEY (Order_ID, Item_ID, Restaurant_ID) REFERENCES ITEM_ORDERS(Food_Order_ID, Menu_Item_ID, Restaurant_ID)
);

-- Employees and Roles

CREATE TABLE EMPLOYEE (
    Employee_ID VARCHAR(10) PRIMARY KEY,
    Start_Date DATE NOT NULL,
    Department VARCHAR(50) NOT NULL,
    Age INT NOT NULL,
    CHECK (Employee_ID REGEXP '^E[0-9]+$'),
    CHECK (Age > 17)
);

CREATE TABLE PLATFORM_MANAGER (
    Manager_ID VARCHAR(10) PRIMARY KEY,
    FOREIGN KEY (Manager_ID) REFERENCES EMPLOYEE(Employee_ID) ON DELETE CASCADE
);

CREATE TABLE SUPPORT_AGENT (
    Agent_ID VARCHAR(10) PRIMARY KEY,
    FOREIGN KEY (Agent_ID) REFERENCES EMPLOYEE(Employee_ID) ON DELETE CASCADE
);

CREATE TABLE DELIVERY_COORDINATOR (
    Coordinator_ID VARCHAR(10) PRIMARY KEY,
    FOREIGN KEY (Coordinator_ID) REFERENCES EMPLOYEE(Employee_ID) ON DELETE CASCADE
);

CREATE TABLE DELIVERY_ASSIGNMENT (
    Assignment_ID INT PRIMARY KEY,
    Driver_ID INT NOT NULL,
    Food_Order_ID INT NOT NULL,
    Coordinator_ID VARCHAR(10) NOT NULL,
    FOREIGN KEY (Driver_ID) REFERENCES DRIVER(Driver_ID) ON DELETE CASCADE,
    FOREIGN KEY (Food_Order_ID) REFERENCES FOOD_ORDER(Order_ID),
    FOREIGN KEY (Coordinator_ID) REFERENCES DELIVERY_COORDINATOR(Coordinator_ID) ON DELETE CASCADE
);