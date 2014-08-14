module Data.Tmux
  ( TmuxLayout(..)
  , parseConfig
  , toCommand
  ) where

import Prelude
import Data.Array

data TmuxConfig = TmuxConfig 
  { title :: String
  , windows :: [WindowConfig]
  }

data WindowConfig = WindowConfig
  { title :: String
  , layout :: TmuxLayout
  }

data TmuxLayout = Full String
                | HSplit TmuxLayout TmuxLayout
                | VSplit TmuxLayout TmuxLayout

class TmuxCommand a where
  render :: String -> a -> [String]

instance configCommand :: TmuxCommand TmuxConfig where
  render cwd (TmuxConfig o) =
    ["new-session -s" ++ quote o.title] +++
    concatMap o.windows (render cwd) +++
    ["select-window -t 0", "kill-window", "select-window -t 1"]

instance windowCommand :: TmuxCommand WindowConfig where
  render cwd (WindowConfig o) =
    ["new-window -n" ++ quote o.title ++ "-c" ++ quote cwd] +++ render cwd o.layout

instance layoutCommand :: TmuxCommand TmuxLayout where
  render _ (Full command) = ["send-keys" ++ quote command ++ "\"Enter\""]
  render cwd (HSplit left right) =
    ["split-window -h -c" ++ quote cwd, "select-pane -L"] +++
    render cwd left +++
    ["select-pane -R"] +++
    render cwd right
  render cwd (VSplit top bottom) =
    ["split-window -v -c" ++ quote cwd, "select-pane -U"] +++
    render cwd top +++
    ["select-pane -D"] +++
    render cwd bottom

toCommand :: String -> TmuxConfig -> String
toCommand cwd config = "tmux " ++ chainCommands (render cwd config)

-- JSON parsing

parseConfig o = TmuxConfig { title: o.title, windows: map parseWindow o.windows }
parseWindow o = WindowConfig { title: o.title, layout: parseLayout o.layout }

foreign import data JSON :: *
foreign import parseLayout "function parseLayout(json) {\
                            \  if (!json) { return _ps.Data_Tmux.Full(''); }\
                            \  if (typeof json === 'string') { return _ps.Data_Tmux.Full(json); }\
                            \  if (typeof json.top !== 'undefined' || typeof json.bottom !== 'undefined') {\
                            \    return _ps.Data_Tmux.VSplit(parseLayout(json.top))(parseLayout(json.bottom));\
                            \  }\
                            \  return _ps.Data_Tmux.HSplit(parseLayout(json.left))(parseLayout(json.right));\
                            \}" :: JSON -> TmuxLayout

-- Helper functions

chainCommands :: [String] -> String
chainCommands = intercalate " \\; "

intercalate :: String -> [String] -> String
intercalate _ [] = ""
intercalate _ [x] = x
intercalate i [x,y] = x ++ i ++ y
intercalate i (x:y:xs) = x ++ i ++ y ++ i ++ intercalate i xs

quote :: String -> String
quote s = " \"" ++ s ++ "\" "

(+++) :: forall a. [a] -> [a] -> [a]
(+++) [] y = y
(+++) (x:xs) ys = x : (+++) xs ys

