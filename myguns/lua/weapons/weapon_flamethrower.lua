AddCSLuaFile()
local AccuracyMeter = 0
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "Flamethrower"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Incendiary"

-- viewmodel

SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50
-- slots

SWEP.SlotPos = 3
SWEP.Slot = 2

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetHoldType("shotgun")
end


-- shoot
function SWEP:PrimaryAttack()
    if !self:HasAmmo() then return end
    local randnumber = math.Rand(8, 15)
    local firephys = ents.Create("prop_physics")
    firephys:SetModel("models/hunter/plates/plate.mdl")
    local tracepara = {}
    tracepara.start = self:GetOwner():GetShootPos()
    tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 100
    tracepara.filter = self:GetOwner()
    tracepara.mask = MASK_SHOT
    local trace = util.TraceLine(tracepara)
    if !trace.Hit then
	firephys:SetPos(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 75)
    else
	firephys:SetPos(self:GetOwner():GetShootPos())
    end
    firephys:SetNoDraw(true)
    firephys:Spawn()
    local function Ignite(collider, colData)
	local victim = colData.HitEntity
	if IsValid(victim) and !victim:IsWorld() and victim:IsOnFire() then
	    local dmg = DamageInfo()
	    dmg:SetDamage(2)
	    dmg:SetAttacker(self:GetOwner())
	    dmg:SetInflictor(self)
	    dmg:SetDamageType(DMG_BURN)
	    victim:TakeDamageInfo(dmg)
	end
	if IsValid(victim) and !victim:IsWorld() and !victim:IsOnFire() then
	    firephys:EmitSound("ambient/fire/ignite.wav", 140, 85, 1, CHAN_WEAPON)
	    victim:Ignite(10)
	    firephys:Remove()
	end
    end
    firephys:AddCallback("PhysicsCollide", Ignite)

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
	firevelocity:SetVelocity(speedinherit + self:GetOwner():GetAimVector() * 2000)
	timer.Simple(randnumber, function()
	    if IsValid(firephys) then
		firephys:Remove()
	    end
	end)
    end
    
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:EmitSound("ambient/fire/gascan_ignite1.wav", 140, 100, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.06)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:TakePrimaryAmmo(1)
    if !self:GetOwner():IsNPC() then
    	self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0))
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -3 + ang:Up() * 1 + ang:Forward() * -4
    return pos, ang
end


