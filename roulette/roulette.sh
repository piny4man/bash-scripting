#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
endColour="\033[0m\e[0m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Exiting...${endColour}\n"
  tput cnorm && exit 1
}

trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Usage: ${greenColour}$0${endColour}${endColour}\n"
  echo -e "\t${purpleColour}-m]${endColour}${grayColour} Desired money to play${endColour}"
  echo -e "\t${purpleColour}-t]${endColour}${grayColour} Roulette usage technique${endColour} ${purpleColour}(${endColour}${yellowColour}martingala${endColour}${purpleColour}/${endColour}${yellowColour}inverseLabrouchere${endColour}${purpleColour})${endColour}"
  echo -e "\t${purpleColour}-h]${endColour}${grayColour} Show help panel${endColour}\n"
}

function martingala(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} We are going to play using Martingala's technique${endColour}\n"
}

while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG ;;
    t) technique=$OPTARG;;
    h) helpPanel;;
  esac
done

if [ $money ] && [ $technique ]; then
  if [ "$technique" == "martingala" ]; then
    martingala
  else
    echo -e "\n${redColour}[!] Specified technique doesn't exist${endColour}"
    helpPanel
  fi
else
  helpPanel
fi
