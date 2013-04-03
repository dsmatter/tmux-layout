main: tmux-layout.coffee
	coffee -c tmux-layout.coffee
	echo 	"#!/usr/bin/env node" | cat - tmux-layout.js | tee tmux-layout.js >/dev/null
	chmod +x tmux-layout.js

clean:
	rm -rf *.js
