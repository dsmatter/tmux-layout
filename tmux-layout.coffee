fs             = require "fs"
{OptionParser} = require "optparse"
{spawn}        = require "child_process"

windowGiven = true
out = null

class WriterVar
  constructor: ->
    @data = ""
  write: (data) ->
    @data += data

readLayout = ->
  data = fs.readFileSync "tmux.json"
  JSON.parse data

emitCommand = (cmd) ->
  out.write "#{cmd}  \\; "

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

compile = (o) ->
  out = o
  layout = readLayout()
  emitPrefix()
  for win in layout
    emitWindow win.name
    handleWindow win
  out.write "\n"
  o

# Argument parsing

switches = [
  ["-h", "--help", "You are looking at it"],
  ["-c", "--compile", "Print the compiled tmux command to STDOUT"],
]

options =
  help    : false,
  compile : false

parser = new OptionParser switches
parser.on "help", ->
  options.help = true
parser.on "compile", ->
  options.compile = true

parser.banner = "Usage: tmux-layout [-h|-c]"
parser.parse(process.argv)

if options.help
  console.log parser.banner
  return

if options.compile
  compile process.stdout
  return

v = compile (new WriterVar)
spawn "sh", ["-c", v.data], stdio: "inherit"
