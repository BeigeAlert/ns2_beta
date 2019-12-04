Log("Loading BetaBalanceNewsFeed.lua for NS2 Balance Beta mod.")

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
                    url = "https://rantology.github.io/",
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

end)