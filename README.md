# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/CoDy23x/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, count(*) as number_of_movies_or_tv_shows
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT type, rating
FROM
	(SELECT type, rating, COUNT(*), RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1, 2
	) as common_rating
WHERE ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT *
FROM netflix
WHERE release_year = 2020 AND type = 'movie';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT
	type, title, CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) as new_duration
FROM
	netflix
WHERE 
	type = 'Movie' AND duration IS NOT NULL
ORDER BY 3 DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT
	*
FROM
	netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') BETWEEN STR_TO_DATE('January 01, 2016', '%M %d, %Y') AND STR_TO_DATE('December 31, 2021', '%M %d, %Y');
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT
	*
FROM
	netflix
WHERE
	LOWER(director) LIKE LOWER('%Rajiv Chilaka%');
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT
	*
FROM
	netflix
WHERE type = 'TV Show' AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) >= 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT
	YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS YEAR,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100, 2) AS average_numbers_of_content
FROM
	netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT
	*
FROM
	netflix
WHERE
	type = 'Movie' AND listed_in LIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT
	*
FROM
	netflix
WHERE
	director = '';
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT
	*
FROM
	netflix
WHERE
	cast LIKE '%Salman Khan%' AND release_year > 2021 - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT
	CASE
		WHEN description LIKE '% kill%' OR description LIKE '%violence%' THEN 'Bad Content'
        ELSE 'Good Content'
        END AS content_category,
	COUNT(*) AS total_content
FROM
	netflix
GROUP BY 1;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
