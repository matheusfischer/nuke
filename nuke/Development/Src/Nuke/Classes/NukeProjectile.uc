class NukeProjectile extends Projectile
	HideCategories(Attachment, Physics, Advanced, Debug, Object);

var(Projectile) const class<DamageType> ProjectileDamageType<AllowAbstract>;

var(Particles) const ParticleSystem FlightParticleTemplate;
var(Particles) const ParticleSystem ExplosionParticleTemplate;

var ParticleSystemComponent FlightParticleSystemComponent;

var bool HasExploded;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if (FlightParticleTemplate != None)
	{
		FlightParticleSystemComponent = new () class'ParticleSystemComponent';
		if (FlightParticleSystemComponent != None)
		{
			FlightParticleSystemComponent.SetTemplate(FlightParticleTemplate);
			AttachComponent(FlightParticleSystemComponent);
		}
	}
	
	MyDamageType = ProjectileDamageType;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (HasExploded)
	{
		return;
	}

	if (WorldInfo.MyEmitterPool != None)
	{
		if (FlightParticleSystemComponent != None)
		{
			FlightParticleSystemComponent.DeactivateSystem();
		}

		if (ExplosionParticleTemplate != None)
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, Location, Rotator(HitNormal));
		}
	}

	if (Damage > 0 && DamageRadius > 0)
	{
		if (Role == ROLE_Authority)
		{
			MakeNoise(1.0);
		}

		ProjectileHurtRadius(HitLocation, HitNormal);
	}

	HasExploded = true;
	LifeSpan = 2.f;
}

defaultproperties
{
}