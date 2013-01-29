import Data.Monoid
import Data.Map (Map)
import qualified Data.Map as Map

import XMonad
import qualified XMonad.StackSet as S

import XMonad.Util.WindowPropertiesRE

import XMonad.Config.Desktop
import XMonad.Config.Gnome

import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops

import XMonad.Layout.PerWorkspace
import XMonad.Layout.TwoPane
import XMonad.Layout.ComboP
import XMonad.Layout.Drawer
import XMonad.Layout.NoBorders

import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Prompt.RunOrRaise


-- Use GNOME configuration as base
baseConfig = ewmh gnomeConfig

defaultLayout          = layoutHook baseConfig
defaultKeys            = keys baseConfig
defaultManageHook      = manageHook baseConfig
defaultLogHook         = logHook baseConfig
defaultHandleEventHook = handleEventHook baseConfig


-- Workspaces
socialWorkspace = "social"
webWorkspace = "web"
codeWorkspace = "code"
terminalsWorkspace = "terminals"
mediaWorkspace = "media"
otherWorkspace = "other"

myWorkspaces :: [String]
myWorkspaces = [socialWorkspace, webWorkspace, codeWorkspace, terminalsWorkspace, mediaWorkspace, otherWorkspace] ++ map show [7..9]


-- Selectors for applications and windows
selectUnityPanel, selectUnityShell :: Property
selectUnityPanel     = ClassName "Unity-2d-panel"
selectUnityShell     = ClassName "Unity-2d-shell"

selectIrc :: Property
selectIrc            = selectTerminal `And` Title "IRC"

selectMail, selectMessageCompose :: Property
selectMail           = ClassName "Thunderbird"
selectMessageCompose = selectMail `And` Role "Msgcompose"

selectIm, selectContacts, selectChat :: Property
selectIm             = ClassName "Empathy" `Or` ClassName "Skype"
selectContacts       = selectIm `And` Role "contact_list"
selectChat           = selectIm `And` (Role "chat" `Or` Role "ConversationsWindow")

selectSocialNetworks, selectBrowser, selectEditor :: Property
selectSocialNetworks = ClassName "Gwibber"
selectBrowser        = ClassName "Google-chrome" `Or` ClassName "Chromium-browser" `Or` ClassName "Firefox" `Or` ClassName "Evince"
selectEditor         = ClassName "Sublime_text" `Or` ClassName "jetbrains-idea-ce" `Or` ClassName "jetbrains-rubymine" `Or` ClassName "Eclipse"

selectTerminal, selectCodeTerminal, selectOtherTerminal :: Property
selectTerminal       = ClassName "Gnome-terminal"
selectCodeTerminal   = selectTerminal `And` Title "Code"
selectOtherTerminal  = selectTerminal `And` Not selectIrc `And` Not selectCodeTerminal

selectIrcOrMail, selectImOrSocialNetworks :: Property
selectIrcOrMail          = selectIrc `Or` selectMail
selectImOrSocialNetworks = selectIm `Or` selectSocialNetworks

selectSpotify, selectSonata :: Property
selectSpotify = ClassName "Spotify"
selectSonata = ClassName "Sonata"

selectSocial, selectWeb, selectCode, selectTerminals :: Property
selectSocial    = selectIrcOrMail `Or` selectImOrSocialNetworks
selectWeb       = selectBrowser
selectCode      = selectEditor `Or` selectCodeTerminal
selectTerminals = selectOtherTerminal
selectMedia     = selectSpotify `Or` selectSonata


-- Layouts
socialLayout = desktopLayoutModifiers $ combineTwoP (TwoPane (1/48) (16/24)) ircAndMail imAndSocials selectIrcOrMail
  where
    imAndSocials = drawer `onBottom` (TwoPane (1/100) (1/2))
    drawer       = simpleDrawer (1/24) (6/24) selectChat
    ircAndMail   = Mirror (TwoPane (1/24) (5/24))

webLayout = desktopLayoutModifiers $ TwoPane (1/12) (7/12)

codeLayout = desktopLayoutModifiers $ drawer `onBottom` (Tall 1 (3/100) (1/2))
  where
    drawer = simpleDrawer (1/24) (6/24) selectCodeTerminal

terminalsLayout = defaultLayout

mediaLayout = defaultLayout

myLayout = smartBorders
         $ onWorkspace socialWorkspace    socialLayout
         $ onWorkspace webWorkspace       webLayout
         $ onWorkspace codeWorkspace      codeLayout
         $ onWorkspace terminalsWorkspace terminalsLayout
         $ onWorkspace mediaWorkspace     mediaLayout
         $ defaultLayout


-- Management hooks
unityManagement :: ManageHook
unityManagement = composeAll [
    propertyToQuery selectUnityPanel --> doIgnore,
    propertyToQuery selectUnityShell --> doFloat
  ]

workspacesManagement :: ManageHook
workspacesManagement = composeAll [
    propertyToQuery selectSocial    --> doShift socialWorkspace,
    propertyToQuery selectWeb       --> doShift webWorkspace,
    propertyToQuery selectCode      --> doShift codeWorkspace,
    propertyToQuery selectTerminals --> doShift terminalsWorkspace,
    propertyToQuery selectMedia     --> doShift mediaWorkspace
  ]

myManageHook :: ManageHook
myManageHook = defaultManageHook <+> unityManagement <+> workspacesManagement <+> composeAll [
    isFullscreen                         --> doFullFloat,
    propertyToQuery selectMessageCompose --> doFloat
  ]


-- Other hooks
hello :: X ()
hello = liftIO $ do
  return ()

myLogHook :: X ()
myLogHook = defaultLogHook <+> hello <+> takeTopFocus
-- myLogHook = takeTopFocus


myHandleEventHook :: Event -> X All
myHandleEventHook event = do
  return (All True)


-- Key bindings
addedKeys :: XConfig t -> Map (KeyMask, KeySym) (X ())
addedKeys conf@(XConfig {XMonad.modMask = modm}) = Map.fromList [
    ((modm,               xK_g), windowPromptGoto defaultXPConfig),
    ((modm,               xK_o), runOrRaisePrompt defaultXPConfig)
  ]

myKeys :: XConfig Layout -> Map (KeyMask, KeySym) (X ())
myKeys layout = addedKeys layout `Map.union` defaultKeys layout


-- Rest
myStartup :: X ()
myStartup = do
  setWMName "LG3D"
  return ()


myConfig = baseConfig {
  modMask         = mod4Mask,
  keys            = myKeys,
  workspaces      = myWorkspaces,
  layoutHook      = myLayout,
  manageHook      = myManageHook,
  logHook         = myLogHook,
  startupHook     = myStartup,
  handleEventHook = myHandleEventHook
}


main :: IO ()
main = xmonad myConfig
