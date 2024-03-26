-- add bad status effects to the client
if CLIENT then
    hook.Add("TTT2FinishedLoading", "ttt2_fake_soda_init_icon_hook", function()
        STATUS:RegisterStatus("ent_ttt2_fake_soda_speeddown", {
            hud = Material("vgui/ttt/hud_icon_fake_soda_speeddown.png"),
            type = "bad",
            name = "speeddown_name",
            sidebarDescription = "speeddown_desc"
        })

        STATUS:RegisterStatus("ent_ttt2_fake_soda_ragedown", {
            hud = Material("vgui/ttt/hud_icon_fake_soda_ragedown.png"),
            type = "bad",
            name = "ragedown_name",
            sidebarDescription = "ragedown_desc"
        })

        STATUS:RegisterStatus("ent_ttt2_fake_soda_shootdown", {
            hud = Material("vgui/ttt/hud_icon_fake_soda_shootdown.png"),
            type = "bad",
            name = "shootdown_name",
            sidebarDescription = "shootdown_desc"
        })

        STATUS:RegisterStatus("ent_ttt2_fake_soda_jumpdown", {
            hud = Material("vgui/ttt/hud_icon_fake_soda_jumpdown.png"),
            type = "bad",
            name = "jumpdown_name",
            sidebarDescription = "jumpdown_desc"
        })
    end)
end