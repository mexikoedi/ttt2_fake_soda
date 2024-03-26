-- convars added with default values
CreateConVar("ttt2_fake_soda_speeddown", 0.70, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Set the speed you can get after drinking the SpeedDown soda. (0.5 = 50%, 0.75 = 75% etc.)")
CreateConVar("ttt2_fake_soda_ragedown", 0.70, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How much less damage you deal after drinking the RageDown soda. (0.20 = 20%, 0.40 = 40% etc.)")
CreateConVar("ttt2_fake_soda_shootdown", 0.60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How much longer the delay is after drinking ShootDown soda. (0.20 = 20%, 0.40 = 40% etc.)")
CreateConVar("ttt2_fake_soda_jumpdown", 0.70, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How much less jumpforce you have after drinking the JumpDown soda. (0.9 = 90%, 0.2 = 20% etc.)")
CreateConVar("ttt2_fake_soda_armordown", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many armor points you lose after drinking the ArmorDown soda.")
CreateConVar("ttt2_fake_soda_healdown", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many heal points you lose after drinking the HealDown soda.")
CreateConVar("ttt2_fake_soda_creditdown", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many equipment credits you lose after drinking the CreditDown soda.")
CreateConVar("ttt2_fake_soda_amount", 3, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Amount of placeable fake sodas")
CreateConVar("ttt2_fake_soda_destruction", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Destruction of placeable fake sodas")
CreateConVar("ttt2_fake_soda_drink_sound", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Sound of the soda drinking")
CreateConVar("ttt2_fake_soda_primary_sound", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Sound of the primary attack")
CreateConVar("ttt2_fake_soda_secondary_sound", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Sound of the secondary attack")
if CLIENT then
    -- Use string or string.format("%.f",<steamid64>) 
    -- addon dev emblem in scoreboard
    hook.Add("TTT2FinishedLoading", "TTT2RegistermexikoediAddonDev", function() AddTTT2AddonDev("76561198279816989") end)
end