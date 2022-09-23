# Welcome to My Sqlite
***

## Task


This is a functional recreation of a simple SQL Client that can be used either with the class contained in my_sqlite_request.rb or run in the terminal with cli.rb

The main problem here is the translation of SQL commands to something relevant in the context of a CSV file.
Since the structure of an SQL table and a CSV file are essentialy the same, the logical translation is not difficult
However, it is the use of the CSV gem in ruby that makes this project more challenging. The documentation of the gem is not great, and requires a lot of trial and error to get it to perform what you want



With the terminal based functionality, it was a matter of parsing user input in a way that could be piped to the MySqliteRequest class.
The terminal required a lot of string manipulation, and make sure the methods of the class ran in the correct order to generate the output
## Description


Our code begins with the declaration of instance variables that describe parts of the input. Functions of a certain SQL type are paired "setters" and "performers", where the setters initialize the instance variables for the final run command
and the "performers" make the actual manipulation of the data. When a setter is run, it can trigger a conditional statement in the final run function that allows its paired "performer" to manipulate the data before output.
An important aspect of this project that we strived to acheive were agnostic functions. Given the complexity of the inputs, it would make for bad code if the codebase had to be re-configured every time something was added. 
It's much better to code something that takes the same thing every time, and put the responsibility of uniformality on the inputs themselves. 

It is when the data is done being manipulated does run_select, for example, output it. the run_join and run_where manipulate the virtual table @table before run_select gets to it. run_select is agnostic if run_join and run_where
have run, only that it is a CSV table in a certain format.

Our case function, described in run(), determines which part of the trie we execute.

## Installation
This is a vanilla ruby project with the dependencies included in-file

## Contributors
Connor Cable - https://github.com/ctcmc

## Usage

For unit tests: ruby unit_tests.rb

For class usage:
require relative 'my_sqlite_request.rb'
my_sqlite_request.rb ---> Contains the MySqliteRequest class

Can be run with the following example commands:

request = MySqliteRequest.new
request = request.from('nba_player_data.csv')
request = request.select('name')
request = request.where('birth_state', 'Indiana')
request.run

These commands can be chained :

request = MySqliteRequest.new
request.from('nba_player_data.csv).select('name').where('birth_state', 'Indiana')

For terminal usage:
ruby cli.rb

Can be run with the following example commands:

SELECT name, weight FROM nba_player_data.csv JOIN nba_players ON name = player ORDER by name ASC
SELECT * FROM nba_player_data.csv
UPDATE nba_player_data.csv SET college = "University of California, Santa Cruz", name = "Connor" WHERE name = 'Tom Abernethy'
DELETE FROM nba_player_data.csv WHERE name = 'Connor';




### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar Silicon Valley</a></i></span>
<span><img alt='Qwasar Silicon Valley Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px'></span>
