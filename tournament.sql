-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP DATABASE if exists tournament;
CREATE DATABASE tournament;
\c tournament;

CREATE TABLE players (
       id serial PRIMARY KEY,
       name text);

CREATE TABLE matches (
       matchid serial PRIMARY KEY,
--       round integer default 1,
       winner integer REFERENCES players(id),
       loser integer REFERENCES players(id));

CREATE VIEW wins AS 
	SELECT id, 
		(SELECT count(*) FROM matches WHERE players.id = matches.winner) AS wins 
	FROM players;

CREATE VIEW opponentsList AS
		SELECT id, loser AS opponent
		FROM players join matches
		ON id = winner
	UNION
		SELECT id, winner AS opponent
		FROM players join matches
		ON id = loser
	ORDER BY id, opponent;

CREATE VIEW opponentsWinRank AS
	SELECT opponentslist.id, sum(wins) AS opponent_wins
		FROM opponentslist join wins 
		ON opponent = wins.id 
		GROUP BY opponentslist.id 
		ORDER BY opponentslist.id;

-- with help from http://discussions.udacity.com/t/p2-normalized-table-design/19927/2
CREATE VIEW standings AS
	SELECT players.id,name,
		(SELECT count(*) FROM matches WHERE players.id = matches.winner) AS wins,
		(SELECT count(*) FROM matches WHERE players.id = matches.winner OR players.id = matches.loser) AS matches, 
	opponent_wins AS OMW
FROM players LEFT JOIN opponentsWinRank ON players.id = opponentswinrank.id
ORDER BY wins DESC, OMW DESC, matches;

-- adapted from http://stackoverflow.com/questions/19595809/skip-every-nth-result-row-in-postgresql
-- Odd rows
CREATE VIEW oddRows AS
	SELECT o.id,o.name,o.wins,o.matches,row_number() over (ORDER BY wins DESC, matches)
	FROM (SELECT id,name,wins,matches,row_number() over (ORDER BY wins DESC, matches) AS rank FROM standings) o 
	WHERE o.rank % 2 = 1; 
-- Even rows
CREATE VIEW evenRows AS
	SELECT e.id,e.name,e.wins,e.matches,row_number() over (ORDER BY wins DESC, matches)
	FROM (SELECT id,name,wins,matches,row_number() over (ORDER BY wins DESC, matches) AS rank FROM standings) e
	WHERE e.rank % 2 = 0; 

CREATE VIEW pairs AS
	SELECT oddRows.id AS id1, oddRows.name AS name1, evenRows.id AS id2, evenRows.name AS name2
	FROM oddRows join evenRows
	ON oddRows.row_number = evenRows.row_number;