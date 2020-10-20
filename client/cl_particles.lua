
local StreamedLoopParticlesEmitters = {}
local StreamedAttachedLoopParticlesEmitters = {}

local function split(str,sep) -- http://lua-users.org/wiki/SplitJoin
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local function IsValidPlayerEvenLocal(ply)
   if (IsValidPlayer(ply) or GetPlayerId() == ply) then
      return true
   else
      return false
   end
end

local function IsStreamedNPC(npc)
   for i,v in ipairs(GetStreamedNPC()) do
      if v == npc then
         return true
      end
   end
   return false
end

AddEvent("OnPackageStart",function()
   for i,v in ipairs(particlespakfiles) do
      LoadPak(v, "/"..v.."/", "../../../OnsetModding/Plugins/"..v.."/Content")
   end
end)

function GetTemporaryParticleName(pid)
    local particle_path = TemporaryParticles[pid]
    local splitb = split(particle_path,"/")
    return splitb[#splitb]
end

function GetLoopParticleName(pid)
    local particle_path = LoopParticles[pid]
    local splitb = split(particle_path,"/")
    return splitb[#splitb]
end

local function DestroyClientLoopParticle(pid)
   if StreamedLoopParticlesEmitters[pid] then
      StreamedLoopParticlesEmitters[pid]:Destroy()
      StreamedLoopParticlesEmitters[pid] = nil
      return true
   end
   return false
end

local function DestroyClientAttachedLoopParticle(pid)
   if StreamedAttachedLoopParticlesEmitters[pid] then
      if StreamedAttachedLoopParticlesEmitters[pid][1]:IsValid() then
         StreamedAttachedLoopParticlesEmitters[pid][1]:Destroy()
      end
      StreamedAttachedLoopParticlesEmitters[pid] = nil
      return true
   end
   return false
end

function GetStreamedLoopParticles()
   local tbl = {}
   for k,v in pairs(StreamedLoopParticlesEmitters) do
      table.insert(tbl,k)
   end
   return tbl
end

local function CreateClientTemporaryParticle(pid,x,y,z,rx,ry,rz,sx,sy,sz)
    local HitEffect = GetWorld():SpawnEmitterAtLocation(UParticleSystem.LoadFromAsset(TemporaryParticles[pid]), FVector(x,y,z), FRotator(rx,ry,rz), FVector(sx,sy,sz))
    if HitEffect then
       --AddPlayerChat(GetTemporaryParticleName(pid))
       return true
    end
    return false
end

local function CreateClientLoopParticle(id,pid,x,y,z,rx,ry,rz,sx,sy,sz)
    --AddPlayerChat(tostring(id) .. " " .. tostring(pid) .. " " .. tostring(x) .. " " .. tostring(y) .. " " .. tostring(z) .. " " .. tostring(rx) .. " " .. tostring(ry) .. " " .. tostring(rz) .. " " .. tostring(sx) .. " " .. tostring(sy) .. " " .. tostring(sz))
    local HitEffect = GetWorld():SpawnEmitterAtLocation(UParticleSystem.LoadFromAsset(LoopParticles[pid]), FVector(x,y,z), FRotator(rx,ry,rz), FVector(sx,sy,sz))
    if HitEffect then
       StreamedLoopParticlesEmitters[id] = HitEffect
       --AddPlayerChat(GetLoopParticleName(pid))
       return true
    end
    return false
end

local function CreateClientTemporaryParticleAttached(attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz)
   local component
   if attach_type == 1 then
      if IsValidPlayerEvenLocal(attachid) then
         component = GetPlayerSkeletalMeshComponent(attachid, "Body")
      end
   elseif attach_type == 2 then
      if IsValidVehicle(attachid) then
         component = GetVehicleSkeletalMeshComponent(attachid)
      end
   elseif attach_type == 3 then
      if IsValidObject(attachid) then
         component = GetObjectStaticMeshComponent(attachid)
      end
   elseif attach_type == 4 then
      if IsStreamedNPC(attachid) then
         component = GetNPCSkeletalMeshComponent(attachid, "Body")
      end
   end
   if component then
      local HitEffect = GetWorld():SpawnEmitterAttached(UParticleSystem.LoadFromAsset(TemporaryParticles[pid]), component, "", FVector(rely,relx,relz), FRotator(rx,ry,rz), EAttachLocation.KeepRelativeOffset)
      if HitEffect then
         HitEffect:SetRelativeScale3D(FVector(sx, sy, sz))
         --AddPlayerChat(GetTemporaryParticleName(pid))
         return true
      end
   end
   return false
end

local function CreateClientLoopParticleAttached(id,attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz)
   local component
   if attach_type == 1 then
      if IsValidPlayerEvenLocal(attachid) then
         component = GetPlayerSkeletalMeshComponent(attachid, "Body")
      end
   elseif attach_type == 2 then
      if IsValidVehicle(attachid) then
         component = GetVehicleSkeletalMeshComponent(attachid)
      end
   elseif attach_type == 3 then
      if IsValidObject(attachid) then
         component = GetObjectStaticMeshComponent(attachid)
      end
   elseif attach_type == 4 then
      if IsStreamedNPC(attachid) then
         component = GetNPCSkeletalMeshComponent(attachid, "Body")
      end
   end
   if component then
      local HitEffect = GetWorld():SpawnEmitterAttached(UParticleSystem.LoadFromAsset(LoopParticles[pid]), component, "", FVector(rely,relx,relz), FRotator(rx,ry,rz), EAttachLocation.KeepRelativeOffset)
      if HitEffect then
         HitEffect:SetRelativeScale3D(FVector(sx, sy, sz))
         StreamedAttachedLoopParticlesEmitters[id] = {HitEffect,attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz}
         --AddPlayerChat(GetLoopParticleName(pid))
         return true
      end
   else
      StreamedAttachedLoopParticlesEmitters[id] = {nil,attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz}
   end
   return false
end

AddEvent("OnPlayerStreamIn",function(ply)
    for k,v in pairs(StreamedAttachedLoopParticlesEmitters) do
      if (v[2] == 2 and v[3] == ply) then
          CreateClientLoopParticleAttached(k,v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13])
       end
    end
end)

AddEvent("OnVehicleStreamIn",function(veh)
   for k,v in pairs(StreamedAttachedLoopParticlesEmitters) do
      if (v[2] == 2 and v[3] == veh) then
         CreateClientLoopParticleAttached(k,v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13])
      end
   end
end)

AddEvent("OnObjectStreamIn",function(obj)
   for k,v in pairs(StreamedAttachedLoopParticlesEmitters) do
      if (v[2] == 3 and v[3] == obj) then
         CreateClientLoopParticleAttached(k,v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13])
      end
   end
end)

AddEvent("OnNPCStreamIn",function(npc)
   for k,v in pairs(StreamedAttachedLoopParticlesEmitters) do
      if (v[2] == 4 and v[3] == npc) then
         CreateClientLoopParticleAttached(k,v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13])
      end
   end
end)

AddRemoteEvent("CreateClientTemporaryParticle",CreateClientTemporaryParticle)
AddRemoteEvent("CreateClientTemporaryParticleAttached",function(tbl)
    CreateClientTemporaryParticleAttached(tbl[1],tbl[2],tbl[3],tbl[4],tbl[5],tbl[6],tbl[7],tbl[8],tbl[9],tbl[10],tbl[11],tbl[12])
end)
AddRemoteEvent("CreateClientLoopParticle",function(tbl)
    CreateClientLoopParticle(tbl[1],tbl[2],tbl[3],tbl[4],tbl[5],tbl[6],tbl[7],tbl[8],tbl[9],tbl[10],tbl[11])
end)
AddRemoteEvent("CreateClientLoopParticleAttached",function(tbl)
   CreateClientLoopParticleAttached(tbl[1],tbl[2],tbl[3],tbl[4],tbl[5],tbl[6],tbl[7],tbl[8],tbl[9],tbl[10],tbl[11],tbl[12],tbl[13])
end)
AddRemoteEvent("DestroyClientLoopParticle",DestroyClientLoopParticle)
AddRemoteEvent("DestroyClientAttachedLoopParticle",DestroyClientAttachedLoopParticle)

AddRemoteEvent("SyncAttachedLoopParticles",function(tbl)
    --AddPlayerChat("SYNC IN PROGRESS")
    for k,v in pairs(tbl) do
       CreateClientLoopParticleAttached(k,v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12])
    end
end)