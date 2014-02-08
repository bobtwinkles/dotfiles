{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses #-}
import XMonad
import XMonad.Core
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.WorkspaceCompare
import XMonad.Util.Loggers
import XMonad.Util.NamedWindows (getName)
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Layout.SimplestFloat
import XMonad.Layout.OneBig
import XMonad.Layout.Simplest
import System.IO
import Data.List
import Data.Maybe
import Data.Traversable (traverse, fmapDefault)
import qualified XMonad.StackSet as W
import Control.Monad.State.Lazy

-- Starts an xmobar on a specified screen
xmobar screen config = spawnPipe . intercalate " " $ options
    where options = [ "xmobar"
                     , "-x"
                     , show screen
                     , show config
                     ]

-- Autofloat some special windows, put things in their place
myManageHook = composeAll
    [ title =? "Fireworks"          --> doFloat
    , title =? "Isomtric Renderer"  --> doFloat
    , title =? "Horse Race"         --> doFloat
    --, title =? "Minecraft"          --> doFloat
    --, title =? "Minecraft Launcher" --> doFloat
    --, title =? "Tekkit"             --> doFloat
    , title =? "tile"               --> doFloat
    , title =? "Krafty Kat"         --> doFloat
    , title =? "W.o.T. Client"      --> doFloat
    , title =? "Phys Canvas"        --> doFloat
    , title =? "Eclipse"            --> doFloat
    , title =? "testing"            --> doFloat
    , title =? "xmessage"           --> doFloat
    , title =? "Defend Rome"        --> doFullFloat
    , title =? "Team Fortress 2 - OpenGL" --> doFullFloat
    , title =? "Nightly"            --> doShift "3"
    , className =? "orage"          --> doFloat
    , className =? "Steam"          --> doShift "9"
    , className =? "Skype"          --> doShift "8"
    , className =? "sun-awt-X11-XFramePeer" --> doIgnore
    , isFullscreen                  --> doFullFloat
    , manageDocks
    ]

-------------------------------------------------------------------------------
------------------------Custom layout class------------------------------------
-------------------------------------------------------------------------------

-- Takes the current index, total number of rectangles, and the current
-- rectangle. Returns a list of rectangles
-- Thanks to sjdrodge for his help with making a less derpy implementation

bspSplit :: Int -> Int -> Rectangle -> [Rectangle]
bspSplit c n rec
    | c == n - 1 = [rec]
    | side <  2  = x : next y
    | otherwise  = y : next x
        where
         side = c `rem` 4
         next = bspSplit (c + 1) n
         (x:y:ys) = (if even side then splitHorizontally else splitVertically) 2 rec

data BinarySplit a = BinarySplit deriving ( Read, Show )
instance LayoutClass BinarySplit a where
    pureLayout (BinarySplit) rectangle stack = zip windows rectangles
     where
        windows = W.integrate stack
        numWindows = length windows
        rectangles = bspSplit 0 numWindows rectangle

myLayoutHook = noBorders $ avoidStrutsOn [D] $ (BinarySplit ||| Full ||| simplestFloat ||| tiled ||| Mirror tiled ||| OneBig (3/4) (3/4)) where
               tiled = Tall nmaster delta ratio
               nmaster = 1
               delta = 3/100
               ratio = 1/2

-- XMobar output stuff
myTitleLength = 30

formatTitle :: Int -> String -> String
formatTitle maxLength t
    | len <  maxLength = formatTitle maxLength ( t ++ " " )
    | len == maxLength = t
    | len >  maxLength = shorten maxLength t
    where len = length t;

formatTitles :: Int -> [String] -> String
formatTitles maxLength ( x : xs ) = "[" ++ (formatTitle maxLength x) ++ "]" ++ formatTitles maxLength xs
formatTitles maxLength _          = ""

listWindowTitles :: [Window] -> X [String]
listWindowTitles xs = traverse (fmap show . getName) xs

logTitles :: X ( Maybe String )
logTitles = withWindowSet $ fmap Just . (\x ->
          let 
            focused       = W.peek x
            allWindows    = W.index x
            windows       = case focused of
                                 Nothing -> []
                                 Just x  -> filter (\y -> not ( Just y == focused ) ) allWindows
            numWindows    = length windows
            titles        = listWindowTitles windows
            desiredLength = min (quot 50 numWindows) myTitleLength
          in fmap (formatTitles desiredLength) titles)

-- And the main config
main = do 
    xmproc <- Main.xmobar 0 ".xmonad/xmobarrc"
    xmonad $ ewmh defaultConfig
        { terminal      = "terminator"
        , manageHook = myManageHook <+> manageHook defaultConfig
        , handleEventHook = docksEventHook
        , layoutHook = myLayoutHook 
        , startupHook = ewmhDesktopsStartup >> setWMName "LG3D"
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = wrap "[" "]" . xmobarColor "#859900" "" . formatTitle myTitleLength
                        , ppSep = "|"
                        , ppHidden = xmobarColor "#b58900" ""
                        , ppCurrent = wrap "[" "]" . xmobarColor "#dc322f" "" 
                        , ppHiddenNoWindows = xmobarColor "#93a1a1" ""
                        , ppExtras = [ logTitles ]
                        }
        , borderWidth = 2
        , normalBorderColor  = "#268bd2"
        , focusedBorderColor = "#dc322f"
        } `additionalKeys`
        [ ((mod4Mask, xK_z), spawn "xscreensaver-command -lock")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -a")
--        , ((controlMask .|. shiftMask, xK_grave), spawn "wmctrl -a $(wmctrl -l | cut -c 29-79 | awk '{print tolower($0)}'| dmenu)")
        , ((mod1Mask, xK_s), sendMessage $ ToggleStrut R)
        , ((mod1Mask .|. shiftMask, xK_s), sendMessage ToggleStruts)
        , ((0, 0x1008ff13), spawn "amixer -q set Master 5000+") --XF86AudioRaiseVolume
        , ((0, 0x1008ff11), spawn "amixer -q set Master 5000-") --XF86AudioLowerVolume
        , ((0, 0x1008ff12), spawn "amixer -q set Master toggle") --XF86AudioMute
        ]
