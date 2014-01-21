#!/bin/sh

# Get working directory
OLDIFS=$IFS
IFS=$'\n'
_mydir="$(pwd)"
IFS=$OLDIFS

function choose_bootstrap_project(){

  choice=''

  # Ask the user which bootstrap project must be initialized
  PS3='Please enter your bootstrap project: '
  select opt in "${PROJECTS[@]}"
  do
    # Ask the user if he/she is sure with the choice
    anwser=$(ask_confirmation "Are you sure you want to bootstrap project ${opt}")
    if [ $anwser == "Y" ]
      then # If confirmed than set choice
        echo ${opt}
      else # Ask the user if he/she want to bootstrap another project
        anwser=$(ask_confirmation "Do you want to bootstrap another project")
        if [ $anwser == "Y" ]
          then
            choose_bootstrap_project
          else
           echo "Nothing to do here..."
           exit
        fi
    fi
    break;
  done
}

function read_bootstrap_directory(){

  # http://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
  OLDIFS=$IFS
  IFS=$'\n'

  # Read project directories into array
  for file in ${1}/*; do
    if [ -d "${file}" ];then
      PROJECTS+=($(basename "${file}"))
    fi
  done

  IFS=$OLDIFS
}

function ask_confirmation(){
  read -p "${1} - Y/n? " ans

  case $ans in
    "Y"|"y"|"yes"|"Yes")
      echo "Y"
      break ;;
    "N"|"n"|"no"|"No")
      echo "N"
      break ;;
  esac
}

function ask_directory(){
  read -e -p "${1}" DIRECTORY

  if [ ! -d "$DIRECTORY" ]; then
    echo "[notice] - The given directoy does not exists"
    ask_directory "${1}"
    exit;
  fi

  echo $DIRECTORY
}

PROJECTS=()

# BEGIN SCRIPT
read_bootstrap_directory "${_mydir}"

# Check if there is a bootstrap directory at the current working directory
if [ $PROJECTS ]; then
    BOOTSTRAP_DIR=${_mydir}
else
    echo "[notice] - No bootstrap directories found at current working directory"
    anwser=$(ask_confirmation "Do you want to specify a directory with bootstrap projects?")
    if [ $anwser == "Y" ]
      then
        # Ask the user to specify the bootstrap directory
        BOOTSTRAP_DIR=$(ask_directory "Please enter your bootstrap directory: ")
        read_bootstrap_directory "${BOOTSTRAP_DIR}"
      else
        echo "[notice] - Sadly no one want to play with me :("
        exit;
    fi
fi

# Store the confirmed project
CONFIRMED_PROJECT=$(choose_bootstrap_project)

# Ask the user if the current path is the correct project path
anwser=$(ask_confirmation "Do you want to bootstrap at the current path? \n Location: ${_mydir}")

if [ $anwser == "N" ]
  then
    BOOTSTRAP_PROJECT_PATH=$(ask_directory "Please enter your bootstrap project path: ")
  else
    BOOTSTRAP_PROJECT_PATH=${_mydir}
fi

