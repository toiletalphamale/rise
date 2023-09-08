local gui = shared.risegui
local playersService = game:GetService("Players")
local textService = game:GetService("TextService")
local lightingService = game:GetService("Lighting")
local textChatService = game:GetService("TextChatService")
local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local collectionService = game:GetService("CollectionService")
local replicatedStorageService = game:GetService("ReplicatedStorage")
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local riseConnections = {}
local riseEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new("BindableEvent")
		return self[index]
	end
})
local worldtoscreenpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local bedwars = {}
local bedwarsStore = {
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	blockRaycast = RaycastParams.new(),
	equippedKit = "none",
	grapple = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	matchState = 0,
	matchStateChanged = tick(),
	pots = {},
	queueType = "bedwars_test",
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new("BindableEvent"),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {KVOP25KYFPPP4 = "vape"},
		chatStrings2 = {vape = "KVOP25KYFPPP4"},
		clientUsers = {},
		oldChatFunctions = {}
	},
	zephyrOrb = 0
}
bedwarsStore.blockRaycast.FilterType = Enum.RaycastFilterType.Include

local entityLibrary = loadstring(readfile("risesix/libraries/entityHandler.lua"))()
shared.vapeentity = entityLibrary
do
    entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute("Team") ~= plr:GetAttribute("Team")
	end
    entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = game:GetService("HttpService"):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
        if char then
            task.spawn(function()
                local humrootpart = char:WaitForChild("HumanoidRootPart", 10)
                local head = char:WaitForChild("Head", 10)
                local hum = char:WaitForChild("Humanoid", 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
                if humrootpart and hum and head then
					local childremoved
                    local newent
                    if localcheck then
                        entityLibrary.isAlive = true
                        entityLibrary.character.Head = head
                        entityLibrary.character.Humanoid = hum
                        entityLibrary.character.HumanoidRootPart = humrootpart
                    else
						newent = {
                            Player = plr,
                            Character = char,
                            HumanoidRootPart = humrootpart,
                            RootPart = humrootpart,
                            Head = head,
                            Humanoid = hum,
                            Targetable = entityLibrary.isPlayerTargetable(plr),
                            Team = plr.Team,
                            Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
                        }
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("Health"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find("Shield") then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
                    end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Humanoid" then			
							if localcheck then
								if char == lplr.Character then
									if part.Name == "HumanoidRootPart" then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild("HumanoidRootPart")
										if not root then 
											root = char:WaitForChild("HumanoidRootPart", 3)
										end
										if root then 
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then 
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
                end
            end)
        end
    end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal("Character"):Connect(function()
            if plr.Character then
                entityLibrary.refreshEntity(plr, localcheck)
            else
                if localcheck then
                    entityLibrary.isAlive = false
                else
                    entityLibrary.removeEntity(plr)
                end
            end
        end))
        table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal("Team"):Connect(function()
			local tab = {}
			for i,v in next, entityLibrary.entityList do
                if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then 
                    table.insert(tab, v)
                end
            end
			for i,v in next, tab do 
				entityLibrary.refreshEntity(v.Player)
			end
            if localcheck then
                entityLibrary.fullEntityRefresh()
            else
				entityLibrary.refreshEntity(plr, localcheck)
            end
        end))
		if plr.Character then
            task.spawn(entityLibrary.refreshEntity, plr, localcheck)
        end
    end
	entityLibrary.fullEntityRefresh()
	entityLibrary.LocalPosition = Vector3.zero
    task.spawn(function()
		repeat
			task.wait()
			if entityLibrary.isAlive then
				entityLibrary.groundTick = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
		until not shared.risegui
	end)
	task.spawn(function()
		local postable = {}
		repeat
			task.wait()
			if entityLibrary.isAlive then
				table.insert(postable, {Time = tick(), Position = entityLibrary.character.HumanoidRootPart.Position})
				if #postable > 100 then 
					table.remove(postable, 1)
				end
				local closestmag = 9e9
				local closestpos = entityLibrary.character.HumanoidRootPart.Position
				local currenttime = tick()
				for i, v in pairs(postable) do 
					local mag = 0.1 - (currenttime - v.Time)
					if mag < closestmag and mag > 0 then
						closestmag = mag
						closestpos = v.Position
					end
				end
				entityLibrary.LocalPosition = closestpos
			end
		until not shared.risegui
	end)
end
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

local function runFunction(func) func() end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField")
end

local function getPlayerColor(plr)
	return tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color
end


local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then 
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.round(bulletTime / physicsUpdate) do 
		if velocityCheck then 
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), bedwarsStore.blockRaycast)
		if floorDetection then 
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor("gumdrop_bounce_pad")
			if bouncepad and bouncepad:GetAttribute("PlacedByUserId") == targetPart.Player.UserId then 
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local function getItem(itemName, inv)
	for slot, item in pairs(inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local function getItemNear(itemName, inv)
	for slot, item in pairs(inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName or item.itemType:find(itemName) then
			return item, slot
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in pairs(bedwarsStore.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in pairs(char:GetAttributes()) do 
		if attributeName:find("Shield") and type(attributeValue) == "number" then 
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end

local function getPickaxe()
	return getItemNear("pick")
end

local function getAxe()
	local bestAxe, bestAxeSlot = nil, nil
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find("axe") and item.itemType:find("pickaxe") == nil and item.itemType:find("void") == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
	return bestAxe, bestAxeSlot
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.damage or 0
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end

local function getBow()
	local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find("bow") then 
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType("arrow")	
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear("wool")
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local function attackValue(vec)
	return {value = vec}
end

local function getSpeedMultiplier(reduce)
	local speed = 1
	if lplr.Character then 
		local SpeedDamageBoost = lplr.Character:GetAttribute("SpeedBoost")
		if SpeedDamageBoost and SpeedDamageBoost > 1 then 
			speed = speed + (SpeedDamageBoost - 1)
		end
		if bedwarsStore.grapple > tick() then
			speed = 5.5
		end
		if lplr.Character:GetAttribute("GrimReaperChannel") then 
			speed = speed + 0.6
		end
		if lplr.Character:GetAttribute("SpeedPieBuff") then 
			speed = speed + (bedwarsStore.queueType == "SURVIVAL" and 0.15 or 0.24)
		end
		local armor = bedwarsStore.localInventory.inventory.armor[3]
		if type(armor) ~= "table" then armor = {itemType = ""} end
		if armor.itemType == "speed_boots" then 
			speed = speed + 1
		end
		if bedwarsStore.zephyrOrb ~= 0 then 
			speed = speed + 1.3
		end
	end
	return reduce and speed ~= 1 and math.max(speed * (0.8 - (0.3 * math.floor(speed))), 1) or speed
end

local blacklistedblocks = {
	bed = true,
	ceramic = true
}
local cachedNormalSides = {}
for i,v in pairs(Enum.NormalId:GetEnumItems()) do if v.Name ~= "Bottom" then table.insert(cachedNormalSides, v) end end

local function getPlacedBlock(pos)
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3) 
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
    return realvec
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in pairs(bedwarsStore.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end

local function switchItem(tool)
	bedwars.ClientHandler:Get(bedwars.EquipItemRemote):CallServerAsync({
		hand = tool
	})
	local started = tick()
	repeat task.wait() until (tick() - started) > 0.3 or lplr.Character.HandInvItem.Value == tool
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool.tool) then
		if legit then
			if getHotbarSlot(tool.itemType) then
				bedwars.ClientStoreHandler:dispatch({
					type = "InventorySelectHotbarSlot", 
					slot = getHotbarSlot(tool.itemType)
				})
				riseEvents.InventoryChanged.Event:Wait()
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool.tool)
	end
end

local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in pairs(cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in pairs(cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in pairs(GetPlacedBlocksNear(pos, v)) do	
			local blockmeta = bedwars.ItemTable[v2]["block"]
			sidehardness = sidehardness + (blockmeta and blockmeta.health or 10)
            if blockmeta then
                local tool = getBestTool(v2)
                if tool then
                    sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
                end
            end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end	
	end
	return softestside, softest
end

local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
                if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
                end
            end
        end
		if not ignore then
			for i, v in pairs(collectionService:GetTagged("Monster")) do
				if v.PrimaryPart and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "DiamondGuardian", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "GolemBoss", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("Drone")) do
				if v.PrimaryPart and tonumber(v:GetAttribute("PlayerUserId")) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "Drone", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
    if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
                end
            end
        end
    end
	return closestEntity
end

local function AllNearPosition(distance, amount, sortfunction)
	local returnedplayer = {}
	local currentamount = 0
    if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
                if mag <= distance then
					table.insert(sortedentities, v)
                end
            end
        end
		for i, v in pairs(collectionService:GetTagged("Monster")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
                if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then continue end
                    table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "DiamondGuardian", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "GolemBoss", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Drone")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
                if mag <= distance then
					if tonumber(v:GetAttribute("PlayerUserId")) == lplr.UserId then continue end
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
                    table.insert(sortedentities, {Player = {Name = "Drone", UserId = 1443379645}, GetAttribute = function() return "none" end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(bedwarsStore.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "Pot", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
                end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in pairs(sortedentities) do 
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

runFunction(function()
	local function dumpRemote(tab)
		for i,v in pairs(tab) do
			if v == "Client" then
				return tab[i + 1]
			end
		end
		return ""
	end

	local KnitGotten, KnitClient
	repeat
		KnitGotten, KnitClient = pcall(function()
			return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
		end)
		if KnitGotten then break end
		task.wait()
	until KnitGotten
	repeat task.wait() until debug.getupvalue(KnitClient.Start, 1)
	local Flamework = require(replicatedStorageService["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
	local Client = require(replicatedStorageService.TS.remotes).default.Client
	local InventoryUtil = require(replicatedStorageService.TS.inventory["inventory-util"]).InventoryUtil

	bedwars = {
		AnimationType = require(replicatedStorageService.TS.animation["animation-type"]).AnimationType,
		AnimationUtil = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]).AnimationUtil,
		AppController = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
		AbilityController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController"),
		AbilityUIController = 	Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-ui-controller@AbilityUIController"),
		AttackRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.SwordController.attackEntity)),
		BalloonController = KnitClient.Controllers.BalloonController,
		BalanceFile = require(replicatedStorageService.TS.balance["balance-file"]).BalanceFile,
		BatteryEffectController = KnitClient.Controllers.BatteryEffectsController,
		BatteryRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BatteryController.KnitStart, 1), 1))),
		BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
		BlockController = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
		BlockCpsController = KnitClient.Controllers.BlockCpsController,
		BlockPlacer = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
		BlockEngineClientEvents = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents,
		BlockPlacementController = KnitClient.Controllers.BlockPlacementController,
		BowConstantsTable = debug.getupvalue(KnitClient.Controllers.ProjectileController.enableBeam, 6),
		ProjectileController = KnitClient.Controllers.ProjectileController,
		ChestController = KnitClient.Controllers.ChestController,
		CannonHandController = KnitClient.Controllers.CannonHandController,
		CannonAimRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.CannonController.startAiming, 5))),
		CannonLaunchRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.CannonHandController.launchSelf)),
		ClickHold = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]).ClickHold,
		ClientHandler = Client,
		ClientConstructor = require(replicatedStorageService["rbxts_include"]["node_modules"]["@rbxts"].net.out.client),
		ClientHandlerDamageBlock = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.shared.remotes).BlockEngineRemotes.Client,
		ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		CombatConstant = require(replicatedStorageService.TS.combat["combat-constant"]).CombatConstant,
		CombatController = KnitClient.Controllers.CombatController,
		ConstantManager = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].constant["constant-manager"]).ConstantManager,
		ConsumeSoulRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
		CooldownController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController"),
		DamageIndicator = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DamageIndicatorController = KnitClient.Controllers.DamageIndicatorController,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker["kill-effect"].effects["default-kill-effect"]),
		DropItem = KnitClient.Controllers.ItemDropController.dropItemInHand,
		DropItemRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.dropItemInHand)),
		DragonSlayerController = KnitClient.Controllers.DragonSlayerController,
		DragonRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.DragonSlayerController.KnitStart, 2), 1))),
		EatRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ConsumeController.onEnable, 1))),
		EquipItemRemote = dumpRemote(debug.getconstants(debug.getproto(require(replicatedStorageService.TS.entity.entities["inventory-entity"]).InventoryEntity.equipItem, 3))),
		EmoteMeta = require(replicatedStorageService.TS.locker.emote["emote-meta"]).EmoteMeta,
		FishermanTable = KnitClient.Controllers.FishermanController,
		FovController = KnitClient.Controllers.FovController,
		GameAnimationUtil = require(replicatedStorageService.TS.animation["animation-util"]).GameAnimationUtil,
		EntityUtil = require(replicatedStorageService.TS.entity["entity-util"]).EntityUtil,
		getIcon = function(item, showinv)
			local itemmeta = bedwars.ItemTable[item.itemType]
			if itemmeta and showinv then
				return itemmeta.image or ""
			end
			return ""
		end,
		getInventory = function(plr)
			local suc, result = pcall(function() 
				return InventoryUtil.getInventory(plr) 
			end)
			return (suc and result or {
				items = {},
				armor = {},
				hand = nil
			})
		end,
		GrimReaperController = KnitClient.Controllers.GrimReaperController,
		GuitarHealRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
		HangGliderController = KnitClient.Controllers.HangGliderController,
		HighlightController = KnitClient.Controllers.EntityHighlightController,
		ItemTable = debug.getupvalue(require(replicatedStorageService.TS.item["item-meta"]).getItemMeta, 1),
		InfernalShieldController = KnitClient.Controllers.InfernalShieldController,
		KatanaController = KnitClient.Controllers.DaoController,
		KillEffectMeta = require(replicatedStorageService.TS.locker["kill-effect"]["kill-effect-meta"]).KillEffectMeta,
		KillEffectController = KnitClient.Controllers.KillEffectController,
		KnockbackUtil = require(replicatedStorageService.TS.damage["knockback-util"]).KnockbackUtil,
		LobbyClientEvents = KnitClient.Controllers.QueueController,
		MapController = KnitClient.Controllers.MapController,
		MatchEndScreenController = Flamework.resolveDependency("client/controllers/game/match/match-end-screen-controller@MatchEndScreenController"),
		MinerRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MinerController.onKitEnabled, 1))),
		MageRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MageController.registerTomeInteraction, 1))),
		MageKitUtil = require(replicatedStorageService.TS.games.bedwars.kit.kits.mage["mage-kit-util"]).MageKitUtil,
		MageController = KnitClient.Controllers.MageController,
		MissileController = KnitClient.Controllers.GuidedProjectileController,
		PickupMetalRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.MetalDetectorController.KnitStart, 1), 2))),
		PickupRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.checkForPickup)),
		ProjectileMeta = require(replicatedStorageService.TS.projectile["projectile-meta"]).ProjectileMeta,
		ProjectileRemote = dumpRemote(debug.getconstants(debug.getupvalue(KnitClient.Controllers.ProjectileController.launchProjectileWithValues, 2))),
		QueryUtil = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
		QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui["queue-card"]).QueueCard,
		QueueMeta = require(replicatedStorageService.TS.game["queue-meta"]).QueueMeta,
		RavenTable = KnitClient.Controllers.RavenController,
		RelicController = KnitClient.Controllers.RelicVotingController,
		ReportRemote = dumpRemote(debug.getconstants(require(lplr.PlayerScripts.TS.controllers.global.report["report-controller"]).default.reportPlayer)),
		ResetRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
		Roact = require(replicatedStorageService["rbxts_include"]["node_modules"]["@rbxts"]["roact"].src),
		RuntimeLib = require(replicatedStorageService["rbxts_include"].RuntimeLib),
		Shop = require(replicatedStorageService.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
		ShopItems = debug.getupvalue(debug.getupvalue(require(replicatedStorageService.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem, 1), 2),
		SoundList = require(replicatedStorageService.TS.sound["game-sound"]).GameSound,
		SoundManager = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
		SpawnRavenRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.RavenController.spawnRaven)),
		SprintController = KnitClient.Controllers.SprintController,
		StopwatchController = KnitClient.Controllers.StopwatchController,
		SwordController = KnitClient.Controllers.SwordController,
		TreeRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BigmanController.KnitStart, 1), 2))),
		TrinityRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.AngelController.onKitEnabled, 1))),
		TopBarController = KnitClient.Controllers.TopBarController,
		ViewmodelController = KnitClient.Controllers.ViewmodelController,
		WeldTable = require(replicatedStorageService.TS.util["weld-util"]).WeldUtil,
		ZephyrController = KnitClient.Controllers.WindWalkerController
	}

	bedwarsStore.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, "wool_white")
	bedwars.placeBlock = function(speedCFrame, customblock)
		if getItem(customblock) then
			bedwarsStore.blockPlacer.blockType = customblock
			return bedwarsStore.blockPlacer:placeBlock(Vector3.new(speedCFrame.X / 3, speedCFrame.Y / 3, speedCFrame.Z / 3))
		end
	end

	local healthbarblocktable = {
		blockHealth = -1,
		breakingBlockPosition = Vector3.zero
	}

	local failedBreak = 0
	bedwars.breakBlock = function(pos, effects, normal, bypass, anim)
		if lplr:GetAttribute("DenyBlockBreak") then
			return
		end
        if gui.Modules["Inf Flight"].Enabled then
            return
        end
		local block, blockpos = nil, nil
		if not bypass then block, blockpos = getLastCovered(pos, normal) end
		if not block then block, blockpos = getPlacedBlock(pos) end
		if blockpos and block then
			if bedwars.BlockEngineClientEvents.DamageBlock:fire(block.Name, blockpos, block):isCancelled() then
				return
			end
			local blockhealthbarpos = {blockPosition = Vector3.zero}
			local blockdmg = 0
			if block and block.Parent ~= nil then
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
				bedwarsStore.blockPlace = tick() + 0.5
				switchToAndUseTool(block)
				blockhealthbarpos = {
					blockPosition = blockpos
				}
				task.spawn(function()
					bedwars.ClientHandlerDamageBlock:Get("DamageBlock"):CallServerAsync({
						blockRef = blockhealthbarpos, 
						hitPosition = blockpos * 3, 
						hitNormal = Vector3.FromNormalId(normal)
					}):andThen(function(result)
						if result ~= "failed" then
							failedBreak = 0
							if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
								local blockdata = bedwars.BlockController:getStore():getBlockData(blockhealthbarpos.blockPosition)
								local blockhealth = blockdata and blockdata:GetAttribute(lplr.Name .. "_Health") or block:GetAttribute("Health")
								healthbarblocktable.blockHealth = blockhealth
								healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
							end
							healthbarblocktable.blockHealth = result == "destroyed" and 0 or healthbarblocktable.blockHealth
							blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
							healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
							if effects then
								bedwars.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg, block)
								if healthbarblocktable.blockHealth <= 0 then
									bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
									bedwars.BlockBreaker.healthbarMaid:DoCleaning()
									healthbarblocktable.breakingBlockPosition = Vector3.zero
								else
									bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
								end
							end
							local animation
							if anim then
								animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
								bedwars.ViewmodelController:playAnimation(15)
							end
							task.wait(0.3)
							if animation ~= nil then
								animation:Stop()
								animation:Destroy()
							end
						else
							failedBreak = failedBreak + 1
						end
					end)
				end)
				task.wait(physicsUpdate)
			end
		end
	end	

	local function updateStore(newStore, oldStore)
		if newStore.Game ~= oldStore.Game then 
			bedwarsStore.matchState = newStore.Game.matchState
			bedwarsStore.queueType = newStore.Game.queueType or "bedwars_test"
		end
		if newStore.Bedwars ~= oldStore.Bedwars then 
			bedwarsStore.equippedKit = newStore.Bedwars.kit ~= "none" and newStore.Bedwars.kit or ""
		end
		if newStore.Inventory ~= oldStore.Inventory then
			local newInventory = (newStore.Inventory and newStore.Inventory.observedInventory or {inventory = {}})
			local oldInventory = (oldStore.Inventory and oldStore.Inventory.observedInventory or {inventory = {}})
			bedwarsStore.localInventory = newStore.Inventory.observedInventory
            if newInventory ~= oldInventory then
				riseEvents.InventoryChanged:Fire()
			end
			if newInventory.inventory.items ~= oldInventory.inventory.items then
				riseEvents.InventoryAmountChanged:Fire()
			end
			if newInventory.inventory.hand ~= oldInventory.inventory.hand then 
				local currentHand = newStore.Inventory.observedInventory.inventory.hand
				local handType = ""
				if currentHand then
					local handData = bedwars.ItemTable[currentHand.itemType]
					handType = handData.sword and "sword" or handData.block and "block" or currentHand.itemType:find("bow") and "bow"
				end
				bedwarsStore.localHand = {tool = currentHand and currentHand.tool, Type = handType, amount = currentHand and currentHand.amount or 0}
			end
		end
	end

	table.insert(riseConnections, bedwars.ClientStoreHandler.changed:connect(updateStore))
	updateStore(bedwars.ClientStoreHandler:getState(), {})

    for i, v in pairs({"MatchEndEvent", "EntityDeathEvent", "EntityDamageEvent", "BedwarsBedBreak", "BalloonPopped", "AngelProgress"}) do 
		bedwars.ClientHandler:WaitFor(v):andThen(function(connection)
			table.insert(riseConnections, connection:Connect(function(...)
				riseEvents[v]:Fire(...)
			end))
		end)
	end
	for i, v in pairs({"PlaceBlockEvent", "BreakBlockEvent"}) do 
		bedwars.ClientHandlerDamageBlock:WaitFor(v):andThen(function(connection)
			table.insert(riseConnections, connection:Connect(function(...)
				riseEvents[v]:Fire(...)
			end))
		end)
	end

	bedwarsStore.blocks = collectionService:GetTagged("block")
	bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	table.insert(riseConnections, collectionService:GetInstanceAddedSignal("block"):Connect(function(block)
		table.insert(bedwarsStore.blocks, block)
		bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	end))
	table.insert(riseConnections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(block)
		block = table.find(bedwarsStore.blocks, block)
		if block then 
			table.remove(bedwarsStore.blocks, block)
			bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
		end
	end))
	for _, ent in pairs(collectionService:GetTagged("entity")) do 
		if ent.Name == "DesertPotEntity" then 
			table.insert(bedwarsStore.pots, ent)
		end
	end
	table.insert(riseConnections, collectionService:GetInstanceAddedSignal("entity"):Connect(function(ent)
		if ent.Name == "DesertPotEntity" then 
			table.insert(bedwarsStore.pots, ent)
		end
	end))
	table.insert(riseConnections, collectionService:GetInstanceRemovedSignal("entity"):Connect(function(ent)
		ent = table.find(bedwarsStore.pots, ent)
		if ent then 
			table.remove(bedwarsStore.pots, ent)
		end
	end))

	local oldZephyrUpdate = bedwars.ZephyrController.updateJump
	bedwars.ZephyrController.updateJump = function(self, orb, ...)
		bedwarsStore.zephyrOrb = orb
		return oldZephyrUpdate(self, orb, ...)
	end

	gui.uninjectEvent.Event:Connect(function()
        for i, v in pairs(riseConnections) do
            if v.Disconnect then pcall(function() v:Disconnect() end) continue end
            if v.disconnect then pcall(function() v:disconnect() end) continue end
        end
        entityLibrary.selfDestruct()
		bedwars.ZephyrController.updateJump = oldZephyrUpdate
		bedwarsStore.blockPlacer:disable()
	end)
end)


runFunction(function()
	local Sprint = {Enabled = false}
	local oldSprintFunction
	Sprint = gui.Categories.Movement:CreateModule("Sprint", function(callback)
        if callback then
            oldSprintFunction = bedwars.SprintController.stopSprinting
            bedwars.SprintController.stopSprinting = function(...)
                local originalCall = oldSprintFunction(...)
                bedwars.SprintController:startSprinting()
                return originalCall
            end
            table.insert(Sprint.Connections, lplr.CharacterAdded:Connect(function(char)
                char:WaitForChild("Humanoid", 9e9)
                task.wait(0.5)
                bedwars.SprintController:stopSprinting()
            end))
            task.spawn(function()
                bedwars.SprintController:startSprinting()
            end)
        else
            bedwars.SprintController.stopSprinting = oldSprintFunction
            bedwars.SprintController:stopSprinting()
        end
    end, "Makes you sprint")
end)

runFunction(function()
	local Velocity = {Enabled = false}
	local VelocityHorizontal = {Value = 100}
	local VelocityVertical = {Value = 100}
	local applyKnockback
	Velocity = gui.Categories.Combat:CreateModule("Velocity", function(callback)
        if callback then
            applyKnockback = bedwars.KnockbackUtil.applyKnockback
            bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
                knockback = knockback or {}
                if VelocityHorizontal.Value == 0 and VelocityVertical.Value == 0 then return end
                knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal.Value / 100)
                knockback.vertical = (knockback.vertical or 1) * (VelocityVertical.Value / 100)
                return applyKnockback(root, mass, dir, knockback, ...)
            end
        else
            bedwars.KnockbackUtil.applyKnockback = applyKnockback
        end
    end, "Uses heavy dick and balls to drag across the floor to reduce velocity.")
	VelocityHorizontal = Velocity:CreateSlider("Horizontal", function() end, 0, 100, 0)
	VelocityVertical = Velocity:CreateSlider("Vertical", function() end, 0, 100, 0)
end)

runFunction(function()
    local Speed = {Enabled = false}
	local SpeedMode = {Value = "CFrame"}
	local SpeedValue = {Value = 1}
    local SpeedDamageBoost = {Enabled = false}
    local raycastparameters = RaycastParams.new()
    local damagetick = tick()

    Speed = gui.Categories.Movement:CreateModule("Speed", function(callback)
        if callback then
            table.insert(Speed.Connections, riseEvents.EntityDamageEvent.Event:Connect(function(damageTable)
                if damageTable.entityInstance == lplr.Character and (damageTable.damageType ~= 0 or damageTable.extra and damageTable.extra.chargeRatio ~= nil) and (not (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.disabled or damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal == 0)) and SpeedDamageBoost.Enabled then 
                    damagetick = tick() + 0.4
                end
            end))
            RunLoops:BindToHeartbeat("Speed", function(delta)
                if entityLibrary.isAlive then
                    if gui.Modules.Flight.Enabled or gui.Modules["Inf Flight"].Enabled or gui.Modules["Long Jump"].Enabled then return end
                    local speedValue = ((damagetick > tick() and SpeedValue.Value * 2.25 or SpeedValue.Value) * getSpeedMultiplier(true))
                    local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == "Normal" and speedValue or (20 * getSpeedMultiplier()))
                    entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
                    if SpeedMode.Value ~= "Normal" then 
                        if SpeedMode.Value == "Heatseeker" then 
                            speedValue = tick() % 1 < 0.6 and 5 or (20 * getSpeedMultiplier(true)) / 0.4
                        end
                        local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
                        raycastparameters.FilterDescendantsInstances = {lplr.Character}
                        local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
                        if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
                        entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
                    end
                end
            end)
        else
            RunLoops:UnbindFromHeartbeat("Speed")
        end
    end, "Increases your movement speed", function() return SpeedMode.Value end)
    SpeedMode = Speed:CreateDropdown("Mode", function() gui:UpdateTextGUI() end, {"CFrame", "Normal", "Heatseeker"})
    SpeedValue = Speed:CreateSlider("Speed", function() end, 1, 23, 23)
    SpeedDamageBoost = Speed:CreateToggle("Damage Boost", function() end, true)
end)

local autobankballoon = false
runFunction(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = "Normal"}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute("InflatedBalloons") or 0) < 1 then
			autobankballoon = true
			if getItem("balloon") then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = gui.Categories.Movement:CreateModule("Flight", function(callback)
        if callback then
            olddeflate = bedwars.BalloonController.deflateBalloon
            bedwars.BalloonController.deflateBalloon = function() end

            table.insert(Fly.Connections, inputService.InputBegan:Connect(function(input1)
                if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
                    if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
                        FlyUp = true
                    end
                    if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
                        FlyDown = true
                    end
                end
            end))
            table.insert(Fly.Connections, inputService.InputEnded:Connect(function(input1)
                if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
                    FlyUp = false
                end
                if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
                    FlyDown = false
                end
            end))
            table.insert(Fly.Connections, riseEvents.BalloonPopped.Event:Connect(function(poppedTable)
                if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute("BalloonOwner") == lplr.UserId then 
                    lastonground = not onground
                    repeat task.wait() until (lplr.Character:GetAttribute("InflatedBalloons") or 0) <= 0 or not Fly.Enabled
                    inflateBalloon() 
                end
            end))
            table.insert(Fly.Connections, riseEvents.AutoBankBalloon.Event:Connect(function()
                repeat task.wait() until getItem("balloon")
                inflateBalloon()
            end))

            local balloons
            if entityLibrary.isAlive and (not bedwarsStore.queueType:find("mega")) then
                balloons = inflateBalloon()
            end
            local megacheck = bedwarsStore.queueType:find("mega") or bedwarsStore.queueType == "winter_event"

            task.spawn(function()
                repeat task.wait() until bedwarsStore.queueType ~= "bedwars_test" or (not Fly.Enabled)
                if not Fly.Enabled then return end
                megacheck = bedwarsStore.queueType:find("mega") or bedwarsStore.queueType == "winter_event"
            end)

            local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
            if flyAllowed <= 0 and shared.damageanim and (not balloons) then 
                shared.damageanim()
                bedwars.SoundManager:playSound(bedwars.SoundList["DAMAGE_"..math.random(1, 3)])
            end

            groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
            FlyCoroutine = coroutine.create(function()
                repeat
                    repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
                    flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
                    if (not Fly.Enabled) then break end
                    local Flytppos = -99999
                    if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then 
                        local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
                        if ray then 
                            Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
                            local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
                            args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
                            entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
                            task.wait(0.12)
                            if (not Fly.Enabled) then break end
                            flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
                            if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then 
                                local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
                                args[2] = Flytppos
                                entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
                            end
                        end
                    end
                until (not Fly.Enabled)
            end)
            coroutine.resume(FlyCoroutine)

            RunLoops:BindToHeartbeat("Fly", function(delta) 
                if entityLibrary.isAlive then
                    local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
                    flyAllowed = ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
                    playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

                    if flyAllowed <= 0 then 
                        local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
                        onground = newray and true or false
                        if lastonground ~= onground then 
                            if (not onground) then 
                                groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
                                if FlyAnywayProgressBarFrame then 
                                    FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
                                end
                            else
                                if FlyAnywayProgressBarFrame then 
                                    FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
                                end
                            end
                        end
                        if FlyAnywayProgressBarFrame then 
                            FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0).."s"
                        end
                        lastonground = onground
                    else
                        onground = true
                        lastonground = true
                    end

                    local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == "Normal" and FlySpeed.Value or (20 * getSpeedMultiplier()))
                    entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
                    if FlyMode.Value ~= "Normal" then
                        local speedValue = FlySpeed.Value
                        if FlyMode.Value == "Heatseeker" then 
                            speedValue = tick() % 1 < 0.6 and 5 or (20 * getSpeedMultiplier(true)) / 0.4
                        end
                        entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20)) * delta
                    end
                end
            end)
        else
            pcall(function() coroutine.close(FlyCoroutine) end)
            autobankballoon = false
            waitingforballoon = false
            lastonground = nil
            FlyUp = false
            FlyDown = false
            RunLoops:UnbindFromHeartbeat("Fly")
            if FlyAnywayProgressBarFrame then 
                FlyAnywayProgressBarFrame.Visible = false
            end
            if FlyAutoPop.Enabled then
                if entityLibrary.isAlive and lplr.Character:GetAttribute("InflatedBalloons") then
                    for i = 1, lplr.Character:GetAttribute("InflatedBalloons") do
                        olddeflate()
                    end
                end
            end
            bedwars.BalloonController.deflateBalloon = olddeflate
            olddeflate = nil
        end
    end, "Grants you the ability to fly", function() return FlyMode.Value end)
	FlyMode = Fly:CreateDropdown("Mode", function() gui:UpdateTextGUI() end, {"CFrame", "Normal", "Heatseeker"})
	FlySpeed = Fly:CreateSlider("Speed", function() end, 1, 23, 23)
	FlyVerticalSpeed = Fly:CreateSlider("Vertical Speed", function() end, 1, 100, 44)
	FlyVertical = Fly:CreateToggle("Y Level", function() end, true)
    FlyTP = Fly:CreateToggle("TP Down", function() end, true)
end)


runFunction(function()
	local InfiniteFly = {Enabled = false}
	local InfiniteFlyMode = {Value = "CFrame"}
	local InfiniteFlySpeed = {Value = 23}
	local InfiniteFlyVerticalSpeed = {Value = 40}
	local InfiniteFlyVertical = {Enabled = true}
	local InfiniteFlyUp = false
	local InfiniteFlyDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local clonesuccess = false
	local disabledproper = true
	local oldcloneroot
	local cloned
	local clone
	local bodyvelo
	local FlyOverlap = OverlapParams.new()
	FlyOverlap.MaxParts = 9e9
	FlyOverlap.FilterDescendantsInstances = {}
	FlyOverlap.RespectCanCollide = true

	local function disablefunc()
		if bodyvelo then bodyvelo:Destroy() end
		RunLoops:UnbindFromHeartbeat("InfiniteFlyOff")
		disabledproper = true
		if not oldcloneroot or not oldcloneroot.Parent then return end
		lplr.Character.Parent = game
		oldcloneroot.Parent = lplr.Character
		lplr.Character.PrimaryPart = oldcloneroot
		lplr.Character.Parent = workspace
		oldcloneroot.CanCollide = true
		for i,v in pairs(lplr.Character:GetDescendants()) do 
			if v:IsA("Weld") or v:IsA("Motor6D") then 
				if v.Part0 == clone then v.Part0 = oldcloneroot end
				if v.Part1 == clone then v.Part1 = oldcloneroot end
			end
			if v:IsA("BodyVelocity") then 
				v:Destroy()
			end
		end
		for i,v in pairs(oldcloneroot:GetChildren()) do 
			if v:IsA("BodyVelocity") then 
				v:Destroy()
			end
		end
		local oldclonepos = clone.Position.Y
		if clone then 
			clone:Destroy()
			clone = nil
		end
		lplr.Character.Humanoid.HipHeight = hip or 2
		local origcf = {oldcloneroot.CFrame:GetComponents()}
		origcf[2] = oldclonepos
		oldcloneroot.CFrame = CFrame.new(unpack(origcf))
		oldcloneroot = nil
	end

	InfiniteFly = gui.Categories.Movement:CreateModule("Inf Flight", function(callback)
        if callback then
            if not entityLibrary.isAlive then 
                disabledproper = true
            end
            if not disabledproper then 
                warningNotification("InfiniteFly", "Wait for the last fly to finish", 3)
                InfiniteFly:Toggle()
                return 
            end
            table.insert(InfiniteFly.Connections, inputService.InputBegan:Connect(function(input1)
                if InfiniteFlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
                    if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
                        InfiniteFlyUp = true
                    end
                    if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
                        InfiniteFlyDown = true
                    end
                end
            end))
            table.insert(InfiniteFly.Connections, inputService.InputEnded:Connect(function(input1)
                if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
                    InfiniteFlyUp = false
                end
                if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
                    InfiniteFlyDown = false
                end
            end))
            if inputService.TouchEnabled then
                pcall(function()
                    local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
                    table.insert(InfiniteFly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
                        InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
                    end))
                    InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
                end)
            end
            clonesuccess = false
            if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 then
                cloned = lplr.Character
                oldcloneroot = entityLibrary.character.HumanoidRootPart
                lplr.Character.Parent = game
                clone = oldcloneroot:Clone()
                clone.Parent = lplr.Character
                oldcloneroot.Parent = gameCamera
                bedwars.QueryUtil:setQueryIgnored(oldcloneroot, true)
                clone.CFrame = oldcloneroot.CFrame
                lplr.Character.PrimaryPart = clone
                lplr.Character.Parent = workspace
                for i,v in pairs(lplr.Character:GetDescendants()) do 
                    if v:IsA("Weld") or v:IsA("Motor6D") then 
                        if v.Part0 == oldcloneroot then v.Part0 = clone end
                        if v.Part1 == oldcloneroot then v.Part1 = clone end
                    end
                    if v:IsA("BodyVelocity") then 
                        v:Destroy()
                    end
                end
                for i,v in pairs(oldcloneroot:GetChildren()) do 
                    if v:IsA("BodyVelocity") then 
                        v:Destroy()
                    end
                end
                if hip then 
                    lplr.Character.Humanoid.HipHeight = hip
                end
                hip = lplr.Character.Humanoid.HipHeight
                clonesuccess = true
            end
            if not clonesuccess then 
                InfiniteFly:Toggle()
                return 
            end
            local goneup = false
            RunLoops:BindToHeartbeat("InfiniteFly", function(delta) 
                if entityLibrary.isAlive then
                    local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
                    local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (InfiniteFlyMode.Value == "Normal" and InfiniteFlySpeed.Value or (20 * getSpeedMultiplier()))
                    entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (InfiniteFlyUp and InfiniteFlyVerticalSpeed.Value or 0) + (InfiniteFlyDown and -InfiniteFlyVerticalSpeed.Value or 0), 0))
                    if InfiniteFlyMode.Value ~= "Normal" then
                        local speedValue = InfiniteFlySpeed.Value
                        if InfiniteFlyMode.Value == "Heatseeker" then 
                            speedValue = tick() % 1 < 0.6 and 5 or (20 * getSpeedMultiplier(true)) / 0.4
                        end
                        entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20)) * delta
                    end

                    local speedCFrame = {oldcloneroot.CFrame:GetComponents()}
                    speedCFrame[1] = clone.CFrame.X
                    if speedCFrame[2] < 1000 or (not goneup) then 
                        speedCFrame[2] = 100000
                        goneup = true
                    end
                    speedCFrame[3] = clone.CFrame.Z
                    oldcloneroot.CFrame = CFrame.new(unpack(speedCFrame))
                    oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, oldcloneroot.Velocity.Y, clone.Velocity.Z)
                end
            end)
        else
            RunLoops:UnbindFromHeartbeat("InfiniteFly")
            if clonesuccess and oldcloneroot and clone and lplr.Character.Parent == workspace and oldcloneroot.Parent ~= nil and disabledproper and cloned == lplr.Character then 
                local rayparams = RaycastParams.new()
                rayparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
                rayparams.RespectCanCollide = true
                local ray = workspace:Raycast(Vector3.new(oldcloneroot.Position.X, clone.CFrame.p.Y, oldcloneroot.Position.Z), Vector3.new(0, -1000, 0), rayparams)
                local origcf = {clone.CFrame:GetComponents()}
                origcf[1] = oldcloneroot.Position.X
                origcf[2] = ray and ray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (oldcloneroot.Size.Y / 2)) or clone.CFrame.p.Y
                origcf[3] = oldcloneroot.Position.Z
                oldcloneroot.CanCollide = true
                bodyvelo = Instance.new("BodyVelocity")
                bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
                bodyvelo.Velocity = Vector3.new(0, -1, 0)
                bodyvelo.Parent = oldcloneroot
                oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
                RunLoops:BindToHeartbeat("InfiniteFlyOff", function(dt)
                    if oldcloneroot then 
                        oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
                        local bruh = {clone.CFrame:GetComponents()}
                        bruh[2] = oldcloneroot.CFrame.Y
                        local newcf = CFrame.new(unpack(bruh))
                        FlyOverlap.FilterDescendantsInstances = {lplr.Character, gameCamera}
                        local allowed = true
                        for i,v in pairs(workspace:GetPartBoundsInRadius(newcf.p, 2, FlyOverlap)) do 
                            if (v.Position.Y + (v.Size.Y / 2)) > (newcf.p.Y + 0.5) then 
                                allowed = false
                                break
                            end
                        end
                        if allowed then
                            oldcloneroot.CFrame = newcf
                        end
                    end
                end)
                oldcloneroot.CFrame = CFrame.new(unpack(origcf))
                entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                disabledproper = false
                task.delay(1.5, disablefunc)
            end
            InfiniteFlyUp = false
            InfiniteFlyDown = false
        end
    end, "Grants you the ability to fly", function() return InfiniteFlyMode.Value end)
	InfiniteFlyMode = InfiniteFly:CreateDropdown("Mode", function() end, {"CFrame", "Normal", "Heatseeker"})
	InfiniteFlySpeed = InfiniteFly:CreateSlider("Speed", function() end, 1, 23, 23)
	InfiniteFlyVerticalSpeed = InfiniteFly:CreateSlider("Vertical Speed", function() end, 1, 100, 44)
	InfiniteFlyVertical = InfiniteFly:CreateToggle("Y Level", function() end, true)
end)

local killauraNearPlayer
runFunction(function()
	local killauraboxes = {}
	local killaurasortmethod = {Value = "Distance"}
    local killaurarealremote = bedwars.ClientHandler:Get(bedwars.AttackRemote).instance
    local killauramethod = {Value = "Normal"}
	local killauraothermethod = {Value = "Normal"}
    local killauraanimmethod = {Value = "Normal"}
    local killaurarange = {Value = 14}
    local killauraangle = {Value = 360}
    local killauratargets = {Value = 10}
	local killauraautoblock = {Enabled = false}
    local killauramouse = {Enabled = false}
    local killauracframe = {Enabled = false}
    local killauragui = {Enabled = false}
    local killauratarget = {Enabled = false}
    local killaurasound = {Enabled = false}
    local killauraswing = {Enabled = false}
	local killaurasync = {Enabled = false}
    local killaurahandcheck = {Enabled = false}
    local killauraanimation = {Enabled = false}
	local killauraanimationtween = {Enabled = false}
	local killauracolor = {Value = 0.44}
    local Killauranear = false
    local killauraplaying = false
    local oldViewmodelAnimation = function() end
    local oldPlaySound = function() end
    local originalArmC0 = nil
	local killauracurrentanim
	local animationdelay = tick()

	local function getStrength(plr)
		local inv = bedwarsStore.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i,v in pairs(inv.items) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then 
					strongestsword = itemmeta.sword.damage / 100
				end	
			end
			strength = strength + strongestsword
			for i,v in pairs(inv.armor) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then 
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local killaurasortmethods = {
		Distance = function(a, b)
			return (a.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude < (b.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
		end,
		Health = function(a, b) 
			return a.Humanoid.Health < b.Humanoid.Health
		end,
		Threat = function(a, b) 
			return getStrength(a) > getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute("PlayingAsKit")] or 0) > (kitpriolist[b.Player:GetAttribute("PlayingAsKit")] or 0)
		end
	}

	local originalNeckC0
	local originalRootC0
	local anims = {
		Normal = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		Slow = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		New = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
			{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
		},
		Latest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 1) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		["Vertical Spin"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		["Exhibition Old"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		}
	}

	local function closestpos(block, pos)
		local blockpos = block:GetRenderCFrame()
		local startpos = (blockpos * CFrame.new(-(block.Size / 2))).p
		local endpos = (blockpos * CFrame.new((block.Size / 2))).p
		local speedCFrame = block.Position + (pos - block.Position)
		local x = startpos.X > endpos.X and endpos.X or startpos.X
		local y = startpos.Y > endpos.Y and endpos.Y or startpos.Y
		local z = startpos.Z > endpos.Z and endpos.Z or startpos.Z
		local x2 = startpos.X < endpos.X and endpos.X or startpos.X
		local y2 = startpos.Y < endpos.Y and endpos.Y or startpos.Y
		local z2 = startpos.Z < endpos.Z and endpos.Z or startpos.Z
		return Vector3.new(math.clamp(speedCFrame.X, x, x2), math.clamp(speedCFrame.Y, y, y2), math.clamp(speedCFrame.Z, z, z2))
	end

	local function getAttackData()
		if killauramouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end
		if killauragui.Enabled then
			if #bedwars.AppController:getOpenApps() > (bedwarsStore.equippedKit == "hannah" and 4 or 3) then return false end
		end
		local sword = killaurahandcheck.Enabled and bedwarsStore.localHand or getSword()
		if not sword or not sword.tool then return false end
		local swordmeta = bedwars.ItemTable[sword.tool.Name]
		if killaurahandcheck.Enabled then
			if bedwarsStore.localHand.Type ~= "sword" or bedwars.KatanaController.chargingMaid then return false end
		end
		return sword, swordmeta
	end

	local function autoBlockLoop()
		if not killauraautoblock.Enabled or not Killaura.Enabled then return end
		repeat
			if bedwarsStore.blockPlace < tick() and entityLibrary.isAlive then
				local shield = getItem("infernal_shield")
				if shield then 
					switchItem(shield.tool)
					if not lplr.Character:GetAttribute("InfernalShieldRaised") then
						bedwars.InfernalShieldController:raiseShield()
					end
				end
			end
			task.wait()
		until (not Killaura.Enabled) or (not killauraautoblock.Enabled)
	end

    Killaura = gui.Categories.Combat:CreateModule("Kill Aura", function(callback)
        if callback then
            task.spawn(function()
                local oldNearPlayer
                repeat
                    task.wait()
                    if (killauraanimation.Enabled and not killauraswing.Enabled) then
                        if killauraNearPlayer then
                            pcall(function()
                                if originalArmC0 == nil then
                                    originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
                                end
                                if killauraplaying == false then
                                    killauraplaying = true
                                    for i,v in pairs(anims[killauraanimmethod.Value]) do 
                                        if (not Killaura.Enabled) or (not killauraNearPlayer) then break end
                                        if not oldNearPlayer and killauraanimationtween.Enabled then
                                            gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0 * v.CFrame
                                            continue
                                        end
                                        killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
                                        killauracurrentanim:Play()
                                        task.wait(v.Time - 0.01)
                                    end
                                    killauraplaying = false
                                end
                            end)	
                        end
                        oldNearPlayer = killauraNearPlayer
                    end
                until Killaura.Enabled == false
            end)

            oldViewmodelAnimation = bedwars.ViewmodelController.playAnimation
            oldPlaySound = bedwars.SoundManager.playSound
            bedwars.SoundManager.playSound = function(tab, soundid, ...)
                if (soundid == bedwars.SoundList.SWORD_SWING_1 or soundid == bedwars.SoundList.SWORD_SWING_2) and Killaura.Enabled and killaurasound.Enabled and killauraNearPlayer then
                    return nil
                end
                return oldPlaySound(tab, soundid, ...)
            end
            bedwars.ViewmodelController.playAnimation = function(Self, id, ...)
                if id == 15 and killauraNearPlayer and killauraswing.Enabled and entityLibrary.isAlive then
                    return nil
                end
                if id == 15 and killauraNearPlayer and killauraanimation.Enabled and entityLibrary.isAlive then
                    return nil
                end
                return oldViewmodelAnimation(Self, id, ...)
            end

            local targetedPlayer
            RunLoops:BindToHeartbeat("Killaura", function()
                if entityLibrary.isAlive then
                    local Root = entityLibrary.character.HumanoidRootPart
                    if Root then
                        local Neck = entityLibrary.character.Head:FindFirstChild("Neck")
                        local LowerTorso = Root.Parent and Root.Parent:FindFirstChild("LowerTorso")
                        local RootC0 = LowerTorso and LowerTorso:FindFirstChild("Root")
                        if Neck and RootC0 then
                            if originalNeckC0 == nil then
                                originalNeckC0 = Neck.C0.p
                            end
                            if originalRootC0 == nil then
                                originalRootC0 = RootC0.C0.p
                            end
                            if originalRootC0 and killauracframe.Enabled then
                                if targetedPlayer ~= nil then
                                    local targetPos = targetedPlayer.RootPart.Position + Vector3.new(0, 2, 0)
                                    local direction = (Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit
                                    local direction2 = (Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit
                                    local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction)))
                                    local lookCFrame2 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction2)))
                                    Neck.C0 = CFrame.new(originalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
                                    RootC0.C0 = lookCFrame2 + originalRootC0
                                else
                                    Neck.C0 = CFrame.new(originalNeckC0)
                                    RootC0.C0 = CFrame.new(originalRootC0)
                                end
                            end
                        end
                    end
                end
            end)
            if killauraautoblock.Enabled then 
                task.spawn(autoBlockLoop)
            end
            task.spawn(function()
                repeat
                    task.wait()
                    if not Killaura.Enabled then break end
					gui.Targets.Killaura = nil
                    local plrs = AllNearPosition(killaurarange.Value, 10, killaurasortmethods[killaurasortmethod.Value], true)
                    local firstPlayerNear
                    if #plrs > 0 then
                        local sword, swordmeta = getAttackData()
                        if sword then
                            for i, plr in pairs(plrs) do
                                local root = plr.RootPart
                                if not root then 
                                    continue
                                end
                                local localfacing = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
                                local vec = (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).unit
                                local angle = math.acos(localfacing:Dot(vec))
                                if angle >= (math.rad(killauraangle.Value) / 2) then
                                    continue
                                end
                                local selfrootpos = entityLibrary.character.HumanoidRootPart.Position
                                if not firstPlayerNear then 
                                    firstPlayerNear = true 
                                    killauraNearPlayer = true
                                    targetedPlayer = plr
									gui.Targets.Killaura = {
										Humanoid = {
											Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
											MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
										},
										Player = plr.Player,
										RootPart = plr.RootPart
									}
                                    if not killaurasync.Enabled then 
                                        if animationdelay <= tick() then
                                            animationdelay = tick() + 0.19
                                            if not killauraswing.Enabled then 
                                                bedwars.SwordController:playSwordEffect(swordmeta)
                                            end
                                        end
                                    end
                                end
                                if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < 0.02 then 
                                    continue
                                end
                                local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14.4 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * ((selfrootpos - root.Position).magnitude - 14.4)) or Vector3.zero)
                                if killaurasync.Enabled then 
                                    if animationdelay <= tick() then
                                        animationdelay = tick() + 0.19
                                        if not killauraswing.Enabled then 
                                            bedwars.SwordController:playSwordEffect(swordmeta)
                                        end
                                    end
                                end
                                bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
                                bedwarsStore.attackReach = math.floor((selfrootpos - root.Position).magnitude * 100) / 100
                                bedwarsStore.attackReachUpdate = tick() + 1
                                killaurarealremote:FireServer({
                                    weapon = sword.tool,
                                    chargedAttack = {chargeRatio = swordmeta.sword and swordmeta.sword.chargedAttack and swordmeta.sword.chargedAttack.maxChargeTimeSec or 0},
                                    entityInstance = plr.Character,
                                    validate = {
                                        raycast = {
                                            cameraPosition = attackValue(root.Position), 
                                            cursorDirection = attackValue(CFrame.new(selfpos, root.Position).lookVector)
                                        },
                                        targetPosition = attackValue(root.Position),
                                        selfPosition = attackValue(selfpos)
                                    }
                                })
                                break
                            end
                        end
                    end
                    if not firstPlayerNear then 
                        targetedPlayer = nil
                        killauraNearPlayer = false
                        pcall(function()
                            if originalArmC0 == nil then
                                originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
                            end
                            if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
                                pcall(function()
                                    killauracurrentanim:Cancel()
                                end)
                                if killauraanimationtween.Enabled then 
                                    gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
                                else
                                    killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
                                    killauracurrentanim:Play()
                                end
                            end
                        end)
                    end
                until (not Killaura.Enabled)
            end)
        else
			gui.Targets.Killaura = nil
            RunLoops:UnbindFromHeartbeat("Killaura") 
            killauraNearPlayer = false
            bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
            bedwars.SoundManager.playSound = oldPlaySound
            oldViewmodelAnimation = nil
            pcall(function()
                if entityLibrary.isAlive then
                    local Root = entityLibrary.character.HumanoidRootPart
                    if Root then
                        local Neck = Root.Parent.Head.Neck
                        if originalNeckC0 and originalRootC0 then 
                            Neck.C0 = CFrame.new(originalNeckC0)
                            Root.Parent.LowerTorso.Root.C0 = CFrame.new(originalRootC0)
                        end
                    end
                end
                if originalArmC0 == nil then
                    originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
                end
                if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
                    pcall(function()
                        killauracurrentanim:Cancel()
                    end)
                    if killauraanimationtween.Enabled then 
                        gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
                    else
                        killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
                        killauracurrentanim:Play()
                    end
                end
            end)
        end
    end, "Automatically attacks nearby entities", function() return "Switch" end)
	local sortmethods = {"Distance"}
	for i,v in pairs(killaurasortmethods) do if i ~= "Distance" then table.insert(sortmethods, i) end end
	killaurasortmethod = Killaura:CreateDropdown("Sort", function() end, sortmethods)
    killaurarange = Killaura:CreateSlider("Attack range", function() end, 1, 18, 18)
    killauraangle = Killaura:CreateSlider("Max angle", function() end, 1, 360, 360)
	local animmethods = {}
	for i,v in pairs(anims) do table.insert(animmethods, i) end
    killauraanimmethod = Killaura:CreateDropdown("Animation", function() end, animmethods)
	local oldviewmodel
	local oldraise
	local oldeffect
	killauraautoblock = Killaura:CreateToggle("AutoBlock", function(callback)
        if callback then 
            oldviewmodel = bedwars.ViewmodelController.setHeldItem
            bedwars.ViewmodelController.setHeldItem = function(self, newItem, ...)
                if newItem and newItem.Name == "infernal_shield" then 
                    return
                end
                return oldviewmodel(self, newItem)
            end
            oldraise = bedwars.InfernalShieldController.raiseShield
            bedwars.InfernalShieldController.raiseShield = function(self)
                if os.clock() - self.lastShieldRaised < 0.4 then
                    return
                end
                self.lastShieldRaised = os.clock()
                self.infernalShieldState:SendToServer({raised = true})
                self.raisedMaid:GiveTask(function()
                    self.infernalShieldState:SendToServer({raised = false})
                end)
            end
            oldeffect = bedwars.InfernalShieldController.playEffect
            bedwars.InfernalShieldController.playEffect = function()
                return
            end
            if bedwars.ViewmodelController.heldItem and bedwars.ViewmodelController.heldItem.Name == "infernal_shield" then 
                local sword, swordmeta = getSword()
                if sword then 
                    bedwars.ViewmodelController:setHeldItem(sword.tool)
                end
            end
            task.spawn(autoBlockLoop)
        else
            bedwars.ViewmodelController.setHeldItem = oldviewmodel
            bedwars.InfernalShieldController.raiseShield = oldraise
            bedwars.InfernalShieldController.playEffect = oldeffect
        end
    end, true)
    killauramouse = Killaura:CreateToggle("Require mouse down", function() end)
    killauragui = Killaura:CreateToggle("GUI Check", function() end)
    killauracframe = Killaura:CreateToggle("Face target", function() end)
    killaurasound = Killaura:CreateToggle("No Swing Sound", function() end)
    killauraswing = Killaura:CreateToggle("No Swing", function() end)
    killaurahandcheck = Killaura:CreateToggle("Limit to items", function() end)
    killauraanimation = Killaura:CreateToggle("Custom Animation", function() end)
	killauraanimationtween = Killaura:CreateToggle("No Tween", function() end)
	killaurasync = Killaura:CreateToggle("Synced Animation", function() end)
end)

runFunction(function()
	local MultiAura = {Enabled = false}
	local firetimes = 0
	MultiAura = gui.Categories.Exploit:CreateModule("Multi Aura", function(callback)
		if callback then
			task.spawn(function()
				local rem = bedwars.ClientHandler:Get("SwordSwingMiss")
				repeat
					task.wait(0.016)
					if AllNearPosition(14, 1) then 
						rem:SendToServer({
							weapon = "diamond_great_hammer",
							chargeRatio = 1
						})
					end
				until (not MultiAura.Enabled)
			end)
		end
	end, "Reduces or eliminates fall damage")
end)

runFunction(function()
	local NoFall = {Enabled = false}
	local oldfall
	NoFall = gui.Categories.Player:CreateModule("No Fall", function(callback)
		if callback then
			task.spawn(function()
				repeat
					task.wait(0.5)
					bedwars.ClientHandler:Get("GroundHit"):SendToServer()
				until (not NoFall.Enabled)
			end)
		end
	end, "Reduces or eliminates fall damage")
end)

local LongJump = {Enabled = false}
runFunction(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpdelay = tick()
	local LongJumpSlowdown = {Value = 1.5}
	local LongJumpSpeed = {Value = 1.5}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then 
			local newray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, bedwarsStore.blockRaycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://4809574295"
				sound.Parent = workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
			local ray = workspace:Raycast(pos, Vector3.new(0, -30, 0), bedwarsStore.blockRaycast)
			if ray then
				pos = ray.Position + Vector3.new(0, 0, 0)
				offsetshootpos = pos
			end
			bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta["fireball"], "fireball", "fireball", offsetshootpos, "", Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
			projectileRemote:CallServerAsync(fireball["tool"], "fireball", "fireball", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
		end,
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, "tnt")
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, "cannon")
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == "cannon" and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then 
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2
						})
						bedwars.ClientHandler:Get(bedwars.CannonAimRemote):SendToServer({
							["cannonBlockPos"] = pos2,
							["lookVector"] = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute("Health") then 
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do 
								local call = bedwars.ClientHandler:Get(bedwars.CannonLaunchRemote):CallServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block.Position)})
								if call then
									bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)	
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				switchItem(tnt.tool)
				if not (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedStorageService["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].useAbility:FireServer("dash", {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 1.25
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("jade_hammer_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("jade_hammer_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("jade_hammer_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("jade_hammer_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("void_axe_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("void_axe_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("void_axe_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("void_axe_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	LongJump = gui.Categories.Movement:CreateModule("Long Jump", function(callback)
		if callback then
			table.insert(LongJump.Connections, riseEvents.EntityDamageEvent.Event:Connect(function(damageTable)
				if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then 
					local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
					if damagetimertick < tick() or knockbackBoost >= damagetimer then
						damagetimer = knockbackBoost
						damagetimertick = tick() + 2.5
						local newDirection = damageTable.fromPosition and entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(damageTable.fromPosition.X, damageTable.fromPosition.Y, damageTable.fromPosition.Z) or entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
					end
				end
			end))
			task.spawn(function()
				local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
				local tntcheck
				LongJumpdelay = tick()
				for i,v in pairs(damagemethods) do 
					local item = getItem(i)
					if item then
						if i == "tnt" then 
							local pos = getScaffold(LongJumpOrigin)
							tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
							v(item, pos)
						else
							v(item, LongJumpOrigin)
						end
						break
					end
				end
				local passed = false
				local funnytick = tick() + 0.4
				RunLoops:BindToHeartbeat("LongJump", function(dt)
					if entityLibrary.isAlive then 
						if entityLibrary.character.Humanoid.Health <= 0 then 
							LongJump.ToggleButton(false)
							return
						end
						if not LongJumpOrigin then 
							LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
						end
						local newval = damagetimer ~= 0
						if newval then 
							local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
							if not passed then 
								passed = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)) == nil
							end
							if directionvec == nil then 
								directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							end
							local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
							local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (20 * getSpeedMultiplier()) or Vector3.zero
							local val = (LongJumpSlowdown.Value / 10)
							longJumpCFrame = longJumpCFrame * (newnum > 1 and damagetimer - newvelo.Magnitude or 3) * dt
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, bedwarsStore.blockRaycast)
							if ray then 
								longJumpCFrame = Vector3.zero
								newvelo = Vector3.zero
							end

							entityLibrary.character.HumanoidRootPart.Velocity = newvelo
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
						else
							entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
							entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
							if tntcheck then 
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
							end
						end
					else
						LongJumpOrigin = nil
						tntcheck = nil
					end
				end)
			end)
		else
			RunLoops:UnbindFromHeartbeat("LongJump")
			directionvec = nil
			tntcheck = nil
			LongJumpOrigin = nil
			damagetimer = 0
			damagetimertick = 0
		end
	end, "Makes you jump further than normal")
	LongJumpSpeed = LongJump:CreateSlider("Speed", function() end, 1, 55, 55)
end)

local spiderActive = false
local holdingshift = false
runFunction(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {Enabled = false}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
		local possible = workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = gui.Categories.Movement:CreateModule("Phase", function(callback)
		if callback then
			RunLoops:BindToHeartbeat("Phase", function()
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not gui.Modules["Wall Climb"].Enabled or holdingshift) then
					if PhaseDelay <= tick() then
						raycastparameters.FilterDescendantsInstances = {bedwarsStore.blocks, collectionService:GetTagged("spawn-cage"), workspace.SpectatorPlatform}
						local PhaseRayCheck = workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
						if PhaseRayCheck then
							local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute("GreedyBlock")) and "Z" or "X"
							if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
								local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
								if isPointInMapOccupied(PhaseDestination.p) then
									PhaseDelay = tick() + 1
									entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
								end
							end
						end
					end
				end
			end)
		else
			RunLoops:UnbindFromHeartbeat("Phase")
		end
	end, "Lets you go through solid blocks")
	PhaseStudLimit = Phase:CreateSlider("Blocks", function() end, 1, 3, 3)
end)

runFunction(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local Spider = {Enabled = false}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = "Normal"}
	local SpiderPart
	Spider = gui.Categories.Movement:CreateModule("Wall Climb", function(callback)
		if callback then
			table.insert(Spider.Connections, inputService.InputBegan:Connect(function(input1)
				if input1.KeyCode == Enum.KeyCode.LeftShift then 
					holdingshift = true
				end
			end))
			table.insert(Spider.Connections, inputService.InputEnded:Connect(function(input1)
				if input1.KeyCode == Enum.KeyCode.LeftShift then 
					holdingshift = false
				end
			end))
			RunLoops:BindToHeartbeat("Spider", function()
				if entityLibrary.isAlive and (not gui.Modules.PhaseEnabled or not holdingshift) then
					if SpiderMode.Value == "Normal" then
						local vec = entityLibrary.character.Humanoid.MoveDirection * 2
						local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)))
						local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
						if newray and (not newray.CanCollide) then newray = nil end 
						if newray2 and (not newray2.CanCollide) then newray2 = nil end 
						if spiderActive and (not newray) and (not newray2) then
							entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
						end
						spiderActive = ((newray or newray2) and true or false)
						if (newray or newray2) then
							entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
						end
					else
						if not SpiderPart then 
							SpiderPart = Instance.new("TrussPart")
							SpiderPart.Size = Vector3.new(2, 2, 2)
							SpiderPart.Transparency = 1
							SpiderPart.Anchored = true
							SpiderPart.Parent = gameCamera
						end
						local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
						if newray2 and (not newray2.CanCollide) then newray2 = nil end
						spiderActive = (newray2 and true or false)
						if newray2 then 
							newray2pos = newray2pos * 3
							local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
							SpiderPart.Position = newpos
						else
							SpiderPart.Position = Vector3.zero
						end
					end
				end
			end)
		else
			if SpiderPart then SpiderPart:Destroy() end
			RunLoops:UnbindFromHeartbeat("Spider")
			holdingshift = false
		end
	end, "Allows you to climb up walls like a spider")
	SpiderMode = Spider:CreateDropdown("Mode", function() 
		if SpiderPart then SpiderPart:Destroy() end
	end, {"Normal", "Classic"})
	SpiderSpeed = Spider:CreateSlider("Speed", function() end, 0, 40, 40)
end)

runFunction(function()
	local ProjectileAura = {Enabled = false}
	local ProjectileAuraRange = {Value = 40}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)
	local lastTarget
	local fireDelays = {}

	local function shootProjectile(item, ammotypething)
		local plr = EntityNearPosition(ProjectileAuraRange.Value)
		lastTarget = plr
		if plr then 
			if plr.Character:GetAttribute("InfernalShieldRaised") then return end
			local rayparams = RaycastParams.new()
			local tab = {lplr.Character}
			for i,v in pairs(entityLibrary.entityList) do if v.Targetable then table.insert(tab, v.Character) end end
			rayparams.FilterDescendantsInstances = tab
			local rayCheckPos = CFrame.new(entityLibrary.character.HumanoidRootPart.Position, plr.RootPart.Position)
			if bedwars.QueryUtil:raycast(rayCheckPos.p, plr.RootPart.Position - rayCheckPos.p, rayparams) then return end
			local projsource = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = projsource.projectileType(ammotypething)	
			local projmeta = bedwars.ProjectileMeta[ammo]
			local startPos = entityLibrary.character.HumanoidRootPart.Position
			local offsetStartPos = startPos + Vector3.new(0, 2, 0)
			local prediction = (worldmeta and projmeta.predictionLifetimeSec or projmeta.lifetimeSec or 3)
			local launchvelo = (projmeta.launchVelocity or 100)
			local gravity = (projmeta.gravitationalAcceleration or 196.2)
			local multigrav = gravity
			local pos = plr.RootPart.Position
			local playergrav = workspace.Gravity
			local balloons = plr.Character:GetAttribute("InflatedBalloons")
			if balloons and balloons > 0 then 
				playergrav = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
			end
			if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then 
				playergrav = (workspace.Gravity * 0.3)
			end
			local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / launchvelo, plr, playergrav)
			if projmeta.projectile == "telepearl" then
				shootpos = pos
				shootvelo = Vector3.zero
			end
			local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
			shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
			local calculated = LaunchDirection(offsetStartPos, shootpos, launchvelo, multigrav, false)
			if calculated then 
				local guid = game:GetService("HttpService"):GenerateGUID()
				bedwars.ProjectileController:createLocalProjectile(tab, ammotypething, ammo, offsetStartPos, guid, calculated, {drawDurationSeconds = 1})
				projectileRemote:CallServerAsync(item.tool, ammotypething, ammo, offsetStartPos, startPos, calculated, guid, {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
				task.wait(projsource.fireDelaySec)
			end
		end
	end

	ProjectileAura = gui.Categories.Player:CreateModule("Projectile Aura", function(callback)
		if callback then 
			task.spawn(function()
				repeat
					task.wait()
					if entityLibrary.isAlive then
						if getItem("arrow") then
							for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
								if item.itemType:find("bow") then 
									if fireDelays[item.itemType] == nil or fireDelays[item.itemType] < tick() then
										task.spawn(shootProjectile, item, "arrow")
										fireDelays[item.itemType] = tick() + bedwars.ItemTable[item.itemType].projectileSource.fireDelaySec
									end
								end
							end
						end
					else
						lastTarget = nil
					end
				until (not ProjectileAura.Enabled)
			end)
			task.spawn(function()
				repeat
					task.wait()
					if entityLibrary.isAlive then
						local snowball = getItem("snowball")
						if snowball then 
							shootProjectile(snowball, "snowball")
						else
							lastTarget = nil
						end
					else
						lastTarget = nil
					end
				until (not ProjectileAura.Enabled)
			end)
			task.spawn(function()
				repeat
					gui.Targets.ProjectileAura = lastTarget and {
						Humanoid = {
							Health = (lastTarget.Character:GetAttribute("Health") or lastTarget.Humanoid.Health) + getShieldAttribute(lastTarget.Character),
							MaxHealth = lastTarget.Character:GetAttribute("MaxHealth") or lastTarget.Humanoid.MaxHealth
						},
						Player = lastTarget.Player,
						RootPart = lastTarget.RootPart
					}
					task.wait()
				until (not ProjectileAura.Enabled)
			end)
		else
			gui.Targets.ProjectileAura = nil
		end
	end, "Shoots projectiles")
	ProjectileAuraRange = ProjectileAura:CreateSlider("Range", function() end, 1, 50, 50)
end)


local Scaffold = {Enabled = false}
runFunction(function()
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {Enabled = false}
	local ScaffoldTower = {Enabled = false}
	local ScaffoldDownwards = {Enabled = false}
	local ScaffoldStopMotion = {Enabled = false}
	local ScaffoldHandCheck = {Enabled = false}
	local ScaffoldMouseCheck = {Enabled = false}
	local ScaffoldAnimation = {Enabled = false}
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {}
	task.spawn(function()
		for x = -3, 3, 3 do 
			for y = -3, 3, 3 do 
				for z = -3, 3, 3 do 
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then 
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z)) 
					end 
				end 
			end 
		end
	end)

	local function checkblocks(pos)
		for i,v in pairs(scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then 
			for i,v in pairs(bedwarsStore.blocks) do 
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then 
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local oldspeed
	Scaffold = gui.Categories.Player:CreateModule("Scaffold", function(callback)
		if callback then
			if entityLibrary.isAlive then 
				scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
			end
			task.spawn(function()
				repeat
					task.wait()
					if ScaffoldHandCheck.Enabled then 
						if bedwarsStore.localHand.Type ~= "block" then continue end
					end
					if ScaffoldMouseCheck.Enabled then 
						if not inputService:IsMouseButtonPressed(0) then continue end
					end
					if entityLibrary.isAlive then
						local wool, woolamount = getWool()
						if bedwarsStore.localHand.Type == "block" then
							wool = bedwarsStore.localHand.tool.Name
							woolamount = getItem(bedwarsStore.localHand.tool.Name).amount or 0
						elseif (not wool) then 
							wool, woolamount = getBlock()
						end

						if not wool then continue end

						local towering = ScaffoldTower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and game:GetService("UserInputService"):GetFocusedTextBox() == nil
						if towering then
							if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
								scaffoldstopmotionval = true
								scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
							end
							entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
							end
						else
							scaffoldstopmotionval = false
						end
						
						for i = 1, ScaffoldExpand.Value do
							local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 3.5))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
							speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
							if speedCFrame ~= oldpos then
								if not checkblocks(speedCFrame) then
									local oldspeedCFrame = speedCFrame
									speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
									if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
								end
								if ScaffoldAnimation.Enabled then 
									if not getPlacedBlock(speedCFrame) then
									bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
									end
								end
								task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
								if ScaffoldExpand.Value > 1 then 
									task.wait()
								end
								oldpos = speedCFrame
							end
						end
					end
				until (not Scaffold.Enabled)
			end)
		else
			oldpos = Vector3.zero
			oldpos2 = Vector3.zero
		end
	end, "Builds a bridge under you as you walk")
	ScaffoldExpand = Scaffold:CreateSlider("Expand", function() end, 1, 8)
	ScaffoldDiagonal = Scaffold:CreateToggle("Diagonal", function() end, true)
	ScaffoldTower = Scaffold:CreateToggle("Tower", function() end, true)
	ScaffoldDownwards  = Scaffold:CreateToggle("Downwards", function() end, true)
	ScaffoldHandCheck = Scaffold:CreateToggle("Whitelist Only", function() end)
	ScaffoldAnimation = Scaffold:CreateToggle("Animation", function() end)
end)

runFunction(function()
	local Nuker = {Enabled = false}
	local nukerrange = {Value = 1}
	local nukereffects = {Enabled = false}
	local nukeranimation = {Enabled = false}
	local nukerlegit = {Enabled = false}
	local nukerown = {Enabled = false}
    local nukerluckyblock = {Enabled = false}
	local nukerironore = {Enabled = false}
    local nukerbeds = {Enabled = false}
	local nukercustom = {RefreshValues = function() end, ObjectList = {}}
    local luckyblocktable = {}

	Nuker = gui.Categories.Other:CreateModule("Breaker", function(callback)
        if callback then
            for i,v in pairs(bedwarsStore.blocks) do
                if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                    table.insert(luckyblocktable, v)
                end
            end
            table.insert(Nuker.Connections, collectionService:GetInstanceAddedSignal("block"):Connect(function(v)
                if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                    table.insert(luckyblocktable, v)
                end
            end))
            table.insert(Nuker.Connections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(v)
                if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                    table.remove(luckyblocktable, table.find(luckyblocktable, v))
                end
            end))
            task.spawn(function()
                repeat
                    local broke = not entityLibrary.isAlive
                    local tool = (not nukerlegit.Enabled) and {Name = "wood_axe"} or bedwarsStore.localHand.tool
                    if nukerbeds.Enabled then
                        for i, obj in pairs(collectionService:GetTagged("bed")) do
                            if broke then break end
                            if obj.Parent ~= nil then
                                if obj:GetAttribute("BedShieldEndTime") then 
                                    if obj:GetAttribute("BedShieldEndTime") > workspace:GetServerTimeNow() then continue end
                                end
                                if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
                                    if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
                                        local res, amount = getBestBreakSide(obj.Position)
                                        local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
                                        broke = true
                                        bedwars.breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
                                        break
                                    end
                                end
                            end
                        end
                    end
                    broke = broke and not entityLibrary.isAlive
                    for i, obj in pairs(luckyblocktable) do
                        if broke then break end
                        if entityLibrary.isAlive then
                            if obj and obj.Parent ~= nil then
                                if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute("PlacedByUserId") ~= lplr.UserId) then
                                    if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
                                        bedwars.breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
                                        break
                                    end
                                end
                            end
                        end
                    end
                    task.wait()
                until (not Nuker.Enabled)
            end)
        else
            luckyblocktable = {}
        end
    end, "Automatically breaks beds around you")
	nukerrange = Nuker:CreateSlider("Break range", function() end, 1, 30, 30)
	nukerlegit = Nuker:CreateToggle("Hand Check", function() end)
	nukereffects = Nuker:CreateToggle("Show HealthBar & Effects", function(callback) 
        if not callback then
            bedwars.BlockBreaker.healthbarMaid:DoCleaning()
        end
    end)
	nukeranimation = Nuker:CreateToggle("Break Animation", function() end)
	nukerown = Nuker:CreateToggle("Self Break", function() end)
    nukerbeds = Nuker:CreateToggle("Break Beds", function() end, true)
    nukerluckyblock = Nuker:CreateToggle("Break LuckyBlocks", function(callback) 
        if callback then 
            luckyblocktable = {}
            for i,v in pairs(bedwarsStore.blocks) do
                if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                    table.insert(luckyblocktable, v)
                end
            end
        else
            luckyblocktable = {}
        end
    end, true)
	nukerironore = Nuker:CreateToggle("Break IronOre", function(callback) 
        if callback then 
            luckyblocktable = {}
            for i,v in pairs(bedwarsStore.blocks) do
                if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                    table.insert(luckyblocktable, v)
                end
            end
        else
            luckyblocktable = {}
        end
    end)
end)

runFunction(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {Enabled = false}
	PickupRange = gui.Categories.Player:CreateModule("Pickup Range", function(callback)
		if callback then
			local pickedup = {}
			task.spawn(function()
				repeat
					local itemdrops = collectionService:GetTagged("ItemDrop")
					for i,v in pairs(itemdrops) do
						if entityLibrary.isAlive and (v:GetAttribute("ClientDropTime") and tick() - v:GetAttribute("ClientDropTime") > 2 or v:GetAttribute("ClientDropTime") == nil) then
							if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
								task.spawn(function()
									pickedup[v] = tick() + 0.2
									bedwars.ClientHandler:Get(bedwars.PickupRemote):CallServerAsync({
										itemDrop = v
									}):andThen(function(suc)
										if suc then
											bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
										end
									end)
								end)
							end
						end
					end
					task.wait()
				until (not PickupRange.Enabled)
			end)
		end
	end, "Grabs items from far away")
	PickupRangeRange = PickupRange:CreateSlider("Range", function() end, 1, 10, 10)
end)

runFunction(function()
	local AutoLeaveDelay = {Value = 1}
	local AutoPlayAgain = {Enabled = false}
	local AutoLeaveStaff = {Enabled = true}
	local AutoLeaveStaff2 = {Enabled = true}
	local AutoLeaveRandom = {Enabled = false}
	local leaveAttempted = false
	local stafflist = {
		[1774814725] = true,
		[150922276] = true
	}

	local function getRole(plr)
		local suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
		if not suc then 
			repeat
				suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
				task.wait()
			until suc
		end
		if stafflist[plr.UserId] then 
			return 200
		end
		return res
	end

	local flyAllowedmodules = {"Sprint", "AutoClicker", "AutoReport", "AutoReportV2", "AutoRelic", "AimAssist", "AutoLeave", "Reach"}

	local function isEveryoneDead()
		if #bedwars.ClientStoreHandler:getState().Party.members > 0 then
			for i,v in pairs(bedwars.ClientStoreHandler:getState().Party.members) do
				local plr = playersService:FindFirstChild(v.name)
				if plr and isAlive(plr, true) then
					return false
				end
			end
			return true
		else
			return true
		end
	end

	local function autoLeaveAdded(plr)
		task.spawn(function()
			if not gui.Loaded then
				repeat task.wait() until gui.Loaded
			end
			if getRole(plr) >= 100 then
				if #bedwars.ClientStoreHandler:getState().Party.members > 0 then 
					bedwars.LobbyClientEvents.leaveParty()
				end
				gui:CreateNotification("Rise", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name), 20)
				gui.Save = function() end
				for i,v in pairs(gui.Modules) do 
					if v.Enabled then
						v:Toggle(true)
					end
				end
				return
			end
		end)
	end

	AutoLeave = gui.Categories.Other:CreateModule("Auto Play", function(callback)
		if callback then
			table.insert(AutoLeave.Connections, riseEvents.EntityDeathEvent.Event:Connect(function(deathTable)
				if (not leaveAttempted) and deathTable.finalKill and deathTable.entityInstance == lplr.Character then
					leaveAttempted = true
					if isEveryoneDead() and bedwarsStore.matchState ~= 2 then
						task.wait(1 + (AutoLeaveDelay.Value / 10))
						if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
							if not AutoPlayAgain.Enabled then
								bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
							else
								gui:CreateNotification("Auto Play", "Joined a new game", 7)
								if AutoLeaveRandom.Enabled then 
									local listofmodes = {}
									for i,v in pairs(bedwars.QueueMeta) do
										if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
									end
									bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
								else
									bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
								end
							end
						end
					end
				end
			end))
			table.insert(AutoLeave.Connections, riseEvents.MatchEndEvent.Event:Connect(function(deathTable)
				task.wait(AutoLeaveDelay.Value / 10)
				if not AutoLeave.Enabled then return end
				if leaveAttempted then return end
				leaveAttempted = true
				if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
					if not AutoPlayAgain.Enabled then
						bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
					else
						if bedwars.ClientStoreHandler:getState().Party.queueState == 0 then
							if AutoLeaveRandom.Enabled then 
								local listofmodes = {}
								for i,v in pairs(bedwars.QueueMeta) do
									if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
								end
								bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
							else
								bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
							end
						end
					end
				end
			end))
			table.insert(AutoLeave.Connections, playersService.PlayerAdded:Connect(autoLeaveAdded))
			for i, plr in pairs(playersService:GetPlayers()) do
				autoLeaveAdded(plr)
			end
		end
	end, "Leaves if a staff member joins your game or when the match ends.")
	AutoLeaveDelay = AutoLeave:CreateSlider("Delay", function() end, 0, 50, 10)
	AutoPlayAgain = AutoLeave:CreateToggle("Play Again", function() end, true)
	AutoLeaveRandom = AutoLeave:CreateToggle("Random", function() end)
end)

runFunction(function()
	local ChestStealer = {Enabled = false}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {Enabled = false}
	local ChestStealerSkywars = {Enabled = true}
	local cheststealerdelays = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen("ChestApp") then
				local chest = lplr.Character:FindFirstChild("ObservedChestFolder")
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in pairs(collectionService:GetTagged("chest")) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild("ChestFolderValue")
					chest = chest and chest.Value or nil
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 0 then
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
						for i3,v3 in pairs(chestitems) do
							if v3:IsA("Accessory") then
								task.spawn(function()
									pcall(function()
										bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
					end
				end
			end
		end
	}

	ChestStealer = gui.Categories.Player:CreateModule("Stealer", function(callback)
        if callback then
            task.spawn(function()
                repeat task.wait() until bedwarsStore.queueType ~= "bedwars_test"
                if (not ChestStealerSkywars.Enabled) or bedwarsStore.queueType:find("skywars") then
                    repeat 
                        task.wait(0.1)
                        if entityLibrary.isAlive then
                            cheststealerfuncs[ChestStealerOpen.Enabled and "Open" or "Closed"]()
                        end
                    until (not ChestStealer.Enabled)
                end
            end)
        end
    end, "Steals items from chests for you")
	ChestStealerDistance = ChestStealer:CreateSlider("Range", function() end, 0, 18, 18)
	ChestStealerDelay = ChestStealer:CreateSlider("Delay", function() end, 1, 50, 1)
	ChestStealerOpen = ChestStealer:CreateToggle("GUI Check", function() end)
	ChestStealerSkywars = ChestStealer:CreateToggle("Only Skywars", function() end, true)
end)


runFunction(function()
	local AutoConsume = {Enabled = false}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {Enabled = true}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem("speed_potion")
			if lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem("apple")
				local pot = getItem("heal_splash_potion")
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					else
						local newray = workspace:Raycast((oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -76, 0), bedwarsStore.blockRaycast)
						if newray ~= nil then
							bedwars.ClientHandler:Get(bedwars.ProjectileRemote):CallServerAsync(pot.tool, "heal_splash_potion", "heal_splash_potion", (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), game:GetService("HttpService"):GenerateGUID(), {drawDurationSeconds = 1})
						end
					end
				end
			else
				autobankapple = false
			end
			if speedpotion and (not lplr.Character:GetAttribute("StatusEffect_speed")) and AutoConsumeSpeed.Enabled then 
				bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute("Shield_POTION") and ((not lplr.Character:GetAttribute("Shield_POTION")) or lplr.Character:GetAttribute("Shield_POTION") == 0) then
				local shield = getItem("big_shield") or getItem("mini_shield")
				if shield then
					bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
						item = shield.tool
					})
				end
			end
		end
	end

	AutoConsume = gui.Categories.Player:CreateModule("Auto Consume", function(callback)
        if callback then
            table.insert(AutoConsume.Connections, riseEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
            table.insert(AutoConsume.Connections, riseEvents.AttributeChanged.Event:Connect(function(changed)
                if changed:find("Shield") or changed:find("Health") or changed:find("speed") then 
                    AutoConsumeFunc()
                end
            end))
            AutoConsumeFunc()
        end
    end, "Automatically heals for you when health or shield is under threshold.")
	AutoConsumeHealth = AutoConsume:CreateSlider("Health", function() end, 1, 99, 70)
	AutoConsumeSpeed = AutoConsume:CreateToggle("Speed Potions", function() end)
end)

runFunction(function()
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldc1
	local oldfunc
	local nobob = gui.Categories.Render:CreateModule("View Bobbing", function(callback) 
        local viewmodel = gameCamera:FindFirstChild("Viewmodel")
        if viewmodel then
            if callback then
                oldfunc = bedwars.ViewmodelController.playAnimation
                bedwars.ViewmodelController.playAnimation = function(self, animid, details)
                    if animid == bedwars.AnimationType.FP_WALK then
                        return
                    end
                    return oldfunc(self, animid, details)
                end
                bedwars.ViewmodelController:setHeldItem(lplr.Character and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value and lplr.Character.HandInvItem.Value:Clone())
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(nobobdepth.Value / 10))
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (nobobhorizontal.Value / 10))
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (nobobvertical.Value / 10))
                oldc1 = viewmodel.RightHand.RightWrist.C1
                viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
            else
                bedwars.ViewmodelController.playAnimation = oldfunc
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", 0)
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0)
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", 0)
                viewmodel.RightHand.RightWrist.C1 = oldc1
            end
        end
	end, "Allows you to customize the camera shake when walking")
	nobobdepth = nobob:CreateSlider("Depth", function(val)
        if nobob.Enabled then
            lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(val / 10))
        end
    end, 0, 24, 8)
	nobobhorizontal = nobob:CreateSlider("Horizontal", function(val)
        if nobob.Enabled then
            lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (val / 10))
        end
    end, 0, 24, 8)
	nobobvertical = nobob:CreateSlider("Vertical", function(val)
        if nobob.Enabled then
            lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (val / 10))
        end
    end, -2, 24, -2)
	rotationx = nobob:CreateSlider("RotX", function(val)
        if nobob.Enabled then
            gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
        end
    end, 0, 360)
	rotationy = nobob:CreateSlider("RotY", function(val)
        if nobob.Enabled then
            gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
        end
    end, 0, 360)
	rotationz = nobob:CreateSlider("RotZ", function(val)
        if nobob.Enabled then
            gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
        end
    end, 0, 360)
end)

runFunction(function()
	local performed = false
	gui.Categories.Render:CreateModule("UI Cleanup", function(callback)
        if callback and not performed then 
            performed = true
            task.spawn(function()
                local hotbar = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-app"]).HotbarApp
                local hotbaropeninv = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-open-inventory"]).HotbarOpenInventory
                local topbarbutton = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).TopBarButton
                local gametheme = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.shared.ui["game-theme"]).GameTheme
                bedwars.AppController:closeApp("TopBarApp")
                local oldrender = topbarbutton.render
                topbarbutton.render = function(self) 
                    local res = oldrender(self)
                    if not self.props.Text then
                        return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
                    end
                    return res
                end
                hotbaropeninv.render = function(self) 
                    return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
                end
				debug.setconstant(hotbar.render, 52, 0.9975)
				debug.setconstant(hotbar.render, 72, 100)
				debug.setconstant(hotbar.render, 87, 1)
				debug.setconstant(hotbar.render, 88, 0.04)
				debug.setconstant(hotbar.render, 89, -0.025)
				debug.setconstant(hotbar.render, 104, 1.35)
                debug.setconstant(hotbar.render, 105, 0)
				for i,v in pairs(debug.getconstants(hotbar.render)) do 
				--	print(i,v)
				end
             	debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 30, 1)
                debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 31, 0.175)
                debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 33, -0.1)
				debug.setconstant(debug.getupvalue(hotbar.render, 18).render, 71, 0)
                debug.setconstant(debug.getupvalue(hotbar.render, 18).tweenPosition, 16, 0)
                gametheme.topBarBGTransparency = 0.5
                bedwars.TopBarController:mountHud()
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
                bedwars.AbilityUIController.abilityButtonsScreenGui.Visible = false
                bedwars.MatchEndScreenController.waitUntilDisplay = function() return false end
				task.spawn(function()
					repeat
						task.wait()
						local gui = lplr.PlayerGui:FindFirstChild("StatusEffectHudScreen")
						if gui then gui.Enabled = false break end
					until false
				end)
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0
					if bedwars.ClientStoreHandler:getState().Game.customMatch == nil then 
						debug.setconstant(bedwars.QueueCard.render, 9, 0.1)
					end
				end)
            end)
        end
    end, "Makes bedwars UI look nicer")
end)

runFunction(function()
	local FieldOfViewValue = {Value = 70}
	local oldfov
	local oldfov2
	local FieldOfView = {Enabled = false}
	local FieldOfViewZoom = {Enabled = false}
	FieldOfView = gui.Categories.Render:CreateModule("FOV Changer", function(callback)
        if callback then
            if FieldOfViewZoom.Enabled then
                task.spawn(function()
                    repeat
                        task.wait()
                    until not inputService:IsKeyDown(Enum.KeyCode[FieldOfView.Bind ~= "" and FieldOfView.Keybind or "C"])
                    if FieldOfView.Enabled then
                        FieldOfView:Toggle()
                    end
                end)
            end
            oldfov = bedwars.FovController.setFOV
            oldfov2 = bedwars.FovController.getFOV
            bedwars.FovController.setFOV = function(self, fov) return oldfov(self, FieldOfViewValue.Value) end
            bedwars.FovController.getFOV = function(self, fov) return FieldOfViewValue.Value end
        else
            bedwars.FovController.setFOV = oldfov
            bedwars.FovController.getFOV = oldfov2
        end
        bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
    end, "Changes camera fov")
	FieldOfViewValue = FieldOfView:CreateSlider("FOV", function(val)
        if FieldOfView.Enabled then
            bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
        end
    end, 30, 120, 90)
	FieldOfViewZoom = FieldOfView:CreateToggle("Zoom", function() end)
end)


runFunction(function()
	local ESPMethod = {Value = "2D"}
	local ESPTeammates = {Enabled = true}
	local espfolderdrawing = {}
	local espconnections = {}
	local methodused

	local function floorESPPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function ESPWorldToViewport(pos)
		local newpos = worldtoviewportpoint(gameCamera.CFrame:pointToWorldSpace(gameCamera.CFrame:pointToObjectSpace(pos)))
		return Vector2.new(newpos.X, newpos.Y)
	end

	local espfuncs1 = {
		Drawing2D = function(plr)
			if ESPTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {}
			thing.Quad1 = Drawing.new("Square")
			thing.Quad1.Transparency = 1
			thing.Quad1.ZIndex = 2
			thing.Quad1.Filled = false
			thing.Quad1.Thickness = 1
			thing.Quad1.Color = gui.MainColor
			thing.QuadLine2 = Drawing.new("Square")
			thing.QuadLine2.Transparency = 1
			thing.QuadLine2.ZIndex = 1
			thing.QuadLine2.Thickness = 1
			thing.QuadLine2.Filled = false
			thing.QuadLine2.Color = Color3.new()
			thing.QuadLine3 = Drawing.new("Square")
			thing.QuadLine3.Transparency = 1
			thing.QuadLine3.ZIndex = 1
			thing.QuadLine3.Thickness = 1
			thing.QuadLine3.Filled = false
			thing.QuadLine3.Color = Color3.new()
			espfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end
	}
	local espfuncs2 = {
		Drawing2D = function(ent)
			local v = espfolderdrawing[ent]
			espfolderdrawing[ent] = nil
			if v then 
				for i2,v2 in pairs(v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end
	}
	local espupdatefuncs = {
		Drawing2D = function(ent)
			local v = espfolderdrawing[ent.Player]
			if v and v.Main.Quad3 then 
				local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				v.Main.Quad3.Color = color
			end
		end
	}
	local esploop = {
		Drawing2D = function()
			for i,v in pairs(espfolderdrawing) do 
				local rootPos, rootVis = worldtoviewportpoint(v.entity.RootPart.Position)
				if not rootVis then 
					v.Main.Quad1.Visible = false
					v.Main.QuadLine2.Visible = false
					v.Main.QuadLine3.Visible = false
					continue 
				end
				local topPos, topVis = worldtoviewportpoint((CFrame.new(v.entity.RootPart.Position, v.entity.RootPart.Position + gameCamera.CFrame.lookVector) * CFrame.new(2, 3, 0)).p)
				local bottomPos, bottomVis = worldtoviewportpoint((CFrame.new(v.entity.RootPart.Position, v.entity.RootPart.Position + gameCamera.CFrame.lookVector) * CFrame.new(-2, -3.5, 0)).p)
				local sizex, sizey = topPos.X - bottomPos.X, topPos.Y - bottomPos.Y
				local posx, posy = (rootPos.X - sizex / 2),  ((rootPos.Y - sizey / 2))
				v.Main.Quad1.Position = floorESPPosition(Vector2.new(posx, posy))
				v.Main.Quad1.Color = gui:getAccentColor(Vector2.zero)
				v.Main.Quad1.Size = floorESPPosition(Vector2.new(sizex, sizey))
				v.Main.Quad1.Visible = true
				v.Main.QuadLine2.Position = floorESPPosition(Vector2.new(posx - 1, posy + 1))
				v.Main.QuadLine2.Size = floorESPPosition(Vector2.new(sizex + 2, sizey - 2))
				v.Main.QuadLine2.Visible = true
				v.Main.QuadLine3.Position = floorESPPosition(Vector2.new(posx + 1, posy - 1))
				v.Main.QuadLine3.Size = floorESPPosition(Vector2.new(sizex - 2, sizey + 2))
				v.Main.QuadLine3.Visible = true
			end
		end
	}

	local ESP = {Enabled = false}
	ESP = gui.Categories.Render:CreateModule("2D ESP", function(callback) 
        if callback then
            methodused = "Drawing2D"
            if espfuncs2[methodused] then
                table.insert(ESP.Connections, entityLibrary.entityRemovedEvent:Connect(espfuncs2[methodused]))
            end
            if espfuncs1[methodused] then
                local addfunc = espfuncs1[methodused]
                for i,v in pairs(entityLibrary.entityList) do 
                    if espfolderdrawing[v.Player] then espfuncs2[methodused](v.Player) end
                    addfunc(v)
                end
                table.insert(ESP.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
                    if espfolderdrawing[ent.Player] then espfuncs2[methodused](ent.Player) end
                    addfunc(ent)
                end))
            end
            if espupdatefuncs[methodused] then
                table.insert(ESP.Connections, entityLibrary.entityUpdatedEvent:Connect(espupdatefuncs[methodused]))
                for i,v in pairs(entityLibrary.entityList) do 
                    espupdatefuncs[methodused](v)
                end
            end
            if esploop[methodused] then 
                RunLoops:BindToRenderStep("ESP", esploop[methodused])
            end
        else
            RunLoops:UnbindFromRenderStep("ESP")
            if espfuncs2[methodused] then
                for i,v in pairs(espfolderdrawing) do 
                    espfuncs2[methodused](i)
                end
            end
        end
    end, "Renders players using a two-dimensional rectangle")
	ESPTeammates = ESP:CreateToggle("Priority Only", function() if ESP.Enabled then ESP:Toggle(true) ESP:Toggle(true) end end)
end)

runFunction(function()
	local function floorNameTagPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function removeTags(str)
        str = str:gsub("<br%s*/>", "\n")
        return (str:gsub("<[^<>]->", ""))
    end

	local NameTagsFolder = Instance.new("Folder")
	NameTagsFolder.Name = "NameTagsFolder"
	NameTagsFolder.Parent = gui.gui
	local nametagsfolderdrawing = {}

	local nametagfuncs1 = {
		Normal = function(plr)
			if (not plr.Targetable) then return end
			local thing = Instance.new("TextLabel")
			thing.BackgroundColor3 = Color3.new()
			thing.BorderSizePixel = 0
			thing.Visible = false
			thing.RichText = true
			thing.AnchorPoint = Vector2.new(0.5, 1)
			thing.Name = plr.Player.Name
			thing.FontFace = gui.Fonts.ProductSansLight
			thing.TextSize = 24
			thing.BackgroundTransparency = 0.5
			thing.Text = (plr.Player.DisplayName or plr.Player.Name)
			local corner = Instance.new("UICorner")
			corner.Parent = thing
			local nametagSize = gui:GetTextSize(thing.Text, 24, gui.Fonts.ProductSansLight).X + 8
			thing.Size = UDim2.new(0, nametagSize, 0, 32)
			thing.TextColor3 = gui.MainColor
			thing.Parent = NameTagsFolder
			nametagsfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end
	}

	local nametagfuncs2 = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				v.Main:Destroy()
			end
		end
	}

	local nametagloop = {
		Normal = function()
			for i,v in pairs(nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Visible = false
					continue
				end
				v.Main.TextColor3 = gui.MainColor
				v.Main.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
				v.Main.Visible = true
			end
		end
	}

	local methodused

	local NameTags = {Enabled = false}
	NameTags = gui.Categories.Render:CreateModule("Name Tags", function(callback) 
		if callback then
			methodused = "Normal"
			if nametagfuncs2[methodused] then
				table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
			end
			if nametagfuncs1[methodused] then
				local addfunc = nametagfuncs1[methodused]
				for i,v in pairs(entityLibrary.entityList) do 
					if nametagsfolderdrawing[v.Player] then nametagfuncs2[methodused](v.Player) end
					addfunc(v)
				end
				table.insert(NameTags.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
					if nametagsfolderdrawing[ent.Player] then nametagfuncs2[methodused](ent.Player) end
					addfunc(ent)
				end))
			end
			if nametagloop[methodused] then 
				RunLoops:BindToRenderStep("NameTags", nametagloop[methodused])
			end
		else
			RunLoops:UnbindFromRenderStep("NameTags")
			if nametagfuncs2[methodused] then
				for i,v in pairs(nametagsfolderdrawing) do 
					nametagfuncs2[methodused](i)
				end
			end
		end
	end, "Renders a custom name tag above entities")
end)