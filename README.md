# Strappy - Vagrant project bootstrapper

## Important

Strappy has not reached a stable release. There is much to be done and furthermore I only tested it on OSX 10.9.1.

## Why

I wrote this shell script because I got tired of copy pasting Vagrantfile configurations, making provisioning directory’s etc… I’m currently working on multiple projects and I noticed that it took me some time (not much but enough ;) ) to set-up a Vagrant development workflow.

## So how does it work?

Strappy is a simple shell script that runs from the command line. What it basically does is scanning a pre-determined bootstrap directory for vagrant projects. If Strappy finds any projects inside the given strappy project directory it will ask the user to make a choice which bootstrap project s/he wants to bootstrap. During the bootstrapping Strappy will ask the user for some simple questions in order to determine what the user actually wants.

The end result is a fully bootstrapped vagrant project within seconds!

## Setting it up

First of all download the strappy.sh file and place it in a directory of your choosing. I would recommend placing it inside the /usr/local/bin folder, mainly because it’s already defined in your PATH, so you can run it globally inside your system without constantly specifying the absolute path to it.
Then make it executable by running chmod u+x strappy.sh

Second step is creating a Vagrant bootstrap project folder on your system. It doesn’t matter where it is located, because Strappy will ask for it anyhow. Make sure you create a „strapps” folder within it. Inside this folder you will have to place all your Vagrant bootstrap projects.

E.g.

    \Strappy bootstraps
      \strapps
        \Project 1
          Vagrantfile
        \Project 2
          Vagrantfile
        \Project 3
          Vagrantfile

## Running it for the first time

So let's run strappy for the first time!

Start with the command

     strappy

Strappy creates a config file if it runs for the first time. The config file will be created inside the ~ folder

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
