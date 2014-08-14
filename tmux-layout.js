#!/usr/bin/env node

var tmux         = require("./Data/Tmux").Data_Tmux;
var fs           = require("fs");
var spawn        = require("child_process").spawn
var OptionParser = require("optparse").OptionParser

var switches = [
  ["-h", "--help", "You are looking at it"],
  ["-c", "--compile", "Print the compiled tmux command to STDOUT"],
  ["-i", "--init", "Create an example tmux.json file in the current directory"],
];

var options = {
  help    : false,
  compile : false,
  init    : false
};

var parser = new OptionParser(switches);
parser.on("help", function() { options.help = true; });
parser.on("compile", function() { options.compile = true; });
parser.on("init", function() { options.init = true; });
parser.banner = "Usage: [Options] layout-file"
parser.parse(process.argv);

if (options.help) {
  return console.log(parser.toString());
}

if (options.init) {
  if (fs.existsSync("tmux.json")) {
    return console.log("tmux.json already exists - refusing to overwrite");
  }
  var example = {
    "title": "tmux-layout (Purescript)",
    "windows": [
      {
        "title": "Main",
        "layout": {
          "left": {
            "top": "echo hi",
            "bottom": "git status"
          },
          "right": "ls -al"
        }
      }
    ]
  }
  return fs.writeFileSync("tmux.json", JSON.stringify(example, null, 2));
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

