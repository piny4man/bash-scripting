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
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Current money:${endColour} ${greenColour}$money$ ${endColour}"
  echo -ne "${yellowColour}[+]${endColour}${grayColour} How much money do you want to bet?${endColour}${turquoiseColour} -> ${endColour}" && read initialBet
  echo -ne "${yellowColour}[+]${endColour}${grayColour} What type of bet do you want to do every time ${purpleColour}(${endColour}${yellowColour}odd${endColour}${purpleColour}/${endColour}${yellowColour}even${endColour}${purpleColour})${endColour}?${endColour} -> " && read oddEven

  # echo -e "\n${yellowColour}[+]${endColour}${grayColour} We are going to play with an initial amount of ${greenColour}$initialBet$ ${endColour}on ${purpleColour}$oddEven ${endCoulour} ${endColour}"
  
  bet=$initialBet
  playCounter=1
  wrongPlays=""
  maxBenefit=0

  tput civis
  while true; do
    money=$(($money-$bet))
    # echo -e "\n${yellowColour}[+]${endColour}${grayColour} You bet ${greenColour}$bet${endColour}, your current money is ${greenColour}$money$ ${endColour}${endColour}"
    randomNumber="$(($RANDOM % 37))"
    # echo -e "\n${yellowColour}[+]${endColour}${grayColour} Current roulette number is ${blueColour}$randomNumber${endColour}${endColour}"
    
    if [ "$money" -gt 0 ]; then
      if [ "$oddEven" == "even" ]; then
        if [ "$(($randomNumber % 2))" -eq 0 ]; then
          if [ "$randomNumber" -eq 0 ]; then
            # echo -e "${redColour}[@]${endColour}${grayColour} The number is ${redColour}0${endColour}, you ${endColour}${redColour}lose ${endColour}${grayColour}:(${endColour}"
            bet=$(($bet*2)) 
            wrongPlays+="0 "
          else
            # echo -e "${turquoiseColour}[*]${endColour}${grayColour} The number is even, you ${endColour}${turquoiseColour}win${endColour}${grayColour}!${endColour}"
            reward=$(($bet*2))
            # echo -e "${purpleColour}[!]${endColour}${grayColour} You win a total of ${endColour}${greenColour}$reward$ ${endColour}"
            money=$(($money+$reward))
            # echo -e "${purpleColour}[!]${endColour}${grayColour} You have ${endColour}${greenColour}$money$ ${endColour}"
            bet=$initialBet
            wrongPlays=""
            if [ "$money" -gt "$maxBenefit" ]; then
              maxBenefit=$money
            fi
          fi
        else
          # echo -e "${redColour}[@]${endColour}${grayColour} The number is odd, you ${endColour}${redColour}lose ${endColour}${grayColour}:(${endColour}"
          bet=$(($bet*2)) 
          wrongPlays+="$randomNumber "
        fi
      else
        if [ "$(($randomNumber % 2))" -eq 1 ]; then
          # echo -e "${turquoiseColour}[*]${endColour}${grayColour} The number is even, you ${endColour}${turquoiseColour}win${endColour}${grayColour}!${endColour}"
          reward=$(($bet*2))
          # echo -e "${purpleColour}[!]${endColour}${grayColour} You win a total of ${endColour}${greenColour}$reward$ ${endColour}"
          money=$(($money+$reward))
          # echo -e "${purpleColour}[!]${endColour}${grayColour} You have ${endColour}${greenColour}$money$ ${endColour}"
          bet=$initialBet
          wrongPlays=""
          if [ "$money" -gt "$maxBenefit" ]; then
            maxBenefit=$money
          fi
        else
          bet=$(($bet*2)) 
          wrongPlays+="$randomNumber "
        fi
      fi
    else
      echo -e "\n${redColour}[!] You lose all your money!${endColour}"
      echo -e "${yellowColour}[!]${endColour}${grayColour} Total plays ${endColour}${turquoiseColour}$playCounter${endColour}"
      echo -e "${yellowColour}[!]${endColour}${grayColour} Wrong consecutive plays:${endColour}"
      echo -e "${turquoiseColour}[ $wrongPlays]${endColour}"
      echo -e "${yellowColour}[!]${endColour}${grayColour} Maximum benefit earned ${greenColour}$maxBenefit$ ${endColour} ${endColour}"
      tput cnorm; exit 0
    fi

    let playCounter+=1
  done

  tput cnorm
}

function inverseLabrouchere(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Current money:${endColour} ${greenColour}$money$ ${endColour}"
  echo -ne "${yellowColour}[+]${endColour}${grayColour} What type of bet do you want to do every time ${purpleColour}(${endColour}${yellowColour}odd${endColour}${purpleColour}/${endColour}${yellowColour}even${endColour}${purpleColour})${endColour}?${endColour} -> " && read oddEven
  
  declare -a betSequence=(1 2 3 4)
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Starting with ${endColour}${blueColour}[${betSequence[@]}]${endColour}${grayColour} sequence${endColour}"
  
  bet=$((${betSequence[0]} + ${betSequence[-1]}))
  unset betSequence[0]
  unset betSequence[-1]
  betSequence=(${betSequence[@]})

  echo -e "${yellowColour}[+]${endColour}${grayColour} Bet${endColour}${greenColour} $bet$ ${endColour}${grayColour}and our secuence decrease to ${endColour}${blueColour}[${betSequence[@]}]${endColour}"

  tput civis
  while true; do
    randomNumber="$(($RANDOM % 37))"
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Current roulette number is ${blueColour}$randomNumber${endColour}${endColour}"

    if [ "$oddEven" == "even" ]; then
       if [ "$(($randomNumber % 2))" -eq 0 ]; then
        if [ "$randomNumber" -eq 0 ]; then
          # echo -e "${redColour}[@]${endColour}${grayColour} The number is ${redColour}0${endColour}, you ${endColour}${redColour}lose ${endColour}${grayColour}:(${endColour}"
          bet=$(($bet*2)) 
          wrongPlays+="0 "
        else
          # echo -e "${turquoiseColour}[*]${endColour}${grayColour} The number is even, you ${endColour}${turquoiseColour}win${endColour}${grayColour}!${endColour}"
          reward=$(($bet*2))
          # echo -e "${purpleColour}[!]${endColour}${grayColour} You win a total of ${endColour}${greenColour}$reward$ ${endColour}"
          money=$(($money+$reward))
          # echo -e "${purpleColour}[!]${endColour}${grayColour} You have ${endColour}${greenColour}$money$ ${endColour}"
          bet=$initialBet
          wrongPlays=""
          if [ "$money" -gt "$maxBenefit" ]; then
            maxBenefit=$money
          fi
        fi
      else
        # echo -e "${redColour}[@]${endColour}${grayColour} The number is odd, you ${endColour}${redColour}lose ${endColour}${grayColour}:(${endColour}"
        bet=$(($bet*2)) 
        wrongPlays+="$randomNumber "
      fi
    fi

    sleep 5
  done

  tput cnorm
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
  elif [ "$technique" == "inverseLabrouchere" ]; then
    inverseLabrouchere
  else
    echo -e "\n${redColour}[!] Specified technique doesn't exist${endColour}"
    helpPanel
  fi
else
  helpPanel
fi
