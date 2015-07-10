-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP DATABASE IF EXISTS tournament;
CREATE DATABASE tournament;
\c tournament;

CREATE TABLE players (
       id serial PRIMARY KEY,
       name text);

CREATE TABLE matches (
       matchid serial PRIMARY KEY,
       winner integer REFERENCES players(id),
       loser integer REFERENCES players(id));

CREATE VIEW wins AS 
	SELECT id, 
		(SELECT count(*) FROM matches WHERE players.id = matches.winner) AS wins 
	FROM players;

CREATE VIEW opponents_list AS
		SELECT id, loser AS opponent
		FROM players join matches
		ON id = winner
	UNION
		SELECT id, winner AS opponent
		FROM players join matches
		ON id = loser
	ORDER BY id, opponent;

CREATE VIEW opponents_win_rank AS
	SELECT opponents_list.id, sum(wins) AS opponent_wins
		FROM opponents_list join wins 
		ON opponent = wins.id 
		GROUP BY opponents_list.id 
		ORDER BY opponents_list.id;

-- with help from http://discussions.udacity.com/t/p2-normalized-table-design/19927/2
CREATE VIEW standings AS
	SELECT players.id,name,
		(SELECT count(*) FROM matches WHERE players.id = matches.winner) AS wins,
		(SELECT count(*) FROM matches WHERE players.id = matches.winner OR players.id = matches.loser) AS matches, 
	opponent_wins AS OMW
FROM players LEFT JOIN opponents_win_rank ON players.id = opponents_win_rank.id
ORDER BY wins DESC, OMW DESC, matches;

-- adapted from http://stackoverflow.com/questions/19595809/skip-every-nth-result-row-in-postgresql
-- Odd rows
CREATE VIEW odd_rows AS
	SELECT o.id,o.name,o.wins,o.matches,row_number() over (ORDER BY wins DESC, matches)
	FROM (SELECT id,name,wins,matches,row_number() over (ORDER BY wins DESC, matches) AS rank FROM standings) o 
	WHERE o.rank % 2 = 1; 
-- Even rows
CREATE VIEW even_rows AS
	SELECT e.id,e.name,e.wins,e.matches,row_number() over (ORDER BY wins DESC, matches)
	FROM (SELECT id,name,wins,matches,row_number() over (ORDER BY wins DESC, matches) AS rank FROM standings) e
	WHERE e.rank % 2 = 0; 

CREATE VIEW pairs AS
	SELECT odd_rows.id AS id1, odd_rows.name AS name1, even_rows.id AS id2, even_rows.name AS name2
	FROM odd_rows join even_rows
	ON odd_rows.row_number = even_rows.row_number;