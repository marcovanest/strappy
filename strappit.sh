#!/bin/sh

project_choice=-1

function bootstrap_project(){

  choice=''

  # Ask the user which bootstrap project must be initialized
  PS3='Please enter your bootstrap project: '
  select opt in "${project[@]}"
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
            bootstrap_project
          else
           echo "Nothing to do here..."
           exit
        fi
    fi
    break;
  done
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

# Get working directory
_mydir="$(pwd)"

BOOTSTRAP_DIR=''

# Check if there is a bootstrap directory
if [ $project ]; then
    BOOTSTRAP_DIR=${_mydir}
else
    echo "[notice] - No bootstrap directories found at current working directory"
    anwser=$(ask_confirmation "Do you want to specify a directory with bootstrap projects?")
    if [ $anwser == "Y" ]
      then
        BOOTSTRAP_DIR=$(ask_directory "Please enter your bootstrap directory: ")
      else
        echo "[notice] - Sadly no one want to play with me :("
        exit;
    fi
fi

project=()
# Read project directories into array
for file in "${BOOTSTRAP_DIR}*"
  do
  if [ -d "$file" ];then
    project+=($file)
    echo ${file}
  fi
done

# Ask the user if the current location is the desired bootstrap path
#anwser=$(ask_confirmation "Do you want to bootstrap at the current location? \n Location: ${_mydir}")

#if [ $anwser == "N" ]
#  echo "[notice] - Sadly no one want to play with me :("
#  exit;
#fi

# Ask the user if he/she is sure with his/her choice
#confirm_project_directory=-1
#PS3=''
#echo "Are you sure you want to bootstrap project ${project_choice}"
#select yn in "Yes" "No"; do
#case $yn in
#  Yes ) confirm_project_directory=1 break;;
#  No ) confirm_project_directory=2 break;;
#esac
#done#

#if [ $confirm_project_directory -eq 1 ]
#  then
#    echo "\0/"
#  else
#    echo "/0\/"
#fi#

#PS3=''
#echo "Do you want to bootstrap at the current location? \nLocation: ${_mydir} "
#select yn in "Yes" "No"; do
#case $yn in
#  Yes ) get_project_name break;;
#  No ) exit;;
#esac
#done

