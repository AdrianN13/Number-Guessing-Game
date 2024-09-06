#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -q -c"
SECRET=$((1 + $RANDOM % 1000))

echo 'Enter your username: '
read USERNAME
USER_CHECK=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
LAST_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
if [ -z "$USER_CHECK" ]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $LAST_BEST_GAME guesses."

fi
echo "Guess the secret number between 1 and 1000:"
COUNTER=0
GUESS_GAME(){
  read GUESS
  COUNTER=$((COUNTER + 1))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    GUESS_GAME
  elif [ $GUESS -eq $SECRET ]
  then
   if [ -z "$LAST_BEST_GAME" ] || [ "$COUNTER" -lt "$LAST_BEST_GAME" ]
    then
      $PSQL "UPDATE users SET best_game=$COUNTER WHERE username='$USERNAME'"
    fi
    $PSQL "UPDATE users SET games_played=$((GAMES_PLAYED + 1)) WHERE username='$USERNAME'"
    echo "You guessed it in $COUNTER tries. The secret number was $SECRET. Nice job!"
    exit 0
  elif [ $GUESS -gt $SECRET ]
  then
    echo "It's lower than that, guess again:"
    GUESS_GAME
  else
    echo "It's higher than that, guess again:"
    GUESS_GAME
  fi
}

GUESS_GAME