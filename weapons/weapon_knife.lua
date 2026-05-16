AddCSLuaFile()
-- my first melee weapon!, based on the mp5.

-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Knife"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
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

-- anim
function SWEP:Initialize()
    self:SetHoldType("knife")
end

-- shoot
function SWEP:PrimaryAttack()
    local bullet = {}
	bullet.Damage = 5
	bullet.Num = 3
	bullet.Force = 0.05
	bullet.Distance = 30
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(0.4, 0.05, 0.4)
	bullet.TracerName = "none"
	bullet.Tracer = 0
    timer.Simple(0.075, function()
    	self:FireBullets(bullet)
	bullet.Distance = 40
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.1, function()
    	self:FireBullets(bullet)
	bullet.Distance = 50
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.125, function()
    	self:FireBullets(bullet)
	bullet.Distance = 65
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.15, function()
    	self:FireBullets(bullet)
	bullet.Distance = 50
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.175, function()
    	self:FireBullets(bullet)
	bullet.Distance = 40
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.2, function()
    	self:FireBullets(bullet)
	bullet.Distance = 30
    end)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("npc/vort/claw_swing2.wav", 120, 100, 1, CHAN_AUTO)
    self:SetNextPrimaryFire(CurTime() + 0.66)
    self:SetNextSecondaryFire(CurTime() + 0.8)
end

function SWEP:SecondaryAttack()
    local bullet = {}
	bullet.Damage = 2
	bullet.Num = 3
	bullet.Force = 0.1
	bullet.Distance = 45
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(0.1, 0.05, 0.1)
	bullet.TracerName = "none"
	bullet.Tracer = 0
    timer.Simple(0.05, function()
    	self:FireBullets(bullet)
	bullet.Distance = 65
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.06, function()
    	self:FireBullets(bullet)
	bullet.Distance = 75
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.07, function()
    	self:FireBullets(bullet)
	bullet.Distance = 76
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.08, function()
    	self:FireBullets(bullet)
	bullet.Distance = 77
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.09, function()
    	self:FireBullets(bullet)
	bullet.Distance = 78
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Damage = 3
	bullet.Num = 1
	bullet.Spread = Vector(0, 0, 0)
    end)
    timer.Simple(0.1, function()
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 79
    end)
    timer.Simple(0.15, function()
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 80
    end)
    timer.Simple(0.2, function()
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 81
    end)
    timer.Simple(0.25, function()
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 82
    end)
    timer.Simple(0.3, function()
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 83
    end)
    timer.Simple(0.35, function()
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 84
    end)
    timer.Simple(0.4, function()
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 85
    end)
    timer.Simple(0.45, function()
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 86
    end)
    timer.Simple(0.5, function()
    	self:FireBullets(bullet)
    end)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 120, 70, 1, CHAN_AUTO)
    self:SetNextSecondaryFire(CurTime() + 0.8)
    self:SetNextPrimaryFire(CurTime() + 0.8)
end
