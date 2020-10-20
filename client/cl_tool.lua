
local toolgun = ImportPackage("toolgun")

local regTool1 = {
    name = "Temporary Particles Tool",
    Shoot_event = "OnToolgunTemporaryParticle",
    Tool_table = TemporaryParticles,
    Tool_selected_event = "OnSelectTemporaryParticleTool",
    Tool_unselected_event = "OnUnselectTemporaryParticleTool",
}

local regTool2 = {
    name = "Looped Particles Tool",
    Shoot_event = "OnToolgunLoopParticle",
    Tool_table = LoopParticles,
    Tool_selected_event = "OnSelectLoopParticleTool",
    Tool_unselected_event = "OnUnselectLoopParticleTool",
}

AddEvent("OnPackageStart", function()
    if toolgun then
        toolgun.RegisterTool(regTool1)
        toolgun.RegisterTool(regTool2)
    end
 end)

AddEvent("OnToolgunTemporaryParticle", function(index, selected, hittype, hitid, hitX, hitY, hitZ)
   CallRemoteEvent("RE_OnToolgunTemporaryParticle", index, selected, hittype, hitid, hitX, hitY, hitZ)
end)

AddEvent("OnToolgunLoopParticle", function(index, selected, hittype, hitid, hitX, hitY, hitZ)
    CallRemoteEvent("RE_OnToolgunLoopParticle", index, selected, hittype, hitid, hitX, hitY, hitZ)
 end)