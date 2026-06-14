AddCSLuaFile()
local AccuracyMeter = 0.015
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "M3 Super 90"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 1
SWEP.Slot = 3

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetHoldType("Shotgun")
end


-- shoot
function SWEP:PrimaryAttack()
    if timer.Exists("reload") then
	timer.Remove("reload")
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	self:SetNextPrimaryFire(CurTime() + 0.4)
	return
    end
    if ( !self:CanPrimaryAttack() ) then return end
    if !self:GetOwner():IsNPC() then
    	self:GetOwner():ViewPunch( Angle( AccuracyMeter * -160, math.random(AccuracyMeter * 160, AccuracyMeter * -160), 0 ) )
    end
    timer.Simple(0.5, function()
	self:EmitSound("weapons/shotgun/shotgun_cock.wav", 140, 85, 1, CHAN_WEAPON)
    end)
    local bullet = {}
	bullet.Damage = 6
	bullet.Num = 9
	bullet.Force = 2
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.15
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    EmitSound("weapons/shotgun/shotgun_dbl_fire.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 90)
    self:EmitSound("weapons/shotgun/shotgun_fire7.wav", 140, 80, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 1)
    self:TakePrimaryAmmo(1)
end

-- reload the magazine to shoot more bullets

function SWEP:Reload()
    if timer.Exists("reload") then
	return
    else
    	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
    	timer.Create("reload", 0.45, 0, function()
	    if !IsValid(self:GetOwner()) then
		timer.Remove("reload")
		return
	    end
	    if self:Ammo1() == 0 then
		timer.Remove("reload")
		self:SetNextPrimaryFire(CurTime() + 0.4)
	    	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	    	return
	    end
	    if self:Clip1() > self:GetMaxClip1() - 1 then
		self:SetNextPrimaryFire(CurTime() + 0.4)
		timer.Remove("reload")
	    	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	    	return
	    end
	    timer.Simple(0.3, function()
	        self:SetClip1(self:Clip1() + 1)
		self:GetOwner():RemoveAmmo(1, "Buckshot")
	    end)
	    self:SendWeaponAnim(ACT_VM_RELOAD)
	end)
    end
    self:GetOwner():SetAnimation(PLAYER_RELOAD)
end

function SWEP:Think()
    if AccuracyMeter > 0.01 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.1 * FrameTime()))
    end
end

function SWEP:Holster()
    if timer.Exists("reload") then
	timer.Remove("reload")
    end
    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -4 + ang:Up() * 1 + ang:Forward() * -7
    return pos, ang
end
