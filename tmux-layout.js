#!/usr/bin/env node

var tmux         = require("./Data/Tmux").Data_Tmux;
var fs           = require("fs");
var spawn        = require("child_process").spawn
var OptionParser = require("optparse").OptionParser

var switches = [
  ["-h", "--help", "You are looking at it"],
  ["-c", "--compile", "Print the compiled tmux command to STDOUT"],
];

var options = {
  help    : false,
  compile : false
};

var parser = new OptionParser(switches);
parser.on("help", function() { options.help = true; });
parser.on("compile", function() { options.compile = true; });
parser.banner = "Usage: tmux-layout [-h|-c] [config]"
parser.parse(process.argv);

if (options.help) {
  return console.log(parser.banner);
}

try {
  var lastArg = process.argv[process.argv.length - 1];
  var path = lastArg.match(/\.json$/) ? lastArg : "tmux.json";
  var json = JSON.parse(fs.readFileSync(path));
  var config = tmux.parseConfig(json);
  var command = tmux.toCommand(process.cwd())(config);

  if (options.compile) {
    return console.log(command);
  }
  spawn("sh", ["-c", command], { stdio: "inherit" });
} catch (err) {
  if (err.code === "ENOENT" || err.code === "EACCES") {
    process.stderr.write("tmux layout not readable: " + err.path + "\n");
    process.exit(1);
  }
  console.log("Error while parsing config:");
  throw err;
}

