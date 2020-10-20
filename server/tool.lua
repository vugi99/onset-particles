

AddRemoteEvent("RE_OnToolgunTemporaryParticle", function(ply, index, selected, hittype, hitid, hitX, hitY, hitZ)
    CreateTemporaryParticle(index,hitX, hitY, hitZ,0,0,0,1,1,1)
end)

AddRemoteEvent("RE_OnToolgunLoopParticle", function(ply, index, selected, hittype, hitid, hitX, hitY, hitZ)
    CreateLoopParticle(index,hitX, hitY, hitZ,0,0,0,1,1,1)
end)