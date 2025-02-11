#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
#psql -X --username=freecodecamp --dbname=bikes --tuples-only -c

MAIN_MENU() {
  # CHECK FOR ARG
  if [[ $1 ]]
  then
    echo "$1"
  fi

# PRINT OUT SERVICES
SERVICES=$($PSQL "select name, service_id from services")
echo "$SERVICES" | while IFS="|" read NAME SERVICE_ID
do
  SERVICE_ID=$(sed -E 's/ //g' <<< $SERVICE_ID)
  NAME=$(sed -E 's/^ *//' <<< $NAME)
  if [[ $SERVICE_ID =~ [0-9]+ ]]
  then
    echo "$SERVICE_ID) $NAME"
  fi
done

# GET DESIRED SERVICE
read SERVICE_ID_SELECTED
SERVICE_ID_CHECK=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
if [[ -z $SERVICE_ID_CHECK ]]
then
  MAIN_MENU
fi

# GET CUSTOMER INFO
echo -e "\nYour phone number:"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
  # get name 
  echo -e "\nYour name:"
  read CUSTOMER_NAME
  # insert both into customers
  CREATE_CUSTOMER=$($PSQL "insert into customers(phone, name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
fi
CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

# BOOK A TIME
echo -e "\nDesired Time:"
read SERVICE_TIME
BOOK_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $SERVICE_ID_CHECK at $SERVICE_TIME, $CUSTOMER_NAME."
exit 0
}

MAIN_MENU
