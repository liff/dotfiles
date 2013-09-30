import Data.Monoid
import Data.Map (Map)
import qualified Data.Map as Map
import Control.Monad (liftM)

import XMonad
import qualified XMonad.StackSet as S
import XMonad.Config.Desktop
import XMonad.Config.Gnome

--import XMonad.Hooks.ICCCMFocus
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

import XMonad.Util.WindowPropertiesRE



role = stringProperty "WM_WINDOW_ROLE"


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
unityPanelProperties     = ClassName "Unity-2d-panel"
unityShellProperties     = ClassName "Unity-2d-shell"
selectUnityPanel         = propertyToQuery unityPanelProperties
selectUnityShell         = propertyToQuery unityShellProperties

ircProperties            = terminalProperties `And` Title "IRC"
selectIrc                = propertyToQuery ircProperties

mailProperties           = ClassName "Thunderbird" `Or` ClassName "evolution" `Or` ClassName "Evolution"
selectMail               = propertyToQuery mailProperties
selectMessageCompose     = selectMail <&&> (role =? "Msgcompose" <||> role ~? "EMsg")

imProperties             = ClassName "Empathy" `Or` ClassName "Skype" `Or` ClassName "Pidgin"
contactsProperties       = imProperties `And` (Role "contact_list" `Or` Role "buddy_list")
chatProperties           = imProperties `And` (Role "chat" `Or` Role "ConversationsWindow" `Or` Role "conversation")
selectIm                 = propertyToQuery imProperties
selectContacts           = propertyToQuery contactsProperties
selectChat               = propertyToQuery chatProperties

socialNetworksProperties = ClassName "Gwibber" `Or` Title "Friends"
browserProperties        = ClassName "Google-chrome" `Or` ClassName "Chromium-browser" `Or` ClassName "Firefox" `Or` ClassName "Evince"
editorProperties         = ClassName "Sublime_text" `Or` ClassName "jetbrains-idea-ce" `Or` ClassName "jetbrains-rubymine" `Or` ClassName "Eclipse"
selectSocialNetworks     = propertyToQuery socialNetworksProperties
selectBrowser            = propertyToQuery browserProperties
selectEditor             = propertyToQuery editorProperties

terminalProperties       = ClassName "Gnome-terminal"
codeTerminalProperties   = terminalProperties `And` Title "Code"
otherTerminalProperties  = terminalProperties `And` (Not ircProperties) `And` (Not codeTerminalProperties)
selectTerminal           = propertyToQuery terminalProperties
selectCodeTerminal       = propertyToQuery codeTerminalProperties
selectOtherTerminal      = propertyToQuery otherTerminalProperties

ircOrMailProperties          = ircProperties `Or` mailProperties
imOrSocialNetworksProperties = imProperties `Or` socialNetworksProperties
selectIrcOrMail              = propertyToQuery ircOrMailProperties
selectImOrSocialNetworks     = propertyToQuery imOrSocialNetworksProperties

selectSpotify            = className =? "Spotify"
selectSonata             = className =? "Sonata"

selectSocial             = selectIrcOrMail <||> selectImOrSocialNetworks
selectWeb                = selectBrowser
selectCode               = selectEditor <||> selectCodeTerminal
selectTerminals          = selectOtherTerminal
selectMedia              = selectSpotify <||> selectSonata


-- Layouts
socialLayout = desktopLayoutModifiers $
  combineTwoP (TwoPane (1/48) (16/24)) ircAndMail imAndSocials ircOrMailProperties
  where
    imAndSocials = drawer `onBottom` (TwoPane (1/100) (1/2))
    drawer       = simpleDrawer (1/24) (6/24) chatProperties
    ircAndMail   = Mirror (TwoPane (1/24) (5/24))

webLayout = desktopLayoutModifiers $ TwoPane (1/12) (7/12)

codeLayout = desktopLayoutModifiers $ drawer `onBottom` (Tall 1 (3/100) (1/2))
  where
    drawer = simpleDrawer (1/24) (6/24) codeTerminalProperties

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
    selectUnityPanel --> doIgnore,
    selectUnityShell --> doFloat
  ]

workspacesManagement :: ManageHook
workspacesManagement = composeAll [
    selectSocial    --> doShift socialWorkspace,
    selectWeb       --> doShift webWorkspace,
    selectCode      --> doShift codeWorkspace,
    selectTerminals --> doShift terminalsWorkspace,
    selectMedia     --> doShift mediaWorkspace
  ]

myManageHook :: ManageHook
myManageHook = defaultManageHook <+> unityManagement <+> workspacesManagement <+> composeAll [
    isFullscreen         --> doFullFloat,
    selectMessageCompose --> doFloat
  ]


-- Other hooks
hello :: X ()
hello = liftIO $ do
  return ()

myLogHook :: X ()
--myLogHook = defaultLogHook <+> hello <+> takeTopFocus
myLogHook = defaultLogHook
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
