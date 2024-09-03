#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

echo -e "Enter your username:"
read USERNAME

USERNAME_ID=$($PSQL "SELECT id FROM users WHERE username = '$USERNAME'")

if [[ -z $USERNAME_ID ]]
then
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USERNAME_ID=$($PSQL "SELECT id FROM users WHERE username = '$USERNAME'")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USERNAME_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USERNAME_ID")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

SECRET_NUMBER=$((1 + RANDOM % 1000))
GUESS_COUNTER=0

NEW_GUESS() {
  GUESS_COUNTER=$((GUESS_COUNTER + 1))

  if [[ $1 ]]
  then
    echo -e "$1\n"
    read USER_NUMBER
  fi

  if [[ ! $USER_NUMBER =~ ^[0-9]+$ ]]
  then
  NEW_GUESS "That is not an integer, guess again:"

  elif [[ $USER_NUMBER -eq $SECRET_NUMBER ]]
  then
    echo -e "\nYou guessed it in $GUESS_COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USERNAME_ID, $GUESS_COUNTER)")

  elif [[ $USER_NUMBER < $SECRET_NUMBER ]]
  then
    NEW_GUESS "It's higher than that, guess again:"
  else
    NEW_GUESS "It's lower than that, guess again:"
  fi

}

NEW_GUESS "Guess the secret number between 1 and 1000:"