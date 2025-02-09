#!/bin/bash

# Set up PSQL command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# Query the database (handling atomic_number, symbol, or name)
QUERY_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, ROUND(atomic_mass, 2), melting_point_celsius, boiling_point_celsius 
FROM elements 
INNER JOIN properties USING(atomic_number) 
INNER JOIN types USING(type_id) 
WHERE atomic_number::TEXT = '$1' OR symbol ILIKE '$1' OR name ILIKE '$1'")

# Check if element was found
if [[ -z $QUERY_RESULT ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

# Read query result into variables
IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$QUERY_RESULT"

# Output final result
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."

# Test case for missing argument
if [[ $1 == "test" ]]
then
  echo "Running test case: No argument provided"
  ./elements.sh > output.txt
  if grep -q "Please provide an element as an argument." output.txt; then
    echo "Test passed"
  else
    echo "Test failed"
  fi
  rm output.txt
fi
