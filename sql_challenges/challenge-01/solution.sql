--lesson 1
SELECT title FROM movies;
SELECT director FROM movies;
SELECT title, director FROM movies;
SELECT title, year FROM movies;
SELECT * FROM movies;

--lesson2
SELECT * FROM movies WHERE Id == 6;
SELECT * FROM movies WHERE year >= 2000 AND year <= 2010;
SELECT * FROM movies WHERE NOT year BETWEEN 2000 AND 2010;
SELECT * FROM movies WHERE id <= 5;

--lesson 3
SELECT * FROM movies WHERE title == "Toy Story";
SELECT * FROM Movies WHERE title LIKE 'Toy Story%';
SELECT * FROM Movies WHERE director = "John Lasseter";
SELECT * FROM Movies WHERE director != "John Lasseter";
SELECT * FROM Movies WHERE title LIKE 'WALL-%';

--lesson 4
SELECT DISTINCT director FROM movies ORDER BY director ASC;
SELECT DISTINCT * FROM movies ORDER BY year ASC LIMIT 4;
SELECT DISTINCT * FROM movies ORDER BY title ASC LIMIT 5;
SELECT DISTINCT * FROM movies ORDER BY title ASC LIMIT 5 OFFSET 5;

--lesson 5
SELECT * FROM north_american_cities WHERE country == "Canada";
SELECT * FROM north_american_cities WHERE country == "United States" ORDER BY latitude DESC;

SELECT * FROM north_american_cities 
    WHERE longitude < (
        SELECT longitude
        FROM north_american_cities
        WHERE city = 'Chicago'
    )
ORDER BY longitude ASC

SELECT * FROM north_american_cities 
    WHERE country == "Mexico"
    ORDER BY population DESC
    LIMIT 2

SELECT * FROM north_american_cities 
    WHERE country == "United States"
    ORDER BY population DESC
    LIMIT 2
    OFFSET 2