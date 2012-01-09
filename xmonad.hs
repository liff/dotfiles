import qualified Data.Map as Map

import XMonad
import qualified XMonad.StackSet as S
import XMonad.Config.Desktop

import XMonad.Util.WindowProperties

import XMonad.Layout.PerWorkspace
import XMonad.Layout.TwoPane
import XMonad.Layout.ComboP
import XMonad.Layout.Drawer

import XMonad.Prompt
import XMonad.Prompt.Window


baseConfig = desktopConfig

defaultLayout = layoutHook baseConfig
defaultKeys = keys defaultConfig
defaultManageHook = manageHook baseConfig

socialWorkspace = "social"
webWorkspace = "web"
codeWorkspace = "code"
terminalsWorkspace = "terminals"

myWorkspaces = [socialWorkspace, webWorkspace, codeWorkspace, terminalsWorkspace] ++ map show [5..9]

selectIrc            = Title "irc"
selectMail           = Title "mail"
selectIm             = Title "empathy"
selectSocialNetworks = Title "gwibber"
selectChat           = Title "chat"
selectBrowser        = Title "chrome" `Or` Title "firefox"
selectMpc            = Title "sonata"

selectIrcOrMail          = selectIrc `Or` selectMail
selectImOrSocialNetworks = selectIm `Or` selectSocialNetworks
selectSocial             = selectIrcOrMail `Or` selectImOrSocialNetworks `Or` selectChat

socialLayout = combineTwoP (TwoPane (1/48) (16/24)) ircAndMail imAndSocials selectIrcOrMail
  where
    imAndSocials = drawer `onBottom` (TwoPane (1/100) (1/2))
    drawer       = simpleDrawer (1/24) (6/24) selectChat
    ircAndMail   = Mirror (TwoPane (1/24) (5/24))

webLayout = TwoPane (1/12) (7/12)

terminalsLayout = defaultLayout

myLayout = onWorkspace socialWorkspace    socialLayout
         $ onWorkspace webWorkspace       webLayout
         $ onWorkspace terminalsWorkspace terminalsLayout
         $ defaultLayout

myManageHook = defaultManageHook <+> composeAll [
    propertyToQuery selectIrc     --> (doF S.shiftMaster),
    propertyToQuery selectIm      --> (doF S.shiftMaster),
    propertyToQuery selectMpc     --> (doShift socialWorkspace <+> doFloat),
    propertyToQuery selectSocial  --> (doShift socialWorkspace),
    propertyToQuery selectBrowser --> (doShift webWorkspace)
  ]

addedKeys conf@(XConfig {XMonad.modMask = modm}) = Map.fromList [
    ((modm, xK_g), windowPromptGoto defaultXPConfig)
  ]

myKeys layout = addedKeys layout `Map.union` defaultKeys layout

myStartup = do
  spawn "xterm -title irc -bg black -fg white"
  spawn "xterm -title mail -bg yellow"
  spawn "xterm -title gwibber -bg blue"
  spawn "xterm -title empathy -bg green"
  spawn "xterm -title chat -bg lightgreen"
  spawn "xterm -title sonata -bg navy"
  spawn "xterm -title chrome -bg lightblue"
  spawn "xterm -title firefox -bg red -fg white"

myConfig = baseConfig {
  modMask     = mod3Mask,
  keys        = myKeys,
  workspaces  = myWorkspaces,
  layoutHook  = myLayout,
  manageHook  = myManageHook,
  startupHook = myStartup
}

main = xmonad myConfig

