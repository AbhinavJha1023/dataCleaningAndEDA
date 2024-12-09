-- Data Cleaning Project
-- Removing Duplicates
create table layoff_stage
like layoffs;

select *
from layoff_stage;

insert layoff_stage
select *
from layoffs;

with dup_cte as
(
	select *,
    row_number() over (
    partition by company, location, industry, total_laid_off, 
    percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) as row_num
    from layoff_stage
)
select *
from dup_cte
where row_num > 1;

-- Cannot Directly Delete From CTE
-- Form A New Table And Add row_num And Then Delete

CREATE TABLE `layoff_stage2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoff_stage2
select *,
row_number() over (
partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions
) as row_num
from layoff_stage;
    
select *
from layoff_stage2
where row_num > 1;

SET SQL_SAFE_UPDATES = 0;

delete
from layoff_stage2
where row_num > 1;

select *
from layoff_stage2;


-- Standardizing Data
select company, trim(company)
from layoff_stage2;

update layoff_stage2
set company = trim(company);

select *
from layoff_stage2
where industry like "Crypto%";

update layoff_stage2
set industry = "Crypto"
where industry like "Crypto%";

update layoff_stage2
set country = "United States"
where industry like "United States%";

-- Converting Text To Date
select `date`,
str_to_date(`date`, '%m/%d/%Y') as Date
from layoff_stage2;

update layoff_stage2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoff_stage2
modify column `date` date;

-- Removing Null/Blank Values

select *
from layoff_stage2
where industry is null
or industry = '';

-- Set '' To Null

update layoff_stage2
set industry = null
where industry = '';

-- We Will Fill Up Blank Industries With Company Respective Industry In Other Rows
select *
from layoff_stage2 t1
join layoff_stage2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = "")
and t2.industry is not null;

update layoff_stage2 t1
join layoff_stage2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

-- Removing Rows And Columns
select *
from layoff_stage2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoff_stage2
where total_laid_off is null
and percentage_laid_off is null;

-- Drop Row_num Column Since It Is Useless Now
alter table layoff_stage2
drop column row_num;