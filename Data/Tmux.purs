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
  render :: a -> [String]

instance configCommand :: TmuxCommand TmuxConfig where
  render (TmuxConfig o) =
    ["new-session -s" ++ quote o.title] +++
    concatMap o.windows render +++
    ["select-window -t 0", "kill-window", "select-window -t 1"]

instance windowCommand :: TmuxCommand WindowConfig where
  render (WindowConfig o) =
    ["new-window -n" ++ quote o.title] +++ render o.layout

instance layoutCommand :: TmuxCommand TmuxLayout where
  render (Full command) = ["send-keys" ++ quote command ++ "\"Enter\""]
  render (HSplit left right) =
    ["split-window -h", "select-pane -L"] +++
    render left +++
    ["select-pane -R"] +++
    render right
  render (VSplit top bottom) =
    ["split-window -v", "select-pane -U"] +++
    render top +++
    ["select-pane -D"] +++
    render bottom

toCommand :: TmuxConfig -> String
toCommand config = "tmux " ++ chainCommands (render config)

-- JSON parsing

parseConfig o = TmuxConfig { title: o.title, windows: map parseWindow o.windows }
parseWindow o = WindowConfig { title: o.title, layout: parseLayout o.layout }

foreign import data JSON :: *
foreign import parseLayout "function parseLayout(json) {\
                            \  if (!json) { return _ps.Data_Tmux.Full(''); }\
                            \  if (typeof json === 'string') { return _ps.Data_Tmux.Full(json); }\
                            \  if (json.top || json.bottom) {\
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

