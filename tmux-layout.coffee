fs = require "fs"

windowGiven = true

readLayout = ->
  data = fs.readFileSync "tmux.json"
  JSON.parse data

emitCommand = (cmd) ->
  process.stdout.write "#{cmd} \\; "

emitPrefix = ->
  emitCommand "tmux new-session"

emitWindow = (name) ->
  if windowGiven
    windowGiven = false
    return
  cmd = "new-window"
  cmd += " -n \"#{name}\"" if name?
  emitCommand cmd

emitKeys = (keys) ->
  emitCommand "send-keys \"#{keys}\" \"Enter\""

emitSplitVertical = ->
  emitCommand "split-window -v"

emitSplitHorizontal = ->
  emitCommand "split-window -h"

emitMove = (direction) ->
  emitCommand "select-pane -#{direction}"

emitMoveUp = ->
  emitMove "U"

emitMoveDown = ->
  emitMove "D"

emitMoveLeft = ->
  emitMove "L"

emitMoveRight= ->
  emitMove "R"

handleWindow = (win) ->
  return unless win?
  if typeof win is "string"
    emitKeys win
  else if typeof win is "object"
    if win.top?
      emitSplitVertical()
      emitMoveUp()
      handleWindow win.top
      emitMoveDown()
      handleWindow win.bottom
    else if win.left?
      emitSplitHorizontal()
      emitMoveLeft()
      handleWindow win.left
      emitMoveRight()
      handleWindow win.right

layout = readLayout()
emitPrefix()
for win in layout
  emitWindow win.name
  handleWindow win
console.log()