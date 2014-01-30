# Strappy - Vagrant project bootstrapper

## Important

Strappy has not reached a stable release. There is much to be done and furthermore I only tested it on OSX 10.9.1.

## Why

I wrote this shell script because I got tired of copy pasting Vagrantfile configurations, making provisioning directory’s etc… I’m currently working on multiple projects and I noticed that it took me some time (not much but enough ;) ) to set-up a Vagrant development workflow.

Another big reason for writing this script is that all my bootstrap projects are under version control. If I clone them I have to manually remove the .git file because I don't want the bootstrap files under version control inside a working project. Next I've to cd into my shared folder and run git init. Last but not least is creating a .gitignore file for the specific files inside my project. I found these steps very boring and found the need to automate this. So Strappy was born...

## So how does it work?

Strappy is a simple shell script that runs from the command line. What it basically does is scanning a pre-determined bootstrap directory for vagrant projects. If Strappy finds any projects inside the given strappy project directory it will ask the user to make a choice which bootstrap project s/he wants to bootstrap. During the bootstrapping Strappy will ask the user for some simple questions in order to determine what the user actually wants.

During the process the following actions are executed

* Copy all files and folders recursively over to the new project
* Parses the Vagrantfile and extract the manifest and module paths, if they are not present inside the project folder they will be created
   The same goes for the manifests files.
* Asks the user to vagrant up
* Asks the user to git init

The end result is a fully bootstrapped vagrant project within seconds!

## Setting it up

First of all download the strappy.sh file and place it in a directory of your choosing. I would recommend placing it inside the /usr/local/bin folder, mainly because it’s already defined in your PATH, so you can run it globally inside your system without constantly specifying the absolute path to it.
Then make it executable by running chmod u+x strappy.sh

## Running it for the first time

So let's run strappy for the first time!

Start with the command

     strappy

A config file is created if Strappy runs for the first time. The file will be created inside the home folder. If you want to check it out just run cat ~/.strappy_config. It's nothing special and it only contains a key/value pair that contains the StrappyBootstrapp directory.

This directory is exactly what Strappy wants to know if you run it the first time ever. So it will ask you for it

     Created the Strappy config file
     Strappy did not found a StrappyBootstrap directory. Do you want to create one in your user dir? - Y/n?

Option 1) If you answer the above question with "yes" then a StrappyBootstrap directory will be created inside your home dir

     StrappyBootstrap dir created at /Users/{username}/StrappyBootstrap
     Created vagrantstrapps folder. This is the directory where you place all your bootstrap projects
     No bootstrap projects found

Option 2) If you answer the question with "no" then a strappy will ask the user to specify one

     Do you want to create the StrappyBootstrap dir at another location? - Y/n?
     Please enter the path: /User/{username}/Projects  <--- Just an example
     StrappyBootstrap dir created at /Users/{name}/Projects/StrappyBootstrap
     Created vagrantstrapps folder. This is the directory where you place all your bootstrap projects
     No bootstrap projects found

Strappy will update config file with the directory chosen above. So the next time you run strappy you won't be asked again to create one. Instead it will directly list out the bootstrap projects for you that you have defined.

Ok good, Strappy is almost set-up!. The next step is to add some bootstrap projects inside the vagrantstrapps folder.

     cd /User/{username}/StrappyBootstrap/vagrantstrapps
     OR
     cd /User/{username}/Projects/StrappyBootstrap/vagrantstrapps <--- Custom path if you choose for that
     git clone https://github.com/marcovanest/bootstrap_dev_env.git <-- Just an example you could also copy a existing project from your harddrive into it

Now you have defined your first bootstrap project it's time to strap it for a new project.

     strappy

Strappy will now show you a option list with your bootstrap project as an option.

    1) Awesome_Bootstrap_project
    Please enter your bootstrap project: 1

Select the desired project and hit enter. The next question is one to make really sure

    Are you sure you want to bootstrap project Awesome_Bootstrap_project - Y/n?

If you're not sure enter "no" and you will return to the previous question. If you are sure enter "yes"

    Do you want to bootstrap at the current path?
    Location: /Users/marcovanest/Projects/MyAweSomeProject/bootstrap_dev_env - Y/n?

Option 1) By entering "yes" Strappy will bootstrap the project in the current folder path. There will be an additional question where you must enter the project name

    Please enter the project name: GeekApp

Option 2) If you enter "no" you must enter the full path to the desired project folder, including the project name

    Please enter your bootstrap project path: /Users/{username}/Projects/Test/Awesome

Hit enter when you're done. Strappy will ask you the following question. If you're not sure enter "no" and you will return to the previous question.

    Directory does not exists. Do you want to create it? - Y/n?

Enter "yes" if you want to create. Strappy will parse the Vagrantfile and will ask you to create a git repository

    Done with parsing Vagrantfile
    Do you want to create a git repository - Y/n?

After this you're done and ready to go!