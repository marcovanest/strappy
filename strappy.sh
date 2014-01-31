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

  DIR="${1%/}/vagrantstrapps"
  if [ -d $DIR ]; then
    # Read project directories into array
    for file in ${DIR}/*; do
      if [ -d "${file}" ];then
        PROJECTS+=($(/usr/bin/basename "${file}"))
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
    exit;
  fi
}

function choose_project(){

  # Ask the user which bootstrap project must be initialized
  PS3='Please enter your bootstrap project: '
  select opt in "${PROJECTS[@]}"
  do
    if [ -n "$opt" ]; then
      # Ask the user if he/she is sure with the choice
      answer=$(ask_confirmation "Are you sure you want to bootstrap project ${opt}")
      if [ $answer == "Y" ]; then # If confirmed than set choice
          echo ${opt}
      else # Ask the user if he/she want to bootstrap another project
        answer=$(ask_confirmation "Do you want to bootstrap another project")
        if [ $answer == "Y" ]; then
          choose_project
        else
          return 0
          exit;
        fi
      fi

      else choose_project
    fi
    break;
  done
}

function search_file(){
  while read result; do
    RESULTS+=(`echo ${result##*=} | /usr/bin/sed 's/^"\(.*\)"$/\1/'`)
  done <<< `/usr/bin/grep $1 $2`
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
    *)
      ask_confirmation "${1}"
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

# Check if the Strappy config file exists, if not create it
if [ ! -f ~/.strappy_config ]; then
  create_file ~/.strappy_config
  write_file ~/.strappy_config "strappybootstrap_dir="
  echo "Created the Strappy config file"
fi

source ~/.strappy_config

# Check if there is a StrappyBootstrap directory present in the User folder, if not create it
if [  -z "$strappybootstrap_dir" ]; then
  answer=$(ask_confirmation "Strappy did not found a StrappyBootstrap directory. Do you want to create one in your user dir?")

  if [ $answer == "Y" ]; then
    create_directory $HOME/StrappyBootstrap
    StrappyBootstrapFolder=$HOME
  else
    answer=$(ask_confirmation "Do you want to create the StrappyBootstrap dir at another location?")

    if [ $answer == "Y" ]; then
      PATH=$(ask_directory "Please enter the path: ")
      create_directory $PATH/StrappyBootstrap
      StrappyBootstrapFolder=$PATH
      else
      echo "Sadly no one want to play with me :("
      exit;
    fi
  fi

  write_file ~/.strappy_config "strappybootstrap_dir=\"${StrappyBootstrapFolder}/StrappyBootstrap\""
  echo "StrappyBootstrap dir created at ${StrappyBootstrapFolder}/StrappyBootstrap"

  # Create the vagrantstrapps folder
  if [ ! -d "$StrappyBootstrapFolder/StrappyBootstrap/vagrantstrapps" ]; then
    create_directory $StrappyBootstrapFolder/StrappyBootstrap/vagrantstrapps
    echo "Created vagrantstrapps folder. This is the directory where you place all your bootstrap projects"
  fi
fi

PROJECTS=()
BOOTSTRAP_DIR=''

source ~/.strappy_config

# Check the current working directory for bootstrap projects
read_directory "${strappybootstrap_dir}"

# Check if there are any bootstrap projects found
bootstraps_found "${strappybootstrap_dir}"

# Ask the user to choose a bootstrap project
CONFIRMED_PROJECT=$(choose_project)

# Check if there is a project selected
if [ ! $CONFIRMED_PROJECT ]; then
  exit;
fi

# Ask the user if the current path is the correct project path
answer=$(ask_confirmation "Do you want to bootstrap at the current path?${NEWLINE}Location: ${_mydir}")

if [ $answer == "N" ]; then # If the user does not want to bootstrap at the current path, ask for another
  BOOTSTRAP_PROJECT_PATH=$(ask_directory "Please enter your bootstrap project path: ")
else
  PATH=$(ask_directory "Please enter the project name: ")
  BOOTSTRAP_PROJECT_PATH=${_mydir}/$PATH
fi

# Check if the directory is already bootstrapped by strappy
if [ -f "${BOOTSTRAP_PROJECT_PATH}/.strappy" ]; then
  echo "Strappy found"
else
  # Copy the bootstrap project file to the given project directory
  /bin/cp -r ${BOOTSTRAP_DIR%/}/vagrantstrapps/${CONFIRMED_PROJECT%/}/. $BOOTSTRAP_PROJECT_PATH/

  # Create strappy file, this file will be used to check if a directory already is bootstrapped by strappy
  create_file $BOOTSTRAP_PROJECT_PATH/.strappy

  # Write the bootstrap project into the strappy file
  write_file $BOOTSTRAP_PROJECT_PATH/.strappy ${BOOTSTRAP_DIR}vagrantstrapps/${CONFIRMED_PROJECT}
fi

# Change directory to the project dir
change_directory ${BOOTSTRAP_PROJECT_PATH}

# Check if Vagrantfile is present
if [ -f "Vagrantfile" ]; then

  # Extract the defined machine blocks into temporary files, so they can parsed separately
  `/usr/bin/awk '/config.vm.define[[:space:]]\"[a-z]*\"[[:space:]]do[[:space:]]\|[a-zA-Z_]*\|/ {f=1; i++} f{print $0 > ("block"i)} /end/ {f=0}' Vagrantfile`

  for file in $(/usr/bin/find . -type f -name 'block*' -exec /usr/bin/basename {} \;) ; do

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

  echo "Done with parsing Vagrantfile"

  # Ask the user to vagrant up or not
  answer=$(ask_confirmation "Do you want to vagrant up?")

  if [ $answer == "Y" ]; then
    /usr/bin/vagrant up
  fi
fi

# Check if git is installed
/usr/bin/git --version 2>&1 >/dev/null
GIT=$?

if [ $GIT -eq 0 ]; then
  # Ask the user to create a git repository
  answer=$(ask_confirmation "Do you want to create a git repository")
  if [ $answer == "Y" ]; then
    /usr/bin/git init 2>&1 >/dev/null;

    # Check if the git repository is correctly initialized
    SUCCES=$?
    if [ $SUCCES -eq 0 ]; then
      echo "Initialized empty Git repository"
    fi
  fi
fi