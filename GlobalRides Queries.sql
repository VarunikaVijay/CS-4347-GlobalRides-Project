-- TopEarningDrivers: List the names and total earnings of the top five drivers.
SELECT u.User_Id AS Driver_ID, u.First_Name, u.Middle_Name, u.Last_Name, SUM(r.Fare) AS Total_Earnings
FROM RIDES r
	JOIN USERS u ON r.Driver_ID = u.User_ID
GROUP BY u.User_Id, u.First_Name, u.Middle_Name, u.Last_Name
ORDER BY Total_Earnings DESC
LIMIT 5;

-- HighSpendingCustomers: Identify customers who have spent more than $1,000 and list their total expenditure.
SELECT c.Customer_ID, u.First_Name, u.Middle_Name, u.Last_Name, SUM(fo.Total_Amount) AS Total_Expenditure
FROM FOOD_ORDER fo
	JOIN CUSTOMER c ON fo.Customer_ID = c.Customer_ID
    JOIN USERS u ON c.Customer_ID = u.User_ID
GROUP BY c.Customer_ID, u.First_Name, u.Middle_Name, u.Last_Name
HAVING SUM(fo.Total_Amount) > 1000;

-- FrequentReviewers: Find customers who have left at least 10 reviews and their average review rating.
SELECT c.Customer_ID, u.First_Name, u.Middle_Name, u.Last_Name, COUNT(r.Review_ID) AS Total_Reviews, AVG(r.Rating) AS AVG_Rating
FROM CUSTOMER c
	JOIN USERS u ON c.Customer_ID = u.User_ID
    JOIN (
		SELECT Customer_ID, Review_ID 
        FROM RESTAURANT_REVIEW
        UNION ALL
        SELECT Customer_ID, Review_ID
        FROM ITEM_REVIEW
    ) AS all_reviews ON c.Customer_ID = all_reviews.Customer_ID
    JOIN REVIEW r ON all_reviews.Review_ID = r.Review_ID
GROUP BY c.Customer_ID, u.First_Name, u.Middle_Name, u.Last_Name
HAVING COUNT(r.Review_ID) >= 10;

-- InactiveRestaurants: List restaurants that have not received any orders in the past months.
SELECT r.Restaurant_ID, r.Name
FROM RESTAURANT r
	LEFT JOIN FOOD_ORDER fo ON r.Restaurant_ID = fo.Restaurant_ID
		AND fo.Order_Date >= CURDATE() - INTERVAL 1 MONTH
WHERE fo.Order_ID IS NULL;

-- PeakOrderDay: Identify the day of the week with the highest number of orders in the past month.
SELECT DAYNAME(Order_Date) AS Day_of_the_Week, COUNT(*) AS Total_Orders
FROM FOOD_ORDER
WHERE Order_Date >= CURDATE() - INTERVAL 1 MONTH
GROUP BY DAYNAME(Order_Date)
ORDER BY Total_Orders DESC
LIMIT 1;

-- HighEarningRestaurants: Find the top three restaurants with the highest total revenue in the past year.
SELECT r.Restaurant_ID, r.Name, SUM(fo.Total_Amount) AS Total_Revenue
FROM FOOD_ORDER fo
	JOIN RESTAURANT r ON fo.Restaurant_ID = r.Restaurant_ID
WHERE fo.Order_Date >= CURDATE() - INTERVAL 1 YEAR
GROUP BY r.Restaurant_ID, r.Name
ORDER BY Total_Revenue DESC
LIMIT 3;

-- PopularCuisineType: Identify the most frequently ordered cuisine type in the past six months.
SELECT r.Cuisine, COUNT(fo.Order_ID) AS Number_of_Orders
FROM FOOD_ORDER fo
	JOIN RESTAURANT r ON fo.Restaurant_ID = r.Restaurant_ID
WHERE fo.Order_Date >= CURDATE() - INTERVAL 6 MONTH
GROUP BY r.Cuisine
ORDER BY Number_of_Orders DESC
LIMIT 1;

-- LongestRideRoutes: Identify the top five ride routes with the longest travel distances.
SELECT r.Pickup_Location, r.Drop_Off_Location, r.Distance
FROM RIDES r
ORDER BY r.Distance DESC
LIMIT 5;

-- DriverRideCounts: Display the total number of rides delivered by each driver in the past three months.
SELECT r.Driver_ID, u.First_Name, u.Middle_Name, u.Last_Name, COUNT(r.Ride_ID) AS Total_Rides
FROM RIDES r
	JOIN USERS u ON r.Driver_ID = u.User_ID
WHERE r.Pickup_Time >= CURDATE() - INTERVAL 3 MONTH
GROUP BY r.Driver_ID, u.First_Name, u.Middle_Name, u.Last_Name;

-- UndeliveredOrders: Find all orders that were not delivered within the promised time window and their delay durations.
SELECT fo.Order_ID, fo.Order_Date, fo.Promised_Delivery_Time, fo.Actual_Delivery_Time, TIMESTAMPDIFF(MINUTE, fo.Promised_Delivery_Time, fo.Actual_Delivery_Time) AS Minutes_Delayed
FROM FOOD_ORDER fo
WHERE fo.Actual_Delivery_Time > fo.Promised_Delivery_Time;

-- MostCommonPaymentMethods: Identify the most frequently used payment method on the platform for both rides and food orders.
SELECT Payment_Method, COUNT(*) AS Usage_Count
FROM (
	SELECT r.Payment_Method
    FROM RIDES r
    UNION ALL
    SELECT fo.Payment_Method
    FROM Food_Order fo
) AS payment_methods
GROUP BY Payment_Method
ORDER BY Usage_Count DESC
LIMIT 1;

-- MultiRoleUsers: Identify users who simultaneously serve as both Drivers and Restaurant Owners, along with their details.
SELECT u.User_ID, u.First_Name, u.Middle_Name, u.Last_Name, u.Address, u.Date_of_Birth, u.Gender, d.Vehicle, COUNT(r.Restaurant_ID) AS Number_of_Restaurants_Owned
FROM USERS u
	JOIN DRIVER d ON u.User_ID = d.Driver_ID
	JOIN RESTAURANT_OWNER ro ON u.User_ID = ro.Owner_ID
    JOIN RESTAURANT r ON ro.Owner_ID = r.Owner_ID
GROUP BY u.User_ID, u.First_Name, u.Middle_Name, u.Last_Name, u.Address, u.Date_of_Birth, u.Gender, d.Vehicle;

-- DriverVehicleTypes: Display the distribution of drivers by vehicle type (Sedan, SUV, and etc.), including the total number for each type.
SELECT d.Vehicle, COUNT(*) AS Total_Drivers
FROM DRIVER d
GROUP BY d.Vehicle;


