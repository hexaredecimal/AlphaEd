
```
com.vincent presents
           _____  .____   __________  ___ ___    _____   
          /  _  \ |    |  \______   \/   |   \  /  _  \  
         /  /_\  \|    |   |     ___/    ~    \/  /_\  \ 
        /    |    \    |___|    |   \    Y    /    |    \
        \____|__  /_______ \____|    \___|_  /\____|__  /
                \/        \/               \/         \/ 

                      A simple modal Editor ∆
                          forked - bed 🛌
```

# Introduction

> **ALPHA Ed** - is a simple *command line* based modal text editor created in bash. It is simple to use and it is general purpose enough to be used for literally anything that involves writting text. It is forked for bed, and it is also written completely in shell script or bash script.  

 *Alpha Ed is provided for free as it is open source. See licence on the repository page.*



# KeyBindings

    pgUp - move to the first line (line 1)
    pgDwn - move to the last line (line n-1) 
    w  - move one line up (⬆️)
    s  - move one line down (⬇️)
    <- - move one char left (⬅️)  *
    -> - move one char right (➡️) *

    r  - read a new file to the buffer
    f  - set target file name (the file to save to)
    g  - write to the target file (save)
    
    e  - edit the currently selected line
    a  - create a new line and write on it 
    d  - delete the whole line
    n  - creates a new line, but sticks to the currently selected
    h  - view the help file
    c  - create a command line
    q  - close the text editor (quit)

* > (*) These are the arrow buttons on your keyboard. If using a mobile device such as a smartphone, I highly suggest that you use hacker's keyboard. It is free on the Google Play store. It will give you a full QWERTY virtual keyboard for your device.

- >Contribution and new features are always welcome. To contribute sign up or sign in on GitHub and clone the repository. make changes then submit a pull request.


# Features
 >* Console based
 >* Easy KeyBindings
 >* Zero dependencies 
 >* Ansi escape code based
 

# bugs
   >* Line deleting - **FIXED**
   > * appending a new line - **FIXED**
   > * creating a new line - **FIXED**
   > * exiting - **FIXED**

# TODO
  > * Syntax highlighting
  

#### note 

> The editor is entirely written in shell script, it is slow on some devices as it depends on processes for execution, some processes start slowly.

# Build
> * AlphaEd only depends on sh, which is by default, installed on most Android devices.
> * The editor builds using **c4droid** mobile ide
> * **c4droid** uses the **tcc** *(Tiny c compiler)* compiler for Android. As a result, the output executable has a smaller size
> ### build instructions
>> * Have **c4droid** installed
>> * clone this repository and unzip the folder
>> * open the **Alpha.c** in c4droid 
>> * compile and run
>> * if successful, build apk by exporting.
>> * if fails create an issue and put the resulting error message

