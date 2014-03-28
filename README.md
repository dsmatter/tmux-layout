# tmux-layout
A tiny utitility to generate [tmux](http://tmux.sourceforge.net) commands from a layout description in JSON format.

## Installation
Make sure you have installed node.js including NPM

     sudo npm install -g tmux-layout

## Usage
Start a new tmux session with a given layout

    tmux-layout # uses tmux.json file in current directory
    tmux-layout /path/to/layout.json

Print out the "compiled" tmux command

    tmux-layout -c /path/to/layout.json

## Layout Files
The layout files are kept very simple, yet. The following example file should suffice for documentation purporses:

    {
      "title": "tmux-layout (Purescript)",
      "windows": [
        {
          "title": "Main",
          "layout": {
            "left": {
              "top": "psci",
              "bottom": "git status"
            },
            "right": "ls -al"
          }
        }
      ]
    }
    
