-- LoyalCustomers: Which customers have placed orders consistently every month for the past year?
CREATE VIEW LoyalCustomers AS
	SELECT c.Customer_ID, u.First_Name, u.Middle_Name, u.Last_Name
	FROM CUSTOMER c
		JOIN USERS u ON c.Customer_ID = u.User_ID
		JOIN FOOD_ORDER fo ON c.Customer_ID = fo.Customer_ID
	WHERE fo.Order_Date >= CURDATE() - INTERVAL 1 YEAR
	GROUP BY c.Customer_ID, u.First_Name, u.Middle_Name, u.Last_Name
	HAVING COUNT(DISTINCT MONTH(fo.Order_Date)) = 12;

-- TopRatedRestaurants: Which restaurants have an average review rating of 4.5 or higher over the past six months?
CREATE VIEW TopRatedRestaurants AS
	SELECT rt.Restaurant_ID, rt.Name, AVG(r.Rating) AS AVG_Rating
    FROM RESTAURANT rt
		JOIN RESTAURANT_REVIEW rr ON rt.Restaurant_ID = rr.Restaurant_ID
        JOIN REVIEW r ON rr.Review_ID = r.Review_ID
	WHERE r.Review_Date >= CURDATE() - INTERVAL 6 MONTH
    GROUP BY rt.Restaurant_ID, rt.Name
    HAVING AVG(r.Rating) >= 4.5;
    
-- ActiveDrivers: Which delivery drivers have completed at least 20 deliveries within the last two weeks?
CREATE VIEW ActiveDrivers AS
	SELECT d.Driver_ID, u.First_Name, u.Middle_Name, u.Last_Name, COUNT(*) AS Completed_Deliveries
    FROM DELIVERY_ASSIGNMENT da
		JOIN FOOD_ORDER fo ON da.Food_Order_ID = fo.Order_ID
        JOIN DRIVER d ON da.Driver_ID = d.Driver_ID
        JOIN USERS u ON d.Driver_ID = u.User_ID
	WHERE fo.Order_Date >= CURDATE() - INTERVAL 14 DAY
		AND fo.Delivery_Status = 'Delivered'
	GROUP BY d.Driver_ID, u.First_Name, u.Middle_Name, u.Last_Name
    HAVING COUNT(*) >= 20;
    
-- PopularMenuItems: What are the top 10 most frequently ordered menu items across all restaurants in the past three months?
CREATE VIEW PopularMenuItems AS
	SELECT mi.Item_ID, mi.Restaurant_ID, mi.Name AS Item_Name, r.Name AS Restaurant_Name, COUNT(*) AS Times_Ordered
    FROM ITEM_ORDERS o
		JOIN MENU_ITEMS mi ON o.Menu_Item_ID = mi.Item_ID AND o.Restaurant_ID = mi.Restaurant_ID
        JOIN FOOD_ORDER fo ON o.Food_Order_ID = fo.Order_ID
        JOIN RESTAURANT r ON mi.Restaurant_ID = r.Restaurant_ID
	WHERE fo.Order_Date >= CURDATE() - INTERVAL 3 MONTH
    GROUP BY mi.Item_ID, mi.Restaurant_ID, mi.Name, r.Name
	ORDER BY Times_Ordered DESC
    LIMIT 10;
    
-- ProminentOwners: Which restaurant owners manage multiple restaurants with a combined total of at least 50 orders in the past month?
CREATE VIEW ProminentOwners AS
	SELECT r.Owner_ID, u.First_Name, u.Middle_Name, u.Last_Name, COUNT(fo.Order_ID) AS Total_Orders, COUNT(DISTINCT r.Restaurant_ID) AS Number_of_Restaurants
    FROM RESTAURANT r
		JOIN FOOD_ORDER fo ON r.Restaurant_ID = fo.Restaurant_ID
        JOIN USERS u ON r.Owner_ID = u.User_ID
	WHERE fo.Order_Date >= CURDATE() - INTERVAL 1 MONTH
    GROUP BY r.Owner_ID, u.First_Name, u.Middle_Name, u.Last_Name
    HAVING COUNT(DISTINCT r.Restaurant_ID) > 1 
		AND COUNT(fo.Order_ID) >= 50;