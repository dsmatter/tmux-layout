(function (_ps) {
    "use strict";
    _ps.Prelude = (function (module) {
        function $plus$plus(s1) {  return function(s2) {    return s1 + s2;  };};
        module["++"] = $plus$plus;
        return module;
    })(_ps.Prelude || {});
    _ps.Data_Array = (function (module) {
        function concat(l1) {  return function (l2) {    return l1.concat(l2);  };};
        var concatMap = function (_1) {
            return function (_2) {
                if (_1.length === 0) {
                    return [  ];
                };
                if (_1.length > 0) {
                    var _6 = _1.slice(1);
                    return concat(_2(_1[0]))(concatMap(_6)(_2));
                };
                throw "Failed pattern match";
            };
        };
        var $colon = function (a) {
            return concat([ a ]);
        };
        var map = function (_1) {
            return function (_2) {
                if (_2.length === 0) {
                    return [  ];
                };
                if (_2.length > 0) {
                    var _6 = _2.slice(1);
                    return $colon(_1(_2[0]))(map(_1)(_6));
                };
                throw "Failed pattern match";
            };
        };
        module.concatMap = concatMap;
        module[":"] = $colon;
        module.concat = concat;
        module.map = map;
        return module;
    })(_ps.Data_Array || {});
    _ps.Data_Tmux = (function (module) {
        var Full = function (value0) {
            return {
                ctor: "Data.Tmux.Full", 
                values: [ value0 ]
            };
        };
        var HSplit = function (value0) {
            return function (value1) {
                return {
                    ctor: "Data.Tmux.HSplit", 
                    values: [ value0, value1 ]
                };
            };
        };
        var VSplit = function (value0) {
            return function (value1) {
                return {
                    ctor: "Data.Tmux.VSplit", 
                    values: [ value0, value1 ]
                };
            };
        };
        var WindowConfig = function (value0) {
            return {
                ctor: "Data.Tmux.WindowConfig", 
                values: [ value0 ]
            };
        };
        var TmuxConfig = function (value0) {
            return {
                ctor: "Data.Tmux.TmuxConfig", 
                values: [ value0 ]
            };
        };
        function render(dict) {
            return dict.render;
        };
        function parseLayout(json) {  if (!json) { return _ps.Data_Tmux.Full(''); }  if (typeof json === 'string') { return _ps.Data_Tmux.Full(json); }  if (typeof json.top !== 'undefined' || typeof json.bottom !== 'undefined') {    return _ps.Data_Tmux.VSplit(parseLayout(json.top))(parseLayout(json.bottom));  }  return _ps.Data_Tmux.HSplit(parseLayout(json.left))(parseLayout(json.right));};
        var quote = function (s) {
            return " \"" + s + "\" ";
        };
        var parseWindow = function (o) {
            return WindowConfig({
                title: o.title, 
                layout: parseLayout(o.layout)
            });
        };
        var parseConfig = function (o) {
            return TmuxConfig({
                title: o.title, 
                windows: _ps.Data_Array.map(parseWindow)(o.windows)
            });
        };
        var intercalate = function (_1) {
            return function (_2) {
                if (_2.length === 0) {
                    return "";
                };
                if (_2.length === 1) {
                    return _2[0];
                };
                if (_2.length === 2) {
                    return _2[0] + _1 + _2[1];
                };
                if (_2.length > 0) {
                    var _9 = _2.slice(1);
                    if (_9.length > 0) {
                        var _11 = _9.slice(1);
                        return _2[0] + _1 + _9[0] + _1 + intercalate(_1)(_11);
                    };
                };
                throw "Failed pattern match";
            };
        };
        var chainCommands = intercalate(" \\; ");
        var $plus$plus$plus = function (_1) {
            return function (_2) {
                if (_1.length === 0) {
                    return _2;
                };
                if (_1.length > 0) {
                    var _6 = _1.slice(1);
                    return _ps.Data_Array[":"](_1[0])($plus$plus$plus(_6)(_2));
                };
                throw "Failed pattern match";
            };
        };
        var layoutCommand_render = function (_1) {
            return function (_2) {
                if (_2.ctor === "Data.Tmux.Full") {
                    return [ "send-keys" + quote(_2.values[0]) + "\"Enter\"" ];
                };
                if (_2.ctor === "Data.Tmux.HSplit") {
                    return $plus$plus$plus($plus$plus$plus($plus$plus$plus([ "split-window -h -c" + quote(_1), "select-pane -L" ])(render(layoutCommand({}))(_1)(_2.values[0])))([ "select-pane -R" ]))(render(layoutCommand({}))(_1)(_2.values[1]));
                };
                if (_2.ctor === "Data.Tmux.VSplit") {
                    return $plus$plus$plus($plus$plus$plus($plus$plus$plus([ "split-window -v -c" + quote(_1), "select-pane -U" ])(render(layoutCommand({}))(_1)(_2.values[0])))([ "select-pane -D" ]))(render(layoutCommand({}))(_1)(_2.values[1]));
                };
                throw "Failed pattern match";
            };
        };
        var layoutCommand = function (_1) {
            return {
                render: layoutCommand_render
            };
        };
        var windowCommand_render = function (_1) {
            return function (_2) {
                return $plus$plus$plus([ "new-window -n" + quote((_2.values[0]).title) + "-c" + quote(_1) ])(render(layoutCommand({}))(_1)((_2.values[0]).layout));
                throw "Failed pattern match";
            };
        };
        var windowCommand = function (_1) {
            return {
                render: windowCommand_render
            };
        };
        var configCommand_render = function (_1) {
            return function (_2) {
                return $plus$plus$plus($plus$plus$plus([ "new-session -s" + quote((_2.values[0]).title) ])(_ps.Data_Array.concatMap((_2.values[0]).windows)(render(windowCommand({}))(_1))))([ "select-window -t 0", "kill-window", "select-window -t 1" ]);
                throw "Failed pattern match";
            };
        };
        var configCommand = function (_1) {
            return {
                render: configCommand_render
            };
        };
        var toCommand = function (cwd) {
            return function (config) {
                return "tmux " + chainCommands(render(configCommand({}))(cwd)(config));
            };
        };
        module.Full = Full;
        module.HSplit = HSplit;
        module.VSplit = VSplit;
        module.toCommand = toCommand;
        module.parseConfig = parseConfig;
        module.configCommand = configCommand;
        module.windowCommand = windowCommand;
        module.layoutCommand = layoutCommand;
        return module;
    })(_ps.Data_Tmux || {});
})((typeof module !== "undefined" && module.exports) ? module.exports : (typeof window !== "undefined") ? window.PS = window.PS || {} : (function () {
    throw "PureScript doesn't know how to export modules in the current environment";
})());