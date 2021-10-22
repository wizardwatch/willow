import XMonad
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import XMonad.Hooks.ManageDocks
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Tabbed as Tabbed
import XMonad.Layout.Master as Master

import XMonad.Layout.Spacing (Border (Border), Spacing, spacingRaw)
import XMonad.Layout.LayoutModifier (ModifiedLayout)

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border 0 i 0 i) True (Border i 0 i 0) True

masterAndTabs = Master.mastered (1/100) (1/2) $ Tabbed.tabbed Tabbed.shrinkText theme
 where
  theme = def { Tabbed.fontName            = "xft:FreeSans:size=11"
              , Tabbed.activeBorderColor   = "#81A1C1"
              , Tabbed.inactiveBorderColor = "#3B4252"
              }

layouts = avoidStruts $ mySpacing 5 $ tiled ||| Full ||| masterAndTabs
	where
		tiled 	= Tall nmaster delta ratio
		nmaster = 1
		ratio 	= 1/2
		delta 	= 3/100

main :: IO ()
main = xmonad
	. docks
		$ def
		{ terminal = "alacritty"
		, layoutHook = layouts
		}

