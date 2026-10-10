AddCSLuaFile()

CreateConVar("sv_magic_crowbar_enabled", 1)

local spell = 1
local maxspells = 3
local reloaded = 0
local plr = Entity(1)
local ammoneeded = 0
local shot = 0
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "Magic Crowbar"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Other"
SWEP.Purpose = "Use the reload key to cycle through spells.\n\nThere are 3 spells to use."

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/c_crowbar.mdl"
SWEP.UseHands = false
SWEP.ViewModelFov = 50


SWEP.SlotPos = 3
SWEP.Slot = 0


SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true


SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Ammo        = "none"


function SWEP:Initialize()
    self:SetHoldType("magic")
end

local function checkammo(ent, ammo)
    if ent:Ammo1() < ammo then 
	return false
    else
	return true
    end
end

-- shoot
function SWEP:PrimaryAttack()
    if spell == 1 and shot == 0 then
	ammoneeded = 5
	if checkammo(self, ammoneeded) == false then
	    return
	end
	self:EmitSound("weapons/physcannon/superphys_launch1.wav", 140, 100, 1, CHAN_WEAPON)
	local prop = ents.Create("prop_physics")
	prop:SetModel("models/props_c17/oildrum001_explosive.mdl")
	prop:SetPos(plr:GetShootPos())
	prop:SetKeyValue("physdamagescale", 1)
    	prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    	timer.Simple(0.05, function()
	    if IsValid(prop) then
	    	prop:SetCollisionGroup(COLLISION_GROUP_NONE)
	    end
    	end)
	prop:Spawn()

	local physobj = prop:GetPhysicsObject()
	local spin = Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000), math.Rand(-1000, 1000))
	physobj:SetVelocity(plr:GetVelocity() + (plr:GetAimVector() * 50000))
	physobj:ApplyTorqueCenter(spin)
	prop:Ignite(100)
	self:SetNextSecondaryFire(CurTime() + 1)
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SendWeaponAnim(ACT_VM_MISSCENTER)
	plr:RemoveAmmo(ammoneeded, "AR2AltFire")
    end
    if spell == 2 and shot == 0 then
	ammoneeded = 5
	if checkammo(self, ammoneeded) == false then
	    return
	end
	self:EmitSound("friends/friend_join.wav", 140, 100, 1, CHAN_WEAPON)
	local tracepara = {}
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 100000
	tracepara.filter = self:GetOwner()
	tracepara.mask = MASK_SOLID
	local trace = util.TraceLine(tracepara)
    	if trace.Hit and IsValid(self) and IsValid(self:GetOwner()) then

	    local entity = trace.Entity
	    local dmg = DamageInfo()
	    local dmgvalue = 100
	    dmg:SetDamage(dmgvalue)
	    if trace.HitGroup == HITGROUP_HEAD then
		dmg:SetDamage(dmgvalue * 2)
	    else
		if trace.HitGroup > 3 then
		    dmg:SetDamage(dmgvalue * 0.25)
		else
		    if trace.HitGroup == 10 then
			dmg:SetDamage(dmgvalue * 0.01)
		    end
		end
	    end
	    dmg:SetDamageForce(self:GetOwner():GetAimVector() * 500)
	    dmg:SetDamagePosition(trace.HitPos)
	    dmg:SetAttacker(self:GetOwner())
	    dmg:SetInflictor(self)
	    dmg:SetDamageType(DMG_DISSOLVE + DMG_BLAST)
	    entity:TakeDamageInfo(dmg)
    	    local extrasound = ents.Create("base_gmodentity")
    	    extrasound:Spawn()
    	    extrasound:SetPos(trace.HitPos)
    	    extrasound:EmitSound("weapons/physcannon/energy_disintegrate4.wav", 100, 135, 1, CHAN_WEAPON)
    	    extrasound:Remove()
    	end	
	self:SetNextSecondaryFire(CurTime() + 1)
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SendWeaponAnim(ACT_VM_MISSCENTER)
	plr:RemoveAmmo(ammoneeded, "AR2AltFire")
    end
    if spell == 3 and shot == 0 then
	ammoneeded = 10
	if checkammo(self, ammoneeded) == false then
	    return
	end
	self:EmitSound("ambient/fire/ignite.wav", 140, 100, 1, CHAN_WEAPON)
	local tracepara = {}
    	tracepara.start = self:GetOwner():GetShootPos()
    	tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 100
    	tracepara.filter = self:GetOwner()
    	tracepara.mask = MASK_SHOT
    	local trace = util.TraceLine(tracepara)
        local randnumber = math.Rand(8, 15)
        local firephys = ents.Create("prop_physics_override")
        firephys:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
        if !trace.Hit then
            firephys:SetPos(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 75)
        else
            firephys:SetPos(self:GetOwner():GetShootPos())
        end
        firephys:SetNoDraw(true)
	firephys:SetKeyValue("health", 50)
	firephys:SetKeyValue("physdamagescale", 10)
	firephys:SetKeyValue("massScale", 1000)
	firephys:SetKeyValue("ExplodeDamage", 150)
	firephys:SetKeyValue("ExplodeRadius", 300)
        firephys:Spawn()

	firephys:CallOnRemove("Explode", function()
	    firephys:EmitSound("npc/env_headcrabcanister/explosion.wav", 140, 100, 1, CHAN_AUTO)
	    local boom = ents.Create("env_explosion")
	    boom:SetPos(firephys:GetPos())
	    boom:SetKeyValue("iMagnitude", 350)
	    boom:SetKeyValue("iRadiusOverride", 300)
	    boom:SetKeyValue("DamageForce", 0)
	    boom:Fire("Explode")
	    boom:Remove()
	end)
        constraint.Keepupright(firephys, Angle(0,0,0), 0, 999999)
        local fire = ents.Create("env_fire")
        fire:SetPos(firephys:GetPos())
        fire:SetKeyValue("health", "randnumber")
        fire:SetKeyValue("firesize", "150")
        fire:SetKeyValue("spawnflags", "400")
        fire:SetKeyValue("damagescale", "11.2")
        fire:SetKeyValue("fireattack", "1")
        fire:Spawn()
        fire:SetParent(firephys)
        fire:Fire("StartFire")
        local firevelocity = firephys:GetPhysicsObject()
        if firevelocity:IsValid() then
            firevelocity:Wake()
            local speedinherit = self:GetOwner():GetVelocity()
            firevelocity:SetVelocity(speedinherit + self:GetOwner():GetAimVector() * 1000)
            timer.Simple(randnumber, function()
                if IsValid(firephys) then
                    firephys:Remove()
                end
            end)
        end
    	self:SetNextSecondaryFire(CurTime() + 1)
    	self:SetNextPrimaryFire(CurTime() + 1)
    	self:SendWeaponAnim(ACT_VM_MISSCENTER)
    	plr:RemoveAmmo(ammoneeded, "AR2AltFire")
    end
    shot = 1
end
function SWEP:SecondaryAttack()
    if spell == 1 then
	ammoneeded = 1
	if checkammo(self, ammoneeded) == false then
	    return
	end
	self:EmitSound("ambient/energy/zap1.wav", 140, 100, 1, CHAN_WEAPON)
	local prop = ents.Create("prop_physics")
	prop:SetModel("models/props_junk/gascan001a.mdl")
	prop:SetPos(plr:GetShootPos())
	prop:SetKeyValue("physdamagescale", 1)
    	prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    	timer.Simple(0.05, function()
	    if IsValid(prop) then
	    	prop:SetCollisionGroup(COLLISION_GROUP_NONE)
	    end
    	end)
	prop:Spawn()

	local physobj = prop:GetPhysicsObject()
	local spin = Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000), math.Rand(-1000, 1000))
	physobj:SetVelocity(plr:GetVelocity() + (plr:GetAimVector() * 50000))
	physobj:ApplyTorqueCenter(spin)
	prop:Ignite(100)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SendWeaponAnim(ACT_VM_MISSCENTER)
	plr:RemoveAmmo(ammoneeded, "AR2AltFire")
    end
    if spell == 2 then
	ammoneeded = 1
	if checkammo(self, ammoneeded) == false then
	    return
	end
	self:EmitSound("friends/message.wav", 140, 100, 1, CHAN_WEAPON)
	local tracepara = {}
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 100000
	tracepara.filter = self:GetOwner()
	tracepara.mask = MASK_SOLID
	local trace = util.TraceLine(tracepara)
    	if trace.Hit and IsValid(self) and IsValid(self:GetOwner()) then

	    local entity = trace.Entity
	    local dmg = DamageInfo()
	    local dmgvalue = 25
	    dmg:SetDamage(dmgvalue)
	    if trace.HitGroup == HITGROUP_HEAD then
		dmg:SetDamage(dmgvalue * 2)
	    else
		if trace.HitGroup > 3 then
		    dmg:SetDamage(dmgvalue * 0.25)
		else
		    if trace.HitGroup == 10 then
			dmg:SetDamage(dmgvalue * 0.01)
		    end
		end
	    end
	    dmg:SetDamageForce(self:GetOwner():GetAimVector() * 500)
	    dmg:SetDamagePosition(trace.HitPos)
	    dmg:SetAttacker(self:GetOwner())
	    dmg:SetInflictor(self)
	    dmg:SetDamageType(DMG_DISSOLVE + DMG_SHOCK)
	    entity:TakeDamageInfo(dmg)
    	    local extrasound = ents.Create("base_gmodentity")
    	    extrasound:Spawn()
    	    extrasound:SetPos(trace.HitPos)
    	    extrasound:EmitSound("weapons/stunstick/stunstick_impact1.wav", 100, 100, 1, CHAN_WEAPON)
    	    extrasound:Remove()
    	end	
	self:SetNextSecondaryFire(CurTime() + 0.25)
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SendWeaponAnim(ACT_VM_MISSCENTER)
	plr:RemoveAmmo(ammoneeded, "AR2AltFire")
    end
    if spell == 3 then
	ammoneeded = 2
	if checkammo(self, ammoneeded) == false then
	    return
	end
	self:EmitSound("ambient/fire/gascan_ignite1.wav", 140, 100, 1, CHAN_WEAPON)
	local tracepara = {}
    	tracepara.start = self:GetOwner():GetShootPos()
    	tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 100
    	tracepara.filter = self:GetOwner()
    	tracepara.mask = MASK_SHOT
    	local trace = util.TraceLine(tracepara)
        local randnumber = math.Rand(8, 15)
        local firephys = ents.Create("prop_physics_override")
        firephys:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
        if !trace.Hit then
            firephys:SetPos(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 75)
        else
            firephys:SetPos(self:GetOwner():GetShootPos())
        end
        firephys:SetNoDraw(true)
	firephys:SetKeyValue("health", 50)
	firephys:SetKeyValue("physdamagescale", 10)
	firephys:SetKeyValue("massScale", 1000)
	firephys:SetKeyValue("ExplodeDamage", 75)
	firephys:SetKeyValue("ExplodeRadius", 100)
        firephys:Spawn()

	firephys:CallOnRemove("Explode", function()
	    local boom = ents.Create("env_explosion")
	    boom:SetPos(firephys:GetPos())
	    boom:SetKeyValue("iMagnitude", 75)
	    boom:SetKeyValue("iRadiusOverride", 100)
	    boom:SetKeyValue("DamageForce", 0)
	    boom:Fire("Explode")
	    boom:Remove()
	end)
        constraint.Keepupright(firephys, Angle(0,0,0), 0, 999999)
        local fire = ents.Create("env_fire")
        fire:SetPos(firephys:GetPos())
        fire:SetKeyValue("health", "randnumber")
        fire:SetKeyValue("firesize", "150")
        fire:SetKeyValue("spawnflags", "400")
        fire:SetKeyValue("damagescale", "11.2")
        fire:SetKeyValue("fireattack", "1")
        fire:Spawn()
        fire:SetParent(firephys)
        fire:Fire("StartFire")
        local firevelocity = firephys:GetPhysicsObject()
        if firevelocity:IsValid() then
            firevelocity:Wake()
            local speedinherit = self:GetOwner():GetVelocity()
            firevelocity:SetVelocity(speedinherit + self:GetOwner():GetAimVector() * 1000)
            timer.Simple(randnumber, function()
                if IsValid(firephys) then
                    firephys:Remove()
                end
            end)
        end
    	self:SetNextSecondaryFire(CurTime() + 1)
    	self:SetNextPrimaryFire(CurTime() + 1)
    	self:SendWeaponAnim(ACT_VM_MISSCENTER)
    	plr:RemoveAmmo(ammoneeded, "AR2AltFire")
    end
    shot = 1
end


function SWEP:Reload()
    if reloaded == 1 then return end
    self:EmitSound("friends/friend_online.wav", 140, 100, 1, CHAN_WEAPON)
    reloaded = 1
    if spell > maxspells - 1 then
	spell = 1
    else
	spell = spell + 1
    end
    if spell == 1 then
	plr:PrintMessage(HUD_PRINTCENTER, "Spell 1: Flaming Barrel")
    end
    if spell == 2 then
	plr:PrintMessage(HUD_PRINTCENTER, "Spell 2: Vaporize")
    end
    if spell == 3 then
	plr:PrintMessage(HUD_PRINTCENTER, "Spell 3: Fireball")
    end
end

function SWEP:Deploy()
    if GetConVar("sv_magic_crowbar_enabled"):GetFloat() < 1 then
	self:Remove()
	return
    end
    plr = self:GetOwner()
    shot = 0
    return true
end

function SWEP:Holster()
    shot = 0
    return true
end

function SWEP:Think()
    if plr:KeyReleased(IN_RELOAD) then
	reloaded = 0
    end
    if plr:KeyReleased(IN_ATTACK) then
	shot = 0
    end
end