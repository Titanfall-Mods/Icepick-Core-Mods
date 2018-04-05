
void function SpawnList_Shared_Init()
{
	// Find the correct spawn list
	switch ( GetMapName() )
	{
		case "sp_training":
			break;
		case "sp_crashsite":
			break;
		case "sp_sewers1":
			break;
		case "sp_boomtown":
		case "sp_boomtown_start":
		case "sp_boomtown_end":
			// #include scripts/spawnlists/sp_boomtown.nut
			break;
		case "sp_hub_timeshift":
		case "sp_timeshift_spoke02":
			// #include scripts/spawnlists/sp_timeshift_spoke.nut
			break;
		case "sp_beacon":
		case "sp_beacon_spoke0":
		case "sp_beacon_spoke2":
			break;
		case "sp_tday":
			break;
		case "sp_ship_01":
		case "sp_ship_02":
		case "sp_ship_03":
		case "sp_ship_04":
		case "sp_ship_05":
		case "sp_s2s":
			break;
		case "sp_skyway_v1":
			break;
		default:
			print("[Error] Missing spawnlist for level '" + GetMapName() + "'!");
			break;
	}
}
