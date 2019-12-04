Log("Loading BetaBalanceNewsFeed.lua for NS2 Balance Beta mod.")

local kBetaBalanceWebpageURL = "https://rantology.github.io/"

local ged = GetGlobalEventDispatcher()
ged:HookEvent(ged, "OnMainMenuCreated", function()

    local navBar = GetNavBar()
    if navBar then
        local newsFeed = navBar.newsFeed
        if newsFeed then
            local result = newsFeed:AddWebPage(
            {
                name = "betaBalanceChangelog",
                label = "Beta Changelog",
                webPageParams =
                {
                    url = kBetaBalanceWebpageURL,
                    clickMode = "Full",
                    wheelEnabled = true,
                },
            }, 1)
            if result then
                newsFeed:SetCurrentPage("betaBalanceChangelog")
            else
                Log("Failed to add beta balance changelog webpage to newsfeed. (name already taken?)")
            end
        else
            Log("Main menu news feed not found!  Cannot add beta balance changelog to newsfeed.")
        end
    else
        Log("Main menu nav bar not loaded!  Cannot add beta balance changelog to newsfeed.")
    end
    
    -- Open the menu to show the popup immediately.
    GetMainMenu():Open()

end)

function DisplayBetaBalanceChangelog()
    Client.ShowWebpage(kBetaBalanceWebpageURL)
end

Event.Hook("Console_changelog", DisplayBetaBalanceChangelog)