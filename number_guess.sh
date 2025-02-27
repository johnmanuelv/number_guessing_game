#!/bin/bash

# Database connection variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random secret number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Ask for the username
echo "Enter your username:"
read USERNAME

# Retrieve user information from the database
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]; then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)"
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=0
  BEST_GAME="N/A"
else
  # Existing user
  IFS='|' read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  
  # Handle NULL best_game (first-time player hasn't won yet)
  if [[ -z $BEST_GAME ]]; then
    BEST_GAME="N/A"
  fi

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start the guessing game
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

while true; do
  read GUESS

  # Check if input is an integer
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if [[ $GUESS -eq $SECRET_NUMBER ]]; then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Update user stats in the database
    NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
    $PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED WHERE username='$USERNAME'"

    # Update best game if it's the first win or a better score
    if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
      $PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'"
    fi
    
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done
