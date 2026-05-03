AddCSLuaFile()

local armed = 0
-- spawnmenu
local shoot = 0
SWEP.Spawnable = true
SWEP.PrintName = "AT4"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 4

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim

function SWEP:Initialize()
    self:SetDeploySpeed(0.5)
end

-- shoot
function SWEP:PrimaryAttack()
    if self:Clip1() < 1 then
	self:GetOwner():SetWalkSpeed(200)
        self:GetOwner():SetRunSpeed(400)
	self:GetOwner():SetDuckSpeed(0.1)
	self:GetOwner():SetUnDuckSpeed(0.1)
	self:GetOwner():SetJumpPower(200)
	local drop = ents.Create("prop_physics")
	drop:SetModel("models/weapons/w_rocket_launcher.mdl")
	drop:SetPos(self:GetOwner():GetShootPos())
	drop:SetAngles(self:GetOwner():GetAimVector():Angle())
	drop:Spawn()
	local throw = drop:GetPhysicsObject()
	if IsValid(throw) then
	    throw:Wake()
	    local throwVelocity = self:GetOwner():GetAimVector() * 50
            local playerVelocity2 = self:GetOwner():GetVelocity()
            throw:SetVelocity(throwVelocity + playerVelocity2)
	end
	self:GetOwner():StripWeapon("weapon_at4")
    else
	if armed == 0 then return end
	self:TakePrimaryAmmo(1)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        self:EmitSound("weapons/stinger_fire1.wav", 120, math.Rand(90, 133), 1, CHAN_WEAPON)
        local rocket = ents.Create("prop_dynamic")
        if !IsValid(rocket) then return end
    	rocket:SetModel("models/weapons/w_missile.mdl")
    	rocket:SetPos(self:GetOwner():GetShootPos())
    	rocket:SetAngles(self:GetOwner():GetAimVector():Angle())
	local prop = ents.Create("prop_physics")
	prop:SetModel("models/props_phx/construct/wood/wood_boardx1.mdl")
	prop:SetKeyValue("modelscale", 0.35)
	prop:SetKeyValue("physdamagescale", 100)
	prop:SetPos(self:GetOwner():GetShootPos())
	prop:SetAngles(self:GetOwner():GetAimVector():Angle())
	prop:SetKeyValue("ExplodeDamage", "5000")
	prop:SetKeyValue("ExplodeRadius", "300")
	prop:SetKeyValue("massScale", 1.65)
	prop:SetNoDraw(true)
    	rocket:Spawn()
	prop:Spawn()
	rocket:SetParent(prop)
	
	prop:CallOnRemove("Explode", function()
	    local randompicker = math.random(1, 4)
	    if randompicker == 1 then
	        prop:EmitSound("ambient/explosions/explode_2.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	    end
	    if randompicker == 2 then
	        prop:EmitSound("ambient/explosions/explode_3.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	    end
	    if randompicker == 3 then
	        prop:EmitSound("ambient/explosions/explode_1.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	    end
	    if randompicker == 4 then
	        prop:EmitSound("ambient/explosions/explode_5.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	    end
	    local boom = ents.Create("env_explosion")
	    boom:SetPos(prop:GetPos())
	    boom:SetKeyValue("iMagnitude", 10000)
	    boom:SetKeyValue("iRadiusOverride", 100)
	    boom:Fire("Explode")

	    local boom2 = ents.Create("env_explosion")
	    boom2:SetPos(prop:GetPos())
	    boom2:SetKeyValue("iMagnitude", 150)
	    boom2:SetKeyValue("iRadiusOverride", 750)
	    boom2:Fire("Explode")

    	    local splashPos = prop:GetPos() 
    	    local burned = ents.FindInSphere(splashPos, 150)
	    
    	    for _, burning in pairs(burned) do
		if IsValid(burning) and !burning:IsWorld() then
	    	    burning:Ignite(math.Rand(60, 120))
		end
    	    end


	    for k, v in ipairs(ents.FindByClass("predicted_viewmodel")) do
	    	v:Extinguish()
	    end
	    
	    for k, v in ipairs(ents.FindByClass("weapon_")) do
	    	v:Extinguish()
	    end
	    
	    for k, v in ipairs(ents.FindByClass("physgun_beam")) do
	    	v:Extinguish()
	    end

	    for i = 1, math.random(10, 30) do
		 local offset = Vector(
		     math.Rand(-10, 10),
		     math.Rand(-10, 10),
		     0
		 )
		 
		 local push = Vector(
		     math.Rand(-1000, 1000),
		     math.Rand(-1000, 1000),
		     math.Rand(-1000, 1000)
		 )
		 
	    	-- fire
		 local randnumber = math.random(1, 3)
	   	 local firephys = ents.Create("prop_physics")
	   	 firephys:SetModel("models/hunter/plates/plate.mdl")
		 firephys:SetKeyValue("massScale", "10")
	   	 firephys:SetPos(prop:GetPos() + offset)
	   	 firephys:SetNoDraw(true)
	   	 firephys:Spawn()


		 constraint.Keepupright(firephys, Angle(0,0,0), 0, 999999)
	   	 local fire = ents.Create("env_fire")
	   	 fire:SetPos(firephys:GetPos())
	   	 fire:SetKeyValue("health", "randnumber")
	  	 fire:SetKeyValue("firesize", "200")
	   	 fire:SetKeyValue("spawnflags", "400")
	    	 fire:SetKeyValue("damagescale", "3.10625")
	   	 fire:SetKeyValue("fireattack", "1")
	   	 fire:Spawn()
	   	 fire:SetParent(firephys)
	    	 fire:Fire("StartFire")
		 local firevelocity = firephys:GetPhysicsObject()
		 if firevelocity:IsValid() then
		     firevelocity:Wake()
		     local speedinherit = push
		     firevelocity:SetVelocity(speedinherit)
		 end

		 local angle = Angle(0, 0, 0)
		 timer.Simple(randnumber, function()
		     if IsValid(firephys) then
		         firephys:Remove()
		     end
		 end)
	    end


	end)

	local velocity = self:GetOwner():GetVelocity()

	local speed = velocity:Length()

	local spread = Vector(math.Rand(speed * -5, speed * 5), math.Rand(speed * -5, speed * 5), math.Rand(speed * -5, speed * 5))

    	local woosh = prop:GetPhysicsObject()

    	    if IsValid(woosh) then
	    woosh:Wake()
	    local shootVelocity = self:GetOwner():GetAimVector() * 5000
            local playerVelocity = self:GetOwner():GetVelocity()
            woosh:SetVelocity(shootVelocity + playerVelocity + spread)
	end
    end
end
function SWEP:SecondaryAttack()
    if armed == 1 then
	timer.Simple(1.3, function()
	    if !IsValid(self) then return end
    	    self:GetOwner():SetWalkSpeed(200)
    	    self:GetOwner():SetRunSpeed(400)
    	    self:GetOwner():SetDuckSpeed(0.1)
    	    self:GetOwner():SetUnDuckSpeed(0.1)
    	    self:GetOwner():SetJumpPower(200)
	end)
	self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
	self:SetNextSecondaryFire(CurTime() + 1.3)
	self:SetHoldType("passive")
	armed = 0
    else
	self:GetOwner():SetWalkSpeed(50)
    	self:GetOwner():SetRunSpeed(50)
    	self:GetOwner():SetDuckSpeed(0.95)
    	self:GetOwner():SetUnDuckSpeed(0.95)
    	self:GetOwner():SetJumpPower(0)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType("rpg")
	self:SetNextSecondaryFire(CurTime() + 1.3)
	timer.Simple(1.3, function()
	    if !IsValid(self) then return end
	    armed = 1
	end)
    end
end

function SWEP:Deploy()
    armed = 0
    self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
    self:SetHoldType("passive")
    return true
end

function SWEP:Holster()
    self:GetOwner():SetWalkSpeed(200)
    self:GetOwner():SetRunSpeed(400)
    self:GetOwner():SetDuckSpeed(0.1)
    self:GetOwner():SetUnDuckSpeed(0.1)
    self:GetOwner():SetJumpPower(200)
    return true
end