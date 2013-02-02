class NukeWeaponFireModeProjectile extends NukeWeaponFireMode;

var(Projectile) const NukeProjectile ProjectileArchetype<AllowAbstract>;


protected function BeginFire()
{
	local Vector StartTrace, EndTrace, RealStartLoc, AimDir, SocketLocation;
	local Rotator SocketRotation;
	local ImpactInfo TestImpact;
	local Projectile SpawnedProjectile;
	local SkeletalMeshComponent SkeletalMeshComponent;

	Owner.IncrementFlashCount();

	if (Owner.Role == Role_Authority)
	{
		SkeletalMeshComponent = SkeletalMeshComponent(Owner.Mesh);
		if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(FireSocketName) != None)
		{
			SkeletalMeshComponent.GetSocketWorldLocationAndRotation(FireSocketName, SocketLocation, SocketRotation);
			RealStartLoc = SocketLocation;
			AimDir = Vector(SocketRotation);
		}
		else
		{
			StartTrace = Owner.Instigator.GetWeaponStartTraceLocation();
			AimDir = Vector(Owner.GetAdjustedAim(StartTrace));

			RealStartLoc = Owner.GetPhysicalFireStartLoc(AimDir);

			if (StartTrace != RealStartLoc)
			{
				EndTrace = StartTrace + AimDir * Owner.GetTraceRange();
				TestImpact = Owner.CalcWeaponFire(StartTrace, EndTrace);

				AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
			}
		}

		SpawnedProjectile = Owner.Spawn(ProjectileArchetype.Class,,, RealStartLoc,, ProjectileArchetype);
		if (SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe)
		{
			SpawnedProjectile.Init(AimDir);
		}
	}
}

defaultproperties
{
}