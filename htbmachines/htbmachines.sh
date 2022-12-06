#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl+C
trap ctrl_c INT

# Global variables
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}\n"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por la dificultad de una máquina${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener enlace de la resolución de la máquina${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar panel de ayuda${endColour}\n"
}

function updateFiles(){
  tput civis

  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}"
  else
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    tempMd5Value="$(md5sum bundle_temp.js | awk '{print $1}')"
    originalMd5Value="$(md5sum bundle.js | awk '{print $1}')"
  
    if [ "$tempMd5Value" == "$originalMd5Value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizacions, tienes los ficheros al día :)${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se han detectado actualizaciones disponibles${endColour}"
      sleep 1
      rm bundle.js && mv bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Archivos actualizados correctamente ;)${endColour}"
    fi
  fi
  tput cnorm
}

function searchMachine(){
  machineName="$1"
  machineNameChecker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/:/ --> /')"

  if [ "$machineNameChecker" ]; then
    #TODO Add colors to property names
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina ${endColour}${blueColour}$machineName ${endColour}\n"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/:/ --> /'
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi
}

function searchIp(){
  ipAddress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La màquina correspondiente para la IP ${endColour}${greenColour}$ipAddress${endColour}${grayColour} es ${endColour}${blueColour}$machineName ${endColour}\n"
  else 
    echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}\n"
  fi
}

function getYoutubeLink(){
  machineName="$1"
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/youtube:/" | grep "youtube:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/:/ --> /' | awk 'NF{print $NF}')"

  if [ "$youtubeLink" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial para esta máquina está en el siguiente enlace: ${endColour}${blueColour}$youtubeLink${endColour}\n"
  else  
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi
}

function filterMachinesByDifficulty(){
  difficulty="$1"
  resultsCheck="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$difficulty" ]; then  
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Representando las maquinas que poseen un nivel de dificultad ${endColour}${blueColour}$difficulty${endColour}${grayColour}:${endColour}\n"
  cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}"
  fi
}

# Indicators
declare -i parameter_counter=0

while getopts "m:ui:y:d:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; let parameter_counter+=5;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIp $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  filterMachinesByDifficulty $difficulty
else
  helpPanel
fi
