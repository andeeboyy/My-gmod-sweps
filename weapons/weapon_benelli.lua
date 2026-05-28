AddCSLuaFile()
local AccuracyMeter = 0
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "Benelli M4"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 1

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
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
    	self:GetOwner():ViewPunch( Angle( -10, math.random(10, -10), 0 ) )
    end
    local bullet = {}
	bullet.Damage = 6
	bullet.Num = 9
	bullet.Force = 2
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.1
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 140, 80, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.2)
    self:TakePrimaryAmmo(1)
end

-- reload the magazine to shoot more bullets

function SWEP:Reload()
    if timer.Exists("reload") then
	return
    else
    	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
    	timer.Create("reload", 0.6, 0, function()
	    if !IsValid(self:GetOwner()) then
		timer.Remove("reload")
		return
	    end
	    if self:Ammo1() == 0 then
		timer.Remove("reload")
	    	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	    	return
	    end
	    if self:Clip1() > self:GetMaxClip1() - 1 then
		timer.Remove("reload")
	    	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	    	return
	    end
	    timer.Simple(0.4, function()
	        self:SetClip1(self:Clip1() + 1)
		self:GetOwner():RemoveAmmo(1, "Buckshot")
	    end)
	    self:SendWeaponAnim(ACT_VM_RELOAD)
	end)
    end
    self:GetOwner():SetAnimation(PLAYER_RELOAD)
end

function SWEP:Think()
    if AccuracyMeter > 0.05 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.5 * FrameTime()))
    end
end


