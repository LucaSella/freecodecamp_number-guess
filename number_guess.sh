#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(($RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")

if [[ -z $USER_ID ]]
then
  INPUT_NAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
  echo Welcome, $USERNAME! It looks like this is your first time here.
else
  TOTAL_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID;")

  echo Welcome back, $USERNAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GAME guesses.
fi

N_GUESSES=0
CORRECT=false

echo Guess the secret number between 1 and 1000:

until [[ $CORRECT == true ]]
do
  read USER_GUESS
  ((N_GUESSES++))

  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  elif [[ $USER_GUESS -lt $NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
  elif [[ $USER_GUESS -gt $NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
  else
    echo -e "\nYou guessed it in $N_GUESSES tries. The secret number was $NUMBER. Nice job!"
    CORRECT=true
  fi
done

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $N_GUESSES);")
