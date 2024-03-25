#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY;")

ins_team() {
  local ins_result=$($PSQL "INSERT INTO teams(name) VALUES('$1')")
    if [[ $ins_result == "INSERT 0 1" ]]
    then
      echo "$1 inserted"
    fi
}

ins_game() {
  local ins_result=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$1', '$2', '$3', '$4', '$5', '$6')")
   if [[ $ins_result == "INSERT 0 1" ]]
    then
      echo "$1,$2,$3,$4,$5,$6 inserted"
    fi
}

# Set the index to 1 to use with team_id
tkey=1

while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # sets a temp variable to return each line to comma seperated for
  # being inserted into the array.
  tempvar="$YEAR,$ROUND,$WINNER,$OPPONENT,$WINNER_GOALS,$OPPONENT_GOALS"

  # set each item in the array to the current value of $tempvar into 
  # the index at $key
  f_arr[$key]="$tempvar"

  # increments the $key value by 1 on each iteration of the loop.
  let key++
  
  if [ $YEAR != "year" ]
  then
    if [[ "${teams[@]}" != *$OPPONENT* ]]
    then
      teams[$tkey]=$OPPONENT
      ins_team "$OPPONENT"
      let tkey++
    elif [[ "${teams[@]}" != *$WINNER* ]]
    then
      teams[$tkey]=$WINNER
      ins_team "$WINNER"
      let tkey++
    fi
  fi

  # direct the contents of the games file as stdin input for the read
  # command in the while loop.
done < games.csv

for game in ${!f_arr[@]}
do
  IFS="," read -a temp_game <<< "${f_arr[$game]}"
  for t_id in ${!teams[@]}
  do
    if [[ "${teams[$t_id]}" == "${temp_game[2]}" ]]
    then
      temp_game[2]=$t_id
    fi

    if [[ "${teams[$t_id]}" == "${temp_game[3]}" ]]
    then
      temp_game[3]=$t_id
    fi
  done

  if [ ${temp_game[0]} != "year" ]
  then
    ins_game ${temp_game[0]} "${temp_game[1]}" ${temp_game[2]} ${temp_game[3]} ${temp_game[4]} ${temp_game[5]}
  fi
done
