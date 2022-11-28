# create table for g20 country
DROP TABLE IF EXISTS energy_g20;
CREATE TABLE energy_g20
	(
		entity VARCHAR(255),
        Code VARCHAR(255),
        year INT,
        energy_consumption_twh DOUBLE(12,2)
    );

#updating code for EU 
UPDATE energy_owid
SET Code = "EUU"
WHERE entity = "European Union (27)";

#inserting datas into newly created table
INSERT INTO energy_g20 (entity, code, year, energy_consumption_twh)
SELECT
	entity,
    Code,
	year,
    energy_cons_twh
FROM
	energy_owid
WHERE
	Code IN ("ARG","AUS","BRA","CAN","CHN","FRA",
			 "DEU","IND","IDN","ITA","JPN","MEX",
             "KOR","RUS","SAU","ZAF","TUR","GBR",
             "USA","EUU");

#data for g20 country
SELECT	
	*
FROM 
	energy_g20;


#amount of entity with a code
SELECT
	COUNT(DISTINCT Code)
FROM
	owid_energy_g20
WHERE Code != "";

#datas for all countries
SELECT
	entity,
	Code,
    YEAR(Year) as year,
    `Electricity generation (TWh)` as el_gen_TWh
FROM owid_energy_g20
WHERE Code != "";

#data for non-country entities
SELECT
	Code,
    YEAR(Year) as year,
    `Electricity generation (TWh)` as el_gen_TWh,
    entity
FROM owid_energy_g20
WHERE Code = "";

#top 10 countries only
SELECT
	entity,
    code,
    year,
    FORMAT(energy_cons_twh, 2) as energy_consumption
FROM
	energy_owid
WHERE
	year = 2021 AND
    Code != ""
HAVING Code != ("OWID_WRL") AND Code !=("EUU")
ORDER BY energy_cons_twh DESC
LIMIT 10;

#top 10 countries in 2021 with the most energy consumption + worldwide consumption for comparison
SELECT
	e.entity,
    e.code,
    e.year,
    FORMAT(e.energy_cons_twh, 2) AS energy_consumption,
    FORMAT((100*e.energy_cons_twh) / (a.energy_cons_twh), 2) AS relative_consumption
FROM
	energy_owid e,
    (SELECT
		energy_cons_twh
	 FROM
		energy_owid
	 WHERE
		year = 2021 AND entity = "World") a
WHERE
	e.year = 2021 AND
    e.code != ""
ORDER BY e.energy_cons_twh DESC
LIMIT 11;

# yearly change in energy consumption
SELECT
	*,
    CASE WHEN LAG(entity) OVER() = entity THEN energy_cons_twh - LAG(energy_cons_twh) OVER()
	ELSE Null
	END AS en_cons_change
FROM
	energy_owid;

# average yearly change
SELECT
	e.entity,
    e.code,
    COUNT(DISTINCT(year)) AS last_n_years,
    AVG(o.en_cons_change) AS avg_yearly_change
FROM
	energy_owid e
	JOIN
	(SELECT
		entity,
        CASE WHEN LAG(entity) OVER() = entity THEN energy_cons_twh - LAG(energy_cons_twh) OVER()
		ELSE Null
		END AS en_cons_change
	FROM energy_owid) o ON e.entity = o.entity
GROUP BY e.entity
ORDER BY avg_yearly_change DESC;

#country with highest avg yearly change
SELECT
	e.entity,
    e.code,
    COUNT(DISTINCT(year)) AS last_n_years,
    AVG(o.en_cons_change) AS avg_yearly_change
FROM
	energy_owid e
	JOIN
	(SELECT
		entity,
        CASE WHEN LAG(entity) OVER() = entity THEN energy_cons_twh - LAG(energy_cons_twh) OVER()
		ELSE Null
		END AS en_cons_change
	FROM energy_owid) o ON e.entity = o.entity
WHERE code NOT IN ("OWID_WRL","OWID_USS","")
GROUP BY e.entity
ORDER BY avg_yearly_change DESC;

#2021 energy consumption all country for map
SELECT
	e.entity,
    e.energy_cons_twh
FROM
	energy_owid e
    JOIN
    all_country c ON e.code = c.code
WHERE 
	e.code = c.code AND
	e.year = 2021;

#2021 g20 country energy consumption
SELECT
	e.entity,
    e.energy_cons_twh
FROM
	energy_owid e
    JOIN
    (
    SELECT
    DISTINCT(code)
	FROM
    energy_g20
    ) g ON e.code = g.code
WHERE
    e.year = 2021
ORDER BY
	energy_cons_twh DESC;

#change in the last 5 years
SELECT
	e.entity,
    e.code,
    e.year,
    e.energy_cons_twh,
    CASE WHEN e.entity = LEAD(e.entity) OVER() THEN energy_cons_twh - LEAD(energy_cons_twh) OVER()
    ELSE NULL
    END AS absolute_change,
    CASE WHEN e.entity = LEAD(e.entity) OVER() THEN (energy_cons_twh - LEAD(energy_cons_twh) OVER())*100 / LEAD(energy_cons_twh) OVER()
    ELSE NULL
    END AS relative_change
FROM
	energy_owid e,
    (
    SELECT
		DISTINCT(code)
	FROM
		energy_g20 
	) y
WHERE
	e.code = y.code AND
    e.year BETWEEN 2016 AND 2021;
    
#World energy consumption change over in the years
SELECT
	*,
    CASE WHEN LAG(entity) OVER() = entity THEN energy_cons_twh - LAG(energy_cons_twh) OVER()
    ELSE NULL
    END AS absolut_change
FROM
	energy_owid
WHERE
	entity = "World";

#average change in 10 years
SELECT
	AVG(e.absolut_change) as average_change
FROM
	(
    SELECT
		*,
		CASE WHEN LAG(entity) OVER() = entity THEN energy_cons_twh - LAG(energy_cons_twh) OVER()
		ELSE NULL
		END AS absolut_change
	FROM
		energy_owid
	WHERE
		entity = "World"
	) e
WHERE
	year BETWEEN 2011 AND 2021;
    
    