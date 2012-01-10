import qualified Data.Map as Map

import XMonad
import qualified XMonad.StackSet as S

import XMonad.Util.WindowPropertiesRE

import XMonad.Config.Desktop
import XMonad.Config.Gnome

import XMonad.Hooks.Minimize
import XMonad.Hooks.SetWMName

import XMonad.Layout.PerWorkspace
import XMonad.Layout.TwoPane
import XMonad.Layout.ComboP
import XMonad.Layout.Drawer
import XMonad.Layout.Minimize

import XMonad.Prompt
import XMonad.Prompt.Window


baseConfig = gnomeConfig

defaultLayout = layoutHook baseConfig
defaultKeys = keys baseConfig
defaultManageHook = manageHook baseConfig
defaultHandleEventHook = handleEventHook baseConfig

socialWorkspace = "social"
webWorkspace = "web"
codeWorkspace = "code"
terminalsWorkspace = "terminals"
otherWorkspace = "other"

myWorkspaces = [socialWorkspace, webWorkspace, codeWorkspace, terminalsWorkspace, otherWorkspace] ++ map show [6..9]

selectUnityPanel     = ClassName "Unity-2d-panel"
selectUnityLauncher  = ClassName "Unity-2d-launcher"

selectIrc            = selectTerminal `And` Title "IRC"

selectMail           = ClassName "Thunderbird"
selectMessageCompose = selectMail `And` Role "Msgcompose"

selectIm             = ClassName "Empathy"
selectContacts       = selectIm `And` Role "contact_list"
selectChat           = selectIm `And` Role "chat"

selectSocialNetworks = ClassName "Gwibber"
selectBrowser        = ClassName "Chromium-browser" `Or` ClassName "Firefox"
selectEditor         = ClassName "Sublime_text" `Or` ClassName "jetbrains-idea-ce" `Or` Title "JetBrains RubyMine 3.2.4"

selectTerminal       = ClassName "Gnome-terminal"
selectCodeTerminal   = selectTerminal `And` Title "Code"
selectOtherTerminal  = selectTerminal `And` Not selectIrc `And` Not selectCodeTerminal

selectIrcOrMail          = selectIrc `Or` selectMail
selectImOrSocialNetworks = selectIm `Or` selectSocialNetworks

selectSocial    = selectIrcOrMail `Or` selectImOrSocialNetworks
selectWeb       = selectBrowser
selectCode      = selectEditor `Or` selectCodeTerminal
selectTerminals = selectOtherTerminal

socialLayout = desktopLayoutModifiers $ minimize $ combineTwoP (TwoPane (1/48) (16/24)) ircAndMail imAndSocials selectIrcOrMail
  where
    imAndSocials = drawer `onBottom` (TwoPane (1/100) (1/2))
    drawer       = simpleDrawer (1/24) (6/24) selectChat
    ircAndMail   = Mirror (TwoPane (1/24) (5/24))

webLayout = desktopLayoutModifiers $ TwoPane (1/12) (7/12)

codeLayout = desktopLayoutModifiers $ drawer `onBottom` (Tall 1 (3/100) (1/2))
  where
    drawer = simpleDrawer (1/24) (6/24) selectCodeTerminal

terminalsLayout = defaultLayout

myLayout = onWorkspace socialWorkspace    socialLayout
         $ onWorkspace webWorkspace       webLayout
         $ onWorkspace codeWorkspace      codeLayout
         $ onWorkspace terminalsWorkspace terminalsLayout
         $ defaultLayout

unityManageHook = composeAll [
    propertyToQuery selectUnityPanel    --> doIgnore,
    propertyToQuery selectUnityLauncher --> doFloat
  ]

workspacesManagement = composeAll [
    propertyToQuery selectSocial    --> (doShift socialWorkspace),
    propertyToQuery selectWeb       --> (doShift webWorkspace),
    propertyToQuery selectCode      --> (doShift codeWorkspace),
    propertyToQuery selectTerminals --> (doShift terminalsWorkspace)
  ]

myManageHook = defaultManageHook <+> unityManageHook <+> workspacesManagement <+> composeAll [
    propertyToQuery selectMessageCompose --> doFloat
  ]

myHandleEventHook = minimizeEventHook

addedKeys conf@(XConfig {XMonad.modMask = modm}) = Map.fromList [
    ((modm,               xK_g), windowPromptGoto defaultXPConfig),
    ((modm,               xK_o), gnomeRun),
    ((modm,               xK_i), withFocused minimizeWindow),
    ((modm .|. shiftMask, xK_i), sendMessage RestoreNextMinimizedWin)
  ]

myKeys layout = addedKeys layout `Map.union` defaultKeys layout

myStartup = do
  setWMName "LG3D"
  return ()


myConfig = baseConfig {
  modMask         = mod4Mask,
  keys            = myKeys,
  workspaces      = myWorkspaces,
  layoutHook      = myLayout,
  manageHook      = myManageHook,
  startupHook     = myStartup,
  handleEventHook = myHandleEventHook
}

main = xmonad myConfig

