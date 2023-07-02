#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ HOTEL ~~~~~\n"


MAIN_MENU(){

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Servicios del Hotel: \n" 
  MOSTRAR_SERVICIOS
  ESCOGER_SERVICIO

}

ESCOGER_SERVICIO(){
  echo -e "\nQue servicio desea escoger?\n"
  read SERVICE_ID_SELECTED
  ELECCION_ES_NUMERO
  ELECCION_ESTA_EN_SERVICIO
  INGRESAR_TELEFONO
  ENCONTRAR_USUARIO
  APUNTAR_SERVICIO
  MOSTRAR_RESULTADO
  SEGUIR_EN_PROGRAMA

}

SEGUIR_EN_PROGRAMA(){
  echo "Seguir agregando servicios?" 
  echo -e "\n1. Si\n2. Salir"
  read MAIN_MENU_SELECTION
  case $MAIN_MENU_SELECTION in
    1) MAIN_MENU ;;
    2) EXIT ;;
  esac
}

MOSTRAR_RESULTADO(){
  if [[ $RESULTADO_APUNTADO=="INSERT 0 1" ]]
  then
    NOMBRE_SERVICIO=$($PSQL "SELECT name FROM services WHERE $SERVICE_ID_SELECTED=service_id")
    echo -e "I have put you down for a $NOMBRE_SERVICIO at $SERVICE_TIME, $CUSTOMER_NAME. \n"
  fi
}

APUNTAR_SERVICIO(){
  echo -e "A que hora?\n"
  read SERVICE_TIME
  RESULTADO_APUNTADO=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($ID_USUARIO,$SERVICE_ID,'$SERVICE_TIME')")
}

ENCONTRAR_USUARIO(){
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE '$CUSTOMER_PHONE'=phone")
  if [[ -z $CUSTOMER_NAME ]]
  then
    AGREGAR_USUARIO
  fi
  ID_USUARIO=$($PSQL "SELECT customer_id FROM customers WHERE '$CUSTOMER_PHONE'=phone")
}

AGREGAR_USUARIO(){
  echo -e "Cuál es su nombre?\n"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')"
}

INGRESAR_TELEFONO(){
  echo -e "\nIngrese número de teléfono:\n"
  read CUSTOMER_PHONE
}

ELECCION_ESTA_EN_SERVICIO(){
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE $SERVICE_ID_SELECTED=service_id")
  if [[ -z $SERVICE_ID ]]
  then
    MAIN_MENU "No se encuentra el servicio, pruebe con otro"
  fi
}

ELECCION_ES_NUMERO(){
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Opcion no válida"
  fi
}

EXIT(){
  exit
}

MOSTRAR_SERVICIOS(){

  LISTA_DE_SERVICIOS=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  if [[ -z $LISTA_DE_SERVICIOS ]]
  then
    EXIT "No hay servicios que ofrecer por el momento"
  fi

  echo "$LISTA_DE_SERVICIOS" | while read SERVICE_ID BARRA NOMBRE_SERVICIO
  do
    echo "$SERVICE_ID) $NOMBRE_SERVICIO"
  done
}

MAIN_MENU
