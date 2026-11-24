-- Netflix project MSQL
-- queries left 2,4
-- creating database of Netflix
create database if not exists netflix_db;

use netflix_db;

-- creating my database table--

CREATE TABLE netflix 
( show_id VARCHAR(10) PRIMARY KEY, type VARCHAR(10), 
title VARCHAR(255), director VARCHAR(550),
 cast_members TEXT, country VARCHAR(250), 
 date_added VARCHAR(50), release_year INT, 
rating VARCHAR(20), duration VARCHAR(20), 
listed_in VARCHAR(255), description TEXT );

select count(*) from netflix;

--  Count Movies vs TV Shows.

select type,count(*) as total_number from netflix
group by type;

-- List all movies released in a specific year (e.g., 2020).

select *
from netflix
where type = 'Movie' and release_year=2020;

-- Identify the longest movie on Netflix.
-- data type casting
select director,type, 
cast(substring(duration,1,instr(duration,' ')-1) as unsigned) as movie_duration
from netflix
where type = 'Movie'
order by movie_duration desc limit 1;


-- alternate of upper query

select *
from netflix where 
cast(substring(duration,1,instr(duration,' ')-1) as unsigned) 
=(SELECT max(cast(substring(duration,1,instr(duration,' ')-1) 
as unsigned)) as duration_int
 FROM NETFLIX
WHERE TYPE='Movie');

-- List all TV shows with more than 5 seasons.
with cte_tv_show as 
(select *,cast(substring(duration,1,instr(duration,' ')-1) as unsigned) as
 show_duration
 from 
netflix 
where type = 'Tv Show')

select * from cte_tv_show where show_duration>5
order by show_duration desc;

-- Find content added in the last 10 years.

select *
from netflix
where str_to_date(date_added,'%M %d, %Y')>date_sub(curdate(),interval 10 year);

-- Find all movies/TV shows by director 'Delhiprasad Deenadayalan'.

select * from netflix where 
 trim(upper(director)) like '%DELHIPRASAD DEENADAYALAN%';
 
 -- Find each year and the average numbers of content release in India, return top 5 years.
 
 select release_year,count(*) as total_releases
 from netflix where trim(upper(country)) like '%INDIA%'
 GROUP BY release_year
 order by total_releases desc limit 5;
 
 -- List all movies that are documentaries.
 
 select title,type from netflix 
 where type = 'Movie' and 
 trim(upper(listed_in)) like '%DOCUMENTARIES%';
 
 --  Find all content without a director.
 
 select * from netflix where director ='';
 
 --  Categorize content as 'Bad' if description contains 'kill'/'violence', else 'Good'. Count items..
 
 with my_cte as (select*,
 case when description like '%kill%' or description like '%violence%' then 'bad' else 'good' end as category
 from netflix)
 select category,count(*)
 FROM my_cte 
 group by category;
 
 -- Find the most frequent rating for movies and TV shows.
 with my_cte as (select type,rating,count(*), dense_rank() 
 over (partition by type order by count(*) desc) as my_rank
 from netflix
 group by type,rating)
 select * from my_cte where my_rank=1;
 
 -- Find how many movies actor 'Salman Khan' appeared in in the last 10 years.
 -- run this query on postgres sql
 select *
from netflix where type='Movie'
and trim(upper(casting)) like '%SALMAN KHAN%'
and release_year> extract(year from current_date) -10;
 
 -- Find the top 10 actors in Indian-produced movies.
 -- run this query only on postgrade sql
 
 select unnest(string_to_array(casting,', ')) as actors,count(*) as content
from netflix
where trim(upper(country)) like '%INDIA%'
group by actors
order by content desc limit 10;

--  Find the top 5 countries with the most content.
-- run on only on postsql

select unnest(string_to_array(country,', ')) as country_master_list,count(*) as content
from netflix
group by country_master_list
order by content desc
limit 5

-- Count the number of items in each genre.
-- run this query only in postgrasql

select unnest(string_to_array(listed_in,', ')) as geners_masterlist,count(*) as content
from netflix 
group by geners_masterlist
order by content desc

 


