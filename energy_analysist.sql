# create table for g20 country
DROP TABLE IF EXISTS energy_g20;
CREATE TABLE energy_g20
	(
		entity VARCHAR(255),
        Code VARCHAR(255),
        year INT,
        energy_consumption_twh DOUBLE(12,2)
    );

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
             "USA","OWID_WRL");

#data for g20 country
SELECT
	entity AS country,
    Code,
	year,
    FORMAT(energy_cons_twh, 2) AS energy_consumption_twh
FROM
	energy_owid
WHERE
	Code IN ("ARG","AUS","BRA","CAN","CHN","FRA",
			 "DEU","IND","IDN","ITA","JPN","MEX",
             "KOR","RUS","SAU","ZAF","TUR","GBR",
             "USA","OWID_WRL");


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
HAVING Code != ("OWID_WRL")
ORDER BY energy_cons_twh DESC
LIMIT 10;

#top 10 countries in 2021 with the most energy consumption + worldwide consumption for comparison
SELECT
	entity,
    code,
    year,
    FORMAT(energy_cons_twh, 2) as energy_consumption,
    100*energy_cons_twh / MAX(SUM(energy_cons_twh)) AS relative_consumption
FROM
	energy_owid e
WHERE
	year = 2021 AND
    Code != ""
ORDER BY energy_cons_twh DESC
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

