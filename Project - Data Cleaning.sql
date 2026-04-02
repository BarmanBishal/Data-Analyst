
-- SQL PROJECT FOR DATA CLEANING -- 

SELECT *
FROM layoffs;

-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE layoffs_staging 
LIKE layoffs;

INSERT layoffs_staging 
SELECT * FROM layoffs;


-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways


-- 1. Remove Duplicates

# First let's check for duplicates

SELECT *
FROM layoffs_staging ;
;

SELECT *
FROM layoffs_staging where company = "Casper";

-- USING WINDOW FUNCTION  --

-- add one primary key in the table -- 
alter table layoffs_staging add column `layoff_staging_id` int(10) auto_increment primary key first; 

-- identifying the duplicates -- 

select *, row_number() 
over(partition by company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num 
from layoffs_staging;

select * from 
(
			select *, row_number() 
			over(partition by company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num 
			from layoffs_staging
) as d
where d.row_num > 1;

-- i need only those id's -- 
select layoff_staging_id from
(
			select *, row_number() 
			over(partition by company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num 
			from layoffs_staging
) as d
where d.row_num > 1;

-- delete from here --
delete from layoffs_staging
where layoff_staging_id in 
(
					select layoff_staging_id from
					(
					select *, row_number() 
					over(partition by company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num 
					from layoffs_staging
					) as d 
					where d.row_num > 1
);

-- now drop the primary key -- 
alter table layoffs_staging drop column layoff_staging_id;


SELECT *
FROM layoffs_staging where company = "Casper";
select * from layoffs where company = "Casper";


-- 2. standardize data and fix errors -- 

-- company -- 
select * from layoffs_staging;
select company from layoffs_staging order by 1;

select company, trim(company) from layoffs_staging;

update layoffs_staging set company = trim(company);


-- industry -- 

select distinct industry from layoffs_staging order by 1;

select industry, trim(industry) from layoffs_staging;

select * from layoffs_staging where industry like "Crypto%";

update layoffs_staging set industry = 'Crypto' where industry like "Crypto%";


-- location -- 

select distinct location from layoffs_staging order by 1;

select location, trim(location) from layoffs_staging;

-- country  -- 
select * from layoffs_staging where country like "United States%";

select distinct country, trim(trailing '.' from country) from layoffs_staging order by 1;

select distinct country from layoffs_staging order by 1;

update layoffs_staging set country = 'United States' where country like "United States%";

-- noew very intresting thing change the data type of date 
select `date` from layoffs_staging;

select `date`, str_to_date(`date`,'%m/%d/%Y') from layoffs_staging;

update layoffs_staging set `date` =  str_to_date(`date`,'%m/%d/%Y');

alter table layoffs_staging modify column `date` date;

select * from layoffs_staging;


-- 3. Look at null values and see what

select * from layoffs_staging where total_laid_off is null and percentage_laid_off is null;

-- we got null and black values at industry column
select * from layoffs_staging where industry is null or industry = '';

select * from layoffs_staging where company like 'Bally%';

select distinct company from layoffs_staging;

select * from layoffs_staging t1
join layoffs_staging t2
	on t1.company = t2.company
where t1.industry is null
and t2.industry is not null;

select t1.industry, t2.industry from layoffs_staging t1
join layoffs_staging t2
	on t1.company = t2.company
where t1.industry is null
and t2.industry is not null;

-- first we have to set the value null in industry column
update layoffs_staging set industry = null where industry = '';

-- now going to update 
update layoffs_staging t1
join layoffs_staging t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

-- 4. remove any columns and rows we need to

SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

select * from layoffs_staging;

