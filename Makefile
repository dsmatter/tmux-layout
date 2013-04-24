main: tmux-layout.coffee
	npm install
	node_modules/.bin/coffee -c tmux-layout.coffee
	echo 	"#!/usr/bin/env node" | cat - tmux-layout.js | tee tmux-layout.js >/dev/null
	mv tmux-layout.js tmux-layout
	chmod +x tmux-layout

clean:
	rm -rf tmux-layout
