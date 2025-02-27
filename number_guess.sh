#!/bin/bash

# Database connection variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random secret number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Ask for the username
echo "Enter your username:"
read USERNAME
