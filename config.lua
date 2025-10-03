Config = {}

Config.TrackerItem = "tracker"
Config.UpdateInterval = 1000

-- Blip settings
-- https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs

Config.Tracker = {
    Sheriff = {
        BlipSprite = GetHashKey("blip_ambient_law"),
        BlipModifier = GetHashKey("BLIP_MODIFIER_DEBUG_BLUE"),
        BlipStyle = GetHashKey("BLIP_MODIFIER_PULSE_FOREVER")
    },
    Doctor = {
        BlipSprite = GetHashKey("blip_ambient_law"),
        BlipModifier = GetHashKey("BLIP_MODIFIER_DEBUG_RED"),
        BlipStyle = GetHashKey("BLIP_MODIFIER_PULSE_FOREVER")
    },
    Nurse = {
        BlipSprite = GetHashKey("blip_ambient_law"),
        BlipModifier = GetHashKey("BLIP_MODIFIER_DEBUG_RED"),
        BlipStyle = GetHashKey("BLIP_MODIFIER_AREA_CLAMPED_PULSE")
    },
}

-- Function to check if a player is on duty for a specific job
Config.OnDuty = function(source, job)
    if job == "Sheriff" then
        return exports.outsider_policeman:IsOnPoliceDuty(source)
    elseif job == "Doctor" or job == "Nurse" then
        return exports.outsider_medicalman:IsOnMedicalDuty(source)
    end
    return false
end
