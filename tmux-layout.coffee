fs             = require "fs"
{OptionParser} = require "optparse"
{spawn}        = require "child_process"

class WriterVar
  constructor: ->
    @data = ""
  write: (data) ->
    @data += data

class TmuxCommand
  windowGiven: true

  constructor: (out) ->
    @out = out ? new WriterVar

  parseLayout: (layout) ->
    @emitPrefix()
    for win in layout
      @emitWindow win.name
      @handleWindow win

  run: ->
    throw "Out must be a WriterVar!" unless @out instanceof WriterVar
    spawn "sh", ["-c", @out.data], stdio: "inherit"

  emitCommand: (cmd) ->
    @out.write " \\; #{cmd}"

  emitPrefix: ->
    @out.write "tmux new-session"

  emitWindow: (name) ->
    if @windowGiven
      @windowGiven = false
      return
    cmd = "new-window -c \"#{process.cwd()}\""
    cmd += " -n \"#{name}\"" if name?
    @emitCommand cmd

  emitKeys: (keys) ->
    @emitCommand "send-keys \"#{keys}\" \"Enter\""

  emitSplit: (direction) ->
    @emitCommand "split-window -c \"#{process.cwd()}\" -#{direction}"

  emitSplitVertical: ->
    @emitSplit "v"

  emitSplitHorizontal: ->
    @emitSplit "h"

  emitMove: (direction) ->
    @emitCommand "select-pane -#{direction}"

  emitMoveUp: ->
    @emitMove "U"

  emitMoveDown: ->
    @emitMove "D"

  emitMoveLeft: ->
    @emitMove "L"

  emitMoveRight: ->
    @emitMove "R"

  handleWindow: (win) ->
    return unless win?
    if typeof win is "string"
      @emitKeys win
    else if typeof win is "object"
      if win.top?
        @emitSplitVertical()
        @emitMoveUp()
        @handleWindow win.top
        @emitMoveDown()
        @handleWindow win.bottom
      else if win.left?
        @emitSplitHorizontal()
        @emitMoveLeft()
        @handleWindow win.left
        @emitMoveRight()
        @handleWindow win.right

readLayout = ->
  lastArg = process.argv[process.argv.length - 1]
  path = if lastArg.match /\.json$/ then lastArg else "tmux.json"
  data = fs.readFileSync path
  JSON.parse data

compile = (layout, out) ->
  result = new TmuxCommand out
  result.parseLayout layout
  result

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

# Show usage
if options.help
  console.log parser.banner
  return

# Read in layout
try
  layout = readLayout()
catch err
  throw err unless err.code in ["ENOENT", "EACCES"]
  process.stderr.write "tmux layout file not readable: '#{err.path}'\n"
  process.exit 1

# Compile to STDOUT 
if options.compile
  compile layout, process.stdout
  return

# Compile and run
compile(layout).run()
