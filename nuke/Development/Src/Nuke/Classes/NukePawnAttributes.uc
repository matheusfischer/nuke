class NukePawnAttributes extends Component
	editinlinenew
	native(NukePawn)
	HideCategories(Object);

var(Movement) const float SpeedNormal;
var(Movement) const float SpeedWater;
var(Movement) const float SpeedAir;
var(Movement) const float AccelerationRate;
var(Movement) const float JumpHeight;

defaultproperties
{
	SpeedNormal			= 440.0
	SpeedWater			= 220.0
	SpeedAir			= 440.0
	AccelerationRate	= 2048.0
	JumpHeight			= 166.0	
}