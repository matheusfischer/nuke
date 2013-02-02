class NukeWeapon extends UDKWeapon
	HideCategories(Movement, Display, Attachment, Collision, Physics, Advanced, Debug, Object);
	
var(Weapon) const editinline instanced array<NukeWeaponFireMode> FireModes;

var(Crosshair) const Texture2D CrosshairTexture;
var(Crosshair) const float CrosshairRelativeSize;
var(Crosshair) const float CrosshairU;
var(Crosshair) const float CrosshairV;
var(Crosshair) const float CrosshairUL;
var(Crosshair) const float CrosshairVL;
var(Crosshair) const Color CrosshairColor;
var(Crosshair) const SoundCue CrosshairTargetLockSoundCue;

var ProtectedWrite Actor LastCrosshairTargetLock;

simulated event PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	if (FireModes.Length > 0)
	{
		for (i = 0; i < FireModes.Length; ++i)
		{
			if (FireModes[i] != None)
			{
				FireModes[i].SetOwner(Self);
			}
		}
	}
}

simulated function RenderCrosshair(HUD HUD)
{
	local float CrosshairSize;
	local Vector HitLocation, HitNormal, SocketLocation;
	local Rotator SocketRotation;
	local Actor HitActor;
	local SkeletalMeshComponent SkeletalMeshComponent;
	local Pawn HitPawn;

	if (HUD == None || HUD.Canvas == None || CrosshairTexture == None || CrosshairRelativeSize <= 0.f || CrosshairUL <= 0.f || CrosshairVL <= 0.f || CrosshairColor.A == 0)
	{
		return;
	}

	CrosshairSize = CrosshairRelativeSize * HUD.SizeX;

	SkeletalMeshComponent = SkeletalMeshComponent(Mesh);
	if (SkeletalMeshComponent != None && FireModes.Length > 0 && FireModes[0] != None && SkeletalMeshComponent.GetSocketByName(FireModes[0].FireSocketName) != None)
	{
		SkeletalMeshComponent.GetSocketWorldLocationAndRotation(FireModes[0].FireSocketName, SocketLocation, SocketRotation);
		HitActor = Trace(HitLocation, HitNormal, SocketLocation + Vector(SocketRotation) * 16384.f, SocketLocation, true,,, TRACEFLAG_Bullet);
		if (HitActor != None)
		{
			HitPawn = Pawn(HitActor);
			if (CrosshairTargetLockSoundCue != None && HitPawn != None && HitPawn.Health > 0 && LastCrosshairTargetLock != HitActor && Instigator != None)
			{
				LastCrosshairTargetLock = HitActor;
			}

			HitLocation = HUD.Canvas.Project(HitLocation);
		}
		else
		{
			HitLocation = HUD.Canvas.Project(SocketLocation + Vector(SocketRotation) * 16384.f);
			LastCrosshairTargetLock = None;
		}

		HUD.Canvas.SetPos(HitLocation.X - (CrosshairSize * 0.5f), HitLocation.Y - (CrosshairSize * 0.5f));
	}
	else
	{
		HUD.Canvas.SetPos((HUD.SizeX * 0.5f) - (CrosshairSize * 0.5f), (HUD.SizeY * 0.5f) - (CrosshairSize * 0.5f));
	}

	HUD.Canvas.DrawColor = CrosshairColor;
	HUD.Canvas.DrawTile(CrosshairTexture, CrosshairSize, CrosshairSize, CrosshairU, CrosshairV, CrosshairUL, CrosshairVL);
}

simulated function SendToFiringState(byte FireModeNum)
{
	if (FireModeNum >= FiringStatesArray.Length)
	{
		return;
	}

	SetCurrentFireMode(FireModeNum);
	GotoState(FiringStatesArray[FireModeNum]);
}

simulated function FireAmmunition()
{
	ConsumeAmmo(CurrentFireMode);
	
	if (CurrentFireMode < FireModes.Length && FireModes[CurrentFireMode] != None)
	{
		FireModes[CurrentFireMode].Fire();
	}

	NotifyWeaponFired(CurrentFireMode);
}

simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
	if (FireModeNum < FireModes.Length && FireModes[FireModeNum] != None)
	{
		FireModes[FireModeNum].PlayFiringEffects(HitLocation);
	}	
}

simulated function StopFireEffects(byte FireModeNum)
{
	if (FireModeNum < FireModes.Length && FireModes[FireModeNum] != None)
	{
		FireModes[FireModeNum].StopFiringEffects();
	}
}

simulated function AttachToPawn(Pawn NewPawn)
{	
	local NukePawn NukePawn;

	if (Mesh != None && NewPawn != None && NewPawn.Mesh != None)
	{
		NukePawn = NukePawn(NewPawn);
		if (NukePawn != None && NukePawn.Mesh.GetSocketByName(NukePawn.WeaponSocketName) != None)
		{
			NukePawn.Mesh.AttachComponentToSocket(Mesh, NukePawn.WeaponSocketName);
			Mesh.SetLightEnvironment(NukePawn.LightEnvironment);
			Mesh.SetShadowParent(NukePawn.Mesh);
			
			NukePawn.HasWeaponEquiped = 100.0f;
		}
	}
}

simulated state WeaponEquipping
{
	simulated function WeaponEquipped()
	{
		if (bWeaponPutDown)
		{
			PutDownWeapon();
			return;
		}

		AttachToPawn(Instigator);
		GotoState('Active');
	}
}

simulated function TimeWeaponFiring(byte FireModeNum)
{
	if (CurrentFireMode < FireModes.Length && FireModes[CurrentFireMode] != None && FireModes[CurrentFireMode].RequiredTickDuringFire)
	{
		return;
	}
	
	Super.TimeWeaponFiring(FireModeNum);
}

simulated function bool ShouldRefire()
{
	return Super.ShouldRefire();
}

simulated state WeaponFiring
{
	simulated function Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);
		
		if (FireModes[CurrentFireMode].IsSingleFire)
		{
			return;
		}

		if (CurrentFireMode < FireModes.Length && FireModes[CurrentFireMode] != None && FireModes[CurrentFireMode].RequiredTickDuringFire)
		{
			if (ShouldRefire())
			{
				FireModes[CurrentFireMode].Tick(DeltaTime);
			}
			else
			{
				HandleFinishedFiring();
			}
		}
	}

	simulated function EndState(Name NextStateName)
	{
		local int i;

		Super.EndState(NextStateName);

		if (FireModes.Length > 0)
		{
			for (i = 0; i < FireModes.Length; ++i)
			{
				if (FireModes[i] != None)
				{
					FireModes[i].StopFiringEffects();
				}
			}
		}
	}
}

defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
	End Object
	Mesh=MySkeletalMeshComponent
	Components.Add(MySkeletalMeshComponent)

	FiringStatesArray(0)="WeaponFiring"
	FiringStatesArray(1)="WeaponFiring"	
	CrosshairColor=(R=255,G=255,B=255,A=191)
}