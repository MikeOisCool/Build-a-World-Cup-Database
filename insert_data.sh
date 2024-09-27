#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE teams, games")"
while IFS=',' read -r year round winner opponent winner_goals opponent_goals;
  do
  echo "$winner"
  echo "$opponent"
done < <(tail -n +2 games.csv) | sort -u | while read -r team_name;
  do
    echo "$($PSQL "INSERT INTO teams (name) VALUES ('$team_name') ON CONFLICT (name) DO NOTHING")"
done

while IFS=',' read -r year round winner opponent winner_goals opponent_goals;
  do
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

    if [[ ! -z $winner_id && ! -z $opponent_id ]]; then
      echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")"
    fi
  done < <(tail -n +2 games.csv)