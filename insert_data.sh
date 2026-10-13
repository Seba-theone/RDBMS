#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  
  if [[ $year == 'year' ]]
  then
    continue
  fi
  #echo $year $round $winner $opponent $winner_goals $opponent_goals
  result=$($PSQL "insert into teams(name) values ('$winner'),('$opponent') on conflict(name) do nothing")
  
  win_id=$($PSQL "select team_id from teams where name='$winner'")
  opp_id=$($PSQL "select team_id from teams where name='$opponent'")
  #echo [$winner] win_id $win_id, [$opponent] opp_id $opp_id
  result=$($PSQL "insert into games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) values ($year,'$round',$win_id,$opp_id,$winner_goals,$opponent_goals) ")

done
# Do not change code above this line. Use the PSQL variable above to query your database.
