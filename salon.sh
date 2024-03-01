#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ HAIR SALON ~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to the hair salon! Please choose a service:"
  fi
  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  SERVICES_MENU
}

SERVICES_MENU() {
  read SERVICE_ID_SELECTED
  # make sure it's a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a valid number"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    # make sure it's a valid service
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "Please enter a valid service number"
    else
      echo -e "\nYou've selected $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')."
      echo -e "\nPlease enter your phone number:"
      read CUSTOMER_PHONE
      # see if customer exists
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        # insert new customer
        echo -e "\nYou are a new customer! Please enter your name:"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # insert appointment row
      echo -e "\nWhat time would you like to schedule an appointment?"
      read SERVICE_TIME
      echo $SERVICE_TIME
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME".
    fi
  fi
}

MAIN_MENU



