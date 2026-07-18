AddCSLuaFile()



-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Ragdoll"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

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
    self.camfollow = ents.Create("prop_physics")
    self.camfollow:SetModel("models/props_junk/PopCan01a.mdl")
    self.camfollow:SetMaterial("Models/effects/vol_light001")
    self.ragname = "ragdoll" .. self:EntIndex()
    self.hookname2 = "damage" .. self:EntIndex()
    local plr = self:GetOwner()
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
		dmginfo:SetDamage(dmginfo:GetDamage() * 0.1)
		if dmginfo:GetDamage() < 5 then
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

    hook.Add("Tick", self.hookname, function()
	if !IsValid(ragdoll) then return end
	local head = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
	local headmatrix = ragdoll:GetBoneMatrix(head)
	local headang = headmatrix:GetAngles()
	headang:RotateAroundAxis(headang:Up(), -90)
	headang:RotateAroundAxis(headang:Forward(), 90)
	plr:SetVelocity(ragdoll:GetVelocity() - plr:GetVelocity())
        plr:SetPos(ragdoll:GetPos())
	plr:SetViewEntity(self.camfollow)
        self.camfollow:SetPos(ragdoll:GetBonePosition(head) + self.camfollow:GetForward() * 5)
	headang:RotateAroundAxis(headang:Forward(), 180)
	self.camfollow:SetAngles(headang)
	local headphysobjnum = ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Head1"))
	local headphysobj = ragdoll:GetPhysicsObjectNum(headphysobjnum)
	if plr:KeyDown(IN_JUMP) then
	    headphysobj:ApplyForceCenter(plr:EyeAngles():Up() * 365)
	end


	local aimpara = {}

	local aimangle = plr:EyeAngles()

	aimangle:RotateAroundAxis(aimangle:Forward(), 90)

	aimpara.secondstoarrive = 0.1
	aimpara.pos = Vector(headphysobj:GetPos())
	aimpara.angle = Angle(aimangle)
	aimpara.maxangular = 50000000
	aimpara.maxangulardamp = 1000000
	aimpara.maxspeed = 10000000
	aimpara.maxspeeddamp = 1000000
	aimpara.dampfactor = 0.8
	aimpara.teleportdistance = 2000
	aimpara.delta = deltatime

	headphysobj:ComputeShadowControl(aimpara)

	if plr:IsSprinting() then
	    local torso = ragdoll:GetPhysicsObjectNum(0)
	    torso:ApplyForceCenter(plr:EyeAngles():Forward() * 250)
	end
    end)
    self.camfollow:Spawn()
    self.camfollow:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)




    physobj:SetVelocity(plr:GetVelocity() * 100)
    ragdoll:SetKeyValue("targetname", self.ragname)
    ragdoll:SetKeyValue("physdamagescale", 0)

    return true
end

function SWEP:Holster()
    local plr = self:GetOwner()
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
	local handnum = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_L_Hand"))
	local hand = ent:GetPhysicsObjectNum(handnum)
	if !IsValid(hand) then return end
	hand:ApplyForceCenter(plr:EyeAngles():Forward() * 200)
    end
end

function SWEP:SecondaryAttack()
    local plr = self:GetOwner()
    for _, ent in ipairs(ents.FindByName(self.ragname)) do
	if !IsValid(ent) then return end
	local handnum = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_Hand"))
	local hand = ent:GetPhysicsObjectNum(handnum)
	if !IsValid(hand) then return end
	hand:ApplyForceCenter(plr:EyeAngles():Forward() * 200)
    end
end
