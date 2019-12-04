-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIGlobalEventDispatcher.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton GUIObject that dispatches events that originate from the engine in some way
--    (eg OnResolutionChanged).  It also contains properties with information about the client
--    (eg whether or not the NS2 window is focused).
--
--  Properties
--      WindowFocused       Whether or not the NS2 window is in focus.  Do not set, only get.
--      SteamOverlay        Whether or not the steam overlay is visible (eg player not in-game).
--      MousePosition       The current mouse position.
--      CapsLock            Whether or not caps lock is enabled.
--
--  Events
--      OnResolutionChanged         Fires whenever the user's screen resolution setting changes.
--          newX, newY, oldX, oldY      The new and old screen resolutions.
--
--      OnDisplayChanged            Fires whenever the user changes which monitor the game window is
--                                  inside (eg by dragging the window).
--          newDisplayIndex, oldDisplayIndex
--
--      OnOptionsChanged            Fires whenever an option changes outside the game.  Currently
--                                  the only trigger for this is if the user changes fullscreen mode
--                                  (eg by using alt+enter).
--
--      OnSoundDeviceListChanged    Fires whenever the list of sound devices changes.
--
--      OnSteamFriendsUpdated       Fires whenever the steam friends list is updated.
--          friendsTbl              List of friend data.  See API docs for details on the table
--                                  format.
--
--      OnAvatarDownloaded          Fires when a player avatar has been downloaded and is ready to
--                                  be used as a texture.
--          textureName             The name of the texture the avatar image is bound to.
--
--      OnGUIObjectClicked          Fires whenever any GUIObject is clicked.
--          obj                     The object that was clicked on.
--
--      OnAchievementSet            Fires whenever an achievement is set (that wasn't previously
--                                  set).
--
--      OnAchievementCleared        Fires whenever an achievement is cleared (that was previously
--                                  set).
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")

---@class GUIGlobalEventDispatcher : GUIObject
class "GUIGlobalEventDispatcher" (GUIObject)

GUIGlobalEventDispatcher:AddClassProperty("WindowFocused", true) -- assume it is focused at start.
GUIGlobalEventDispatcher:AddClassProperty("SteamOverlay", false) -- assume it is not active at start.
GUIGlobalEventDispatcher:AddClassProperty("MousePosition", Vector(0, 0, 0))
GUIGlobalEventDispatcher:AddClassProperty("CapsLock", false)

local globalEventDispatcher
function GetGlobalEventDispatcher()
    if not globalEventDispatcher then
        globalEventDispatcher = CreateGUIObject("globalEventDispatcher", GUIGlobalEventDispatcher)
    end
    return globalEventDispatcher
end

function GUIGlobalEventDispatcher:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self:SetUpdates(true)
    
end

Event.Hook("LoadComplete", function()
    GetGlobalEventDispatcher():SetCapsLock(Client.GetCapsLockEnabled())
end)

function GUIGlobalEventDispatcher:OnUpdate(deltaTime, now)

    self:SetWindowFocused(Client.GetIsWindowFocused())
    self:SetSteamOverlay(Client.GetIsSteamOverlayActive())
    
end

Event.Hook("ResolutionChanged", function(oldX, oldY, newX, newY)
    GetGlobalEventDispatcher():FireEvent("OnResolutionChanged", newX, newY, oldX, oldY)
end)

Event.Hook("DisplayChanged", function(oldDisplay, newDisplay)
    GetGlobalEventDispatcher():FireEvent("OnDisplayChanged", newDisplay, oldDisplay)
end)

-- Currently the only thing that triggers this event is toggling fullscreen on/off (eg using alt+enter).
Event.Hook("OptionsChanged", function()
    GetGlobalEventDispatcher():FireEvent("OnOptionsChanged")
end)

Event.Hook("SoundDeviceListChanged", function()
    GetGlobalEventDispatcher():FireEvent("OnSoundDeviceListChanged")
end)

Event.Hook("OnSteamFriendsUpdated", function(friendsTbl)
    GetGlobalEventDispatcher():FireEvent("OnSteamFriendsUpdated", friendsTbl)
end)

Event.Hook("AvatarDownloaded", function(textureName)
    GetGlobalEventDispatcher():FireEvent("OnAvatarDownloaded", textureName)
end)

Event.Hook("AvatarDeactivated", function(textureName)
    GetGlobalEventDispatcher():FireEvent("OnAvatarDeactivated", textureName)
end)

function SendOnGUIObjectClicked(obj)
    GetGlobalEventDispatcher():FireEvent("OnGUIObjectClicked", obj)
end

Event.Hook("SendCapsLockEvent", function(capsLockEnabled)
    GetGlobalEventDispatcher():SetCapsLock(capsLockEnabled)
    return true
end)

-- Extend Client.(Set|Clear)Achievement so we can fire off events when achievements are
-- activated/deactivated.
assert(Client)
assert(Client.SetAchievement)
assert(Client.ClearAchievement)
assert(Client.GetAchievement)
local old_Client_SetAchievement = Client.SetAchievement
function Client.SetAchievement(name)
    
    local wasChanged = false
    if not Client.GetAchievement(name) then
        wasChanged = true
    end
    
    old_Client_SetAchievement(name)
    
    if wasChanged then
        GetGlobalEventDispatcher():FireEvent("OnAchievementSet", name)
    end
    
end

local old_Client_ClearAchievement = Client.ClearAchievement
function Client.ClearAchievement(name)
    
    local wasChanged = false
    if Client.GetAchievement(name) then
        wasChanged = true
    end
    
    old_Client_ClearAchievement(name)
    
    if wasChanged then
        GetGlobalEventDispatcher():FireEvent("OnAchievementCleared", name)
    end

end
