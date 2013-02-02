class NukeWeaponFireMode extends Object
	HideCategories(Object)
	EditInlineNew
	Abstract;
	
var(FireMode) const Name MuzzleSocketEffectName;

var(FireMode) const Name FireSocketName;

var(FireMode) const bool HasRecoil;

var(FireMode) const bool IsSingleFire;

var(FireMode) const bool RequiredTickDuringFire;

var(Particles) const ParticleSystem FireParticleTemplate;

var ProtectedWrite NukeWeapon Owner;

var ProtectedWrite ParticleSystemComponent MuzzleFlashParticleSystem;

simulated function SetOwner(NukeWeapon NewOwner)
{
	if (NewOwner != None)
	{
		Owner = NewOwner;
	}
}

final simulated function Fire()
{
	if (Owner != None)
	{
		BeginFire();
	}
}

simulated function PlayFiringEffects(optional Vector HitLocation)
{
	local SkeletalMeshComponent SkeletalMeshComponent;

	if (Owner == None)
	{
		return;
	}

	SkeletalMeshComponent = SkeletalMeshComponent(Owner.Mesh);
	if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(MuzzleSocketEffectName) != None)
	{
		if (FireParticleTemplate != None)
		{
			if (MuzzleFlashParticleSystem == None)
			{
				MuzzleFlashParticleSystem = new () class'ParticleSystemComponent';
				if (MuzzleFlashParticleSystem != None)
				{
					MuzzleFlashParticleSystem.SetTemplate(FireParticleTemplate);
					SkeletalMeshComponent.AttachComponentToSocket(MuzzleFlashParticleSystem, MuzzleSocketEffectName);
				}
			}

			if (MuzzleFlashParticleSystem != None)
			{
				MuzzleFlashParticleSystem.ActivateSystem();
			}
		}
	}
}

simulated function StopFiringEffects()
{
	if (Owner == None)
	{
		return;
	}

	if (MuzzleFlashParticleSystem != None)
	{
		MuzzleFlashParticleSystem.DeactivateSystem();
	}
}

protected function BeginFire();

function simulated Tick(float DeltaTime);

defaultproperties
{
	HasRecoil=true
}