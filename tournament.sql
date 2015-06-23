-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

create table players (
       id serial PRIMARY KEY,
       name text);

create table matches (
       matchid serial PRIMARY KEY,
--       round integer default 1,
       winner integer references players(id),
       loser integer references players(id));

create view wins as 
	select id, 
		(select count(*) from matches where players.id = matches.winner) as wins 
	from players;

create view opponentsList as
		select id, loser as opponent
		from players join matches
		on id = winner
	union
		select id, winner as opponent
		from players join matches
		on id = loser
	order by id, opponent;

create view opponentsWinRank as
	select opponentslist.id, sum(wins) as opponent_wins
		from opponentslist join wins 
		on opponent = wins.id 
		group by opponentslist.id 
		order by opponentslist.id;

-- with help from http://discussions.udacity.com/t/p2-normalized-table-design/19927/2
create view standings as
	select players.id,name,
		(select count(*) from matches where players.id = matches.winner) as wins,
		(select count(*) from matches where players.id = matches.winner or players.id = matches.loser) as matches, 
	opponent_wins as OMW
from players left join opponentsWinRank on players.id = opponentswinrank.id
order by wins desc, OMW desc, matches;

-- adapted from http://stackoverflow.com/questions/19595809/skip-every-nth-result-row-in-postgresql
-- Odd rows
create view oddRows as
	select o.id,o.name,o.wins,o.matches,row_number() over (order by wins desc, matches)
	from (select id,name,wins,matches,row_number() over (order by wins desc, matches) as rank from standings) o 
	where o.rank % 2 = 1; 
-- Even rows
create view evenRows as
	select e.id,e.name,e.wins,e.matches,row_number() over (order by wins desc, matches)
	from (select id,name,wins,matches,row_number() over (order by wins desc, matches) as rank from standings) e
	where e.rank % 2 = 0; 

create view pairs as
	select oddRows.id as id1, oddRows.name as name1, evenRows.id as id2, evenRows.name as name2
	from oddRows join evenRows
	on oddRows.row_number = evenRows.row_number;