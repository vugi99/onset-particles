
local LoopParticlesTable = {}
local AttachedLoopParticlesTable = {}
local StreamerTable = {}
local checked = {}

local function split(str,sep) -- http://lua-users.org/wiki/SplitJoin
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   str:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function GetTemporaryParticleName(pid)
   local particle_path = TemporaryParticles[pid]
   local splitb = split(particle_path,"/")
   return splitb[#splitb]
end
AddFunctionExport("GetTemporaryParticleName", GetTemporaryParticleName)

function GetLoopParticleName(pid)
   local particle_path = LoopParticles[pid]
   local splitb = split(particle_path,"/")
   return splitb[#splitb]
end
AddFunctionExport("GetLoopParticleName", GetLoopParticleName)

local function table_count(tbl)
   local nb = 0
   for k,v in pairs(tbl) do
      nb = nb + 1
   end
   return nb
end

local function GetDistance2DSquared(x1,y1,x2,y2)
   return ((x2-x1)^2+(y2-y1)^2)
end

local function tblinsert(x,y,z,rx,ry,rz,sx,sy,sz,pid)
   local lastval = 1
   for i,v in ipairs(LoopParticlesTable) do
      lastval = lastval + 1
   end
   LoopParticlesTable[lastval] = {x,y,z,rx,ry,rz,sx,sy,sz,pid}
   return lastval
end

local function tblinsertattached(attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz)
   local lastval = 1
   for i,v in ipairs(AttachedLoopParticlesTable) do
      lastval = lastval + 1
   end
   AttachedLoopParticlesTable[lastval] = {attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz}
   return lastval
end

local function GetPlayerStreamer(ply)
   for i,v in ipairs(StreamerTable) do
      if v.ply == ply then
         return v.streamed
      end
   end
   return false
end

function IsLoopParticleStreamedForPlayer(id,ply)
   local plystreamtable = GetPlayerStreamer(ply)
   if plystreamtable then
      for i,v in ipairs(plystreamtable) do
         if v == id then
            return true
         end
      end
   end
   return false
end
AddFunctionExport("IsLoopParticleStreamedForPlayer", IsLoopParticleStreamedForPlayer)

function CreateTemporaryParticle(pid,x,y,z,rx,ry,rz,sx,sy,sz)
   if (pid <= #TemporaryParticles and pid > 0 and x and y and z and rx and ry and rz and sx and sy and sz) then
      for i,v in ipairs(GetAllPlayers()) do
         local x2,y2,z2 = GetPlayerLocation(v)
         local dist = GetDistance2DSquared(x,y,x2,y2)
         if dist <= TemporaryParticlesNetworkDistance2D^2 then
            CallRemoteEvent(v,"CreateClientTemporaryParticle",pid,x,y,z,rx,ry,rz,sx,sy,sz)
         end
      end
      return true
   end
   return false
end
AddFunctionExport("CreateTemporaryParticle", CreateTemporaryParticle)

function CreateTemporaryParticleAttached(attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz)
   if (pid <= #TemporaryParticles and pid > 0 and attach_type > 0 and attach_type <= 4 and attachid and relx and rely and relz and rx and ry and rz and sx and sy and sz) then
      for i, v in ipairs(GetAllPlayers()) do
         local stream
         if attach_type == 1 then
            if IsValidPlayer(attachid) then
               stream = IsPlayerStreamedIn(v, attachid)
            end
         elseif attach_type == 2 then
            if IsValidVehicle(attachid) then
               stream = IsVehicleStreamedIn(v, attachid)
            end
         elseif attach_type == 3 then
            if IsValidObject(attachid) then
               stream = IsObjectStreamedIn(v, attachid)
            end
         elseif attach_type == 4 then
            if IsValidNPC(attachid) then
               stream = IsNPCStreamedIn(v, attachid)
            end
         end
         if stream then
            CallRemoteEvent(v,"CreateClientTemporaryParticleAttached",{attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz})
         end
      end
      return true
   end
   return false
end
AddFunctionExport("CreateTemporaryParticleAttached", CreateTemporaryParticleAttached)

function CreateLoopParticle(pid,x,y,z,rx,ry,rz,sx,sy,sz)
   if (pid <= #LoopParticles and pid > 0 and x and y and z and rx and ry and rz and sx and sy and sz) then
      local id = tblinsert(x,y,z,rx,ry,rz,sx,sy,sz,pid)
      --print(id)
      for i,v in ipairs(GetAllPlayers()) do
         local x2,y2,z2 = GetPlayerLocation(v)
         local dist = GetDistance2DSquared(x,y,x2,y2)
         if dist <= LoopParticlesNetworkDistance2D^2 then
            for i2,v2 in ipairs(StreamerTable) do
               if v2.ply == v then
                  table.insert(StreamerTable[i2].streamed,id)
               end
            end
            CallRemoteEvent(v,"CreateClientLoopParticle",{id,pid,x,y,z,rx,ry,rz,sx,sy,sz})
         end
      end
      return id
   end
   return false
end
AddFunctionExport("CreateLoopParticle", CreateLoopParticle)

function CreateLoopParticleAttached(attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz)
   if (pid <= #LoopParticles and pid > 0 and attach_type > 0 and attach_type <= 4 and attachid and relx and rely and relz and rx and ry and rz and sx and sy and sz) then
      local good
      if attach_type == 1 then
         if IsValidPlayer(attachid) then
            good = true
         end
      elseif attach_type == 2 then
         if IsValidVehicle(attachid) then
            good = true
         end
      elseif attach_type == 3 then
         if IsValidObject(attachid) then
            good = true
         end
      elseif attach_type == 4 then
         if IsValidNPC(attachid) then
            good = true
         end
      end
      if good then
         local id = tblinsertattached(attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz)
         --print("ATTACHEDID" .. tostring(id))
         for i,v in ipairs(GetAllPlayers()) do
            CallRemoteEvent(v,"CreateClientLoopParticleAttached",{id,attach_type,attachid,pid,relx,rely,relz,rx,ry,rz,sx,sy,sz})
         end
         return id
      end
   end
   return false
end
AddFunctionExport("CreateLoopParticleAttached", CreateLoopParticleAttached)

function DestroyLoopParticle(id)
   if LoopParticlesTable[id] then
      LoopParticlesTable[id] = nil
      for i,v in ipairs(GetAllPlayers()) do
         if IsLoopParticleStreamedForPlayer(id,v) then
            for i2,v2 in ipairs(StreamerTable) do
               if v2.ply == v then
                  for i3,v3 in ipairs(StreamerTable[i2].streamed) do
                     if v3 == id then
                        table.remove(StreamerTable[i2].streamed,i3)
                     end
                  end
               end
            end
            CallRemoteEvent(v,"DestroyClientLoopParticle",id)
         end
      end
      return true
   end
   return false
end
AddFunctionExport("DestroyLoopParticle", DestroyLoopParticle)

function DestroyAttachedLoopParticle(id)
   if AttachedLoopParticlesTable[id] then
      AttachedLoopParticlesTable[id] = nil
      for i,v in ipairs(GetAllPlayers()) do
         CallRemoteEvent(v,"DestroyClientAttachedLoopParticle",id)
      end
      return true
   end
   return false
end
AddFunctionExport("DestroyAttachedLoopParticle", DestroyAttachedLoopParticle)

local function Streamer()
   for i, v in ipairs(GetAllPlayers()) do
      local x,y,z = GetPlayerLocation(v)
      for k2,v2 in pairs(LoopParticlesTable) do
         local x2, y2, z2 = v2[1], v2[2], v2[3]
         local dist = GetDistance2DSquared(x,y,x2,y2)
         if dist <= LoopParticlesNetworkDistance2D^2 then
            if not IsLoopParticleStreamedForPlayer(k2,v) then
               for i3,v3 in ipairs(StreamerTable) do
                  if v3.ply == v then
                     table.insert(StreamerTable[i3].streamed,k2)
                  end
               end
               --print("STREAM")
               CallRemoteEvent(v,"CreateClientLoopParticle",{k2,v2[10],v2[1],v2[2],v2[3],v2[4],v2[5],v2[6],v2[7],v2[8],v2[9]})
            end
         else
            if IsLoopParticleStreamedForPlayer(k2,v) then
               for i3,v3 in ipairs(StreamerTable) do
                  if v3.ply == v then
                     for i4,v4 in ipairs(StreamerTable[i3].streamed) do
                        if v4 == k2 then
                           table.remove(StreamerTable[i3].streamed,i4)
                        end
                     end
                  end
               end
               --print("DESTROYSTREAMED")
               CallRemoteEvent(v,"DestroyClientLoopParticle",k2)
            end
         end
      end
   end
end

AddEvent("OnPlayerJoin",function(ply)
    local tbl = {}
    tbl.ply = ply
    tbl.streamed = {}
    table.insert(StreamerTable,tbl)
end)

AddEvent("OnPlayerQuit",function(ply)
    for i,v in ipairs(StreamerTable) do
       if v.ply == ply then
          table.remove(StreamerTable,i)
       end
    end
    for i,v in ipairs(checked) do
       if v == ply then
          table.remove(checked,i)
       end
    end
    local toremove = {}
    for i, v in pairs(AttachedLoopParticlesTable) do
       if (v[1] == 1 and v[2] == ply) then
          table.insert(toremove, i)
       end
    end
    for i, v in ipairs(toremove) do
       DestroyAttachedLoopParticle(v)
    end
end)

local function IsChecked(ply) 
   for i,v in ipairs(checked) do
      if v == ply then
         return true
      end
   end
   return false
end

AddEvent("OnPlayerSpawn",function(ply)
    if not IsChecked(ply) then
       CallRemoteEvent(ply,"SyncAttachedLoopParticles",AttachedLoopParticlesTable)
       table.insert(checked,ply)
    end
end)

AddEvent("OnVehicleDestroyed", function(veh)
    local toremove = {}
    for i, v in pairs(AttachedLoopParticlesTable) do
       if (v[1] == 2 and v[2] == veh) then
          table.insert(toremove, i)
       end
    end
    for i, v in ipairs(toremove) do
       DestroyAttachedLoopParticle(v)
    end
end)

AddEvent("OnObjectDestroyed", function(obj)
    local toremove = {}
    for i, v in pairs(AttachedLoopParticlesTable) do
       if (v[1] == 3 and v[2] == obj) then
          table.insert(toremove, i)
       end
    end
    for i, v in ipairs(toremove) do
       DestroyAttachedLoopParticle(v)
    end
end)

AddEvent("OnNPCDestroyed", function(npc)
    local toremove = {}
    for i, v in pairs(AttachedLoopParticlesTable) do
       if (v[1] == 4 and v[2] == npc) then
          table.insert(toremove, i)
       end
    end
    for i, v in ipairs(toremove) do
       DestroyAttachedLoopParticle(v)
    end
end)

AddEvent("OnPackageStart",function()
   print(tostring(table_count(TemporaryParticles)) .. " Temporary Particles, " .. tostring(table_count(LoopParticles)) .. " Loop Particles")
   CreateTimer(Streamer, Pool_Update_Rate_ms)
end)



