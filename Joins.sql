-- European soccer database
-- 25,000 matches, 300 teams, 10,000 players in europe between 2018 to 2016
-- tables- country, league, team and match
-- league - group of different teams
--Exploratory data analysis
--Data Manipulation
--1)Explore columns
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'league';
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'country';
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'team';
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'match';

-- we can see league can be connected with country with country id
select c.name, l.name
from country as c
    JOIN league as l
    on l.country_id = c.id;

--CASE staments
--no.of home team wins, away team wins in the season 2013/2014
--win home_goal>away_goal
select count(season)
from match
where home_goal>away_goal and season = '2013/2014'
group by season;

select count(season)
from match
where home_goal<away_goal and season = '2013/2014'
group by season;

--combine using case statements - home win/away win/tie
WITH
    cte_match
    AS
    (
        SELECT *,
            CASE 
            WHEN home_goal > away_goal AND season = '2013/2014' THEN 'home_win'
            WHEN home_goal < away_goal AND season = '2013/2014' THEN 'away_win'
            WHEN home_goal = away_goal AND season = '2013/2014' THEN 'tie'
        END AS win
        FROM match
    )
SELECT *
FROM cte_match
;

-- we can see from above query you are getting results that are not in season as null
-- we don't want them

SELECT *,
    CASE 
            WHEN home_goal > away_goal  THEN 'home_win'
            WHEN home_goal < away_goal  THEN 'away_win'
            WHEN home_goal = away_goal  THEN 'tie'
        END AS win
FROM match
where season ='2013/2014';

--Chelsea home win
CREATE or ALTER VIEW home_chelsea
AS
    SELECT *
    FROM match
    WHERE hometeam_id = (SELECT team_api_id
    FROM team
    WHERE team_long_name = 'Chelsea');

select *,
    CASE WHEN home_goal>away_goal THEN 'home_win'
         WHEN home_goal <away_goal THEN 'away_win'
    ELSE 'tie' END as 'chelsea_win'
from home_chelsea;

--chelsea win or lose id = 8455
select *,
    CASE WHEN hometeam_id = 8455 and home_goal>away_goal THEN 'Chelsea home_win'
         WHEN awayteam_id = 8455 and home_goal <away_goal THEN 'Chelsea away_win'
    END as 'outcome'
from match
where hometeam_id = 8455 or awayteam_id=8455;
-- you get NULL when chelsea lose in a game to remove that add complete case statement
-- in filter to get only that conditions

select *,
    CASE WHEN hometeam_id = 8455 and home_goal>away_goal THEN 'Chelsea home_win'
         WHEN awayteam_id = 8455 and home_goal <away_goal THEN 'Chelsea away_win'
    END as 'outcome'
from match
where     CASE WHEN hometeam_id = 8455 and home_goal>away_goal THEN 'Chelsea home_win'
         WHEN awayteam_id = 8455 and home_goal <away_goal THEN 'Chelsea away_win'
    END IS NOT NULL;

-- CASE WITH AGGREGATE FUNCTIONS

--categorising and filtering data

--how many home and away goals chelsea won in each season
-- home wins
SELECT
    season, count(CASE WHEN home_goal>away_goal and hometeam_id= 8455 then id end) as home_wins
from MATCH
group by season;

SELECT
    season, sum(CASE WHEN home_goal>away_goal and hometeam_id= 8455 then 1 end) as home_wins
from MATCH
group by season;

SELECT
    season, count(CASE WHEN home_goal>away_goal and hometeam_id= 8650 then id end) as home_game_wins, count(CASE WHEN home_goal<away_goal and hometeam_id= 8650 then id end) as away_game_wins
from MATCH
group by season;

SELECT
    season, sum(CASE WHEN home_goal>away_goal and hometeam_id= 8650 then home_goal end) as home_goals_won, sum(CASE WHEN home_goal<away_goal and awayteam_id= 8650 then away_goal end) as away_goals_won
from MATCH
group by season;

SELECT
    season, avg(CASE WHEN hometeam_id= 8650 then home_goal*1.0 end) as home_goals_scored, avg(CASE WHEN awayteam_id= 8650 then away_goal*1.0 end) as away_goals_scored
from MATCH
group by season;

SELECT
    season, round(avg(CASE WHEN hometeam_id= 8650 then home_goal*1.0 end),2)as home_goals_scored, round(avg(CASE WHEN awayteam_id= 8650 then away_goal*1.0 end),2) as away_goals_scored
from MATCH
group by season;

SELECT
    season,
    CAST(ROUND(AVG(CASE WHEN hometeam_id = 8650 THEN home_goal * 1.0 END), 2) AS DECIMAL(10, 2)) AS home_goals_scored,
    CAST(ROUND(AVG(CASE WHEN awayteam_id = 8650 THEN away_goal * 1.0 END), 2) AS DECIMAL(10, 2)) AS away_goals_scored
FROM
    match
GROUP BY
    season;


SELECT
    season,
    CAST(AVG(CASE WHEN hometeam_id = 8650 THEN home_goal * 1.0 END) AS DECIMAL(10, 2)) AS home_goals_scored,
    CAST(AVG(CASE WHEN awayteam_id = 8650 THEN away_goal * 1.0 END) AS DECIMAL(10, 2)) AS away_goals_scored
FROM
    match
GROUP BY
    season;
-- percentages
-- what % of games Chelsea won in the season they played
SELECT season,
    CAST(avg(CASE WHEN home_goal>away_goal and hometeam_id= 8650 then 1.0
        WHEN home_goal<away_goal and hometeam_id= 8650 then 0.0
        END) AS DECIMAL(10,2)) as pct_home_wins,
    CAST(avg(CASE WHEN home_goal<away_goal and awayteam_id= 8650 then 1.0
        WHEN home_goal>away_goal and awayteam_id= 8650 then 0.0
        END) as DECIMAL(10,2))as pct_away_wins
from MATCH
group by season;

--subqueries - before seleceting data we need to do some inter-mediary transformation it needs subquerying
--It can be placed in any part of the query
--select, where, group by, from
--Extract and tranform data, 
--1)comparision: compare subset to a whole - sales performance of my weekly
-- performance with others 
--2)better struture your data/reshaping data
--3)Combining data that cannot be joined
--Simple subquery evaluated once
--home goaled better than avg home_goal
--WHERE
select home_goal
from MATCH
WHERE home_goal > (SELECT AVG(home_goal)
from match);

--Which matches in the 2012/2013 season scored home goals higher than overall average?

select *
from match
where season = '2012/2013' and home_goal > (select avg(home_goal)
    from match)

--subqueries filtering
--which teams are part of poland Ekstralasa league

select country_id
from league
where name ='Poland Ekstraklasa'

select *
from
    team
where 
team_api_id in (select hometeam_id
from match
where country_id= (select country_id
from league
where name ='Poland Ekstraklasa'))
---subqueries in where returns a single column
--subqueries in from satement


select cast(avg(home_goal) as decimal(10,2))
from match;
SELECT SUM(COALESCE(home_goal, 0)) * 1.0 / COUNT(id) * 1.0
FROM match;
SELECT
    SUM(home_goal) * 1.0 / COUNT(id) AS calculated_average,
    AVG(home_goal) AS function_average
FROM match;


select avg(cast(home_goal as decimal(10,2)))
from match;

--Transorm data from long to wide
--prefiltering data
--aggregates of aggregate information
--Top 3 teams who has the highest average of home goals scored?
--calculate avg of each team in the league
-- top 3 descending

select t.team_long_name , m.home_goal as home_avg
from match as m
    LEFT JOIN team AS t
    ON m.hometeam_id = t.team_api_id
where season = '2011/2012'
GROUP BY team;


select hometeam_id, avg(cast(home_goal as decimal(10,2)))
from match
where season = '2011/2012'
group by hometeam_id;
-- home team and their avg
SELECT t.team_long_name team_name, AVG(cast(m.home_goal as decimal(10,2))) AS home_avg
FROM match AS m
    LEFT JOIN team as t
    ON m.hometeam_id = t.team_api_id
WHERE season = '2011/2012'
GROUP BY team_long_name

--home team and their avg top 3
SELECT TOP (3)
    t.team_long_name team_name, AVG(cast(m.home_goal as decimal(10,2))) AS home_avg
FROM match AS m
    LEFT JOIN team as t
    ON m.hometeam_id = t.team_api_id
WHERE season = '2011/2012'
GROUP BY team_long_name
order by home_avg desc;
--home team and their avg top 3 using subquery in from
select team_name, home_avg
from (SELECT t.team_long_name team_name, AVG(cast(m.home_goal as decimal(10,2))) AS home_avg
    FROM match AS m
        LEFT JOIN team as t
        ON m.hometeam_id = t.team_api_id
    WHERE season = '2011/2012'
    GROUP BY team_long_name) as subquery
order by home_avg DESC
OFFSET 0 ROWS 
fetch NEXT 3 ROWS ONLY;
-- can't use limit in sqlserver
-- you can use more than one subquery in from clause

--subqueries in select
--summary values into a detailed dataset
-- include aggregate values to compare individual values like window function partion
--performing mathematical calculations on dataset
--dev from avg , how much an individual value differ from avg

--calculate total matches across all seasons vs total matches played each season
SELECT COUNT(id)
from match;
select season, count(id) as match, (select count(id)
    from match) as total_matches
from MATCH
GROUP BY season;


--select in subquery should have only one value or else you get error
select *,
    (home_goal+away_goal) as goals,
    ((home_goal+away_goal)- (select avg(cast(home_goal+away_goal as decimal(10,2)))
    from match
    where season = '2011/2012')) as dif
from MATCH
where season = '2011/2012';

--subqueries everywhere -- more time to query
--It can become large
/**/
--correlated subquey use outer query to generate a result\

SELECT
    s.stage,
    ROUND(s.avg_goals,2) AS avg_goal,
    (SELECT AVG(home_goal + away_goal)
    FROM match
    WHERE season = '2012/2013') AS overall_avg
FROM
    (SELECT
        stage,
        AVG(home_goal + away_goal) AS avg_goals
    FROM match
    WHERE season = '2012/2013'
    GROUP BY stage) AS s
WHERE s.avg_goals > (SELECT AVG(home_goal + away_goal)
FROM match
WHERE season = '2012/2013');



--1)stage, avg_goals
(SELECT stage, avg(home_goal+away_goal) as avg_goals
FROM match
WHERE season ='2012/2013'
GROUP BY stage)
as averege_goals_per_each_stage;

--2) overall avg goals
(SELECT avg(home_goal+away_goal) as avg_goals
FROM match
WHERE season ='2012/2013')
as overall_avg_goals;

--3)combine and filter results - (cross join- a(3rows) with b(2 rows) you get 3*2= 6 rows 
-- all combinations no nulls cartesian product- does need any common column




select averege_goals_per_each_stage.stage,averege_goals_per_each_stage.avg_goals, overall_avg_goals.avg_goals
FROM
    (SELECT stage, avg(cast(home_goal+away_goal as decimal(10,2))) as avg_goals
    FROM match
    WHERE season ='2012/2013'
    GROUP BY stage) as averege_goals_per_each_stage
CROSS JOIN
    (SELECT avg(cast(home_goal+away_goal as decimal(10,2))) as avg_goals
    FROM match
    WHERE season ='2012/2013') as overall_avg_goals;

-- filter above
select averege_goals_per_each_stage.stage,averege_goals_per_each_stage.avg_goals , overall_avg_goals.avg_goals
FROM
    (SELECT stage, avg(cast(home_goal+away_goal as decimal(10,2))) as avg_goals
    FROM match
    WHERE season ='2012/2013'
    GROUP BY stage) as averege_goals_per_each_stage
CROSS JOIN
    (SELECT avg(cast(home_goal+away_goal as decimal(10,2))) as avg_goals
    FROM match
    WHERE season ='2012/2013') as overall_avg_goals
where averege_goals_per_each_stage.avg_goals>overall_avg_goals.avg_goals;

/*simple subqueries - extracting, structuring, filtering info 
independent of main query, evaluated onlce

corrrelated-subquery - cannot be executed on its own dependent on main query
once for each row executed
*/
