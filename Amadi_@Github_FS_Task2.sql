-- FoodserviceDB Database

-- Creating the database

CREATE DATABASE FoodserviceDB;
GO

-- Use the database
USE FoodserviceDB;


-- Add primary key constraint to Restaurant table
ALTER TABLE restaurants
ADD PRIMARY KEY (Restaurant_ID);

-- Add primary key constraint to Consumers table
ALTER TABLE consumers
ADD PRIMARY KEY (Consumer_ID);

-- Add primary key constraint to Ratings table
ALTER TABLE ratings
ADD CONSTRAINT PK_ratings PRIMARY KEY (Consumer_ID, Restaurant_ID);

-- Add foreign key constraint to Ratings table referencing Consumers table
ALTER TABLE ratings
ADD CONSTRAINT FK_Consumer_ID FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID);

-- Add foreign key constraint to Ratings table referencing Restaurant table
ALTER TABLE ratings
ADD CONSTRAINT FK_Restaurant_ID FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID);

-- Add primary key constraint to Restaurant_Cuisines table
ALTER TABLE restaurant_cuisines
ADD CONSTRAINT PK_restaurant_cuisines PRIMARY KEY (Restaurant_ID, Cuisine);

-- Add foreign key constraint to Restaurant_Cuisines table referencing Restaurant table
ALTER TABLE restaurant_cuisines
ADD CONSTRAINT FK_Restaurant_ID_Cuisines FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID);


-- 1. retrieving all restaurants with a Medium range price, open area, and serving Mexican food

SELECT *
FROM Restaurants r
INNER JOIN Restaurant_Cuisines rc ON r.Restaurant_id = rc.Restaurant_id
WHERE r.Price = 'Medium'
AND r.Area = 'Open'
AND rc.Cuisine = 'Mexican';


-- Q2. retrieving the total number of restaurants with an overall rating of 1 and serving Mexican food
SELECT COUNT(*) AS Total_Mexican_Restaurants_Rating_1
FROM Restaurants r
INNER JOIN Ratings ra ON r.Restaurant_id = ra.Restaurant_id
INNER JOIN Restaurant_Cuisines rc ON r.Restaurant_id = rc.Restaurant_id
WHERE ra.Overall_Rating = 1
AND rc.Cuisine = 'Mexican';

-- comparing the results with the total number of restaurants with an overall rating of 1 serving Italian food
SELECT COUNT(*) AS Total_Italian_Restaurants_Rating_1
FROM Restaurants r
INNER JOIN Ratings ra ON r.Restaurant_id = ra.Restaurant_id
INNER JOIN Restaurant_Cuisines rc ON r.Restaurant_id = rc.Restaurant_id
WHERE ra.Overall_Rating = 1
AND rc.Cuisine = 'Italian';


-- Q3. calculating the average age of consumers who have given a 0 rating to the 'Service_rating' 
SELECT ROUND(AVG(c.Age), 0) AS average_age

FROM consumers c

JOIN ratings r ON c.Consumer_id = r.Consumer_id

WHERE r.Service_Rating = 0;


-- Q4. Retrieving the restaurants ranked by the youngest consumer along with the food rating 
-- by that customer to the restaurant, sorted by food rating from high to low
SELECT 
    r.Name AS Restaurant_Name,
    MIN(c.Age) AS Youngest_Consumer_Age,
    ra.Food_Rating
FROM 
    restaurants r
JOIN 
    ratings ra ON r.Restaurant_id = ra.Restaurant_id
JOIN 
    consumers c ON ra.Consumer_id = c.Consumer_id
GROUP BY 
    r.Restaurant_id, r.Name, ra.Food_Rating
ORDER BY 
    ra.Food_Rating DESC;


-- Q5. Writing a stored procedure for the query given as: 
-- Update the Service_rating of all restaurants to '2' if they have parking available

CREATE PROCEDURE UpdateServiceRatingWithParking
AS
BEGIN
    SET NOCOUNT ON;
    -- Updating Service_Rating for restaurants with parking available
    UPDATE ratings
    SET Service_Rating = '2'
    WHERE Restaurant_id IN (
        SELECT r.Restaurant_id
        FROM restaurants r
        WHERE r.Parking IN ('yes', 'public')
    );
END;


-- Q6. The four queries
-- Query 1: Find the average overall rating for restaurants that serve Mexican cuisine
-- and have a price level of 'Medium'.

SELECT AVG(ra.Overall_Rating) AS Avg_Overall_Rating
FROM Ratings ra
WHERE ra.Restaurant_id IN (
    SELECT r.Restaurant_id
    FROM Restaurants r
    WHERE r.Price = 'Medium'
    AND r.Restaurant_id IN (
        SELECT rc.Restaurant_id
        FROM Restaurant_Cuisines rc
        WHERE rc.Cuisine = 'Mexican'
    )
);

-- Query 2: List restaurants with the highest food rating.
SELECT Top 5 r.Name AS Restaurant_Name, MAX(ra.Food_Rating) AS Max_Food_Rating
FROM Restaurants r
JOIN Ratings ra ON r.Restaurant_id = ra.Restaurant_id
GROUP BY r.Name
ORDER BY Max_Food_Rating DESC
;

-- Query 3: Find the number of consumers who have rated a restaurant's service higher than its food.
SELECT COUNT(*) AS Num_Consumers
FROM (
    SELECT ra.Consumer_id
    FROM Ratings ra
    WHERE ra.Service_Rating > ra.Food_Rating
    GROUP BY ra.Consumer_id
) AS Subquery;


-- System functions 
SELECT Name, City, State, LEN(Name) AS Name_Length
FROM restaurants
SELECT Name, City, State
FROM restaurants
WHERE Restaurant_id IN (
    SELECT Restaurant_id
    FROM ratings
    GROUP BY Restaurant_id
    HAVING AVG(Overall_Rating) < 3
);

-- Use of GROUP BY, HAVING and ORDER BY clauses

SELECT COUNT(*), Price

FROM restaurants

GROUP BY Price

HAVING COUNT(*) > 10;


-- Query 4: Find the consumers with the highest and lowest budget, along with their average age.
SELECT c.Budget, AVG(c.Age) AS Avg_Age
FROM Consumers c
GROUP BY c.Budget
ORDER BY CASE WHEN c.Budget = 'High' THEN 1 ELSE 2 END, Avg_Age DESC;

