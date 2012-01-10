import qualified Data.Map as Map

import XMonad
import qualified XMonad.StackSet as S
import XMonad.Config.Desktop

import XMonad.Util.WindowProperties

import XMonad.Hooks.Minimize

import XMonad.Layout.PerWorkspace
import XMonad.Layout.TwoPane
import XMonad.Layout.ComboP
import XMonad.Layout.Drawer
import XMonad.Layout.Minimize

import XMonad.Prompt
import XMonad.Prompt.Window


baseConfig = desktopConfig

defaultLayout = layoutHook baseConfig
defaultKeys = keys defaultConfig
defaultManageHook = manageHook baseConfig
defaultHandleEventHook = handleEventHook baseConfig

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
selectEditor         = Title "sublime" `Or` Title "idea" `Or` Title "rubymine"
selectCodeTerminal   = Title "code"
selectOtherTerminal  = ClassName "XTerm" `And` Not selectIrc `And` Not selectCodeTerminal

selectIrcOrMail          = selectIrc `Or` selectMail
selectImOrSocialNetworks = selectIm `Or` selectSocialNetworks

selectSocial    = selectIrcOrMail `Or` selectImOrSocialNetworks `Or` selectChat
selectWeb       = selectBrowser
selectCode      = selectEditor `Or` selectCodeTerminal
selectTerminals = selectOtherTerminal

socialLayout = minimize $ combineTwoP (TwoPane (1/48) (16/24)) ircAndMail imAndSocials selectIrcOrMail
  where
    imAndSocials = drawer `onBottom` (TwoPane (1/100) (1/2))
    drawer       = simpleDrawer (1/24) (6/24) selectChat
    ircAndMail   = Mirror (TwoPane (1/24) (5/24))

webLayout = TwoPane (1/12) (7/12)

codeLayout = drawer `onBottom` (Tall 1 (3/100) (1/2))
  where
    drawer = simpleDrawer (1/24) (6/24) selectCodeTerminal

terminalsLayout = defaultLayout

myLayout = onWorkspace socialWorkspace    socialLayout
         $ onWorkspace webWorkspace       webLayout
         $ onWorkspace codeWorkspace      codeLayout
         $ onWorkspace terminalsWorkspace terminalsLayout
         $ defaultLayout

myManageHook = defaultManageHook <+> composeAll [
    propertyToQuery selectMpc       --> (doShift socialWorkspace <+> doFloat),
    propertyToQuery selectSocial    --> (doShift socialWorkspace),
    propertyToQuery selectWeb       --> (doShift webWorkspace),
    propertyToQuery selectCode      --> (doShift codeWorkspace),
    propertyToQuery selectTerminals --> (doShift terminalsWorkspace)
  ]

myHandleEventHook = minimizeEventHook

addedKeys conf@(XConfig {XMonad.modMask = modm}) = Map.fromList [
    ((modm,               xK_g), windowPromptGoto defaultXPConfig),
    ((modm,               xK_i), withFocused minimizeWindow),
    ((modm .|. shiftMask, xK_i), sendMessage RestoreNextMinimizedWin)
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
  spawn "xterm -title code -bg black -fg yellow"
  spawn "xterm -title sublime"
  spawn "xterm"
  spawn "xterm"
  spawn "xterm"

myConfig = baseConfig {
  modMask         = mod3Mask,
  keys            = myKeys,
  workspaces      = myWorkspaces,
  layoutHook      = myLayout,
  manageHook      = myManageHook,
  startupHook     = myStartup,
  handleEventHook = myHandleEventHook
}

main = xmonad myConfig

