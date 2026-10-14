#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get services
  SERV=$($PSQL "select service_id, name from services")
  #echo -e "$SERV"
  echo "$SERV" | while IFS='|' read SID SNAME
  do
    echo "$SID) $SNAME"
  done 

  read SERVICE_ID_SELECTED
  #service must be number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  #see if service available
  SNAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SNAME ]]; then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi  

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  #see if client exists in db
  CNAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE' ")
  #echo "CNAME=['$CNAME']"

  if [[ -z $CNAME ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    echo -e "\nWhat time would you like your '$SNAME', '$CUSTOMER_NAME'?"
    read SERVICE_TIME

    #add to db
    resp=$($PSQL "insert into customers(name,phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      #get customer id
    CUST_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")  
    resp=$($PSQL "insert into appointments(time,service_id,customer_id) values ('$SERVICE_TIME',$SERVICE_ID_SELECTED,$CUST_ID)")
    echo -e "\nI have put you down for a $SNAME at $SERVICE_TIME, $CUSTOMER_NAMEq."
    
  else
    #client exists in db
    echo -e "\nWhat time would you like your '$SNAME', '$CNAME'?"
    read SERVICE_TIME
      #get customer id
    CUST_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")  
    resp=$($PSQL "insert into appointments(time,service_id,customer_id) values ('$SERVICE_TIME',$SERVICE_ID_SELECTED,$CUST_ID)")
    echo -e "\nI have put you down for a $SNAME at $SERVICE_TIME, $CNAME."
  fi
}

MAIN_MENU