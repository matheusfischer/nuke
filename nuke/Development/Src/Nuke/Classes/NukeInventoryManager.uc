class NukeInventoryManager extends InventoryManager;

simulated function Inventory AddItemToInventory(Inventory Type)
{
	local Inventory Inv;
	
	if (Type == None)
	{
		return None;
	}
	
	Inv = Spawn(Type.Class, Owner,,,, Type);
	if (Inv != None)
	{
		if (!AddInventory(Inv, false))
		{
			Inv.Destroy();
			return None;
		}
		else
		{
			return Inv;
		}
	}
	
	return None;
}

defaultproperties
{
	PendingFire(0)=0
}