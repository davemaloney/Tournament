#!/usr/bin/env python
# 
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2
import bleach

def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")

def deleteMatches():
    db = connect()
    c = db.cursor()
 
    """Remove all the match records from the database."""
    c.execute("delete from matches")
    db.commit()

    db.close()    

def deletePlayers():
    db = connect()
    c = db.cursor()
 
    """Remove all the player records from the database."""
    c.execute("delete from players")
    db.commit()

    db.close()  

def countPlayers():
    db = connect()
    c = db.cursor()
 
    """Returns the number of players currently registered."""
    c.execute("select count(*) from players")
    playerCount = c.fetchone()[0]
    return playerCount
 
    db.close()

def registerPlayer(name):
    db = connect()
    c = db.cursor()
 
    """Adds a player to the tournament database.
    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)
    Args:
        name: the player's full name (need not be unique).
    """
    name = bleach.clean(name)
    c.execute("insert into players (name) values (%s)",(name,))
    db.commit()

    db.close()

def playerStandings():
    db = connect()
    c = db.cursor()
 
    """Returns a list of the players and their win records, sorted by wins.
    The first entry in the list should be the player in first place, or a player
    tied for first place if there is currently a tie.
    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    c.execute("select id, name, wins, matches from standings")
    playerStandings = c.fetchall()
    return playerStandings
 
    db.close()

def reportMatch(winner, loser):
    db = connect()
    c = db.cursor()
 
    """Records the outcome of a single match between two players.
    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
    """
    winner = bleach.clean(winner)
    loser = bleach.clean(loser)
    c.execute("insert into matches (winner,loser) values (%s,%s)",(winner, loser))
    db.commit()

    db.close()
 
def swissPairings():
    db = connect()
    c = db.cursor()

    """Returns a list of pairs of players for the next round of a match.
    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.
    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    c.execute("select * from pairs")
    pairings = c.fetchall()
    return pairings

    db.close()