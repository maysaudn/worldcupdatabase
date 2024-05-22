#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to add each unique team in the games.csv file into the database

# delete all rows from tables as we test
echo "$($PSQL "TRUNCATE TABLE games, teams")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNERGOALS OPPONENTGOALS;
do
  # skip first line
  if [[ $YEAR != 'year' ]]
  then
    # check if WINNER is in the teams table
    if [[ $WINNER == "$(echo "$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")")" ]]
    then
      echo $WINNER is in the teams table
    else
      if [[ $(echo "$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")") == "INSERT 0 1" ]]
      then
        echo $WINNER has been added to the the teams table;
      fi
    fi

    #check if OPPONENT is in the teams table
    if [[ $OPPONENT == "$(echo "$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")")" ]]
    then
      echo $OPPONENT is in the teams table
    else
      if [[ $(echo "$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")") == "INSERT 0 1" ]]
      then
        echo $OPPONENT has been added to the the teams table;
      fi
    fi

    #add year, round, winner_id, opponent_id, winner_goals, and opponent_goals to games table

    #get winner_id
    WINNER_ID="$(echo "$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")")"
    echo -e "\nthe winner_id for $WINNER is $WINNER_ID"

    #get opponent_id
    OPPONENT_ID="$(echo "$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")")"
    echo -e "\nthe opponent_id for $OPPONENT is $OPPONENT_ID"

    echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNERGOALS, $OPPONENTGOALS)")"

  fi

done
