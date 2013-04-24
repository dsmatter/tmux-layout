# tmux-layout
A tiny utitility to generate [tmux](http://tmux.sourceforge.net) commands from a layout description in JSON format.

## Installation
Make sure you have installed node.js including NPM

     make
     sudo npm install -g .

## Usage
Start a new tmux session with a given layout

    tmux-layout /path/to/layout.json

Print out the "compiled" tmux command

    tmux-layout -c /path/to/layout.json

## Layout Files
The layout files are kept very simple, yet. The following example file should suffice for documentation purporses :)

    [
      {
        "top":
          {
            "left" : "ls -la"
          },
        "bottom" : "uname -a"
      },
      {
        "left"  : "w",
        "right" : ""
      },
      "ls -a"
    ]