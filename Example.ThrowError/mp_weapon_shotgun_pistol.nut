untyped

global function OnWeaponPrimaryAttack_weapon_shotgun_pistol

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_shotgun_pistol
#endif // #if SERVER

var function OnWeaponPrimaryAttack_weapon_shotgun_pistol( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( attackParams, true, weapon )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_shotgun_pistol( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( attackParams, false, weapon )
}
#endif // #if SERVER

function FireWeaponPlayerAndNPC( WeaponPrimaryAttackParams attackParams, bool playerFired, entity weapon )
{
#if CLIENT
	array<string> arr = [];
	for (int i = 0; i < 10000000; i++)
	{
		arr.append( "0" );
	}
	Assert( 0, "Forced error." )
#endif

	// Give infinite ammo
	weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
	weapon.SetWeaponPrimaryAmmoCount( weapon.GetWeaponPrimaryClipCountMax() )

	return 1
}
