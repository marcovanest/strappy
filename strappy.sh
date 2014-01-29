#!/bin/sh

NEWLINE=$'\n'

# Get working directory
OLDIFS=$IFS
IFS=$'\n'
_mydir="$(pwd)"
IFS=$OLDIFS

function read_directory(){

  # http://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
  OLDIFS=$IFS
  IFS=$'\n'

  DIR="${1%/}/strapps"
  if [ -d $DIR ]; then
    # Read project directories into array
    for file in ${DIR}/*; do
      if [ -d "${file}" ];then
        PROJECTS+=($(basename "${file}"))
      fi
    done
  fi

  IFS=$OLDIFS
}

function bootstraps_found(){
  if [ $PROJECTS ]; then
    BOOTSTRAP_DIR=$1
  else
    echo "No bootstrap projects found"
    answer=$(ask_confirmation "Do you want to specify a directory with bootstrap projects?")
    if [ $answer == "Y" ]; then
      BOOTSTRAP_DIR=$(ask_directory "Please enter your bootstrap directory: ")

      read_directory "${BOOTSTRAP_DIR}"
      bootstraps_found "${BOOTSTRAP_DIR}"
    else
      echo "Sadly no one want to play with me :("
      exit;
    fi
  fi
}

function choose_project(){

  # Ask the user which bootstrap project must be initialized
  PS3='Please enter your bootstrap project: '
  select opt in "${PROJECTS[@]}"
  do
    # Ask the user if he/she is sure with the choice
    answer=$(ask_confirmation "Are you sure you want to bootstrap project ${opt}")
    if [ $answer == "Y" ]; then # If confirmed than set choice
        echo ${opt}
      else # Ask the user if he/she want to bootstrap another project
        answer=$(ask_confirmation "Do you want to bootstrap another project")
        if [ $answer == "Y" ]; then
           choose_project
          else
           echo "Nothing to do here..."
           exit
        fi
    fi
    break;
  done
}

function search_file(){
  while read result; do
    RESULTS+=(`echo ${result##*=} | sed 's/^"\(.*\)"$/\1/'`)
  done <<< `grep $1 $2`
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
    answer=$(ask_confirmation "Directory does not exists. Do you want to create it?")

    if [ $answer == "Y" ]; then
      create_directory "$DIRECTORY"
    else
       ask_directory "${1}"
    fi
  fi

  echo $DIRECTORY
}

function create_directory(){
  /bin/mkdir -p $1
}

function create_file(){
  /usr/bin/touch $1
}

function write_file(){
  echo $2 > $1
}

function change_directory(){
  cd $1
}

# BEGIN SCRIPT

PROJECTS=()
BOOTSTRAP_DIR=''

# Check the current working directory for bootstrap projects
read_directory "${_mydir}"

# Check if there are any bootstrap projects found
bootstraps_found "${_mydir}"

# Ask the user to chose a bootstrap project
CONFIRMED_PROJECT=$(choose_project)

# Ask the user if the current path is the correct project path
answer=$(ask_confirmation "Do you want to bootstrap at the current path?${NEWLINE}Location: ${_mydir}")

if [ $answer == "N" ]; then # If the user does not want to bootstrap at the current path, ask for another
  BOOTSTRAP_PROJECT_PATH=$(ask_directory "Please enter your bootstrap project path: ")
else
  BOOTSTRAP_PROJECT_PATH=${_mydir}
fi

# Check if the directory is already bootstrapped by strappy
if [ -f "${BOOTSTRAP_PROJECT_PATH}/.strappy" ]; then
  echo "Strappy found"
else
  # Copy the bootstrap project file to the given project directory
  cp -r ${BOOTSTRAP_DIR%/}/strapps/${CONFIRMED_PROJECT%/}/. $BOOTSTRAP_PROJECT_PATH/

  # Create strappy file, this file will be used to check if a directory already is bootstrapped by strappy
  create_file $BOOTSTRAP_PROJECT_PATH/.strappy

  # Write the bootstrap project into the strappy file
  write_file $BOOTSTRAP_PROJECT_PATH/.strappy ${BOOTSTRAP_DIR}strapps/${CONFIRMED_PROJECT}
fi

# Change directory to the project dir
change_directory ${BOOTSTRAP_PROJECT_PATH}

# Check if the bootstrapped project is a vagrant project
if [ -f "Vagrantfile" ]; then

  # Ask the user to vagrant up or not
  answer=$(ask_confirmation "Vagrantfile found. Do you want to vagrant up?")

  if [ $answer == "Y" ]; then
    vagrant up
  fi

  VAGRANT_PRESENT="Y"

else
  VAGRANT_PRESENT="N"
fi

# Check if Vagrantfile is present
if [ $VAGRANT_PRESENT == "Y" ]; then

  # Extract the defined machine blocks into temporary files, so they can parsed separately
  `awk '/config.vm.define[[:space:]]\"[a-z]*\"[[:space:]]do[[:space:]]\|[a-zA-Z_]*\|/ {f=1; i++} f{print $0 > ("block"i)} /end/ {f=0}' Vagrantfile`

  for file in $(find . -type f -name 'block*' -exec basename {} \;) ; do

    # Search the Vagrantfile for module dirs and check if they exist, if not create them
    unset RESULTS
    RESULTS=()
    search_file 'module_path' $file
    for MODULE_PATH in $RESULTS; do
      if [ ! -d "$BOOTSTRAP_PROJECT_PATH/$MODULE_PATH" ]; then
        create_directory $BOOTSTRAP_PROJECT_PATH/$MODULE_PATH

        echo "Module path ${BOOTSTRAP_PROJECT_PATH}/${MODULE_PATH} created"
      fi
    done

    # Search the Vagrantfile for manifests dirs and check if they exist, if not create them
    unset RESULTS
    RESULTS=()
    search_file 'manifests_path' $file
    for MANIFEST_PATH in $RESULTS; do
      if [ ! -d "$BOOTSTRAP_PROJECT_PATH/$MANIFEST_PATH" ]; then
        create_directory $BOOTSTRAP_PROJECT_PATH/$MANIFEST_PATH

        echo "Manifest path ${BOOTSTRAP_PROJECT_PATH}/${MANIFEST_PATH} created"
      fi
    done

    MANIFEST_PATH=$RESULTS

    # Search the Vagrantfile for manifests files and check if they exist, if not create them
    unset RESULTS
    RESULTS=()
    search_file 'manifest_file' $file
    for MANIFEST_FILE in $RESULTS; do
      if [ ! -f "$MANIFEST_PATH/$MANIFEST_FILE" ]; then
        create_file $MANIFEST_PATH/$MANIFEST_FILE

        echo "Manifest file ${MANIFEST_PATH}/${MANIFEST_FILE} created"
      fi
    done

  done
fi