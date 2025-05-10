-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
					show_id VARCHAR(10),
                    type VARCHAR(10),
                    title VARCHAR(150),
                    director VARCHAR(250),
                    cast VARCHAR(800),
                    country VARCHAR(150),
                    date_added VARCHAR(50),
                    release_year INT,
                    rating VARCHAR(15),
                    duration VARCHAR(15),
                    listed_in VARCHAR(85),
                    description VARCHAR(260)
);

SET GLOBAL LOCAL_INFILE=ON;
LOAD DATA LOCAL INFILE '/Users/cody/Documents/SQL projects/netflix_sql_project/netflix_titles.csv'
INTO TABLE netflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 1. Count the number of Movies vs TV Shows
SELECT type, count(*) as number_of_movies_or_tv_shows
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows
SELECT type, rating
FROM
	(SELECT type, rating, COUNT(*), RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1, 2
	) as common_rating
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERE release_year = 2020 AND type = 'movie';

-- 4. Find the top 5 countries with the most content on Netflix
SELECT country, type, total_content
FROM
	(SELECT TRIM(jt.country) as country, type, count(*) as total_content, RANK() OVER(ORDER BY COUNT(*) DESC) as ranking
	FROM netflix,
		JSON_TABLE(
				CONCAT('["', REPLACE(country, ',', '","'), '"]'),
				"$[*]" COLUMNS (country VARCHAR(255) PATH "$")
		) AS jt
	WHERE TRIM(jt.country) != ''
	GROUP BY 1, 2
    ) AS top_5_countries
WHERE ranking BETWEEN 1 AND 5
GROUP BY 1, 2;

-- 5. Identify the longest movie
SELECT
	type, title, CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) as new_duration
FROM
	netflix
WHERE 
	type = 'Movie' AND duration IS NOT NULL
ORDER BY 3 DESC
LIMIT 1;

-- 6. Find content added in the last 5 years
SELECT
	*
FROM
	netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') BETWEEN STR_TO_DATE('January 01, 2016', '%M %d, %Y') AND STR_TO_DATE('December 31, 2021', '%M %d, %Y');

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT
	*
FROM
	netflix
WHERE
	LOWER(director) LIKE LOWER('%Rajiv Chilaka%');
    
-- 8. List all TV shows with more than 5 seasons
SELECT
	*
FROM
	netflix
WHERE type = 'TV Show' AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) >= 5;

-- 9. Count the number of content items in each genre
SELECT
	jt.listed_in AS genre,
    COUNT(*) AS number_of_content
FROM
	netflix,
	JSON_TABLE(
			CONCAT('["', REPLACE(listed_in, ',', '","'), '"]'),
            "$[*]" COLUMNS (listed_in VARCHAR(255) PATH "$")
			) AS jt
GROUP BY 1;

-- 10.Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release!
SELECT
	YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS YEAR,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100, 2) AS average_numbers_of_content
FROM
	netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT
	*
FROM
	netflix
WHERE
	type = 'Movie' AND listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT
	*
FROM
	netflix
WHERE
	director = '';
    
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT
	*
FROM
	netflix
WHERE
	cast LIKE '%Salman Khan%' AND release_year > 2021 - 10;
    
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT
    TRIM(jt.cast) AS casts,
    COUNT(*) as number_of_movies
FROM
	netflix,
    JSON_TABLE(
			CONCAT('["', REPLACE(cast, ',', '","'), '"]'),
            "$[*]" COLUMNS (cast VARCHAR(255) PATH "$")
			) AS jt
WHERE
	country = 'India' AND TRIM(jt.cast) != ''
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
	-- Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
SELECT
	CASE
		WHEN description LIKE '% kill%' OR description LIKE '%violence%' THEN 'Bad Content'
        ELSE 'Good Content'
        END AS content_category,
	COUNT(*) AS total_content
FROM
	netflix
GROUP BY 1;