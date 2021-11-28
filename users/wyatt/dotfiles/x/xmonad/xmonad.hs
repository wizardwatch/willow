import XMonad
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import XMonad.Hooks.ManageDocks
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Tabbed as Tabbed
import XMonad.Layout.Master as Master

import XMonad.Layout.Spacing (Border (Border), Spacing, spacingRaw)
import XMonad.Layout.LayoutModifier (ModifiedLayout)


backgroundColor    = "#282a36"
currentLineColor   = "#44475a"
selectionColor     = "#44475a"
foregroundColor    = "#f8f8f2"
commentColor       = "#6272a4"
cyanColor          = "#8be9fd"
greenColor         = "#50fa7b"
orangeColor        = "#ffb86c"
pinkColor          = "#ff79c6"
purpleColor        = "#bd93f9"
redColor           = "#ff5555"
yellowColor        = "#f1fa8c"

myNormalBorderColor  = backgroundColor
myFocusedBorderColor = currentLineColor

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border 0 i 0 i) True (Border i 0 i 0) True

masterAndTabs = Master.mastered (1/100) (1/2) $ Tabbed.tabbedRight Tabbed.shrinkText theme
 where
  theme = def { {- Tabbed.fontName            = "xft:Isoevka:size=16" 
              ,-} Tabbed.activeBorderColor   = selectionColor
              , Tabbed.inactiveBorderColor = backgroundColor
              } 

layouts = avoidStruts $ tiled ||| Full ||| masterAndTabs
	where
		tiled 	= Tall nmaster delta ratio
		nmaster = 1
		ratio 	= 1/2
		delta 	= 3/100

main :: IO ()
main = xmonad
	. docks
		$ def
		{ terminal 		= "alacritty"
		, layoutHook 		= layouts
		, borderWidth 		= 3
		, normalBorderColor 	= backgroundColor
		, focusedBorderColor 	= purpleColor
		}

