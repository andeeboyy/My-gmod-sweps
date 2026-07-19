AddCSLuaFile()

local candeploy = 1
local timerRunning = 0

-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Ragdoll"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"
SWEP.Purpose = "\nRagdoll!\n\nHold jump to bring your head up.\n\nHold sprint to move slightly.\n\nPrimary and Secondary attack lunge the corresponding arm on the side forward.\n\nUse left and right movement keys to grab things."
-- viewmodel
SWEP.ViewModel = "models/props_junk/PopCan01a.mdl"
SWEP.WorldModel = "models/props_junk/PopCan01a.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50
-- slots

SWEP.SlotPos = 1
SWEP.Slot = 0

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Ammo        = "none"

-- function stuff
function SWEP:Initialize()
    if CLIENT then return end
    self.camfollow = ents.Create("prop_physics")
end
function SWEP:Deploy()
    if CLIENT then return end

    local plr = self:GetOwner()

    if candeploy == 0 then
	timer.Simple(0, function()
	    plr:Give("weapon_swep")
	    plr:SelectWeapon("weapon_swep")
	    plr:StripWeapon("weapon_swep")
	    return true
    	end)
    end

    plr:DrawWorldModel(false)
    self.camfollow = ents.Create("prop_physics")
    self.camfollow:SetModel("models/props_junk/PopCan01a.mdl")
    self.camfollow:SetMaterial("Models/effects/vol_light001")
    self.ragname = "ragdoll" .. self:EntIndex()
    self.hookname2 = "damage" .. self:EntIndex()
    plr:SetNoDraw(true)
    plr:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    self.hookname = "hook" .. self:EntIndex()
    local ragdoll = ents.Create("prop_ragdoll")


    for _, ent in ipairs(ents.FindByName(self.ragname)) do
    	if IsValid(ent) then
	    ent:Remove()
	    ent:SetVelocity(ragdoll:GetVelocity() - plr:GetVelocity())
    	end
    end
    hook.Add("EntityTakeDamage", self.hookname2, function(hit, dmginfo)
	if hit == ragdoll then
	    if dmginfo:GetDamageType() == DMG_CRUSH then
		dmginfo:SetDamage(dmginfo:GetDamage() * 0.2)
		if dmginfo:GetDamage() < 20 then
		    dmginfo:SetDamage(0)
		end
	    end
	    plr:TakeDamageInfo(dmginfo)
	end
    end)
    ragdoll:CallOnRemove("cleanup", function()
	plr:SetViewEntity(plr)
	if plr:GetActiveWeapon() == "weapon_ragdoll" then
	    plr:ConCommand("lastinv")
	end
    end)
    local pangles = plr:GetAngles()
    pangles.roll = 0

    ragdoll:SetAngles(pangles)

    ragdoll:SetModel(plr:GetModel())
    ragdoll:SetPos(plr:GetPos())
    ragdoll:Spawn()

    local physobj = ragdoll:GetPhysicsObject()
    physobj:ApplyForceCenter(plr:GetVelocity() * 100)

    hook.Add("Tick", self.hookname, function()
	if !IsValid(ragdoll) then
	    candeploy = 1
    	    plr:SetNoDraw(false)
    	    plr:SetCollisionGroup(COLLISION_GROUP_NONE)
	    plr:Give("weapon_swep")
	    plr:SelectWeapon("weapon_swep")
	    plr:StripWeapon("weapon_ragdoll")
	    plr:Kill()
	    if IsValid(plr:GetRagdollEntity()) then
	    	plr:GetRagdollEntity():Remove()
	    end
	    return
	end
	if plr:GetMoveType() == MOVETYPE_NOCLIP then
	    plr:SetMoveType(MOVETYPE_WALK)
	end
	plr:SetNoDraw(true)
	local head = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
	local headmatrix = ragdoll:GetBoneMatrix(head)
	local headang = headmatrix:GetAngles()
	headang:RotateAroundAxis(headang:Up(), -90)
	headang:RotateAroundAxis(headang:Forward(), 90)

        plr:SetPos(ragdoll:GetPos())
	plr:SetViewEntity(self.camfollow)
        self.camfollow:SetPos(ragdoll:GetBonePosition(head) + self.camfollow:GetForward() * 5)
	headang:RotateAroundAxis(headang:Forward(), 180)
	self.camfollow:SetAngles(headang)
	local headphysobjnum = ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Head1"))
	local headphysobj = ragdoll:GetPhysicsObjectNum(headphysobjnum)

	local aim = plr:EyeAngles():Forward()
	local facedir = headang:Forward()
	local rotateaxis = facedir:Cross(aim)

	headphysobj:ApplyTorqueCenter(rotateaxis * 20)

	headphysobj:AddAngleVelocity(headphysobj:GetAngleVelocity() * -0.5)

	if plr:KeyDown(IN_JUMP) then
	    headphysobj:ApplyForceCenter(plr:EyeAngles():Up() * 250)
	end



	if plr:KeyPressed(IN_MOVELEFT) then
	    if IsValid(self.weldL) then
		plr:PrintMessage(4, "Let go with left hand")
		self.weldL:Remove()
	    else
	    	local hand = ragdoll:LookupBone("ValveBiped.Bip01_L_Hand")
	    	local handmatrix = ragdoll:GetBoneMatrix(hand)
	    	local handang = handmatrix:GetAngles()
	    	local handphys = ragdoll:TranslateBoneToPhysBone(hand)

	    	local tracepara = {}
	    	tracepara.mask = MASK_PLAYERSOLID
	    	tracepara.filter = ragdoll
	    	tracepara.start = ragdoll:GetBonePosition(hand)
            	tracepara.endpos = handang:Forward() * 20
	    	local trace = util.TraceLine(tracepara)
	    	if trace.Hit then
		    plr:PrintMessage(4, "Grabbed with left hand")
		    self.weldL = constraint.Weld(ragdoll, trace.Entity, handphys, trace.PhysicsBone)
	    	end
	    end
	end

	if plr:KeyPressed(IN_MOVERIGHT) then
	    if IsValid(self.weldR) then
		plr:PrintMessage(4, "Let go with right hand")
		self.weldR:Remove()
	    else
	    	local hand = ragdoll:LookupBone("ValveBiped.Bip01_R_Hand")
	    	local handmatrix = ragdoll:GetBoneMatrix(hand)
	    	local handang = handmatrix:GetAngles()
	    	local handphys = ragdoll:TranslateBoneToPhysBone(hand)

	    	local tracepara = {}
	    	tracepara.mask = MASK_PLAYERSOLID
	    	tracepara.filter = ragdoll
	    	tracepara.start = ragdoll:GetBonePosition(hand)
            	tracepara.endpos = handang:Forward() * 100
	    	local trace = util.TraceLine(tracepara)
	    	if trace.Hit then
		    plr:PrintMessage(4, "Grabbed with right hand")
		    self.weldR = constraint.Weld(ragdoll, trace.Entity, handphys, trace.PhysicsBone)
	    	end
	    end
	end




	if plr:IsSprinting() then
	    local torso = ragdoll:GetPhysicsObjectNum(0)
	    torso:ApplyForceCenter(plr:EyeAngles():Forward() * 150)
	end

    end)

    self.camfollow:Spawn()
    self.camfollow:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)



    ragdoll:SetKeyValue("targetname", self.ragname)

    candeploy = 0
    timerRunning = timerRunning + 1
    timer.Simple(2, function()
	timerRunning = timerRunning - 1
    end)
    timer.Simple(2, function()
	if timerRunning == 0 then
	    candeploy = 1
	end
    end)

    return true
end

function SWEP:Holster()
    local plr = self:GetOwner()
    if candeploy == 0 then
	if plr:Alive() then
	    if plr:GetUseEntity():IsVehicle() and plr:KeyDown(IN_USE) then
		candeploy = 1
	    else
 	    	return
	    end
	end
    end
    if !plr:Alive() then
	candeploy = 1
	if IsValid(plr:GetRagdollEntity()) then
	    plr:GetRagdollEntity():Remove()
	end
    	for _, ent in ipairs(ents.FindByName(self.ragname)) do
    	    if IsValid(ent) then
		plr:SetViewEntity(plr)
	    	ent:SetKeyValue("targetname", "")
    	    end
    	end
    	if SERVER then
    	    hook.Remove("Tick", self.hookname)
	    hook.Remove("EntityTakeDamage", self.hookname2)
	    self.camfollow:Remove()
    	end
	return
    end
    plr:SetNoDraw(false)
    plr:SetCollisionGroup(COLLISION_GROUP_NONE)

    if IsValid(self.camfollow) then
	self.camfollow:Remove()
    end

    local angle = plr:EyeAngles()
    angle.pitch = 0

    plr:SetEyeAngles(angle)

    if SERVER then
    	hook.Remove("Tick", self.hookname)
	hook.Remove("EntityTakeDamage", self.hookname2)
    end

    for _, ent in ipairs(ents.FindByName(self.ragname)) do
    	if IsValid(ent) then
	    ent:Remove()
	    plr:SetVelocity(ent:GetVelocity() - plr:GetVelocity())
    	end
    end

    return true
end

function SWEP:Reload()
    return
end

function SWEP:PrimaryAttack()
    local plr = self:GetOwner()
    for _, ent in ipairs(ents.FindByName(self.ragname)) do
	if !IsValid(ent) then return end
	
	local armnum = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_L_UpperArm"))
	local arm = ent:GetPhysicsObjectNum(armnum)
	if !IsValid(arm) then return end
	local aim = plr:EyeAngles():Forward()
	local armdir = arm:GetAngles():Forward()
	local rotateaxis = armdir:Cross(aim)
	arm:ApplyTorqueCenter(rotateaxis * 100)

	armnum = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_L_ForeArm"))
	arm = ent:GetPhysicsObjectNum(armnum)
	if !IsValid(arm) then return end
	aim = plr:EyeAngles():Forward()
	armdir = arm:GetAngles():Forward()
	rotateaxis = armdir:Cross(aim)
	arm:ApplyTorqueCenter(rotateaxis * 100)

	armnum = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_L_Hand"))
	arm = ent:GetPhysicsObjectNum(armnum)
	if !IsValid(arm) then return end
	aim = plr:EyeAngles():Forward()
	armdir = arm:GetAngles():Forward()
	rotateaxis = armdir:Cross(aim)
	arm:ApplyTorqueCenter(rotateaxis * 100)
    end
end

function SWEP:SecondaryAttack()
    local plr = self:GetOwner()
    for _, ent in ipairs(ents.FindByName(self.ragname)) do
	if !IsValid(ent) then return end
	
	local armnum = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_UpperArm"))
	local arm = ent:GetPhysicsObjectNum(armnum)
	if !IsValid(arm) then return end
	local aim = plr:EyeAngles():Forward()
	local armdir = arm:GetAngles():Forward()
	local rotateaxis = armdir:Cross(aim)
	arm:ApplyTorqueCenter(rotateaxis * 100)

	armnum = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_ForeArm"))
	arm = ent:GetPhysicsObjectNum(armnum)
	if !IsValid(arm) then return end
	aim = plr:EyeAngles():Forward()
	armdir = arm:GetAngles():Forward()
	rotateaxis = armdir:Cross(aim)
	arm:ApplyTorqueCenter(rotateaxis * 100)

	armnum = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_Hand"))
	arm = ent:GetPhysicsObjectNum(armnum)
	if !IsValid(arm) then return end
	aim = plr:EyeAngles():Forward()
	armdir = arm:GetAngles():Forward()
	rotateaxis = armdir:Cross(aim)
	arm:ApplyTorqueCenter(rotateaxis * 100)
    end
end

