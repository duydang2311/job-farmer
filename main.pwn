#include <a_samp>
#include <Pawn.CMD>
#include <YSI_Data\y_iterate>
#include <sscanf2>
#include <progress2>
#include <crashdetect>
#include <streamer>

#if !defined RELEASED
    #define RELEASED(%0) \
        (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#endif

const STREAMER_SEED_EXTRA_ID = 's' + 'e' + 'e' + 'd'; // == 417.
const STREAMER_FARM_AREA_EXTRA_ID = STREAMER_SEED_EXTRA_ID + 'f' + 'a' + 'r' + 'm';
const STREAMER_WATER_AREA_EXTRA_ID = STREAMER_SEED_EXTRA_ID + 'w' + 'a' + 't' + 'e' + 'r';
const STREAMER_CONVEYOR_OBJECT_EX_ID = STREAMER_SEED_EXTRA_ID + 'c' + 'o' + 'n' + 'v' + 'e' + 'y' + 'o' + 'r';
const STREAMER_COW_EXTRA_ID = STREAMER_SEED_EXTRA_ID + 'c' + 'o' + 'w';

const VEHICLE_TRACTOR = 531;
const VEHICLE_FARM_TRAILER = 610;
const FARMER_WATER_CAN_MODEL = 1650;
const FARMER_TRAILER_TYPE_OBJECT = 1458;

const MAX_FARM_AREAS = 3;
const MAX_SEEDS_PER_PLAYERS = 20;
const MAX_SEEDS = 1000;
const MAX_SEEDS_PER_VEHICLES = 30;
const MAX_SEED_TYPES = 4;
const MAX_HS_SLOTS_PER_VEHICLE = 10;
const MAX_SEEDS_PER_CONVEYOR = 10;
const MAX_WHISKS_PER_VEHICLE = 5;
const MAX_FARM_ANIMALS = 500;
const MAX_COWS = 18;
const Float:MAX_SEED_WATER = 1.0;
const Float:MAX_SEED_PROGRESS = 1.0;
const Float:MAX_WATER_CAN_CAPACITY = 7.0;
const Float:MAX_GUTTER_WATER = 1.0;
static const Float:SeedBuyCoords[3] = {-365.9562, -1425.8173, 25.7266};
static const Float:FarmerMenuCoords[3] = {-371.0638, -1463.8688, 25.7266};
static const Float:PlayerWCDefaultAttachment[6] = {0.15400, 0.01800, 0.04900, 0.00000, -100.70000, 0.00000};
static const Float:PlayerWCWateringAttachment[6] = {0.13800, 0.01400, -0.00500, -27.2000, 0.00000, 0.00000};
static const Float:VehicleWCDefaultAttachment[6] = {0.00, -1.59, 0.08, -35.00, 0.00, 0.00};
static const Float:PipeCoords[][3] =
{
    {-408.8827, -1417.2362, 25.2505},
    {-408.7325, -1425.9548, 25.7209},
    {-408.6837, -1434.6625, 25.7266}
};

static const Float:TrailerSpawnPos[][][6] =
{
    {
        {-381.8784, -1459.2352, 25.0308, 0.0000, 0.0000, 28.0000},
        {-372.0056, -1454.5005, 25.0308, 0.0000, 0.0000, 28.0000},
        {-375.3328, -1456.1252, 25.0308, 0.0000, 0.0000, 28.0000},
        {-378.5631, -1457.6768, 25.0308, 0.0000, 0.0000, 28.0000}
    },
    {
        {-370.57892, -1452.20862, 24.79080, 20.00000, 0.00000, 208.00000},
        {-380.68860, -1457.18054, 24.79080, 20.00000, 0.00000, 208.00000},
        {-373.93033, -1453.84766, 24.79080, 20.00000, 0.00000, 208.00000},
        {-377.32019, -1455.58228, 24.79080, 20.00000, 0.00000, 208.00000}
    }
};

static const Float:FarmAreaPoints0[] =
{
    -555.0,-1440.0,-529.0,-1422.0,-506.0,-1413.0,-402.0,-1400.0,-373.0,-1380.0,-354.0,-1321.0,-342.0,-1263.0,-433.0,-1278.0,-468.0,-1288.0,-590.0,-1288.0,
    -592.0,-1298.0,-592.0,-1409.0,-555.0,-1440.0
};

static const Float:FarmAreaPoints1[] =
{
    -333.0,-1433.0,-328.0,-1371.0,-325.0,-1347.0,-326.0,-1313.0,-293.0,-1313.0,-215.0,-1310.0,-162.0,-1299.0,-165.0,-1324.0,-165.0,-1365.0,-165.0,-1391.0,
    -160.0,-1416.0,-226.0,-1426.0,-305.0,-1432.0,-333.0,-1433.0
};

static const Float:FarmAreaPoints2[] =
{
    -336.0,-1466.0,-338.0,-1491.0,-338.0,-1527.0,-334.0,-1560.0,-317.0,-1558.0,-213.0,-1558.0,-212.0,-1467.0,-336.0,-1466.0
};

static const Float:WaterPoolPoints[] =
{
    -437.7087, -1450.5369, -431.1374, -1450.7185, -429.6323, -1440.0695, -437.5343, -1440.2272
};

static const Float:CowAreaPoints[] =
{
    -385.1457, -1411.9325,
    -386.9912, -1442.8424,
    -411.0768, -1443.6686,
    -411.1409, -1412.3494
};

static const Float:CowSpawnCoords[MAX_COWS][6] =
{
    {-394.3781, -1413.9000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-398.6791, -1413.9000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-403.3601, -1413.9000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-394.2407, -1420.2000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-399.0385, -1420.2000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-403.1697, -1420.2000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-394.4310, -1422.5000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-399.0599, -1422.5000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-403.3427, -1422.5000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-394.3653, -1429.0000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-398.7914, -1429.0000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-403.2585, -1429.0000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-394.4665, -1431.4000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-399.0181, -1431.4000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-403.3153, -1431.4000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-394.3947, -1437.7000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-398.7983, -1437.7000, 24.4000, 0.0000, 0.0000, 90.0000},
    {-403.3705, -1437.7000, 24.4000, 0.0000, 0.0000, 90.0000}
};

static const Float:GutterCoords[MAX_COWS][3] =
{
    {-394.3781, -1413.4865, 25.0000},
    {-398.6791, -1413.3757, 25.0000},
    {-403.3601, -1413.3763, 25.0000},
    {-394.2407, -1420.8153, 25.0000},
    {-399.0385, -1420.8145, 25.0000},
    {-403.1697, -1420.6896, 25.0000},
    {-394.4310, -1422.3673, 25.0000},
    {-399.0599, -1422.3733, 25.0000},
    {-403.3427, -1422.2648, 25.0000},
    {-394.3653, -1429.5228, 25.0000},
    {-398.7914, -1429.4614, 25.0000},
    {-403.2585, -1429.5509, 25.0000},
    {-394.4665, -1430.9658, 25.0000},
    {-399.0181, -1430.9443, 25.0000},
    {-403.3153, -1430.9907, 25.0000},
    {-394.3947, -1438.1370, 25.0000},
    {-398.7983, -1438.2351, 25.0000},
    {-403.3705, -1438.1302, 25.0000}
};

enum _:DIALOG_IDS
{
    DIALOG_FARMER_MENU,
    DIALOG_SEED_TYPES,
    DIALOG_TRADING_WHISK_CONFIRM
}

enum default_seed_params
{
    seed_Name[32],
    seed_Model,
    Float:seed_Min_Height,
    Float:seed_Max_Height,
    seed_Color,
    Float:seed_Progress_Velocity
}
static const DefaultSeedInfo[MAX_SEED_TYPES][default_seed_params] =
{
    {"Lua mi", 862, -2.2, -0.5, 0xFFFF09FF, 0.008}, // distance 1.7, velocity 0.008 -> 1.4166667 kg
    {"Khoai tay", 678, -1.1, -0.5, 0xC89C04FF, 0.004}, // distance 0.6, velocity 0.004 -> 1.0 kg
    {"Dua gai", 757, -2.0, -0.5, 0x97CD96FF, 0.01}, // distance 1.5, velocity 0.01 -> 1.0 kg
    {"Kim chi", 19473, -1.9, -0.5, 0x00FF00FF, 0.02} // distance 1.4, velocity 0.02 -> 0.46666 kg
};

static const Float:SeedCurrencyRate[MAX_SEED_TYPES] =
{
    12.0,
    7.5,
    7.5,
    4.0
};

static const Float:SeedConveyorCoords[MAX_SEED_TYPES][] =
{
    {-382.9048, -1433.4625, 24.9626, -370.7278, -1433.4625, 31.3873, 90.0000, 0.0000, 0.0000},
    {-382.6043, -1434.3843, 25.0792, -370.9679, -1434.3843, 31.1113, 0.0000, -27.7000, 0.0000},
    {-382.6285, -1433.5414, 25.6044, -371.3854, -1433.5414, 31.4559, 90.0000, 0.0000, 0.0000},
    {-382.7142, -1433.6011, 25.3285, -371.0172, -1433.6011, 31.3638, 90.0000, 0.0000, 0.0000}
};

static const Float:VehicleWhiskAttachments[][3] =
{
    {0.0, -2.7, 0.0},
    {0.0, -3.2, 0.0},
    {0.0, -3.7, 0.0},
    {0.0, -4.2, 0.0},
    {0.0, -4.7, 0.0}
};

enum seed_attachment_params
{
    Float:seed_Min_X,
    Float:seed_Max_X,
    Float:seed_Min_Y,
    Float:seed_Max_Y,
    Float:seed_Min_Z,
    Float:seed_Max_Z,
    Float:seed_Rot_X,
    Float:seed_Rot_Y,
    Float:seed_Rot_Z,
    bool:seed_Random_X,
    bool:seed_Random_Y,
    bool:seed_Random_Z
}
static const VehicleHSAttachmentCoords[MAX_SEED_TYPES][seed_attachment_params] =
{
    {-0.5, 0.5, -4.8, -4.4, 0.0, 0.0, -90.0, 0.0, 0.0, true, true, false},
    {-0.3, 0.3, -4.2, -2.7, 0.0, 0.0, 90.0, 0.0, 0.0, true, true, false},
    {0.0, 0.0, -3.8, -2.2, 0.3, 0.0, 90.0, 0.0, 0.0, false, true, false},
    {-0.2, 0.2, -3.8, -2.0, 0.0, 0.0, 90.0, 0.0, 0.0, true, true, false}
};

static const Float:PlayerHSAttachmentCoords[MAX_SEED_TYPES][6] =
{
    {-0.11200, 0.46100, -0.87500, 0.00000, 6.70000, 0.00000},
    {-0.07700, 0.51500, -0.08000, 0.20000, 81.20000, 46.80000},
    {0.13100, 0.28700, 0.14100, -91.10000, 0.00000, 0.00000},
    {0.19300, 0.59800, -0.91000, 0.00000, 0.00000, 0.00000}
};

enum character_params
{
    char_Farmer_Tractor_Id,
    Float:char_Outputs
}
static Character[MAX_PLAYERS][character_params];

enum farmer_vehicle_params
{
    veh_Owner_Id,
    veh_Water_Can_Object,
    Float:veh_Water_Can_Capacity,
    veh_Trailer_Id,
    bool:veh_Trailer_Is_Vehicle, // true - vehicle, false - object
    bool:veh_Trailer_Is_Attached, // true - attach, false - not attached
    veh_Trailer_Smoke_Object,
    veh_Harvest_Timer,
    veh_HS_Objects[MAX_HS_SLOTS_PER_VEHICLE],
    veh_HS_Types[MAX_HS_SLOTS_PER_VEHICLE],
    Float:veh_HS_Progress[MAX_HS_SLOTS_PER_VEHICLE],
    veh_Whisk_Objects[MAX_WHISKS_PER_VEHICLE],
    veh_Cow_Object_Id,
    Float:veh_Cow_Progress
}
static FarmerVehicles[MAX_VEHICLES][farmer_vehicle_params];

enum seed_params
{
    seed_Owner,
    seed_Timestamp,
    seed_Object,
    seed_Type,
    Text3D:seed_Text3D,
    Float:seed_Pos[3],
    Float:seed_Water,
    Float:seed_Quantity,
    Float:seed_Progress,
    bool:seed_Harvested
}
static Seeds[MAX_SEEDS][seed_params];
static Iterator:I_Seeds<MAX_SEEDS>;

enum seed_conveyor_params
{
    conveyor_Objects[MAX_SEEDS_PER_CONVEYOR],
    Float:conveyor_Progress[MAX_SEEDS_PER_CONVEYOR],
    conveyor_Owners[MAX_SEEDS_PER_CONVEYOR],
    conveyor_Types[MAX_SEEDS_PER_CONVEYOR],
    conveyor_Last_Timestamp
}
static SeedConveyor[seed_conveyor_params];

enum cow_params
{
    cow_Object_Id,
    cow_Owner_Id,
    Float:cow_Progress,
    Float:cow_Fullness, // == 1 (full),
    Float:cow_Water, // == 0 (thirsty)
    Float:cow_Cleanness,
    cow_Whisk_Object_Id,
    cow_Whisk_Timestamp,
    bool:cow_Is_Drinking_Water,
    bool:cow_Being_Dragged,
    Text3D:cow_3D_Bar[2],
    cow_Eating_Timer
}
static Cows[MAX_COWS][cow_params];
static Iterator:I_Cows<MAX_COWS>;

enum gutter_params
{
    Text3D:gutter_3D_Bar[2],
    Float:gutter_Water
}
static Gutters[MAX_COWS][gutter_params];

static VehicleSeeds[MAX_VEHICLES][MAX_SEEDS_PER_VEHICLES] = {-1, ...};
static Iterator:I_VehicleSeeds[MAX_VEHICLES]<MAX_SEEDS_PER_VEHICLES>;

static FarmAreas[MAX_FARM_AREAS],
    WaterPoolArea,
    CowArea;

static PlayerText:td_Seed_Info_Container[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Seed_Info_Preview_Model[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Seed_Info_Name[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Seed_Info_Water_Label[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Seed_Info_Progress_Label[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerBar:bar_Seed_Info_Water[MAX_PLAYERS] = {PlayerBar:INVALID_PLAYER_BAR_ID, ...},
    PlayerBar:bar_Seed_Info_Progress[MAX_PLAYERS] = {PlayerBar:INVALID_PLAYER_BAR_ID, ...};

static PlayerText:td_Water_Can_Container[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Water_Can_Preview_Model[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerBar:bar_Water_Can_Progress[MAX_PLAYERS] = {PlayerBar:INVALID_PLAYER_BAR_ID};

static PlayerText:td_Trailer_Selection_Container[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Trailer_Selection_Items[MAX_PLAYERS][2] = {PlayerText:INVALID_TEXT_DRAW, ...};

static PlayerText:td_Cow_Info_Container[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Cow_Info_Preview_Model[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Cow_Info_Progress_Label[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Cow_Info_Fullness_Label[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Cow_Info_Water_Label[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerText:td_Cow_Info_Cleanness_Label[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
    PlayerBar:bar_Cow_Info_Progress[MAX_PLAYERS] = {PlayerBar:INVALID_PLAYER_BAR_ID, ...},
    PlayerBar:bar_Cow_Info_Fullness[MAX_PLAYERS] = {PlayerBar:INVALID_PLAYER_BAR_ID, ...},
    PlayerBar:bar_Cow_Info_Water[MAX_PLAYERS] = {PlayerBar:INVALID_PLAYER_BAR_ID, ...},
    PlayerBar:bar_Cow_Info_Cleanness[MAX_PLAYERS] = {PlayerBar:INVALID_PLAYER_BAR_ID, ...};

static seedStorage = 0;
static temp_object = 0;

main() {}

GetVehicleRelativePos(vehicleid, &Float:x, &Float:y, &Float:z, Float:xoff=0.0, Float:yoff=0.0, Float:zoff=0.0)
{
    new Float:rot;
    GetVehicleZAngle(vehicleid, rot);
    rot = 360 - rot;
    GetVehiclePos(vehicleid, x, y, z);
    x = floatsin(rot,degrees) * yoff + floatcos(rot,degrees) * xoff + x;
    y = floatcos(rot,degrees) * yoff - floatsin(rot,degrees) * xoff + y;
    z = zoff + z;
	return 1;
}

GetPosInFrontOfPlayer(playerid, &Float:_x, &Float:_y, Float:distance)
{
    new Float:_a;
    GetPlayerPos(playerid, _x, _y, _a);
    GetPlayerFacingAngle(playerid, _a);
    if (GetPlayerVehicleID(playerid))
    {
        GetVehicleZAngle(GetPlayerVehicleID(playerid), _a);
    }
    _x += (distance * floatsin(-_a, degrees));
    _y += (distance * floatcos(-_a, degrees));
    return 1;
}

Float:GetDistanceBetweenPoints3D(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
	return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}

Float:frandom(Float:max, Float:min = 0.0, dp = 4)
{
    new
        // Get the multiplication for storing fractional parts.
        Float:mul = floatpower(10.0, dp),
        // Get the max and min as integers, with extra dp.
        imin = floatround(min * mul),
        imax = floatround(max * mul);
    // Get a random int between two bounds and convert it to a float.
    return float(random(imax - imin) + imin) / mul;
}

bool:GenerateHSAttachmentCoords(type, Float:coords[6])
{
    if(type < 0 || type >= sizeof(VehicleHSAttachmentCoords))
        return false;

    if(VehicleHSAttachmentCoords[type][seed_Random_X])
    {
        coords[0] = frandom(VehicleHSAttachmentCoords[type][seed_Max_X], VehicleHSAttachmentCoords[type][seed_Min_X]);
    }
    else coords[0] = VehicleHSAttachmentCoords[type][seed_Min_X];

    if(VehicleHSAttachmentCoords[type][seed_Random_Y])
    {
        coords[1] = frandom(VehicleHSAttachmentCoords[type][seed_Max_Y], VehicleHSAttachmentCoords[type][seed_Min_Y]);
    }
    else coords[1] = VehicleHSAttachmentCoords[type][seed_Min_Y];

    if(VehicleHSAttachmentCoords[type][seed_Random_Z])
    {
        coords[2] = frandom(VehicleHSAttachmentCoords[type][seed_Max_Z], VehicleHSAttachmentCoords[type][seed_Min_Z]);
    }
    else coords[2] = VehicleHSAttachmentCoords[type][seed_Min_Z];

    coords[3] = VehicleHSAttachmentCoords[type][seed_Rot_X];
    coords[4] = VehicleHSAttachmentCoords[type][seed_Rot_Y];
    coords[5] = VehicleHSAttachmentCoords[type][seed_Rot_Z];
    return true;
}

GetSeedModelFromType(seed_type)
{
    switch(seed_type)
    {
        case 0: return 862;
        case 1: return 804;
        case 2: return 757;
        case 3: return 19473;
    }
    return 0;
}

GetFreeCharacterAttachmentIdx(playerid)
{
    for(new i = 0; i <= 9; i++)
    {
        if(!IsPlayerAttachedObjectSlotUsed(playerid, i))
            return i;
    }
    return -1;
}

GetClosestVehicleId(playerid, Float:range)
{
	new Float:max_dist = range,
		Float:dist = range,
		Float:pos[3],
		vehicleid = 0,
		player_vehicleid = GetPlayerVehicleID(playerid);
	for(new i = GetVehiclePoolSize(); i != 0; i--)
	{
		if(!IsValidVehicle(i)) continue;
		if(i == player_vehicleid) continue;

		GetVehiclePos(i, pos[0], pos[1], pos[2]);
		dist = GetPlayerDistanceFromPoint(playerid, pos[0], pos[1], pos[2]);
		if(dist <= max_dist)
		{
			max_dist = dist;
			vehicleid = i;
		}
	}
	return vehicleid;
}

GetClosestCowGutterToPoint(Float:range, Float:x, Float:y, Float:z)
{
    new Float:max_dist = range + 0.0001,
        Float:dist,
        index = -1;

    for(new i = 0; i < MAX_COWS; i++)
    {
        dist = GetDistanceBetweenPoints3D(x, y, z, GutterCoords[i][0], GutterCoords[i][1], GutterCoords[i][2]);
        if(dist < max_dist)
        {
            max_dist = dist;
            index = i;
        }
    }
    return index;
}

GetClosestCowIndexToPoint(Float:range, Float:x, Float:y, Float:z)
{
    new Float:max_dist = range + 0.0001,
        Float:dist,
        index = -1;
    foreach(new i : I_Cows)
    {
        Streamer_GetDistanceToItem(x, y, z, STREAMER_TYPE_OBJECT, Cows[i][cow_Object_Id], dist, 3);
        if(dist < max_dist)
        {
            max_dist = dist;
            index = i;
        }
    }
    return index;
}

CowInfoShowForPlayer(playerid, cow_index)
{
    if(td_Cow_Info_Container[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Cow_Info_Container[playerid] = CreatePlayerTextDraw(playerid, 398.000000 + 80.0, 121.000000, "box");
        PlayerTextDrawLetterSize(playerid, td_Cow_Info_Container[playerid], 0.000000, 6.500000);
        PlayerTextDrawTextSize(playerid, td_Cow_Info_Container[playerid], 548.000000 + 80.0, 0.000000);
        PlayerTextDrawAlignment(playerid, td_Cow_Info_Container[playerid], 1);
        PlayerTextDrawColor(playerid, td_Cow_Info_Container[playerid], -1);
        PlayerTextDrawUseBox(playerid, td_Cow_Info_Container[playerid], 1);
        PlayerTextDrawBoxColor(playerid, td_Cow_Info_Container[playerid], 170);
        PlayerTextDrawSetShadow(playerid, td_Cow_Info_Container[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Cow_Info_Container[playerid], 255);
        PlayerTextDrawFont(playerid, td_Cow_Info_Container[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Cow_Info_Container[playerid], 1);
    }

    if(td_Cow_Info_Preview_Model[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Cow_Info_Preview_Model[playerid] = CreatePlayerTextDraw(playerid, 397.000000 + 80.0, 126.000000, "");
        PlayerTextDrawTextSize(playerid, td_Cow_Info_Preview_Model[playerid], 50.000000, 50.000000);
        PlayerTextDrawAlignment(playerid, td_Cow_Info_Preview_Model[playerid], 1);
        PlayerTextDrawColor(playerid, td_Cow_Info_Preview_Model[playerid], -1);
        PlayerTextDrawSetShadow(playerid, td_Cow_Info_Preview_Model[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Cow_Info_Preview_Model[playerid], 170);
        PlayerTextDrawFont(playerid, td_Cow_Info_Preview_Model[playerid], 5);
        PlayerTextDrawSetProportional(playerid, td_Cow_Info_Preview_Model[playerid], 0);
        PlayerTextDrawSetPreviewModel(playerid, td_Cow_Info_Preview_Model[playerid], 19833);
        PlayerTextDrawSetPreviewRot(playerid, td_Cow_Info_Preview_Model[playerid], 0.000000, 0.000000, 90.000000, 0.750000);
    }

    if(bar_Cow_Info_Progress[playerid] == PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        bar_Cow_Info_Progress[playerid] = CreatePlayerProgressBar(playerid, 454.000000 + 80.0, 129.000000, 88.8, -0.3, 0xFF1C1CFF, 1.0);
    }

    if(td_Cow_Info_Progress_Label[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Cow_Info_Progress_Label[playerid] = CreatePlayerTextDraw(playerid, 450.000000 + 80.0, 118.000000, "TRUONG THANH");
        PlayerTextDrawLetterSize(playerid, td_Cow_Info_Progress_Label[playerid], 0.200000, 0.70000);
        PlayerTextDrawTextSize(playerid, td_Cow_Info_Progress_Label[playerid], 583.000000, 0.000000);
        PlayerTextDrawAlignment(playerid, td_Cow_Info_Progress_Label[playerid], 1);
        PlayerTextDrawColor(playerid, td_Cow_Info_Progress_Label[playerid], -86);
        PlayerTextDrawSetShadow(playerid, td_Cow_Info_Progress_Label[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Cow_Info_Progress_Label[playerid], 255);
        PlayerTextDrawFont(playerid, td_Cow_Info_Progress_Label[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Cow_Info_Progress_Label[playerid], 1);
    }

    if(bar_Cow_Info_Fullness[playerid] == PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        bar_Cow_Info_Fullness[playerid] = CreatePlayerProgressBar(playerid, 454.000000 + 80.0, 146.000000, 88.8, -0.3, 0xFF1C1CFF, 1.0);
    }

    if(td_Cow_Info_Fullness_Label[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Cow_Info_Fullness_Label[playerid] = CreatePlayerTextDraw(playerid, 450.000000 + 80.0, 135.000000, "DO NO");
        PlayerTextDrawLetterSize(playerid, td_Cow_Info_Fullness_Label[playerid], 0.200000, 0.699998);
        PlayerTextDrawTextSize(playerid, td_Cow_Info_Fullness_Label[playerid], 583.000000, 0.000000);
        PlayerTextDrawAlignment(playerid, td_Cow_Info_Fullness_Label[playerid], 1);
        PlayerTextDrawColor(playerid, td_Cow_Info_Fullness_Label[playerid], -86);
        PlayerTextDrawSetShadow(playerid, td_Cow_Info_Fullness_Label[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Cow_Info_Fullness_Label[playerid], 255);
        PlayerTextDrawFont(playerid, td_Cow_Info_Fullness_Label[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Cow_Info_Fullness_Label[playerid], 1);
    }

    if(bar_Cow_Info_Water[playerid] == PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        bar_Cow_Info_Water[playerid] = CreatePlayerProgressBar(playerid, 454.000000 + 80.0, 163.000000, 88.8, -0.3, 0xFF1C1CFF, 1.0);
    }

    if(td_Cow_Info_Water_Label[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Cow_Info_Water_Label[playerid] = CreatePlayerTextDraw(playerid, 450.000000 + 80.0, 152.000000, "NUOC");
        PlayerTextDrawLetterSize(playerid, td_Cow_Info_Water_Label[playerid], 0.200000, 0.699998);
        PlayerTextDrawTextSize(playerid, td_Cow_Info_Water_Label[playerid], 583.000000, 0.000000);
        PlayerTextDrawAlignment(playerid, td_Cow_Info_Water_Label[playerid], 1);
        PlayerTextDrawColor(playerid, td_Cow_Info_Water_Label[playerid], -86);
        PlayerTextDrawSetShadow(playerid, td_Cow_Info_Water_Label[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Cow_Info_Water_Label[playerid], 255);
        PlayerTextDrawFont(playerid, td_Cow_Info_Water_Label[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Cow_Info_Water_Label[playerid], 1);
    }

    if(bar_Cow_Info_Cleanness[playerid] == PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        bar_Cow_Info_Cleanness[playerid] = CreatePlayerProgressBar(playerid, 454.000000 + 80.0, 180.000000, 88.8, -0.3, 0xFF1C1CFF, 1.0, BAR_DIRECTION_RIGHT);
    }

    if(td_Cow_Info_Cleanness_Label[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Cow_Info_Cleanness_Label[playerid] = CreatePlayerTextDraw(playerid, 450.000000 + 80.0, 169.000000, "DO_SACH_SE");
        PlayerTextDrawLetterSize(playerid, td_Cow_Info_Cleanness_Label[playerid], 0.200000, 0.699998);
        PlayerTextDrawTextSize(playerid, td_Cow_Info_Cleanness_Label[playerid], 583.000000, 0.000000);
        PlayerTextDrawAlignment(playerid, td_Cow_Info_Cleanness_Label[playerid], 1);
        PlayerTextDrawColor(playerid, td_Cow_Info_Cleanness_Label[playerid], -86);
        PlayerTextDrawSetShadow(playerid, td_Cow_Info_Cleanness_Label[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Cow_Info_Cleanness_Label[playerid], 255);
        PlayerTextDrawFont(playerid, td_Cow_Info_Cleanness_Label[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Cow_Info_Cleanness_Label[playerid], 1);
    }

    SetPlayerProgressBarValue(playerid, bar_Cow_Info_Progress[playerid], Cows[cow_index][cow_Progress]);
    SetPlayerProgressBarValue(playerid, bar_Cow_Info_Fullness[playerid], Cows[cow_index][cow_Fullness]);
    SetPlayerProgressBarValue(playerid, bar_Cow_Info_Water[playerid], Cows[cow_index][cow_Water]);
    SetPlayerProgressBarValue(playerid, bar_Cow_Info_Cleanness[playerid], Cows[cow_index][cow_Cleanness]);

    PlayerTextDrawShow(playerid, td_Cow_Info_Container[playerid]);
    PlayerTextDrawShow(playerid, td_Cow_Info_Preview_Model[playerid]);
    PlayerTextDrawShow(playerid, td_Cow_Info_Progress_Label[playerid]);
    PlayerTextDrawShow(playerid, td_Cow_Info_Fullness_Label[playerid]);
    PlayerTextDrawShow(playerid, td_Cow_Info_Water_Label[playerid]);
    PlayerTextDrawShow(playerid, td_Cow_Info_Cleanness_Label[playerid]);
    ShowPlayerProgressBar(playerid, bar_Cow_Info_Progress[playerid]);
    ShowPlayerProgressBar(playerid, bar_Cow_Info_Fullness[playerid]);
    ShowPlayerProgressBar(playerid, bar_Cow_Info_Water[playerid]);
    ShowPlayerProgressBar(playerid, bar_Cow_Info_Cleanness[playerid]);
    return 1;
}

CowInfoHideForPlayer(playerid)
{
    if(td_Cow_Info_Container[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Cow_Info_Container[playerid]);
    }

    if(td_Cow_Info_Preview_Model[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Cow_Info_Preview_Model[playerid]);
    }

    if(td_Cow_Info_Progress_Label[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Cow_Info_Progress_Label[playerid]);
    }

    if(td_Cow_Info_Fullness_Label[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Cow_Info_Fullness_Label[playerid]);
    }

    if(td_Cow_Info_Water_Label[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Cow_Info_Water_Label[playerid]);
    }

    if(td_Cow_Info_Cleanness_Label[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Cow_Info_Cleanness_Label[playerid]);
    }

    if(bar_Cow_Info_Progress[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        DestroyPlayerProgressBar(playerid, bar_Cow_Info_Progress[playerid]);
    }

    if(bar_Cow_Info_Fullness[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        DestroyPlayerProgressBar(playerid, bar_Cow_Info_Fullness[playerid]);
    }

    if(bar_Cow_Info_Water[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        DestroyPlayerProgressBar(playerid, bar_Cow_Info_Water[playerid]);
    }

    if(bar_Cow_Info_Cleanness[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        DestroyPlayerProgressBar(playerid, bar_Cow_Info_Cleanness[playerid]);
    }

    td_Cow_Info_Container[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Cow_Info_Preview_Model[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Cow_Info_Progress_Label[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Cow_Info_Fullness_Label[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Cow_Info_Water_Label[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Cow_Info_Cleanness_Label[playerid] = PlayerText:INVALID_TEXT_DRAW;
    bar_Cow_Info_Progress[playerid] = PlayerBar:INVALID_PLAYER_BAR_ID;
    bar_Cow_Info_Fullness[playerid] = PlayerBar:INVALID_PLAYER_BAR_ID;
    bar_Cow_Info_Water[playerid] = PlayerBar:INVALID_PLAYER_BAR_ID;
    bar_Cow_Info_Cleanness[playerid] = PlayerBar:INVALID_PLAYER_BAR_ID;
    return 1;
}

SeedInfoShowForPlayer(playerid, seed_index)
{
    new string[64];

    if(td_Seed_Info_Container[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Seed_Info_Container[playerid] = CreatePlayerTextDraw(playerid, 398.000000 + 80.0, 190.000000, "box");
        PlayerTextDrawLetterSize(playerid, td_Seed_Info_Container[playerid], 0.000000, 14.300000);
        PlayerTextDrawTextSize(playerid, td_Seed_Info_Container[playerid], 466.000000 + 80.0, 0.000000);
        PlayerTextDrawAlignment(playerid, td_Seed_Info_Container[playerid], 1);
        PlayerTextDrawColor(playerid, td_Seed_Info_Container[playerid], -1);
        PlayerTextDrawUseBox(playerid, td_Seed_Info_Container[playerid], 1);
        PlayerTextDrawBoxColor(playerid, td_Seed_Info_Container[playerid], 170);
        PlayerTextDrawSetShadow(playerid, td_Seed_Info_Container[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Seed_Info_Container[playerid], 255);
        PlayerTextDrawFont(playerid, td_Seed_Info_Container[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Seed_Info_Container[playerid], 1);
    }

    if(td_Seed_Info_Preview_Model[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Seed_Info_Preview_Model[playerid] = CreatePlayerTextDraw(playerid, 397.000000 + 80.0, 188.000000, "");
        PlayerTextDrawTextSize(playerid, td_Seed_Info_Preview_Model[playerid], 70.000000, 70.000000);
        PlayerTextDrawAlignment(playerid, td_Seed_Info_Preview_Model[playerid], 1);
        PlayerTextDrawColor(playerid, td_Seed_Info_Preview_Model[playerid], -1);
        PlayerTextDrawSetShadow(playerid, td_Seed_Info_Preview_Model[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Seed_Info_Preview_Model[playerid], 119);
        PlayerTextDrawFont(playerid, td_Seed_Info_Preview_Model[playerid], 5);
        PlayerTextDrawSetProportional(playerid, td_Seed_Info_Preview_Model[playerid], 0);
        PlayerTextDrawSetPreviewModel(playerid, td_Seed_Info_Preview_Model[playerid], DefaultSeedInfo[Seeds[seed_index][seed_Type]][seed_Model]);
        PlayerTextDrawSetPreviewRot(playerid, td_Seed_Info_Preview_Model[playerid], 0.000000, 0.000000, 0.000000, 0.800000);
    }
    else PlayerTextDrawSetPreviewModel(playerid, td_Seed_Info_Preview_Model[playerid], DefaultSeedInfo[Seeds[seed_index][seed_Type]][seed_Model]);

    format(string, sizeof(string), "Ten:_%s", DefaultSeedInfo[Seeds[seed_index][seed_Type]][seed_Name]);
    if(td_Seed_Info_Name[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Seed_Info_Name[playerid] = CreatePlayerTextDraw(playerid, 398.000000 + 80.0, 260.000000, string);
        PlayerTextDrawLetterSize(playerid, td_Seed_Info_Name[playerid], 0.300000, 1.200000);
        PlayerTextDrawAlignment(playerid, td_Seed_Info_Name[playerid], 1);
        PlayerTextDrawColor(playerid, td_Seed_Info_Name[playerid], -1);
        PlayerTextDrawSetShadow(playerid, td_Seed_Info_Name[playerid], 0);
        PlayerTextDrawSetOutline(playerid, td_Seed_Info_Name[playerid], 1);
        PlayerTextDrawBackgroundColor(playerid, td_Seed_Info_Name[playerid], 255);
        PlayerTextDrawFont(playerid, td_Seed_Info_Name[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Seed_Info_Name[playerid], 1);
    }
    else PlayerTextDrawSetString(playerid, td_Seed_Info_Name[playerid], string);

    if(td_Seed_Info_Water_Label[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Seed_Info_Water_Label[playerid] = CreatePlayerTextDraw(playerid, 398.000000 + 80.0, 272.000000, "Luong_nuoc");
        PlayerTextDrawLetterSize(playerid, td_Seed_Info_Water_Label[playerid], 0.300000, 1.200000);
        PlayerTextDrawAlignment(playerid, td_Seed_Info_Water_Label[playerid], 1);
        PlayerTextDrawColor(playerid, td_Seed_Info_Water_Label[playerid], -1);
        PlayerTextDrawSetShadow(playerid, td_Seed_Info_Water_Label[playerid], 0);
        PlayerTextDrawSetOutline(playerid, td_Seed_Info_Water_Label[playerid], 1);
        PlayerTextDrawBackgroundColor(playerid, td_Seed_Info_Water_Label[playerid], 255);
        PlayerTextDrawFont(playerid, td_Seed_Info_Water_Label[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Seed_Info_Water_Label[playerid], 1);
    }

    if(bar_Seed_Info_Water[playerid] == INVALID_PLAYER_BAR_ID)
    {
        bar_Seed_Info_Water[playerid] = CreatePlayerProgressBar(playerid, 402.000000 + 80.0, 290.000000, 60.0, 0.5, 0xFF1C1CFF, MAX_SEED_WATER, BAR_DIRECTION_RIGHT);
    }

    if(td_Seed_Info_Progress_Label[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Seed_Info_Progress_Label[playerid] = CreatePlayerTextDraw(playerid, 398.000000 + 80.0, 298.000000, "Sinh_truong");
        PlayerTextDrawLetterSize(playerid, td_Seed_Info_Progress_Label[playerid], 0.300000, 1.200000);
        PlayerTextDrawAlignment(playerid, td_Seed_Info_Progress_Label[playerid], 1);
        PlayerTextDrawColor(playerid, td_Seed_Info_Progress_Label[playerid], -1);
        PlayerTextDrawSetShadow(playerid, td_Seed_Info_Progress_Label[playerid], 0);
        PlayerTextDrawSetOutline(playerid, td_Seed_Info_Progress_Label[playerid], 1);
        PlayerTextDrawBackgroundColor(playerid, td_Seed_Info_Progress_Label[playerid], 255);
        PlayerTextDrawFont(playerid, td_Seed_Info_Progress_Label[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Seed_Info_Progress_Label[playerid], 1);
    }

    if(bar_Seed_Info_Progress[playerid] == INVALID_PLAYER_BAR_ID)
    {
        bar_Seed_Info_Progress[playerid] = CreatePlayerProgressBar(playerid, 402.000000 + 80.0, 315.000000, 60.0, 0.5, 0xFF1C1CFF, MAX_SEED_WATER, BAR_DIRECTION_RIGHT);
    }

    SetPlayerProgressBarValue(playerid, bar_Seed_Info_Water[playerid], Seeds[seed_index][seed_Water]);
    SetPlayerProgressBarValue(playerid, bar_Seed_Info_Progress[playerid], Seeds[seed_index][seed_Progress]);

    PlayerTextDrawShow(playerid, td_Seed_Info_Container[playerid]);
    PlayerTextDrawShow(playerid, td_Seed_Info_Preview_Model[playerid]);
    PlayerTextDrawShow(playerid, td_Seed_Info_Name[playerid]);
    PlayerTextDrawShow(playerid, td_Seed_Info_Water_Label[playerid]);
    PlayerTextDrawShow(playerid, td_Seed_Info_Progress_Label[playerid]);
    ShowPlayerProgressBar(playerid, bar_Seed_Info_Water[playerid]);
    ShowPlayerProgressBar(playerid, bar_Seed_Info_Progress[playerid]);
    return 1;
}

SeedInfoHideForPlayer(playerid)
{
    if(td_Seed_Info_Container[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Seed_Info_Container[playerid]);
    }

    if(td_Seed_Info_Preview_Model[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Seed_Info_Preview_Model[playerid]);
    }

    if(td_Seed_Info_Name[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Seed_Info_Name[playerid]);
    }

    if(td_Seed_Info_Water_Label[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Seed_Info_Water_Label[playerid]);
    }

    if(td_Seed_Info_Progress_Label[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Seed_Info_Progress_Label[playerid]);
    }

    if(bar_Seed_Info_Water[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        DestroyPlayerProgressBar(playerid, bar_Seed_Info_Water[playerid]);
    }

    if(bar_Seed_Info_Progress[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        DestroyPlayerProgressBar(playerid, bar_Seed_Info_Progress[playerid]);
    }

    td_Seed_Info_Container[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Seed_Info_Name[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Seed_Info_Preview_Model[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Seed_Info_Progress_Label[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Seed_Info_Water_Label[playerid] = PlayerText:INVALID_TEXT_DRAW;
    bar_Seed_Info_Water[playerid] = PlayerBar:INVALID_PLAYER_BAR_ID;
    bar_Seed_Info_Progress[playerid] = PlayerBar:INVALID_PLAYER_BAR_ID;
    return 1;
}

WaterCanInfoShowForPlayer(playerid)
{
    if(td_Water_Can_Container[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Water_Can_Container[playerid] = CreatePlayerTextDraw(playerid, 480.000000 + 80.0, 190.000000, "box");
        PlayerTextDrawLetterSize(playerid, td_Water_Can_Container[playerid], 0.000000, 9.000000);
        PlayerTextDrawTextSize(playerid, td_Water_Can_Container[playerid], 548.000000 + 80.0, 0.000000);
        PlayerTextDrawAlignment(playerid, td_Water_Can_Container[playerid], 1);
        PlayerTextDrawColor(playerid, td_Water_Can_Container[playerid], -1);
        PlayerTextDrawUseBox(playerid, td_Water_Can_Container[playerid], 1);
        PlayerTextDrawBoxColor(playerid, td_Water_Can_Container[playerid], 170);
        PlayerTextDrawSetShadow(playerid, td_Water_Can_Container[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Water_Can_Container[playerid], 255);
        PlayerTextDrawFont(playerid, td_Water_Can_Container[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Water_Can_Container[playerid], 1);
    }

    if(td_Water_Can_Preview_Model[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Water_Can_Preview_Model[playerid] = CreatePlayerTextDraw(playerid, 479.000000 + 80.0, 188.000000, "");
        PlayerTextDrawTextSize(playerid, td_Water_Can_Preview_Model[playerid], 70.000000, 70.000000);
        PlayerTextDrawAlignment(playerid, td_Water_Can_Preview_Model[playerid], 1);
        PlayerTextDrawColor(playerid, td_Water_Can_Preview_Model[playerid], -1);
        PlayerTextDrawSetShadow(playerid, td_Water_Can_Preview_Model[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Water_Can_Preview_Model[playerid], 119);
        PlayerTextDrawFont(playerid, td_Water_Can_Preview_Model[playerid], 5);
        PlayerTextDrawSetProportional(playerid, td_Water_Can_Preview_Model[playerid], 0);
        PlayerTextDrawSetPreviewModel(playerid, td_Water_Can_Preview_Model[playerid], 1650);
        PlayerTextDrawSetPreviewRot(playerid, td_Water_Can_Preview_Model[playerid], 0.000000, 0.000000, 0.000000, 0.800000);
    }

    if(bar_Water_Can_Progress[playerid] == PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        bar_Water_Can_Progress[playerid] = CreatePlayerProgressBar(playerid, 483.000000 + 80.0, 265.000000, 62.0, 0.5, 0xFF1C1CFF, MAX_WATER_CAN_CAPACITY, BAR_DIRECTION_RIGHT);
    }

    SetPlayerProgressBarValue(playerid, bar_Water_Can_Progress[playerid], GetPVarFloat(playerid, "WaterCanCapacity"));

    PlayerTextDrawShow(playerid, td_Water_Can_Container[playerid]);
    PlayerTextDrawShow(playerid, td_Water_Can_Preview_Model[playerid]);
    ShowPlayerProgressBar(playerid, bar_Water_Can_Progress[playerid]);
    return 1;
}

WaterCanInfoHideForPlayer(playerid)
{
    if(td_Water_Can_Container[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Water_Can_Container[playerid]);
    }

    if(td_Water_Can_Preview_Model[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Water_Can_Preview_Model[playerid]);
    }

    if(bar_Water_Can_Progress[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        DestroyPlayerProgressBar(playerid, bar_Water_Can_Progress[playerid]);
    }

    td_Water_Can_Container[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Water_Can_Preview_Model[playerid] = PlayerText:INVALID_TEXT_DRAW;
    bar_Water_Can_Progress[playerid] = PlayerBar:INVALID_PLAYER_BAR_ID;
    return 1;
}

TrailerSelectionShowForPlayer(playerid)
{
    if(td_Trailer_Selection_Container[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Trailer_Selection_Container[playerid] = CreatePlayerTextDraw(playerid, 185.000000, 153.000000, "_");
        PlayerTextDrawLetterSize(playerid, td_Trailer_Selection_Container[playerid], 0.000000, 15.500000);
        PlayerTextDrawTextSize(playerid, td_Trailer_Selection_Container[playerid], 470.000000, 0.000000);
        PlayerTextDrawAlignment(playerid, td_Trailer_Selection_Container[playerid], 1);
        PlayerTextDrawColor(playerid, td_Trailer_Selection_Container[playerid], -1);
        PlayerTextDrawUseBox(playerid, td_Trailer_Selection_Container[playerid], 1);
        PlayerTextDrawBoxColor(playerid, td_Trailer_Selection_Container[playerid], -120);
        PlayerTextDrawSetShadow(playerid, td_Trailer_Selection_Container[playerid], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Trailer_Selection_Container[playerid], 255);
        PlayerTextDrawFont(playerid, td_Trailer_Selection_Container[playerid], 1);
        PlayerTextDrawSetProportional(playerid, td_Trailer_Selection_Container[playerid], 1);
    }

    if(td_Trailer_Selection_Items[playerid][0] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Trailer_Selection_Items[playerid][0] = CreatePlayerTextDraw(playerid, 185.000000, 152.000000, "");
        PlayerTextDrawTextSize(playerid, td_Trailer_Selection_Items[playerid][0], 140.000000, 140.000000);
        PlayerTextDrawAlignment(playerid, td_Trailer_Selection_Items[playerid][0], 1);
        PlayerTextDrawColor(playerid, td_Trailer_Selection_Items[playerid][0], -1);
        PlayerTextDrawSetShadow(playerid, td_Trailer_Selection_Items[playerid][0], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Trailer_Selection_Items[playerid][0], 170);
        PlayerTextDrawFont(playerid, td_Trailer_Selection_Items[playerid][0], 5);
        PlayerTextDrawSetProportional(playerid, td_Trailer_Selection_Items[playerid][0], 0);
        PlayerTextDrawSetSelectable(playerid, td_Trailer_Selection_Items[playerid][0], true);
        PlayerTextDrawSetPreviewModel(playerid, td_Trailer_Selection_Items[playerid][0], 610);
        PlayerTextDrawSetPreviewRot(playerid, td_Trailer_Selection_Items[playerid][0], 0.000000, 0.000000, 0.000000, 0.70000);
        PlayerTextDrawSetPreviewVehCol(playerid, td_Trailer_Selection_Items[playerid][0], 1, 1);
    }

    if(td_Trailer_Selection_Items[playerid][1] == PlayerText:INVALID_TEXT_DRAW)
    {
        td_Trailer_Selection_Items[playerid][1] = CreatePlayerTextDraw(playerid, 330.000000, 152.000000, "");
        PlayerTextDrawTextSize(playerid, td_Trailer_Selection_Items[playerid][1], 140.000000, 140.000000);
        PlayerTextDrawAlignment(playerid, td_Trailer_Selection_Items[playerid][1], 1);
        PlayerTextDrawColor(playerid, td_Trailer_Selection_Items[playerid][1], -1);
        PlayerTextDrawSetShadow(playerid, td_Trailer_Selection_Items[playerid][1], 0);
        PlayerTextDrawBackgroundColor(playerid, td_Trailer_Selection_Items[playerid][1], 170);
        PlayerTextDrawFont(playerid, td_Trailer_Selection_Items[playerid][1], 5);
        PlayerTextDrawSetProportional(playerid, td_Trailer_Selection_Items[playerid][1], 0);
        PlayerTextDrawSetSelectable(playerid, td_Trailer_Selection_Items[playerid][1], true);
        PlayerTextDrawSetPreviewModel(playerid, td_Trailer_Selection_Items[playerid][1], FARMER_TRAILER_TYPE_OBJECT);
        PlayerTextDrawSetPreviewRot(playerid, td_Trailer_Selection_Items[playerid][1], -90.000000, 0.000000, 0.000000, 0.70000);
        PlayerTextDrawSetPreviewVehCol(playerid, td_Trailer_Selection_Items[playerid][1], 1, 1);
    }

    PlayerTextDrawShow(playerid, td_Trailer_Selection_Container[playerid]);
    PlayerTextDrawShow(playerid, td_Trailer_Selection_Items[playerid][0]);
    PlayerTextDrawShow(playerid, td_Trailer_Selection_Items[playerid][1]);
    return 1;
}

TrailerSelectionHideForPlayer(playerid)
{
    if(td_Trailer_Selection_Container[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Trailer_Selection_Container[playerid]);
    }

    if(td_Trailer_Selection_Items[playerid][0] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Trailer_Selection_Items[playerid][0]);
    }

    if(td_Trailer_Selection_Items[playerid][1] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td_Trailer_Selection_Items[playerid][1]);
    }

    td_Trailer_Selection_Container[playerid] = PlayerText:INVALID_TEXT_DRAW;
    td_Trailer_Selection_Items[playerid][0] = PlayerText:INVALID_TEXT_DRAW;
    td_Trailer_Selection_Items[playerid][1] = PlayerText:INVALID_TEXT_DRAW;
    return 1;
}

GetClosestSeedIndexToPoint(Float:range, Float:x, Float:y, Float:z)
{
    new Float:object_pos[3],
        Float:max_dist = range+0.01,
        Float:dist,
        objectid = 0,
        seed_index = -1,
        items[5];
    new count = Streamer_GetNearbyItems(x, y, z, STREAMER_TYPE_OBJECT, items, sizeof(items), range, -1);
    if(count > 0)
    {
        for(new i = 0, j = sizeof(items); i < j; i++)
        {
            if(items[i] != 0)
            {
                if(Streamer_GetIntData(STREAMER_TYPE_OBJECT, items[i], E_STREAMER_EXTRA_ID) == STREAMER_SEED_EXTRA_ID)
                {
                    GetDynamicObjectPos(items[i], object_pos[0], object_pos[1], object_pos[2]);
                    dist = floatsqroot(floatpower(object_pos[0] - x, 2) + floatpower(object_pos[1] - y, 2));
                    if(dist <= max_dist)
                    {
                        max_dist = dist;
                        objectid = items[i];
                    }
                }
            }
        }
        if(objectid != 0)
        {
            foreach(new i : I_Seeds)
            {
                if(Seeds[i][seed_Object] == objectid)
                {
                    seed_index = i;
                    break;
                }
            }
        }
    }
    return seed_index;
}

GetFreeVehicleWhiskIndex(vehicleid)
{
    for(new i = 0; i < MAX_WHISKS_PER_VEHICLE; i++)
    {
        if(FarmerVehicles[vehicleid][veh_Whisk_Objects][i] == 0)
            return i;
    }
    return -1;
}

GetFreeSeedConveyorObjIdx()
{
    for(new i = 0; i < MAX_SEEDS_PER_CONVEYOR; i++)
    {
        if(SeedConveyor[conveyor_Objects][i] == 0)
        {
            return i;
        }
    }
    return -1;
}

GetVehicleFreeHSIndex(vehicleid)
{
    for(new i = 0; i < MAX_HS_SLOTS_PER_VEHICLE; i++)
    {
        if(FarmerVehicles[vehicleid][veh_HS_Objects][i] == 0)
            return i;
    }
    return -1;
}

LoadHSToVehicle(vehicleid, type, Float:progress)
{
    new HS_index = GetVehicleFreeHSIndex(vehicleid);
    if(HS_index == -1)
        return HS_index;

    new Float:coords[6];
    if(GenerateHSAttachmentCoords(type, coords))
    {
        FarmerVehicles[vehicleid][veh_HS_Objects][HS_index] = CreateDynamicObject(DefaultSeedInfo[type][seed_Model], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
        FarmerVehicles[vehicleid][veh_HS_Progress][HS_index] = progress;
        FarmerVehicles[vehicleid][veh_HS_Types][HS_index] = type;
        AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_HS_Objects][HS_index], vehicleid, coords[0], coords[1], coords[2], coords[3], coords[4], coords[5]);
    }
    return HS_index;
}

GetPointInFront3D(Float:x,Float:y,Float:z,Float:rx,Float:rz,Float:radius,&Float:tx,&Float:ty,&Float:tz){
	tx = x - (radius * floatcos(rx,degrees) * floatsin(rz,degrees));
	ty = y + (radius * floatcos(rx,degrees) * floatcos(rz,degrees));
	tz = z + (radius * floatsin(rx,degrees));
}

Float:CompRotationFloat(Float:rotation,&Float:crotation=0.0){
	crotation = rotation;
	while(crotation < 0.0) crotation += 360.0;
	while(crotation >= 360.0) crotation -= 360.0;
	return crotation;
}

bool:GetRotationFor2Point3D(Float:x,Float:y,Float:z,Float:tx,Float:ty,Float:tz,&Float:rx,&Float:rz){
	new Float:radius = GetDistanceBetweenPoints3D(x,y,z,tx,ty,tz);
	if(radius <= 0.0) return false;
	CompRotationFloat(-(acos((tz-z)/radius)-90.0),rx);
	CompRotationFloat((atan2(ty-y,tx-x)-90.0),rz);
	return true;
}

CreateCow()
{
    new index = Iter_Free(I_Cows);
    if(index != cellmin)
    {
        Cows[index][cow_Object_Id] = CreateDynamicObject(19833, CowSpawnCoords[index][0], CowSpawnCoords[index][1], CowSpawnCoords[index][2], CowSpawnCoords[index][3], CowSpawnCoords[index][4], CowSpawnCoords[index][5]);
        //Cows[index][cow_Owner_Id] = playerid;
        Cows[index][cow_Owner_Id] = -1;
        Cows[index][cow_Progress] = 0.0;
        Cows[index][cow_Fullness] = 0.1;
        Cows[index][cow_Water] = 0.1;
        Cows[index][cow_Cleanness] = 0.2;
        Cows[index][cow_Is_Drinking_Water] = false;
        Streamer_SetIntData(STREAMER_TYPE_OBJECT, Cows[index][cow_Object_Id], E_STREAMER_EXTRA_ID, STREAMER_COW_EXTRA_ID);
        Iter_Add(I_Cows, index);
    }
    return index;
}

GetVehicleRotation(vehicleid, &Float:rx, &Float:ry, &Float:rz){
	new Float:qw,
        Float:qx,
        Float:qy,
        Float:qz;
	GetVehicleRotationQuat(vehicleid, qw, qx, qy, qz);
	rx = asin(2 * qy * qz - 2 * qx * qw);
	ry = -atan2(qx * qz + qy * qw, 0.5 - qx * qx - qy * qy);
	rz = -atan2(qx * qy + qz * qw, 0.5 - qx * qx - qz * qz);
    return 1;
}

GetPlayerCow(playerid)
{
    foreach(new i : I_Cows)
    {
        if(Cows[i][cow_Owner_Id] == playerid) return i;
    }
    return -1;
}

SetupPlayerForClassSelection(playerid)
{
 	SetPlayerInterior(playerid,14);
	SetPlayerPos(playerid,258.4893,-41.4008,1002.0234);
	SetPlayerFacingAngle(playerid, 270.0);
	SetPlayerCameraPos(playerid,256.0815,-43.0475,1004.0234);
	SetPlayerCameraLookAt(playerid,258.4893,-41.4008,1002.0234);
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == Text:INVALID_TEXT_DRAW)
    {
        TrailerSelectionHideForPlayer(playerid);
    }
    return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(GetPVarType(playerid, "Trailer_Selection_Vehicle_Id"))
    {
        if(playertextid == td_Trailer_Selection_Items[playerid][0]) // model 610
        {
            new vehicleid = GetPVarInt(playerid, "Trailer_Selection_Vehicle_Id");
            if(vehicleid != GetPlayerVehicleID(playerid))
                return SendClientMessage(playerid, -1, "Ban da roi khoi xe, khong the thue trailer.");

            if(GetVehicleTrailer(vehicleid) != 0)
                return SendClientMessage(playerid, -1, "Tren xe dang gan mot trailer.");

            if(FarmerVehicles[vehicleid][veh_Trailer_Id] != 0)
                return SendClientMessage(playerid, -1, "Phuong tien nay da co thue mot trailer truoc do.");

            new Float:pos[3],
                random_index = random(4);
            GetVehiclePos(vehicleid, pos[0], pos[1], pos[2]);
            FarmerVehicles[vehicleid][veh_Trailer_Id] = CreateVehicle(610, TrailerSpawnPos[0][random_index][0], TrailerSpawnPos[0][random_index][1], TrailerSpawnPos[0][random_index][2], TrailerSpawnPos[0][random_index][5], 0, 0, -1);
            FarmerVehicles[vehicleid][veh_Trailer_Is_Vehicle] = true;

            TrailerSelectionHideForPlayer(playerid);
            CancelSelectTextDraw(playerid);
            DeletePVar(playerid, "Trailer_Selection_Vehicle_Id");
        }
        else if(playertextid == td_Trailer_Selection_Items[playerid][1]) // model 607
        {
            new vehicleid = GetPVarInt(playerid, "Trailer_Selection_Vehicle_Id");
            if(vehicleid != GetPlayerVehicleID(playerid))
                return SendClientMessage(playerid, -1, "Ban da roi khoi xe, khong the thue trailer.");

            if(GetVehicleTrailer(vehicleid) != 0)
                return SendClientMessage(playerid, -1, "Tren xe dang gan mot trailer.");

            if(FarmerVehicles[vehicleid][veh_Trailer_Id] != 0)
                return SendClientMessage(playerid, -1, "Phuong tien nay da co thue mot trailer truoc do.");

            new Float:pos[3],
                random_index = random(4);
            GetVehiclePos(vehicleid, pos[0], pos[1], pos[2]);
            FarmerVehicles[vehicleid][veh_Trailer_Id] = CreateDynamicObject(FARMER_TRAILER_TYPE_OBJECT, TrailerSpawnPos[1][random_index][0], TrailerSpawnPos[1][random_index][1], TrailerSpawnPos[1][random_index][2], TrailerSpawnPos[1][random_index][3], TrailerSpawnPos[1][random_index][4], TrailerSpawnPos[1][random_index][5], -1, -1);
            FarmerVehicles[vehicleid][veh_Trailer_Is_Vehicle] = false;

            TrailerSelectionHideForPlayer(playerid);
            CancelSelectTextDraw(playerid);
            DeletePVar(playerid, "Trailer_Selection_Vehicle_Id");
        }
    }
    return 1;
}

public OnGameModeInit()
{
    FarmAreas[0] = CreateDynamicPolygon(FarmAreaPoints0);
	FarmAreas[1] = CreateDynamicPolygon(FarmAreaPoints1);
	FarmAreas[2] = CreateDynamicPolygon(FarmAreaPoints2);
    WaterPoolArea = CreateDynamicPolygon(WaterPoolPoints);
    CowArea = CreateDynamicPolygon(CowAreaPoints);

    Streamer_SetIntData(STREAMER_TYPE_AREA, FarmAreas[0], E_STREAMER_EXTRA_ID, STREAMER_FARM_AREA_EXTRA_ID);
    Streamer_SetIntData(STREAMER_TYPE_AREA, FarmAreas[1], E_STREAMER_EXTRA_ID, STREAMER_FARM_AREA_EXTRA_ID);
    Streamer_SetIntData(STREAMER_TYPE_AREA, FarmAreas[2], E_STREAMER_EXTRA_ID, STREAMER_FARM_AREA_EXTRA_ID);
    Streamer_SetIntData(STREAMER_TYPE_AREA, WaterPoolArea, E_STREAMER_EXTRA_ID, STREAMER_WATER_AREA_EXTRA_ID);
    Streamer_SetIntData(STREAMER_TYPE_AREA, CowArea, E_STREAMER_EXTRA_ID, STREAMER_COW_EXTRA_ID);

    for(new i = 0; i < MAX_SEEDS; i++)
    {
        Seeds[i][seed_Owner] = -1;
        Seeds[i][seed_Timestamp] = 0;
        Seeds[i][seed_Object] = 0;
        Seeds[i][seed_Text3D] = Text3D:INVALID_3DTEXT_ID;
        Seeds[i][seed_Water] = 0.0;
        Seeds[i][seed_Quantity] = 0.0;
        Seeds[i][seed_Progress] = 0.0;
        Seeds[i][seed_Harvested] = false;
    }
    Iter_Init(I_VehicleSeeds);

    for(new i = 0; i < MAX_VEHICLES; i++)
    {
        FarmerVehicles[i][veh_Owner_Id] = -1;
        FarmerVehicles[i][veh_Water_Can_Object] = 0;
        FarmerVehicles[i][veh_Water_Can_Capacity] = 0.0;
        FarmerVehicles[i][veh_Trailer_Id] = 0;
        FarmerVehicles[i][veh_Cow_Object_Id] = 0;
        FarmerVehicles[i][veh_Cow_Progress] = 0.0;
        for(new j = 0; j < MAX_HS_SLOTS_PER_VEHICLE; j++)
        {
            FarmerVehicles[i][veh_HS_Objects][j] = 0;
            FarmerVehicles[i][veh_HS_Progress][j] = 0.0;
            FarmerVehicles[i][veh_HS_Types][j] = -1;
        }
    }

    for(new i = 0; i < MAX_SEEDS_PER_CONVEYOR; i++)
    {
        SeedConveyor[conveyor_Objects][i] = 0;
        SeedConveyor[conveyor_Progress][i] = 0.0;
        SeedConveyor[conveyor_Owners][i] = -1;
        SeedConveyor[conveyor_Types][i] = -1;
    }
    SeedConveyor[conveyor_Last_Timestamp] = 0;

    new bar[2][45];
    bar[0] = "{FFFFFF}IIIIIIIIIIIIIIIIIIII";
    bar[1] = " {FFFFFF}IIIIIIIIIIIIIIIIIIII";
    for(new i = 0; i < MAX_COWS; i++)
    {
        Cows[i][cow_Object_Id] = 0;
        Cows[i][cow_Owner_Id] = -1;
        Cows[i][cow_Fullness] = 0.0;
        Cows[i][cow_Water] = 0.0;
        Cows[i][cow_Progress] = 0.0;
        Cows[i][cow_Cleanness] = 0.0;
        Cows[i][cow_Whisk_Object_Id] = 0;
        Cows[i][cow_Whisk_Timestamp] = 0;
        Cows[i][cow_Is_Drinking_Water] = false;
        Cows[i][cow_Being_Dragged] = false;
        Cows[i][cow_3D_Bar][0] = Text3D:INVALID_3DTEXT_ID;
        Cows[i][cow_3D_Bar][1] = Text3D:INVALID_3DTEXT_ID;

        Gutters[i][gutter_3D_Bar][0] = CreateDynamic3DTextLabel(bar[0], 0xFFFFFFFE, GutterCoords[i][0], GutterCoords[i][1], GutterCoords[i][2], 5.0);
        Gutters[i][gutter_3D_Bar][1] = CreateDynamic3DTextLabel(bar[1], 0xFFFFFFFE, GutterCoords[i][0], GutterCoords[i][1], GutterCoords[i][2], 5.0);
        Gutters[i][gutter_Water] = 0.0;
    }

    temp_object = CreateDynamicObject(6959, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000); //
    temp_object = CreateDynamicObject(6959, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000); //no comment
    temp_object = CreateDynamicObject(6959, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000); //no comment
    temp_object = CreateDynamicObject(6959, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000); //no comment
    temp_object = CreateDynamicObject(6959, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000); //no comment
    temp_object = CreateDynamicObject(18738, -431.2225, -1447.2086, 26.5699, 180.0000, 0.0000, 0.0000); //water_fnt_tme
    temp_object = CreateDynamicObject(19452, -435.1192, -1445.6258, 21.5837, -1.0000, -98.3001, -0.1000); //wall092
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19452, -436.8536, -1445.5603, 20.3463, 0.0000, -6.0000, 0.0000); //wall092
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19452, -429.9877, -1445.5533, 21.2919, 0.0000, -6.0000, 0.0000); //wall092
    SetDynamicObjectMaterial(temp_object, 0, 14650, "ab_trukstpc", "mp_CJ_WOOD5", 0x00000000);
    temp_object = CreateDynamicObject(3675, -347.2409, -1837.6411, -0.6819, 0.0000, 0.0000, 0.0000); //laxrf_refinerypipe
    temp_object = CreateDynamicObject(3675, -344.4609, -1837.6411, -0.6819, 0.0000, 0.0000, 0.0000); //laxrf_refinerypipe
    temp_object = CreateDynamicObject(19790, -418.4371, -1446.8299, 21.2635, 0.0000, 0.0000, 0.0000); //Cube5mx5m
    temp_object = CreateDynamicObject(19790, -345.7672, -1833.8725, -0.7562, 0.0000, 0.0000, 0.0000); //Cube5mx5m
    temp_object = CreateDynamicObject(3675, -344.8309, -1827.0941, 1.7769, -89.2994, -3.8998, 0.0000); //laxrf_refinerypipe
    temp_object = CreateDynamicObject(19433, -436.1025, -1452.3708, 20.4477, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(3675, -345.8879, -1827.1761, 1.7759, -89.2994, -3.8998, 0.0000); //laxrf_refinerypipe
    temp_object = CreateDynamicObject(3675, -419.9096, -1447.7353, 26.1564, 270.0000, 0.0000, -90.0000); //laxrf_refinerypipe
    temp_object = CreateDynamicObject(3675, -419.9096, -1446.1335, 26.1564, 270.0000, 0.0000, -90.0000); //laxrf_refinerypipe
    temp_object = CreateDynamicObject(3042, -431.1368, -1447.1678, 27.0202, 90.0000, 180.0000, 270.0000); //ct_vent
    temp_object = CreateDynamicObject(5836, -426.6358, -1446.7904, 21.6089, 0.0000, 0.0000, 90.0000); //ci_watertank
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "mp_diner_wood", 0x00000000);
    SetDynamicObjectMaterial(temp_object, 1, 2215, "chick_tray", "plaincup_cb", 0x00000000);
    SetDynamicObjectMaterial(temp_object, 2, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(3675, -419.4418, -1449.6804, 22.3929, 2.2999, 0.0000, 7.0998); //laxrf_refinerypipe
    temp_object = CreateDynamicObject(3675, -418.4794, -1449.5605, 22.3929, 2.2999, 0.0000, 7.0998); //laxrf_refinerypipe
    temp_object = CreateDynamicObject(3468, -420.0158, -1444.6440, 26.8731, -2.2999, 0.0000, 179.6000); //vegstreetsign2
    temp_object = CreateDynamicObject(19433, -434.5273, -1452.3564, 20.6634, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -432.9418, -1452.3426, 20.8805, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19452, -431.8898, -1445.5854, 22.0893, -1.0000, -97.8001, -0.1000); //wall092
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -431.3673, -1452.3302, 21.0963, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -436.1058, -1440.7170, 20.4612, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -434.5107, -1440.7043, 20.6798, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -432.9252, -1440.6905, 20.8969, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -431.3597, -1440.6749, 21.1114, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -430.6260, -1440.6761, 21.2119, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(18741, -431.4580, -1447.2989, 20.8253, 0.0000, 0.0000, 0.0000); //water_ripples
    temp_object = CreateDynamicObject(19433, -430.3601, -1451.0826, 21.2651, 0.0000, -6.0000, -2.5999); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -435.3789, -1451.6413, 22.2194, 0.4000, 97.5998, -179.4001); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -434.5444, -1450.3950, 20.6634, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19842, -424.5736, -1446.4719, 22.6765, 2.9999, -0.5000, -90.0000); //WaterFallWater1
    SetDynamicObjectMaterial(temp_object, 0, 14714, "vghss1int2", "HS1_2Floor1", 0x00000000);
    temp_object = CreateDynamicObject(19433, -436.1098, -1450.4090, 20.4491, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -431.4142, -1450.3691, 21.0923, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -432.9707, -1450.3813, 20.8892, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -430.6607, -1450.3607, 21.1954, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -430.3840, -1451.6025, 21.2651, 0.0000, -6.0000, -2.5999); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -431.1788, -1452.3280, 21.1222, -7.7999, 0.0000, 90.5000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -435.3843, -1451.1208, 22.2157, 0.4000, 97.5998, -179.4001); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -432.3210, -1451.1246, 22.6247, 0.4000, 97.5998, -179.4001); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -432.3138, -1451.5946, 22.6082, 0.4000, 97.5998, -179.4001); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(19433, -436.8391, -1451.2457, 20.3353, 0.0000, -6.0000, 0.0000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(3042, -436.8186, -1441.2264, 21.7035, -6.0000, -178.1999, 90.0000); //ct_vent
    temp_object = CreateDynamicObject(19452, -430.4186, -1445.5356, 20.8570, 0.0000, -6.0000, -6.1999); //wall092
    SetDynamicObjectMaterial(temp_object, 0, 14650, "ab_trukstpc", "mp_CJ_WOOD5", 0x00000000);
    temp_object = CreateDynamicObject(19433, -436.8391, -1451.6357, 20.3353, 0.0000, -6.0000, 0.0000); //wall073
    SetDynamicObjectMaterial(temp_object, 0, 14652, "ab_trukstpa", "CJ_WOOD6", 0x00000000);
    temp_object = CreateDynamicObject(2245, -436.0108, -1451.4929, 22.4808, 0.0000, 0.0000, 0.0000); //Plant_Pot_11
    temp_object = CreateDynamicObject(2245, -432.2308, -1451.5930, 22.9708, 0.0000, 0.0000, 0.0000); //Plant_Pot_11
    temp_object = CreateDynamicObject(2245, -433.6405, -1451.5930, 22.8108, 0.0000, 0.0000, 0.0000); //Plant_Pot_11
    temp_object = CreateDynamicObject(3042, -436.8088, -1449.9519, 21.7439, -6.0000, -178.1999, 90.0000); //ct_vent
    temp_object = CreateDynamicObject(1650, -430.3929, -1449.7729, 22.4838, 90.0000, 45.0000, 75.0000); //petrolcanm
    temp_object = CreateDynamicObject(1650, -430.3528, -1448.7065, 22.7987, 0.0000, 0.0000, 94.1996); //petrolcanm
    temp_object = CreateDynamicObject(19463, -370.3959, -1436.8343, 32.5377, 4.0000, 90.0998, 0.5999); //wall103
    SetDynamicObjectMaterial(temp_object, 0, 16322, "a51_stores", "des_ghotwood1", 0x00000000);
    temp_object = CreateDynamicObject(16083, -368.0439, -1435.6396, 26.5291, 0.0000, 0.0000, 78.6996); //des_quarry_hopper01
    temp_object = CreateDynamicObject(3631, -380.2806, -1434.4659, 25.5177, 0.0000, -27.7000, -0.6998); //oilcrat_LAS
    SetDynamicObjectMaterial(temp_object, 1, 10101, "2notherbuildsfe", "sl_vicwall02", 0x00000000);
    temp_object = CreateDynamicObject(2649, -367.8258, -1433.3885, 29.1201, 180.0000, 0.0000, 270.0000); //CJ_aircon2
    temp_object = CreateDynamicObject(19463, -366.8959, -1436.8155, 32.5306, 4.0000, 90.0998, 0.5999); //wall103
    SetDynamicObjectMaterial(temp_object, 0, 16322, "a51_stores", "des_ghotwood1", 0x00000000);
    temp_object = CreateDynamicObject(19463, -363.4060, -1436.7784, 32.5246, 4.0000, 90.0998, 0.5999); //wall103
    SetDynamicObjectMaterial(temp_object, 0, 16322, "a51_stores", "des_ghotwood1", 0x00000000);
    temp_object = CreateDynamicObject(3631, -373.5429, -1434.5648, 29.0550, 0.0000, -27.7000, -1.0000); //oilcrat_LAS
    SetDynamicObjectMaterial(temp_object, 1, 10101, "2notherbuildsfe", "sl_vicwall02", 0x00000000);
    temp_object = CreateDynamicObject(19789, -374.8280, -1434.5493, 24.3465, 0.0000, 0.0000, 0.0000); //Cube1mx1m
    temp_object = CreateDynamicObject(2960, -374.9189, -1434.5295, 26.6431, 0.0000, -89.4999, 0.0000); //kmb_beam
    temp_object = CreateDynamicObject(11480, -367.2579, -1462.4637, 26.8066, 0.0000, 0.0000, 101.7998); //des_nwt_carport
    temp_object = CreateDynamicObject(997, -392.4173, -1416.0108, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(8656, -410.8221, -1428.0407, 24.5000, 0.0000, 0.0000, 0.0000); //shbbyhswall09_lvs
    SetDynamicObjectMaterial(temp_object, 0, 642, "canopy", "wood02", 0x00000000);
    SetDynamicObjectMaterial(temp_object, 1, 3178, "counthousmisc", "shackwood01", 0x00000000);
    temp_object = CreateDynamicObject(19448, -406.5000, -1412.6500, 23.8798, 0.0000, 0.0000, 90.0000); //wall088
    SetDynamicObjectMaterial(temp_object, 0, 19071, "wssections", "wood1", 0x00000000);
    temp_object = CreateDynamicObject(997, -392.4173, -1421.4617, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -396.9570, -1421.4007, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -401.3167, -1421.4423, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(19448, -397.1951, -1412.6499, 23.8780, 0.0000, 0.0000, 90.0000); //wall088
    SetDynamicObjectMaterial(temp_object, 0, 19071, "wssections", "wood1", 0x00000000);
    temp_object = CreateDynamicObject(996, -357.1991, -1465.0537, 25.2600, 0.0000, 0.0000, 97.1998); //lhouse_barrier1
    temp_object = CreateDynamicObject(996, -358.4003, -1456.8808, 25.2600, 0.0000, 0.0000, 107.4998); //lhouse_barrier1
    temp_object = CreateDynamicObject(996, -356.1593, -1473.2877, 25.2600, 0.0000, 0.0000, 97.1998); //lhouse_barrier1
    temp_object = CreateDynamicObject(997, -400.1968, -1418.2618, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -395.6970, -1416.0108, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -400.1069, -1416.0108, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -404.4968, -1416.0108, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -401.3167, -1416.0008, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -395.6970, -1418.2618, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -396.9570, -1416.0008, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -404.5667, -1418.2618, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(19448, -397.1951, -1421.5302, 23.8780, 0.0000, 0.0000, 90.0000); //wall088
    SetDynamicObjectMaterial(temp_object, 0, 19071, "wssections", "wood1", 0x00000000);
    temp_object = CreateDynamicObject(19448, -406.4854, -1421.5302, 23.8780, 0.0000, 0.0000, 90.0000); //wall088
    SetDynamicObjectMaterial(temp_object, 0, 19071, "wssections", "wood1", 0x00000000);
    temp_object = CreateDynamicObject(997, -392.4173, -1424.8218, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -395.6970, -1424.7937, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -396.9570, -1424.7913, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -400.1968, -1424.7755, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -404.5667, -1424.7652, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -401.3167, -1424.8035, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -395.6970, -1426.9748, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -392.4173, -1430.1324, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -400.1968, -1426.9970, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -404.5667, -1426.9951, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -396.9570, -1430.1417, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(19448, -406.4952, -1430.2396, 23.8780, 0.0000, 0.0000, 90.0000); //wall088
    SetDynamicObjectMaterial(temp_object, 0, 19071, "wssections", "wood1", 0x00000000);
    temp_object = CreateDynamicObject(997, -401.3167, -1430.1536, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(19448, -397.1952, -1430.2396, 23.8780, 0.0000, 0.0000, 90.0000); //wall088
    SetDynamicObjectMaterial(temp_object, 0, 19071, "wssections", "wood1", 0x00000000);
    temp_object = CreateDynamicObject(997, -392.4173, -1433.5539, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -395.6970, -1433.5565, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -400.1968, -1433.5604, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -396.9570, -1433.5729, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -401.3167, -1433.5831, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -404.5667, -1433.5764, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -392.4173, -1438.8947, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -395.6970, -1435.6862, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -396.9570, -1438.9036, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -400.1968, -1435.6724, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -401.3167, -1438.8432, 24.7248, 0.0000, 0.0000, 90.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(997, -404.5667, -1435.6866, 24.7248, 0.0000, 0.0000, 0.0000); //lhouse_barrier3
    temp_object = CreateDynamicObject(19448, -397.1952, -1438.9836, 23.8780, 0.0000, 0.0000, 90.0000); //wall088
    SetDynamicObjectMaterial(temp_object, 0, 19071, "wssections", "wood1", 0x00000000);
    temp_object = CreateDynamicObject(19448, -406.4853, -1438.9836, 23.8780, 0.0000, 0.0000, 90.0000); //wall088
    SetDynamicObjectMaterial(temp_object, 0, 19071, "wssections", "wood1", 0x00000000);
    temp_object = CreateDynamicObject(2960, -394.7088, -1413.1353, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -399.1192, -1413.1353, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -403.5093, -1413.1353, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -394.7088, -1421.3481, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -399.1384, -1421.3481, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -403.5082, -1421.3481, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -394.7088, -1421.9987, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -399.1790, -1421.9987, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -403.5287, -1421.9987, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -394.7088, -1430.0386, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -399.1290, -1430.0386, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -403.5285, -1430.0386, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -394.7088, -1430.7093, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -399.1286, -1430.7093, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -403.5292, -1430.7093, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -394.7088, -1438.8123, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -399.1888, -1438.8123, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);
    temp_object = CreateDynamicObject(2960, -403.5486, -1438.8123, 24.7438, 90.0000, 0.0000, 0.0000); //mangnuoc
    SetDynamicObjectMaterial(temp_object, 0, 3054, "break_ballx", "brk_Ball2", 0xFFFFFFFF);

    CreateDynamicObject(916, -410.0172, -1417.5487, 24.2201, 0.0000, 0.0000, 88.5999); //thungdungong
    CreateDynamicObject(18633, -410.1362, -1417.6109, 24.1884, 0.0000, 120.0000, 0.0000); //pipe
    CreateDynamicObject(18633, -410.0569, -1417.6309, 24.1658, 0.0000, 120.0000, 0.0000); //pipe
    CreateDynamicObject(18633, -409.9046, -1417.6409, 24.1701, 0.0000, 120.0000, 0.0000); //pipe
    CreateDynamicObject(916, -409.9867, -1425.9028, 24.7848, 0.0000, 0.0000, 89.2000); //FRUITCRATE2
    CreateDynamicObject(916, -410.1104, -1434.7625, 24.8548, 0.0000, 0.0000, 89.2000); //FRUITCRATE2
    CreateDynamicObject(18633, -410.1230, -1425.9782, 24.7245, 0.0000, 150.0000, 0.0000); //pipe
    CreateDynamicObject(18633, -409.8933, -1425.9782, 24.7070, 0.0000, 150.0000, 0.0000); //pipe
    CreateDynamicObject(18633, -410.1181, -1434.8483, 24.8136, 0.0000, 150.0000, 0.0000); //GTASAWrench1
    CreateDynamicObject(18633, -409.9827, -1434.8283, 24.7993, 0.0000, 150.0000, 0.0000); //GTASAWrench1

    CreateDynamic3DTextLabel("An Y de mua hat giong.", -1, SeedBuyCoords[0], SeedBuyCoords[1], SeedBuyCoords[2] - 0.4, 10.0, _, _, 1, 0, 0, _, 10.0, _);
    CreateDynamicPickup(1239, 1, SeedBuyCoords[0], SeedBuyCoords[1], SeedBuyCoords[2], 0, 0, -1, 20.0, -1);

    CreateDynamic3DTextLabel("An Y de mo menu farmer.", -1, FarmerMenuCoords[0], FarmerMenuCoords[1], FarmerMenuCoords[2] - 0.4, 10.0, _, _, 1, 0, 0, _, 10.0, _);
    CreateDynamicPickup(1239, 1, FarmerMenuCoords[0], FarmerMenuCoords[1], FarmerMenuCoords[2], 0, 0, -1, 20.0, -1);

    for(new i = sizeof(PipeCoords) - 1; i != -1; i--)
    {
        CreateDynamicPickup(1239, 1, PipeCoords[i][0], PipeCoords[i][1], PipeCoords[i][2], 0, 0, -1, 20.0, -1);
        CreateDynamic3DTextLabel("Bam Y de lay Pipe", -1, PipeCoords[i][0], PipeCoords[i][1], PipeCoords[i][2] - 0.4, 10.0, _, _, 1, 0, 0, _, 10.0, _);
    }

    SetTimer("SeedLifeCycle", 3000, true);
    SetTimer("CowLifeCycle", 3000, true);
    return 1;
}

forward PlayerShowerCow(playerid, cow_idx);
public PlayerShowerCow(playerid, cow_idx)
{
    new Float:pos[3],
        Float:dist;
    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    GetPosInFrontOfPlayer(playerid, pos[0], pos[1], 1.5);

    Streamer_GetDistanceToItem(pos[0], pos[1], pos[2], STREAMER_TYPE_OBJECT, Cows[cow_idx][cow_Object_Id], dist, 3);
    printf("playerid %d, cow %d, dist %.2f", playerid, cow_idx, dist);
    if(dist <= 1.75)
    {
        Cows[cow_idx][cow_Cleanness] += 0.02;
        if(Cows[cow_idx][cow_Cleanness] >= 1.0)
        {
            Cows[cow_idx][cow_Cleanness] = 1.0;
        }

        if(bar_Cow_Info_Cleanness[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
        {
            SetPlayerProgressBarValue(playerid, bar_Cow_Info_Cleanness[playerid], Cows[cow_idx][cow_Cleanness]);
        }
    }
    return 1;
}

forward PlayerDraggingCow(playerid, cow_idx);
public PlayerDraggingCow(playerid, cow_idx)
{
    new Float:pos[6];

    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    GetDynamicObjectPos(Cows[cow_idx][cow_Object_Id], pos[3], pos[4], pos[5]);

    if(GetDistanceBetweenPoints3D(pos[0], pos[1], pos[2], pos[3], pos[4], pos[5]) <= 2.0)
    {
        return 1;
    }

    new Float:rotx,
        Float:rotz;
    pos[2] -= 1.0;
    GetPosInFrontOfPlayer(playerid, pos[0], pos[1], -1.5);
    GetRotationFor2Point3D(pos[0], pos[1], pos[2], pos[3], pos[4], pos[5], rotx, rotz);

    StopDynamicObject(Cows[cow_idx][cow_Object_Id]);
    MoveDynamicObject(Cows[cow_idx][cow_Object_Id], pos[0], pos[1], pos[2], GetDistanceBetweenPoints3D(pos[0], pos[1], pos[2], pos[3], pos[4], pos[5]) / 1.0, rotx, 0.0, rotz);
    return 1;
}

forward SeedLifeCycle();
public SeedLifeCycle()
{
    new Float:z;
    foreach(new i : I_Seeds)
    {
        if(Seeds[i][seed_Harvested])
        {
            continue;
        }

        StopDynamicObject(Seeds[i][seed_Object]);

        if(Seeds[i][seed_Progress] >= 1.0)
        {
            Seeds[i][seed_Progress] = 1.0;
            continue;
        }

        Seeds[i][seed_Water] -= 0.01;
        if(Seeds[i][seed_Water] <= 0.0)
        {
            Seeds[i][seed_Water] = 0.0;
            continue;
        }

        Streamer_GetFloatData(STREAMER_TYPE_OBJECT, Seeds[i][seed_Object], E_STREAMER_Z, z);
        MoveDynamicObject(Seeds[i][seed_Object], Seeds[i][seed_Pos][0], Seeds[i][seed_Pos][1], Seeds[i][seed_Pos][2] + DefaultSeedInfo[Seeds[i][seed_Type]][seed_Max_Height], DefaultSeedInfo[Seeds[i][seed_Type]][seed_Progress_Velocity] * (Seeds[i][seed_Water] / 1.0), 0.0, 0.0, 0.0);
        Seeds[i][seed_Progress] = (z - Seeds[i][seed_Pos][2] - DefaultSeedInfo[Seeds[i][seed_Type]][seed_Min_Height]) / (DefaultSeedInfo[Seeds[i][seed_Type]][seed_Max_Height] - DefaultSeedInfo[Seeds[i][seed_Type]][seed_Min_Height]);
    }
    return 1;
}

forward CowLifeCycle();
public CowLifeCycle()
{
    foreach(new i : I_Cows)
    {
        if(Cows[i][cow_Progress] >= 1.0)
        {
            continue;
        }

        Cows[i][cow_Progress] += Cows[i][cow_Fullness] * 0.012 + Cows[i][cow_Water] * 0.004 + Cows[i][cow_Cleanness] * 0.002;
        Cows[i][cow_Fullness] -= 0.008;
        Cows[i][cow_Water] -= 0.01;
        Cows[i][cow_Cleanness] -= 0.01;

        if(Cows[i][cow_Progress] >= 1.0)
        {
            Cows[i][cow_Progress] = 1.0;
        }

        if(Cows[i][cow_Fullness] <= 0.0)
        {
            Cows[i][cow_Fullness] = 0.0;
        }

        if(Cows[i][cow_Water] <= 0.0)
        {
            Cows[i][cow_Water] = 0.0;
        }

        if(Cows[i][cow_Cleanness] <= 0.0)
        {
            Cows[i][cow_Cleanness] = 0.0;
        }

        if(!Cows[i][cow_Being_Dragged])
        {
            if(Cows[i][cow_Water] <= 0.5)
            {
                if(Gutters[i][gutter_Water] > 0.001)
                {
                    if(!Cows[i][cow_Is_Drinking_Water])
                    {
                        new Float:pos[3],
                            Float:rotz,
                            Float:unused;

                        GetDynamicObjectPos(Cows[i][cow_Object_Id], pos[0], pos[1], pos[2]);
                        GetRotationFor2Point3D(GutterCoords[i][0], GutterCoords[i][1], GutterCoords[i][2], pos[0], pos[1], pos[2], unused, rotz);
                        Cows[i][cow_Is_Drinking_Water] = true;

                        MoveDynamicObject(Cows[i][cow_Object_Id], pos[0] + 0.0001, pos[1] + 0.0001, pos[2], 0.0001, 0.0, 0.0, rotz);
                    }
                }
            }

            if(Cows[i][cow_Is_Drinking_Water])
            {
                if(Cows[i][cow_Water] >= 1.0 || Gutters[i][gutter_Water] <= 0.001)
                {
                    new Float:pos[3];

                    GetDynamicObjectPos(Cows[i][cow_Object_Id], pos[0], pos[1], pos[2]);
                    Cows[i][cow_Water] = 1.0;
                    Cows[i][cow_Is_Drinking_Water] = false;

                    MoveDynamicObject(Cows[i][cow_Object_Id], pos[0] + 0.0001, pos[1] + 0.0001, pos[2], 0.00005, CowSpawnCoords[i][3], CowSpawnCoords[i][4], CowSpawnCoords[i][5]);
                }
                else
                {
                    if(Gutters[i][gutter_Water] <= 0.15)
                    {
                        new bar[2][45],
                            column;

                        bar[0] = "{40afff}IIIIIIIIIIIIIIIIIIII";
                        bar[1] = " {40afff}IIIIIIIIIIIIIIIIIIII";

                        Cows[i][cow_Water] += Gutters[i][gutter_Water];
                        Gutters[i][gutter_Water] = 0.0;

                        Cows[i][cow_Is_Drinking_Water] = false;

                        column = floatround(Gutters[i][gutter_Water] * 20 / MAX_GUTTER_WATER);
                        strins(bar[0], "{FFFFFF}", column + 8, 45);
                        strins(bar[1], "{FFFFFF}", column + 8 + 1, 45);

                        UpdateDynamic3DTextLabelText(Gutters[i][gutter_3D_Bar][0], 0xFFFFFFFE, bar[0]);
                        UpdateDynamic3DTextLabelText(Gutters[i][gutter_3D_Bar][1], 0xFFFFFFFE, bar[1]);
                    }
                    else
                    {
                        new bar[2][45],
                            column;

                        bar[0] = "{40afff}IIIIIIIIIIIIIIIIIIII";
                        bar[1] = " {40afff}IIIIIIIIIIIIIIIIIIII";

                        Gutters[i][gutter_Water] -= 0.15;
                        Cows[i][cow_Water] += 0.15;

                        column = floatround(Gutters[i][gutter_Water] * 20 / MAX_GUTTER_WATER);
                        strins(bar[0], "{FFFFFF}", column + 8, 45);
                        strins(bar[1], "{FFFFFF}", column + 8 + 1, 45);

                        UpdateDynamic3DTextLabelText(Gutters[i][gutter_3D_Bar][0], 0xFFFFFFFE, bar[0]);
                        UpdateDynamic3DTextLabelText(Gutters[i][gutter_3D_Bar][1], 0xFFFFFFFE, bar[1]);
                    }
                }
            }
            else
            {
                StopDynamicObject(Cows[i][cow_Object_Id]);
                MoveDynamicObject(Cows[i][cow_Object_Id], CowSpawnCoords[i][0], CowSpawnCoords[i][1], CowSpawnCoords[i][2] + (Cows[i][cow_Progress] * 0.3), 0.05, CowSpawnCoords[i][3], CowSpawnCoords[i][4], CowSpawnCoords[i][5]);
            }
        }
    }
    return 1;
}

forward CowEatingUpdate(cow);
public CowEatingUpdate(cow)
{
    new now = gettime();
    if(Cows[cow][cow_Whisk_Object_Id] != 0)
    {
        if(now - Cows[cow][cow_Whisk_Timestamp] >= 20)
        {
            DestroyDynamicObject(Cows[cow][cow_Whisk_Object_Id]);
            DestroyDynamic3DTextLabel(Cows[cow][cow_3D_Bar][0]);
            DestroyDynamic3DTextLabel(Cows[cow][cow_3D_Bar][1]);
            Cows[cow][cow_Whisk_Object_Id] = 0;
            Cows[cow][cow_3D_Bar][0] = Text3D:INVALID_3DTEXT_ID;
            Cows[cow][cow_3D_Bar][1] = Text3D:INVALID_3DTEXT_ID;
            Cows[cow][cow_Whisk_Timestamp] = 0;
            KillTimer(Cows[cow][cow_Eating_Timer]);
        }
        else
        {
            new bar[2][45],
                column;

            bar[0] = "{00db21}IIIIIIIIIIIIIIIIIIII";
            bar[1] = " {00db21}IIIIIIIIIIIIIIIIIIII";

            column = now - Cows[cow][cow_Whisk_Timestamp];
            strins(bar[0], "{FFFFFF}", column + 8, 45);
            strins(bar[1], "{FFFFFF}", column + 8 + 1, 45);

            UpdateDynamic3DTextLabelText(Cows[cow][cow_3D_Bar][0], 0xFFFFFFFE, bar[0]);
            UpdateDynamic3DTextLabelText(Cows[cow][cow_3D_Bar][1], 0xFFFFFFFE, bar[1]);
        }
        Cows[cow][cow_Fullness] += 0.035;
        Cows[cow][cow_Water] += 0.00017;

        if(Cows[cow][cow_Fullness] >= 1.0)
        {
            Cows[cow][cow_Fullness] = 1.0;
        }

        if(Cows[cow][cow_Water] >= 1.0)
        {
            Cows[cow][cow_Water] = 1.0;
        }
    }
    return 1;
}

forward VehicleHarvestTimer(vehicleid);
public VehicleHarvestTimer(vehicleid)
{
    if(FarmerVehicles[vehicleid][veh_Trailer_Smoke_Object] == 0)
    {
        if(FarmerVehicles[vehicleid][veh_Harvest_Timer] != 0)
        {
            KillTimer(FarmerVehicles[vehicleid][veh_Harvest_Timer]);
            FarmerVehicles[vehicleid][veh_Harvest_Timer] = 0;
        }
        return 1;
    }

    if(GetVehicleTrailer(vehicleid) == 0)
        return 1;

    new trailerid = GetVehicleTrailer(vehicleid);
    if(trailerid != FarmerVehicles[vehicleid][veh_Trailer_Id])
        return 1;

    new Float:pos[3],
        items[5] = {0, ...},
        count = 0;
    GetVehiclePos(trailerid, pos[0], pos[1], pos[2]);
    count = Streamer_GetNearbyItems(pos[0], pos[1], pos[2], STREAMER_TYPE_OBJECT, items, sizeof(items), 2.0, -1);
    if(count > 0)
    {
        new string[112];
        count = 0;
        for(new i = 0, j = sizeof(items); i < j; i++)
        {
            if(count < 3)
            {
                if(items[i] != 0)
                {
                    if(Streamer_GetIntData(STREAMER_TYPE_OBJECT, items[i], E_STREAMER_EXTRA_ID) == STREAMER_SEED_EXTRA_ID)
                    {
                        foreach(new x : I_Seeds)
                        {
                            if(Seeds[x][seed_Object] == items[i])
                            {
                                if(!Seeds[x][seed_Harvested])
                                {
                                    if(Seeds[x][seed_Progress] >= 0.8)
                                    {
                                        StopDynamicObject(Seeds[x][seed_Object]);

                                        GetDynamicObjectPos(Seeds[x][seed_Object], pos[0], pos[1], pos[2]);
                                        MoveDynamicObject(Seeds[x][seed_Object], pos[0], pos[1], pos[2] + 0.3, 0.2, 0.0, 90.0, 0.0);
                                        format(string, sizeof(string), "{%06x}%s{FFFFFF}[%d/%d]\n{0cad00}Da thu hoach", DefaultSeedInfo[Seeds[x][seed_Type]][seed_Color] >>> 8, DefaultSeedInfo[Seeds[x][seed_Type]][seed_Name], x, MAX_SEEDS - 1);
                                        UpdateDynamic3DTextLabelText(Seeds[x][seed_Text3D], -1, string);
                                        Seeds[x][seed_Harvested] = true;
                                        count++;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else return 1;
        }
    }
    return 1;
}

forward PlayerLoadSeedToConveyor(playerid);
public PlayerLoadSeedToConveyor(playerid)
{
    new idx = GetFreeSeedConveyorObjIdx();
    if(idx == -1)
    {
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
        SendClientMessage(playerid, -1, "Bang chuyen dang qua tai.");
        return 1;
    }

    new seed_type = GetPVarInt(playerid, "HS_Type");
    SeedConveyor[conveyor_Objects][idx] = CreateDynamicObject(DefaultSeedInfo[seed_type][seed_Model], SeedConveyorCoords[seed_type][0], SeedConveyorCoords[seed_type][1], SeedConveyorCoords[seed_type][2], SeedConveyorCoords[seed_type][6], SeedConveyorCoords[seed_type][7], SeedConveyorCoords[seed_type][8]);
    MoveDynamicObject(SeedConveyor[conveyor_Objects][idx], SeedConveyorCoords[seed_type][3], SeedConveyorCoords[seed_type][4], SeedConveyorCoords[seed_type][5], 0.8);
    SeedConveyor[conveyor_Progress][idx] = GetPVarFloat(playerid, "HS_Progress");
    SeedConveyor[conveyor_Owners][idx] = playerid;
    SeedConveyor[conveyor_Types][idx] = seed_type;
    Streamer_SetIntData(STREAMER_TYPE_OBJECT, SeedConveyor[conveyor_Objects][idx], E_STREAMER_EXTRA_ID, STREAMER_CONVEYOR_OBJECT_EX_ID);
    SeedConveyor[conveyor_Last_Timestamp] = gettime();

    RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "HS_AttachmentIndex"));
    DeletePVar(playerid, "HS_AttachmentIndex");
    DeletePVar(playerid, "HS_Progress");
    DeletePVar(playerid, "HS_Type");
    DeletePVar(playerid, "HS_Conveyor_Loading_Timer");
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    DisablePlayerCheckpoint(playerid);

    if(GetPVarType(playerid, "DraggingCow_Index") && GetPVarType(playerid, "DraggingCow_Vehicle_Id"))
    {
        new vehicleid = GetPVarInt(playerid, "DraggingCow_Vehicle_Id"),
            cow_idx = GetPVarInt(playerid, "DraggingCow_Index"),
            Float:pos[3];

        GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], 0.0, -5.0, 0.0);
        if(IsPlayerInRangeOfPoint(playerid, 3.0, pos[0], pos[1], pos[2]))
        {
            if(FarmerVehicles[vehicleid][veh_Cow_Object_Id] == 0)
            {
                KillTimer(GetPVarInt(playerid, "DraggingCow_Timer"));
                DeletePVar(playerid, "DraggingCow_Timer");
                DeletePVar(playerid, "DraggingCow_Index");
                DeletePVar(playerid, "DraggingCow_Vehicle_Id");

                FarmerVehicles[vehicleid][veh_Cow_Object_Id] = CreateDynamicObject(19833, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
                FarmerVehicles[vehicleid][veh_Cow_Progress] = Cows[cow_idx][cow_Progress];
                switch(GetVehicleModel(vehicleid))
                {
                    case 422, 600:
                    {
                        AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Cow_Object_Id], vehicleid, 0.0, -1.2, -0.3, 0.0, 0.0, 180.0);
                    }
                    case 478:
                    {
                        AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Cow_Object_Id], vehicleid, 0.0, -1.2, -0.1, 0.0, 0.0, 180.0);
                    }
                    case 543:
                    {
                        AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Cow_Object_Id], vehicleid, 0.0, -1.4, -0.2, 0.0, 0.0, 180.0);
                    }
                    case 531:
                    {
                        AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Cow_Object_Id], vehicleid, 0.0, -3.5, -0.3, 0.0, 0.0, 180.0);
                    }
                    default:
                    {
                        StopDynamicObject(Cows[cow_idx][cow_Object_Id]);

                        SetDynamicObjectPos(Cows[cow_idx][cow_Object_Id], CowSpawnCoords[cow_idx][0], CowSpawnCoords[cow_idx][1], CowSpawnCoords[cow_idx][2]);
                        SetDynamicObjectRot(Cows[cow_idx][cow_Object_Id], CowSpawnCoords[cow_idx][3], CowSpawnCoords[cow_idx][4], CowSpawnCoords[cow_idx][5]);
                        return 1;
                    }
                }

                DestroyDynamicObject(Cows[cow_idx][cow_Object_Id]);
                Cows[cow_idx][cow_Object_Id] = 0;
                Cows[cow_idx][cow_Owner_Id] = -1;
                Cows[cow_idx][cow_Fullness] = 0.0;
                Cows[cow_idx][cow_Water] = 0.0;
                Cows[cow_idx][cow_Progress] = 0.0;
                Cows[cow_idx][cow_Cleanness] = 0.0;
                Cows[cow_idx][cow_Whisk_Object_Id] = 0;
                Cows[cow_idx][cow_Whisk_Timestamp] = 0;
                Cows[cow_idx][cow_Is_Drinking_Water] = false;
                Cows[cow_idx][cow_Being_Dragged] = false;
                Iter_Remove(I_Cows, cow_idx);
            }
        }
        else SetPlayerCheckpoint(playerid, pos[0], pos[1], pos[2], 1.0);
    }
    return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID) == STREAMER_FARM_AREA_EXTRA_ID)
    {
        if(IsPlayerInAnyVehicle(playerid))
        {
            new vehicleid = GetPlayerVehicleID(playerid);
            if(FarmerVehicles[vehicleid][veh_Trailer_Smoke_Object] != 0)
            {
                if(FarmerVehicles[vehicleid][veh_Harvest_Timer] != 0)
                {
                    KillTimer(FarmerVehicles[vehicleid][veh_Harvest_Timer]);
                }
                FarmerVehicles[vehicleid][veh_Harvest_Timer] = SetTimerEx("VehicleHarvestTimer", 200, true, "i", vehicleid);
            }
        }

        for(new i = 0; i < sizeof(FarmAreas); i++)
        {
            if(areaid == FarmAreas[i])
            {
                new string[64];
                format(string, sizeof(string), "enter area %d, farm index %d", areaid, i);
                SendClientMessage(playerid, -1, string);
                break;
            }
        }
    }
    else if(Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID) == STREAMER_WATER_AREA_EXTRA_ID)
    {
        new string[64];
        format(string, sizeof(string), "enter water area %d", areaid);
        SendClientMessage(playerid, -1, string);
    }
    return 1;
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
    switch(Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID))
    {
        case STREAMER_FARM_AREA_EXTRA_ID:
        {
            if(IsPlayerInAnyVehicle(playerid))
            {
                new vehicleid = GetPlayerVehicleID(playerid);
                if(FarmerVehicles[vehicleid][veh_Harvest_Timer] != 0)
                {
                    KillTimer(FarmerVehicles[vehicleid][veh_Harvest_Timer]);
                    FarmerVehicles[vehicleid][veh_Harvest_Timer] = 0;
                }
            }

            for(new i = 0; i < sizeof(FarmAreas); i++)
            {
                if(areaid == FarmAreas[i])
                {
                    new string[64];
                    format(string, sizeof(string), "leave area %d, farm index %d", areaid, i);
                    SendClientMessage(playerid, -1, string);
                    break;
                }
            }
        }
        case STREAMER_WATER_AREA_EXTRA_ID:
        {
            new string[64];
            format(string, sizeof(string), "leave water area %d", areaid);
            SendClientMessage(playerid, -1, string);
            if(GetPVarType(playerid, "ChargingWaterCanTimer"))
            {
                KillTimer(GetPVarInt(playerid, "ChargingWaterCanTimer"));
                WaterCanInfoHideForPlayer(playerid);
                DeletePVar(playerid, "ChargingWaterCanTimer");
            }
        }
        case STREAMER_COW_EXTRA_ID:
        {
            if(GetPVarType(playerid, "DraggingCow_Timer"))
            {
                SendClientMessage(playerid, -1, "Ban khong duoc roi khoi khu vuc chan nuoi trong luc dan bo.");

                KillTimer(GetPVarInt(playerid, "DraggingCow_Timer"));
                DeletePVar(playerid, "DraggingCow_Timer");

                if(GetPVarType(playerid, "DraggingCow_Index"))
                {
                    new index = GetPVarInt(playerid, "DraggingCow_Index");
                    StopDynamicObject(Cows[index][cow_Object_Id]);
                    SetDynamicObjectPos(Cows[index][cow_Object_Id], CowSpawnCoords[index][0], CowSpawnCoords[index][1], CowSpawnCoords[index][2]);
                    SetDynamicObjectRot(Cows[index][cow_Object_Id], CowSpawnCoords[index][3], CowSpawnCoords[index][4], CowSpawnCoords[index][5]);

                    DeletePVar(playerid, "DraggingCow_Index");
                }
            }
        }
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & KEY_FIRE)
    {
        if(IsPlayerInAnyVehicle(playerid))
        {
            new vehicleid = GetPlayerVehicleID(playerid);
            if(GetVehicleModel(vehicleid) == VEHICLE_TRACTOR)
            {
                new trailerid = GetVehicleTrailer(vehicleid);
                if(trailerid != 0)
                {
                    if(Iter_Count(I_VehicleSeeds[trailerid]) > 0)
                    {
                        for(new i = 0; i < MAX_FARM_AREAS; i++)
                        {
                            if(IsPlayerInDynamicArea(playerid, FarmAreas[i]))
                            {
                                new Float:pos[3],
                                    items[5];
                                GetVehiclePos(trailerid, pos[0], pos[1], pos[2]);
                                Streamer_GetNearbyItems(pos[0], pos[1], pos[2], STREAMER_TYPE_OBJECT, items, sizeof(items), 3.5, -1);

                                for(new m = 0, n = sizeof(items); m < n; m++)
                                {
                                    if(items[m] != 0)
                                    {
                                        if(Streamer_GetIntData(STREAMER_TYPE_OBJECT, items[m], E_STREAMER_EXTRA_ID) == STREAMER_SEED_EXTRA_ID)
                                        {
                                            return 1;
                                        }
                                    }
                                }

                                new seeds[3] = {-1, ...},
                                    j = 0;
                                for(new x = Iter_End(I_VehicleSeeds[trailerid]); (x = Iter_Prev(I_VehicleSeeds[trailerid], x)) != Iter_Begin(I_VehicleSeeds[trailerid]); )
                                {
                                    seeds[j] = x;
                                    if(++j >= sizeof(seeds))
                                    {
                                        break;
                                    }
                                }

                                new index,
                                    k,
                                    text[92],
                                    Float:rot[3];
                                for(j = 0, k = sizeof(seeds); j < k; j++)
                                {
                                    if(seeds[j] != -1)
                                    {
                                        index = Iter_Free(I_Seeds);
                                        if(index == cellmin)
                                        {
                                            return SendClientMessage(playerid, -1, "So hat giong trong server da dat den gioi han.");
                                        }

                                        GetVehicleRotation(vehicleid, rot[0], rot[1], rot[2]);
                                        GetVehicleRelativePos(trailerid, Seeds[index][seed_Pos][0], Seeds[index][seed_Pos][1], Seeds[index][seed_Pos][2], - (j - 1) * (2.0 + (random(100) + 1) / 50), 0.0, (floattan(rot[1], degrees) * ((j - 1) * (2.0 + (random(100) + 1) / 50))));
                                        Seeds[index][seed_Object] = CreateDynamicObject(DefaultSeedInfo[VehicleSeeds[trailerid][seeds[j]]][seed_Model], Seeds[index][seed_Pos][0], Seeds[index][seed_Pos][1], Seeds[index][seed_Pos][2] + DefaultSeedInfo[VehicleSeeds[trailerid][seeds[j]]][seed_Min_Height], 0.0, 0.0, 0.0, -1, -1);
                                        Seeds[index][seed_Timestamp] = gettime();
                                        Seeds[index][seed_Owner] = FarmerVehicles[vehicleid][veh_Owner_Id];
                                        Seeds[index][seed_Water] = 0.0;
                                        Seeds[index][seed_Quantity] = 0.0;
                                        Seeds[index][seed_Progress] = 0.0;
                                        Seeds[index][seed_Harvested] = false;
                                        Seeds[index][seed_Type] = VehicleSeeds[trailerid][seeds[j]];
                                        format(text, sizeof(text), "{%06x}%s{FFFFFF}[%d/%d]", DefaultSeedInfo[Seeds[index][seed_Type]][seed_Color] >>> 8, DefaultSeedInfo[Seeds[index][seed_Type]][seed_Name], index, MAX_SEEDS - 1);
                                        Seeds[index][seed_Text3D] = CreateDynamic3DTextLabel(text, -1, Seeds[index][seed_Pos][0], Seeds[index][seed_Pos][1], Seeds[index][seed_Pos][2], 3.0, _, _, 0, 0, 0, playerid, 5.0);
                                        Streamer_SetIntData(STREAMER_TYPE_OBJECT, Seeds[index][seed_Object], E_STREAMER_EXTRA_ID, STREAMER_SEED_EXTRA_ID);

                                        Character[playerid][char_Outputs] += 0.5;
                                        Iter_Add(I_Seeds, index);
                                        Iter_Remove(I_VehicleSeeds[trailerid], seeds[j]);
                                    }
                                }
                                return 1;
                            }
                        }
                    }

                }
            }
        }
    }
    if(newkeys & KEY_YES)
    {
        if(IsPlayerInRangeOfPoint(playerid, 4.0, FarmerMenuCoords[0], FarmerMenuCoords[1], FarmerMenuCoords[2]))
        {
            ShowPlayerDialog(playerid, DIALOG_FARMER_MENU, DIALOG_STYLE_LIST, "Farmer Menu", "Thue xe\nLay trailer\nCham soc bo\nBan bo", "Chon", "Tat");
            return 1;
        }
        if(IsPlayerInAnyVehicle(playerid))
        {
            new vehicleid = GetPlayerVehicleID(playerid);
            if(FarmerVehicles[vehicleid][veh_Owner_Id] == playerid)
            {
                new trailerid = GetVehicleTrailer(vehicleid);
                if(FarmerVehicles[vehicleid][veh_Trailer_Id] != 0)
                {
                    if(FarmerVehicles[vehicleid][veh_Trailer_Is_Vehicle])
                    {
                        if(trailerid != 0)
                        {
                            DetachTrailerFromVehicle(vehicleid);
                            return 1;
                        }

                        new Float:pos[3];
                        GetVehiclePos(FarmerVehicles[vehicleid][veh_Trailer_Id], pos[0], pos[1], pos[2]);
                        if(GetVehicleDistanceFromPoint(vehicleid, pos[0], pos[1], pos[2]) <= 4.0)
                        {
                            AttachTrailerToVehicle(FarmerVehicles[vehicleid][veh_Trailer_Id], vehicleid);
                            return 1;
                        }
                    }
                    else
                    {
                        if(FarmerVehicles[vehicleid][veh_Trailer_Is_Attached])
                        {
                            new Float:pos[3];
                            GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], 0.0, -3.0, 0.0);
                            if(GetDistanceBetweenPoints3D(-368.1176, -1440.3578, 25.7266, pos[0], pos[1], pos[2]) <= 2.5)
                            {
                                if(seedStorage >= 5.0)
                                {
                                    new string[110];
                                    format(string, sizeof(string), "Hien tai trong kho dang co %.2f san luong tich tru, ban co muon doi 5.0 san luong tich tru cho 1 bo rom?", seedStorage);
                                    ShowPlayerDialog(playerid, DIALOG_TRADING_WHISK_CONFIRM, DIALOG_STYLE_MSGBOX, "Doi san luong tich tru", string, "Doi", "Huy");
                                    return 1;
                                }
                                else
                                {
                                    new string[110];
                                    format(string, sizeof(string), "Trong kho chi con %.2f san luong tich tru, can it nhat 5.0 san luong tich tru de doi 1 bo rom.", seedStorage);
                                    SendClientMessage(playerid, -1, string);
                                    return 1;
                                }
                            }
                            new Float:rot[3],
                                Float:coords[6];
                            GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], 0.0, -4.0, -0.9);
                            GetVehicleRotation(vehicleid, rot[0], rot[1], rot[2]);

                            DestroyDynamicObject(FarmerVehicles[vehicleid][veh_Trailer_Id]);

                            FarmerVehicles[vehicleid][veh_Trailer_Id] = CreateDynamicObject(FARMER_TRAILER_TYPE_OBJECT, pos[0], pos[1], pos[2], rot[0] + 25.0, rot[1], rot[2] + 180.0, -1, -1);
                            FarmerVehicles[vehicleid][veh_Trailer_Is_Attached] = false;

                            GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], -0.5, -2.7, -0.9);

                            for(new i = 0; i < MAX_HS_SLOTS_PER_VEHICLE; i++)
                            {
                                if(FarmerVehicles[vehicleid][veh_HS_Objects][i] != 0)
                                {
                                    GenerateHSAttachmentCoords(FarmerVehicles[vehicleid][veh_HS_Types][i], coords);
                                    GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], coords[0], coords[1] - 1.5, coords[2]);
                                    DestroyDynamicObject(FarmerVehicles[vehicleid][veh_HS_Objects][i]);
                                    FarmerVehicles[vehicleid][veh_HS_Objects][i] = CreateDynamicObject(DefaultSeedInfo[FarmerVehicles[vehicleid][veh_HS_Types][i]][seed_Model], pos[0], pos[1], pos[2], rot[0] + coords[3], rot[1] + coords[4], rot[2] + coords[5], -1, -1);
                                }
                            }

                            if(FarmerVehicles[vehicleid][veh_Cow_Object_Id] != 0)
                            {
                                GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], 0.0, -4.5, -0.3);
                                DestroyDynamicObject(FarmerVehicles[vehicleid][veh_Cow_Object_Id]);
                                FarmerVehicles[vehicleid][veh_Cow_Object_Id] = CreateDynamicObject(19833, pos[0], pos[1], pos[2], rot[0], 0.0, rot[2] + 180.0);
                            }
                            return 1;
                        }
                        else
                        {
                            new Float:pos[3];
                            GetDynamicObjectPos(FarmerVehicles[vehicleid][veh_Trailer_Id], pos[0], pos[1], pos[2]);
                            if(GetVehicleDistanceFromPoint(vehicleid, pos[0], pos[1], pos[2]) <= 4.0)
                            {
                                new Float:coords[6];
                                AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Trailer_Id], vehicleid, 0.0, -3.0, -0.9, 25.0, 0.0, 180.0);
                                FarmerVehicles[vehicleid][veh_Trailer_Is_Attached] = true;

                                for(new i = 0; i < MAX_HS_SLOTS_PER_VEHICLE; i++)
                                {
                                    if(FarmerVehicles[vehicleid][veh_HS_Objects][i] != 0)
                                    {
                                        GenerateHSAttachmentCoords(FarmerVehicles[vehicleid][veh_HS_Types][i], coords);
                                        DestroyDynamicObject(FarmerVehicles[vehicleid][veh_HS_Objects][i]);
                                        FarmerVehicles[vehicleid][veh_HS_Objects][i] = CreateDynamicObject(DefaultSeedInfo[FarmerVehicles[vehicleid][veh_HS_Types][i]][seed_Model], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1);
                                        AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_HS_Objects][i], vehicleid, coords[0], coords[1], coords[2], coords[3], coords[4], coords[5]);
                                    }
                                }

                                if(FarmerVehicles[vehicleid][veh_Cow_Object_Id] != 0)
                                {
                                    DestroyDynamicObject(FarmerVehicles[vehicleid][veh_Cow_Object_Id]);
                                    FarmerVehicles[vehicleid][veh_Cow_Object_Id] = CreateDynamicObject(19833, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
                                    AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Cow_Object_Id], vehicleid, 0.0, -3.5, -0.3, 0.0, 0.0, 180.0);
                                }
                                return 1;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            for(new i = 0, j = sizeof(PipeCoords); i < j; i++)
            {
                if(IsPlayerInRangeOfPoint(playerid, 4.0, PipeCoords[i][0], PipeCoords[i][1], PipeCoords[i][2]))
                {
                    if(GetPVarType(playerid, "ShowerPipe_AttachmentIndex"))
                    {
                        ApplyAnimation(playerid, "CARRY", "liftup105", 4.0, 0, 0, 0, 0,0);
                        RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "ShowerPipe_AttachmentIndex"));
                        DeletePVar(playerid, "ShowerPipe_AttachmentIndex");
                    }
                    else
                    {
                        new index = GetFreeCharacterAttachmentIdx(playerid);
                        if(index != -1)
                        {
                            ApplyAnimation(playerid, "CARRY", "liftup105", 4.0, 0, 0, 0, 0,0);
                            SetPlayerAttachedObject(playerid, index, 18633, 6, 0.09599, 0.01699, 0.03899, 98.30008, -84.10005, -8.09997, 1.00000, 1.00000, 1.00000);
                            SetPVarInt(playerid, "ShowerPipe_AttachmentIndex", index);
                        }
                        else
                        {
                            SendClientMessage(playerid, -1, "ban khong con du attachment index nao.");
                        }
                    }
                    return 1;
                }
            }
            if(!GetPVarType(playerid, "SeedAttachmentIndex"))
            {
                if(IsPlayerInRangeOfPoint(playerid, 2.0, SeedBuyCoords[0], SeedBuyCoords[1], SeedBuyCoords[2]))
                {
                    ShowPlayerDialog(playerid, DIALOG_SEED_TYPES, DIALOG_STYLE_LIST, "Farmer > Seed Types", "Lua mi\nKhoai tay\nDua gai\nKim chi", "Chon", "Huy Bo");
                    return 1;
                }
            }
            else if(GetPVarType(playerid, "SeedAttachmentIndex"))
            {
                if(IsPlayerInRangeOfPoint(playerid, 2.0, SeedBuyCoords[0], SeedBuyCoords[1], SeedBuyCoords[2]))
                {
                    if(!GetPVarType(playerid, "SeedLiftingTimer"))
                    {
                        ApplyAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0,0); // datxuongkieu1
                        SetPVarInt(playerid, "SeedLiftingTimer", SetTimerEx("OnSeedLiftingAnimated", 600, false, "ii", playerid, 1));
                        return 1;
                    }
                }
                new trailerid = GetClosestVehicleId(playerid, 3.0);
                if(trailerid != 0)
                {
                    if(GetVehicleModel(trailerid) == VEHICLE_FARM_TRAILER)
                    {
                        if(!GetPVarType(playerid, "SeedLiftingTimer"))
                        {
                            ApplyAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0,0); // datxuongkieu1
                            SetPVarInt(playerid, "SeedLiftingTimer", SetTimerEx("OnSeedLiftingAnimated", 600, false, "ii", playerid, 1));
                            new index,
                                seed_type = GetPVarInt(playerid, "SeedType");
                            for(new i = 0; i < 10; i++)
                            {
                                index = Iter_Free(I_VehicleSeeds[trailerid]);
                                if(index == cellmin)
                                {
                                    SendClientMessage(playerid, -1, "Phuong tien da het cho chua seeds.");
                                    break;
                                }
                                VehicleSeeds[trailerid][index] = seed_type;
                                Iter_Add(I_VehicleSeeds[trailerid], index);
                            }
                            return 1;
                        }
                    }
                }
            }
            if(Character[playerid][char_Farmer_Tractor_Id] != -1)
            {
                new vehicleid = Character[playerid][char_Farmer_Tractor_Id];
                if(FarmerVehicles[vehicleid][veh_Owner_Id] == playerid)
                {
                    new Float:pos[3];
                    if(FarmerVehicles[vehicleid][veh_Trailer_Id] != 0)
                    {
                        if((!FarmerVehicles[vehicleid][veh_Trailer_Is_Vehicle] && FarmerVehicles[vehicleid][veh_Trailer_Is_Attached]))
                        {
                            GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], 0.0, -3.5, 0.0);
                            if(IsPlayerInRangeOfPoint(playerid, 2.7, pos[0], pos[1], pos[2]))
                            {
                                if(GetPVarType(playerid, "HS_AttachmentIndex"))
                                {
                                    if(LoadHSToVehicle(vehicleid, GetPVarInt(playerid, "HS_Type"), GetPVarFloat(playerid, "HS_Progress")) != -1)
                                    {
                                        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                                        ApplyAnimation(playerid, "CARRY", "putdwn105", 4.0, 0, 0, 0, 0,0);
                                        RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "HS_AttachmentIndex"));
                                        DeletePVar(playerid, "HS_AttachmentIndex");
                                        DeletePVar(playerid, "HS_Type");
                                        DeletePVar(playerid, "HS_Progress");
                                        return 1;
                                    }
                                    return SendClientMessage(playerid, -1, "Khong the load seed vao phuong tien (co the da full hoac khong the generate seed coords)");
                                }
                                else if(GetPVarType(playerid, "Whisk_AttachmentIndex"))
                                {
                                    new whisk_index = GetFreeVehicleWhiskIndex(vehicleid);
                                    if(whisk_index == -1)
                                        return SendClientMessage(playerid, -1, "Phuong tien da dat max whisk");

                                    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                                    ApplyAnimation(playerid, "CARRY", "putdwn105", 4.0, 0, 0, 0, 0,0);
                                    RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "Whisk_AttachmentIndex"));

                                    FarmerVehicles[vehicleid][veh_Whisk_Objects][whisk_index] = CreateDynamicObject(2901, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
                                    AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Whisk_Objects][whisk_index], vehicleid, VehicleWhiskAttachments[whisk_index][0], VehicleWhiskAttachments[whisk_index][1], VehicleWhiskAttachments[whisk_index][2], 0.0, 0.0, 0.0);

                                    DeletePVar(playerid, "Whisk_AttachmentIndex");
                                }
                                else
                                {

                                    for(new i = MAX_HS_SLOTS_PER_VEHICLE-1; i != -1; i--)
                                    {
                                        if(FarmerVehicles[vehicleid][veh_HS_Objects][i] != 0)
                                        {
                                            new attach_index = GetFreeCharacterAttachmentIdx(playerid);
                                            if(attach_index != -1)
                                            {
                                                SetPVarInt(playerid, "HS_AttachmentIndex", attach_index);
                                                SetPVarInt(playerid, "HS_Type", FarmerVehicles[vehicleid][veh_HS_Types][i]);
                                                SetPVarFloat(playerid, "HS_Progress", FarmerVehicles[vehicleid][veh_HS_Progress][i]);

                                                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
                                                ApplyAnimation(playerid, "CARRY", "liftup105", 4.0, 0, 0, 0, 0,0); // datxuongkieu1
                                                SetPlayerAttachedObject(playerid, attach_index, DefaultSeedInfo[FarmerVehicles[vehicleid][veh_HS_Types][i]][seed_Model], 1, PlayerHSAttachmentCoords[FarmerVehicles[vehicleid][veh_HS_Types][i]][0], PlayerHSAttachmentCoords[FarmerVehicles[vehicleid][veh_HS_Types][i]][1], PlayerHSAttachmentCoords[FarmerVehicles[vehicleid][veh_HS_Types][i]][2], PlayerHSAttachmentCoords[FarmerVehicles[vehicleid][veh_HS_Types][i]][3], PlayerHSAttachmentCoords[FarmerVehicles[vehicleid][veh_HS_Types][i]][4], PlayerHSAttachmentCoords[FarmerVehicles[vehicleid][veh_HS_Types][i]][5]);

                                                DestroyDynamicObject(FarmerVehicles[vehicleid][veh_HS_Objects][i]);
                                                FarmerVehicles[vehicleid][veh_HS_Objects][i] = 0;
                                                FarmerVehicles[vehicleid][veh_HS_Types][i] = 0;
                                                FarmerVehicles[vehicleid][veh_HS_Progress][i] = 0.0;
                                                return 1;
                                            }
                                            else break;
                                        }
                                    }
                                    for(new i = MAX_WHISKS_PER_VEHICLE - 1; i != -1; i--)
                                    {
                                        if(FarmerVehicles[vehicleid][veh_Whisk_Objects][i] != 0)
                                        {
                                            new attach_index = GetFreeCharacterAttachmentIdx(playerid);
                                            if(attach_index != -1)
                                            {
                                                SetPVarInt(playerid, "Whisk_AttachmentIndex", attach_index);

                                                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
                                                ApplyAnimation(playerid, "CARRY", "liftup105", 4.0, 0, 0, 0, 0,0); // datxuongkieu1
                                                SetPlayerAttachedObject(playerid, attach_index, 2901, 1, 0.12000, 0.41200, 0.02100, 0.20000, -82.70000, -0.90000);

                                                DestroyDynamicObject(FarmerVehicles[vehicleid][veh_Whisk_Objects][i]);
                                                FarmerVehicles[vehicleid][veh_Whisk_Objects][i] = 0;
                                                return 1;
                                            }
                                            else break;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], 0.0, -0.7, 0.0);
                    if(IsPlayerInRangeOfPoint(playerid, 2.0, pos[0], pos[1], pos[2]))
                    {
                        if(FarmerVehicles[vehicleid][veh_Water_Can_Object] != 0)
                        {
                            if(GetPVarType(playerid, "WaterCanAttachmentIndex"))
                            {
                                RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanAttachmentIndex"));
                                DeletePVar(playerid, "WaterCanAttachmentIndex");
                                DeletePVar(playerid, "WaterCanCapacity");
                            }

                            new index = GetFreeCharacterAttachmentIdx(playerid);
                            if(index == -1)
                                return SendClientMessage(playerid, -1, "Attachment index da dat toi da.");

                            ApplyAnimation(playerid, "CARRY", "putdwn105", 4.0, 0, 0, 0, 0,0);

                            SetPlayerAttachedObject(playerid, index, FARMER_WATER_CAN_MODEL, 6, PlayerWCDefaultAttachment[0], PlayerWCDefaultAttachment[1], PlayerWCDefaultAttachment[2], PlayerWCDefaultAttachment[3], PlayerWCDefaultAttachment[4], PlayerWCDefaultAttachment[5], 1.00000, 1.00000, 1.00000);
                            SetPVarInt(playerid, "WaterCanAttachmentIndex", index);
                            SetPVarFloat(playerid, "WaterCanCapacity", FarmerVehicles[vehicleid][veh_Water_Can_Capacity]);

                            DestroyDynamicObject(FarmerVehicles[vehicleid][veh_Water_Can_Object]);
                            FarmerVehicles[vehicleid][veh_Water_Can_Object] = 0;
                            FarmerVehicles[vehicleid][veh_Water_Can_Capacity] = 0.00;
                            return 1;
                        }
                        else if(GetPVarType(playerid, "WaterCanAttachmentIndex"))
                        {
                            if(FarmerVehicles[vehicleid][veh_Water_Can_Object] != 0)
                            {
                                DestroyDynamicObject(FarmerVehicles[vehicleid][veh_Water_Can_Object]);
                            }

                            ApplyAnimation(playerid, "CARRY", "putdwn105", 4.0, 0, 0, 0, 0,0);

                            FarmerVehicles[vehicleid][veh_Water_Can_Object] = CreateDynamicObject(FARMER_WATER_CAN_MODEL, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _, _, _, 50.0, 50.0);
                            FarmerVehicles[vehicleid][veh_Water_Can_Capacity] = GetPVarFloat(playerid, "WaterCanCapacity");
                            RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanAttachmentIndex"));
                            AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Water_Can_Object], vehicleid, VehicleWCDefaultAttachment[0], VehicleWCDefaultAttachment[1], VehicleWCDefaultAttachment[2], VehicleWCDefaultAttachment[3], VehicleWCDefaultAttachment[4], VehicleWCDefaultAttachment[5]);
                            DeletePVar(playerid, "WaterCanAttachmentIndex");
                            DeletePVar(playerid, "WaterCanCapacity");
                            return 1;
                        }
                    }
                }
            }
            if(GetPVarType(playerid, "HS_AttachmentIndex"))
            {
                if(IsPlayerInRangeOfPoint(playerid, 2.0, -383.4536, -1434.3390, 25.7266)) // transport seed
                {
                    if(!GetPVarType(playerid, "HS_Conveyor_Loading_Timer"))
                    {
                        if(gettime() - SeedConveyor[conveyor_Last_Timestamp] >= 1)
                        {
                            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                            ApplyAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0,0);
                            SetPVarInt(playerid, "HS_Conveyor_Loading_Timer", SetTimerEx("PlayerLoadSeedToConveyor", 500, false, "i", playerid));
                        }
                        else return SendClientMessage(playerid, -1, "Dang co seed duoc van chuyen o gan, hay doi 1s sau roi dat len bang chuyen.");
                    }
                }
                if(IsPlayerInRangeOfPoint(playerid, 2.0, -374.8646, -1439.6108, 25.7266))
                {

                }
                for(new i = 0, j = sizeof(FarmAreas); i < j; i++)
                {
                    if(IsPlayerInDynamicArea(playerid, FarmAreas[i]))
                    {
                        new index = Iter_Free(I_Seeds);
                        if(index != cellmin)
                        {
                            new text[112];
                            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                            ApplyAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0,0);
                            Seeds[index][seed_Type] = GetPVarInt(playerid, "HS_Type");
                            GetPlayerPos(playerid, Seeds[index][seed_Pos][0], Seeds[index][seed_Pos][1], Seeds[index][seed_Pos][2]);
                            GetPosInFrontOfPlayer(playerid, Seeds[index][seed_Pos][0], Seeds[index][seed_Pos][1], 1.5);
                            Seeds[index][seed_Object] = CreateDynamicObject(DefaultSeedInfo[Seeds[index][seed_Type]][seed_Model], Seeds[index][seed_Pos][0], Seeds[index][seed_Pos][1], Seeds[index][seed_Pos][2] - 0.7, 90.0, 0.0, 0.0, -1, -1);
                            Seeds[index][seed_Timestamp] = gettime();
                            Seeds[index][seed_Owner] = playerid;
                            Seeds[index][seed_Water] = 0.0;
                            Seeds[index][seed_Quantity] = 0.0;
                            Seeds[index][seed_Progress] = GetPVarFloat(playerid, "HS_Progress");
                            Seeds[index][seed_Harvested] = true;
                            format(text, sizeof(text), "{%06x}%s{FFFFFF}[%d/%d]\n{0cad00}Da thu hoach", DefaultSeedInfo[Seeds[index][seed_Type]][seed_Color] >>> 8, DefaultSeedInfo[Seeds[index][seed_Type]][seed_Name], index, MAX_SEEDS - 1);
                            Seeds[index][seed_Text3D] = CreateDynamic3DTextLabel(text, -1, Seeds[index][seed_Pos][0], Seeds[index][seed_Pos][1], Seeds[index][seed_Pos][2] - 0.7, 3.0, _, _, 0, 0, 0, playerid, 5.0);
                            Streamer_SetIntData(STREAMER_TYPE_OBJECT, Seeds[index][seed_Object], E_STREAMER_EXTRA_ID, STREAMER_SEED_EXTRA_ID);
                            Iter_Add(I_Seeds, index);

                            RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "HS_AttachmentIndex"));
                            DeletePVar(playerid, "HS_AttachmentIndex");
                            DeletePVar(playerid, "HS_Type");
                            DeletePVar(playerid, "HS_Progress");
                            return 1;
                        }
                        break;
                    }
                }
            }
            if(GetPVarType(playerid, "WaterCanAttachmentIndex"))
            {
                if(IsPlayerInDynamicArea(playerid, WaterPoolArea))
                {
                    if(GetPVarFloat(playerid, "WaterCanCapacity") >= MAX_WATER_CAN_CAPACITY)
                    {
                        SetPVarFloat(playerid, "WaterCanCapacity", MAX_WATER_CAN_CAPACITY);
                        return 1;
                    }
                    if(GetPVarType(playerid, "ChargingWaterCanTimer"))
                    {
                        KillTimer(GetPVarInt(playerid, "ChargingWaterCanTimer"));
                    }

                    ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.0, 1, 1, 1, 1, 0, 1);
                    WaterCanInfoShowForPlayer(playerid);
                    SetPVarInt(playerid, "ChargingWaterCanTimer", SetTimerEx("ChargePlayerWaterCan", 200, true, "i", playerid));
                    print("timer");
                    return 1;
                }
            }

            new Float:pos[3];
            GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
            new index = GetClosestSeedIndexToPoint(4.0, pos[0], pos[1], pos[2]);
            if(index != -1)
            {
                if(!GetPVarType(playerid, "HS_AttachmentIndex"))
                {
                    if(Seeds[index][seed_Harvested])
                    {
                        if(Seeds[index][seed_Owner] == playerid)
                        {
                            if(!GetPVarType(playerid, "HS_LiftingTimer"))
                            {
                                ApplyAnimation(playerid, "CARRY", "LIFTUP", 4.0, 0, 0, 0, 0,0);
                                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
                                SetPVarInt(playerid, "HS_LiftingTimer", SetTimerEx("OnHSLiftingAnimated", 400, false, "iii", playerid, index, 0));
                                return 1;
                            }
                        }
                    }
                }
            }

            index = GetClosestSeedIndexToPoint(3.0, pos[0], pos[1], pos[2]);
            if(index != -1)
            {
                SeedInfoShowForPlayer(playerid, index);
                if(GetPVarType(playerid, "WaterCanAttachmentIndex"))
                {
                    SetPlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanAttachmentIndex"), 1650, 6, PlayerWCWateringAttachment[0],PlayerWCWateringAttachment[1], PlayerWCWateringAttachment[2], PlayerWCWateringAttachment[3], PlayerWCWateringAttachment[4], PlayerWCWateringAttachment[5]);
                    WaterCanInfoShowForPlayer(playerid);

                    if(GetPVarType(playerid, "WateringSeedTimer"))
                    {
                        KillTimer(GetPVarInt(playerid, "WateringSeedTimer"));
                    }

                    if(GetPVarFloat(playerid, "WaterCanCapacity") > 0.001)
                    {
                        new particle_index = GetFreeCharacterAttachmentIdx(playerid);

                        if(GetPVarType(playerid, "WaterCanParticleAttachmentIdx"))
                        {
                            particle_index = GetPVarInt(playerid, "WaterCanParticleAttachmentIdx");
                        }

                        ApplyAnimation(playerid, "PED", "GUN_STAND", 4.1, 1, 1, 1, 1, 0, 1);
                        if(particle_index != -1)
                        {
                            SetPVarInt(playerid, "WaterCanParticleAttachmentIdx", particle_index);
                            SetPlayerAttachedObject(playerid, particle_index, 18676, 6, -1.12999, 0.01600, -0.86800, 0.00000, 53.19995, 0.00000, 1.00000, 1.00000, 1.00000);
                        }
                    }
                    SetPVarInt(playerid, "WateringSeedTimer", SetTimerEx("PlayerWaterSeed", 200, true, "ii", playerid, index));
                }
                return 1;
            }

            index = GetClosestCowIndexToPoint(1.5, pos[0], pos[1], pos[2]);
            if(index != -1)
            {
                if(GetPVarType(playerid, "Whisk_AttachmentIndex"))
                {
                    if(Cows[index][cow_Whisk_Object_Id] == 0)
                    {
                        new
                            Float:rotz,
                            Float:unused;

                        GetDynamicObjectPos(Cows[index][cow_Object_Id], pos[0], pos[1], pos[2]);
                        GetDynamicObjectRot(Cows[index][cow_Object_Id], unused, unused, rotz);
                        GetPointInFront3D(pos[0], pos[1], pos[2], 0.0, rotz, -1.0, pos[0], pos[1], pos[2]);

                        // idle 1, 18633, 6, 0.09599, 0.01699, 0.03899, 98.30008, -84.10005, -8.09997, 1.00000, 1.00000, 1.00000
                        Cows[index][cow_Whisk_Object_Id] = CreateDynamicObject(2901, pos[0], pos[1], pos[2] + 1.0, 0.0, 0.0, rotz);
                        Cows[index][cow_Whisk_Timestamp] = gettime();
                        Cows[index][cow_3D_Bar][0] = CreateDynamic3DTextLabel("{FFFFFF}IIIIIIIIIIIIIIIIIIII", 0xFFFFFFFE, pos[0], pos[1], pos[2] + 1.0, 5.0);
                        Cows[index][cow_3D_Bar][1] = CreateDynamic3DTextLabel(" {FFFFFF}IIIIIIIIIIIIIIIIIIII", 0xFFFFFFFE, pos[0], pos[1], pos[2] + 1.0, 5.0);

                        Cows[index][cow_Eating_Timer] = SetTimerEx("CowEatingUpdate", 1000, true, "i", index);

                        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                        ApplyAnimation(playerid, "CARRY", "liftup105", 4.0, 0, 0, 0, 0,0); // datxuongkieu1
                        RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "Whisk_AttachmentIndex"));
                        DeletePVar(playerid, "Whisk_AttachmentIndex");
                    }
                }

                CowInfoShowForPlayer(playerid, index);

                if(GetPVarType(playerid, "CowInfoUpdateTimer"))
                {
                    KillTimer(GetPVarInt(playerid, "CowInfoUpdateTimer"));
                }

                SetPVarInt(playerid, "CowInfoUpdateTimer", SetTimerEx("UpdateCowInfoForPlayer", 1000, true, "ii", playerid, index));
                return 1;
            }
        }
    }
    if(newkeys & KEY_HANDBRAKE)
    {
        if(GetPVarType(playerid, "ShowerPipe_AttachmentIndex"))
        {
            new Float:pos[3],
                cow_idx;
            GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
            cow_idx = GetClosestCowIndexToPoint(3.5, pos[0], pos[1], pos[2]);
            if(cow_idx != -1)
            {
                new index = GetFreeCharacterAttachmentIdx(playerid);
                if(GetPVarType(playerid, "PipeWater_AttachmentIndex"))
                {
                    index = GetPVarInt(playerid, "PipeWater_AttachmentIndex");
                }

                if(index != -1)
                {
                    ApplyAnimation(playerid, "PED", "IDLE_CSAW", 4.0,1,0,0,1,1);

                    SetPlayerAttachedObject(playerid, index, 18676, 6, 0.30000, -0.07400, -1.21200, 0.00000, 0.00000, 0.00000);
                    SetPVarInt(playerid, "PipeWater_AttachmentIndex", index);
                }

                if(GetPVarType(playerid, "ShoweringCow_Timer"))
                {
                    KillTimer(GetPVarInt(playerid, "ShoweringCow_Timer"));
                }

                SetPVarInt(playerid, "ShoweringCow_Timer", SetTimerEx("PlayerShowerCow", 200, true, "ii", playerid, cow_idx));
                return 1;
            }
        }

        if(GetPVarType(playerid, "WaterCanAttachmentIndex"))
        {
            new Float:pos[3];
            GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
            new index = GetClosestCowGutterToPoint(1.5, pos[0], pos[1], pos[2]);
            if(index != -1)
            {
                SetPlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanAttachmentIndex"), 1650, 6, PlayerWCWateringAttachment[0],PlayerWCWateringAttachment[1], PlayerWCWateringAttachment[2], PlayerWCWateringAttachment[3], PlayerWCWateringAttachment[4], PlayerWCWateringAttachment[5]);
                WaterCanInfoShowForPlayer(playerid);

                if(GetPVarType(playerid, "GutterWaterPouringTimer"))
                {
                    KillTimer(GetPVarInt(playerid, "GutterWaterPouringTimer"));
                }

                if(GetPVarFloat(playerid, "WaterCanCapacity") > 0.001)
                {
                    new particle_index = GetFreeCharacterAttachmentIdx(playerid);

                    if(GetPVarType(playerid, "WaterCanParticleAttachmentIdx"))
                    {
                        particle_index = GetPVarInt(playerid, "WaterCanParticleAttachmentIdx");
                    }

                    ApplyAnimation(playerid, "PED", "GUN_STAND", 4.1, 1, 1, 1, 1, 0, 1);
                    if(particle_index != -1)
                    {
                        SetPVarInt(playerid, "WaterCanParticleAttachmentIdx", particle_index);
                        SetPlayerAttachedObject(playerid, particle_index, 18676, 6, -1.12999, 0.01600, -0.86800, 0.00000, 53.19995, 0.00000, 1.00000, 1.00000, 1.00000);
                    }
                }
                SetPVarInt(playerid, "GutterWaterPouringTimer", SetTimerEx("PouringWaterIntoGutter", 200, true, "ii", playerid, index));
                return 1;
            }
        }
    }
    if(RELEASED(KEY_HANDBRAKE))
    {
        if(GetPVarType(playerid, "PipeWater_AttachmentIndex"))
        {
            ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
            RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "PipeWater_AttachmentIndex"));
            DeletePVar(playerid, "PipeWater_AttachmentIndex");
        }

        if(GetPVarType(playerid, "ShoweringCow_Timer"))
        {
            KillTimer(GetPVarInt(playerid, "ShoweringCow_Timer"));
            DeletePVar(playerid, "ShoweringCow_Timer");
        }

        if(GetPVarType(playerid, "GutterWaterPouringTimer"))
        {
            if(GetPVarInt(playerid, "GutterWaterPouringTimer") != -1)
            {
                KillTimer(GetPVarInt(playerid, "GutterWaterPouringTimer"));
            }

            if(GetPVarType(playerid, "WaterCanParticleAttachmentIdx"))
            {
                RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanParticleAttachmentIdx"));
                DeletePVar(playerid, "WaterCanParticleAttachmentIdx");
            }

            ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
            DeletePVar(playerid, "GutterWaterPouringTimer");
            if(GetPVarType(playerid, "WaterCanAttachmentIndex"))
            {
                SetPlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanAttachmentIndex"), 1650, 6, PlayerWCDefaultAttachment[0],PlayerWCDefaultAttachment[1], PlayerWCDefaultAttachment[2], PlayerWCDefaultAttachment[3], PlayerWCDefaultAttachment[4], PlayerWCDefaultAttachment[5]);
            }
            WaterCanInfoHideForPlayer(playerid);
        }
    }
    if(RELEASED(KEY_YES))
    {
        if(GetPVarType(playerid, "ChargingWaterCanTimer"))
        {
            if(GetPVarInt(playerid, "ChargingWaterCanTimer") != -1)
            {
                KillTimer(GetPVarInt(playerid, "ChargingWaterCanTimer"));
            }
            ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
            DeletePVar(playerid, "ChargingWaterCanTimer");
        }

        if(GetPVarType(playerid, "WateringSeedTimer"))
        {
            if(GetPVarInt(playerid, "WateringSeedTimer") != -1)
            {
                KillTimer(GetPVarInt(playerid, "WateringSeedTimer"));
            }

            if(GetPVarType(playerid, "WaterCanParticleAttachmentIdx"))
            {
                RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanParticleAttachmentIdx"));
                DeletePVar(playerid, "WaterCanParticleAttachmentIdx");
            }

            ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
            DeletePVar(playerid, "WateringSeedTimer");
            if(GetPVarType(playerid, "WaterCanAttachmentIndex"))
            {
                SetPlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanAttachmentIndex"), 1650, 6, PlayerWCDefaultAttachment[0],PlayerWCDefaultAttachment[1], PlayerWCDefaultAttachment[2], PlayerWCDefaultAttachment[3], PlayerWCDefaultAttachment[4], PlayerWCDefaultAttachment[5]);
            }
        }

        if(GetPVarType(playerid, "CowInfoUpdateTimer"))
        {
            KillTimer(GetPVarInt(playerid, "CowInfoUpdateTimer"));
            DeletePVar(playerid, "CowInfoUpdateTimer");
        }

        SeedInfoHideForPlayer(playerid);
        WaterCanInfoHideForPlayer(playerid);
        CowInfoHideForPlayer(playerid);
    }
    return 1;
}

forward UpdateCowInfoForPlayer(playerid, cow_index);
public UpdateCowInfoForPlayer(playerid, cow_index)
{
    if(bar_Cow_Info_Progress[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        SetPlayerProgressBarValue(playerid, bar_Cow_Info_Progress[playerid], Cows[cow_index][cow_Progress]);
    }

    if(bar_Cow_Info_Fullness[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        SetPlayerProgressBarValue(playerid, bar_Cow_Info_Fullness[playerid], Cows[cow_index][cow_Fullness]);
    }

    if(bar_Cow_Info_Water[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        SetPlayerProgressBarValue(playerid, bar_Cow_Info_Water[playerid], Cows[cow_index][cow_Water]);
    }

    if(bar_Cow_Info_Cleanness[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        SetPlayerProgressBarValue(playerid, bar_Cow_Info_Cleanness[playerid], Cows[cow_index][cow_Cleanness]);
    }
    return 1;
}

forward ChargePlayerWaterCan(playerid);
public ChargePlayerWaterCan(playerid)
{
    if(!GetPVarType(playerid, "WaterCanAttachmentIndex"))
    {
        if(GetPVarType(playerid, "ChargingWaterCanTimer"))
        {
            if(GetPVarInt(playerid, "ChargingWaterCanTimer") != -1)
            {
                KillTimer(GetPVarInt(playerid, "ChargingWaterCanTimer"));
            }
        }
        DeletePVar(playerid, "ChargingWaterCanTimer");
        return 0;
    }
    new Float:capacity = GetPVarFloat(playerid, "WaterCanCapacity");
    if(capacity >= MAX_WATER_CAN_CAPACITY)
    {
        ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
        SetPVarFloat(playerid, "WaterCanCapacity", MAX_WATER_CAN_CAPACITY);
        if(PlayerBar:bar_Water_Can_Progress[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
        {
            SetPlayerProgressBarValue(playerid, bar_Water_Can_Progress[playerid], MAX_WATER_CAN_CAPACITY);
        }

        if(GetPVarType(playerid, "ChargingWaterCanTimer"))
        {
            if(GetPVarInt(playerid, "ChargingWaterCanTimer") != -1)
            {
                KillTimer(GetPVarInt(playerid, "ChargingWaterCanTimer"));
                SetPVarInt(playerid, "ChargingWaterCanTimer", -1);
            }
        }
        return 1;
    }

    if(PlayerBar:bar_Water_Can_Progress[playerid] != PlayerBar:INVALID_PLAYER_BAR_ID)
    {
        SetPlayerProgressBarValue(playerid, bar_Water_Can_Progress[playerid], capacity + 0.1);
    }
    SetPVarFloat(playerid, "WaterCanCapacity", capacity + 0.1);
    return 1;
}

forward PouringWaterIntoGutter(playerid, gutter_id);
public PouringWaterIntoGutter(playerid, gutter_id)
{
    if(!GetPVarType(playerid, "WaterCanAttachmentIndex"))
    {
        if(GetPVarType(playerid, "GutterWaterPouringTimer"))
        {
            KillTimer(GetPVarInt(playerid, "GutterWaterPouringTimer"));
            DeletePVar(playerid, "GutterWaterPouringTimer");
        }
        return 1;
    }

    new Float:capacity = GetPVarFloat(playerid, "WaterCanCapacity");
    if(capacity <= 0.0)
    {
        capacity = 0.0;
        //ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
        if(bar_Water_Can_Progress[playerid] != INVALID_PLAYER_BAR_ID)
        {
            SetPlayerProgressBarValue(playerid, bar_Water_Can_Progress[playerid], capacity);
        }

        if(GetPVarType(playerid, "WaterCanParticleAttachmentIdx"))
        {
            RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanParticleAttachmentIdx"));
            DeletePVar(playerid, "WaterCanParticleAttachmentIdx");
        }

        if(GetPVarType(playerid, "GutterWaterPouringTimer"))
        {
            if(GetPVarInt(playerid, "GutterWaterPouringTimer") != -1)
            {
                KillTimer(GetPVarInt(playerid, "GutterWaterPouringTimer"));
                SetPVarInt(playerid, "GutterWaterPouringTimer", -1);
            }
        }
        return 1;
    }

    SetPVarFloat(playerid, "WaterCanCapacity", capacity - 0.05);
    Gutters[gutter_id][gutter_Water] += 0.05;

    if(Gutters[gutter_id][gutter_Water] >= 1.0)
    {
        Gutters[gutter_id][gutter_Water] = 1.0;
    }

    if(bar_Water_Can_Progress[playerid] != INVALID_PLAYER_BAR_ID)
    {
        SetPlayerProgressBarValue(playerid, bar_Water_Can_Progress[playerid], capacity);
    }

    if(Gutters[gutter_id][gutter_3D_Bar][0] != Text3D:INVALID_3DTEXT_ID)
    {
        new bar[45],
            column;

        bar = "{40afff}IIIIIIIIIIIIIIIIIIII";

        column = floatround(Gutters[gutter_id][gutter_Water] * 20 / MAX_GUTTER_WATER);
        strins(bar, "{FFFFFF}", column + 8, 45);

        UpdateDynamic3DTextLabelText(Gutters[gutter_id][gutter_3D_Bar][0], 0xFFFFFFFE, bar);
    }
    else
    {
        new bar[45],
            column;

        bar = "{40afff}IIIIIIIIIIIIIIIIIIII";

        column = floatround(Gutters[gutter_id][gutter_Water] * 20 / MAX_GUTTER_WATER);
        strins(bar, "{FFFFFF}", column + 8, 45);

        Gutters[gutter_id][gutter_3D_Bar][0] = CreateDynamic3DTextLabel(bar, -1, GutterCoords[gutter_id][0], GutterCoords[gutter_id][1], GutterCoords[gutter_id][2], 5.0);
    }

    if(Gutters[gutter_id][gutter_3D_Bar][1] != Text3D:INVALID_3DTEXT_ID)
    {
        new bar[45],
            column;

        bar = "{40afff} IIIIIIIIIIIIIIIIIIII";

        column = floatround(Gutters[gutter_id][gutter_Water] * 20 / MAX_GUTTER_WATER);
        strins(bar, "{FFFFFF}", column + 8 + 1, 45);

        UpdateDynamic3DTextLabelText(Gutters[gutter_id][gutter_3D_Bar][1], 0xFFFFFFFE, bar);
    }
    else
    {
        new bar[45],
            column;

        bar = "{40afff} IIIIIIIIIIIIIIIIIIII";

        column = floatround(Gutters[gutter_id][gutter_Water] * 20 / MAX_GUTTER_WATER);
        strins(bar, "{FFFFFF}", column + 8 + 1, 45);

        Gutters[gutter_id][gutter_3D_Bar][1] = CreateDynamic3DTextLabel(bar, -1, GutterCoords[gutter_id][0], GutterCoords[gutter_id][1], GutterCoords[gutter_id][2], 5.0);
    }
    return 1;
}

forward PlayerWaterSeed(playerid, seed_index);
public PlayerWaterSeed(playerid, seed_index)
{
    if(!GetPVarType(playerid, "WaterCanAttachmentIndex"))
    {
        if(GetPVarType(playerid, "WateringSeedTimer"))
        {
            KillTimer(GetPVarInt(playerid, "WateringSeedTimer"));
            DeletePVar(playerid, "WateringSeedTimer");
        }
        return 1;
    }

    if(Seeds[seed_index][seed_Water] >= MAX_SEED_WATER)
    {
        Seeds[seed_index][seed_Water] = MAX_SEED_WATER - 0.00001;
        if(bar_Seed_Info_Water[playerid] != INVALID_PLAYER_BAR_ID)
        {
            SetPlayerProgressBarValue(playerid, bar_Seed_Info_Water[playerid], Seeds[seed_index][seed_Water]);
        }
    }

    new Float:capacity = GetPVarFloat(playerid, "WaterCanCapacity");
    if(capacity <= 0.0)
    {
        capacity = 0.0;
        //ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
        if(bar_Water_Can_Progress[playerid] != INVALID_PLAYER_BAR_ID)
        {
            SetPlayerProgressBarValue(playerid, bar_Water_Can_Progress[playerid], capacity);
        }

        if(GetPVarType(playerid, "WaterCanParticleAttachmentIdx"))
        {
            RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "WaterCanParticleAttachmentIdx"));
            DeletePVar(playerid, "WaterCanParticleAttachmentIdx");
        }

        if(GetPVarType(playerid, "WateringSeedTimer"))
        {
            if(GetPVarInt(playerid, "WateringSeedTimer") != -1)
            {
                KillTimer(GetPVarInt(playerid, "WateringSeedTimer"));
                SetPVarInt(playerid, "WateringSeedTimer", -1);
            }
        }
        return 1;
    }

    SetPVarFloat(playerid, "WaterCanCapacity", capacity - 0.05);
    Seeds[seed_index][seed_Water] += 0.05;
    Character[playerid][char_Outputs] += 0.05;

    if(bar_Seed_Info_Water[playerid] != INVALID_PLAYER_BAR_ID)
    {
        SetPlayerProgressBarValue(playerid, bar_Seed_Info_Water[playerid], Seeds[seed_index][seed_Water]);
    }

    if(bar_Water_Can_Progress[playerid] != INVALID_PLAYER_BAR_ID)
    {
        SetPlayerProgressBarValue(playerid, bar_Water_Can_Progress[playerid], capacity);
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_SEED_TYPES:
        {
            if(response)
            {
                if(!GetPVarType(playerid, "SeedLiftingTimer") && !GetPVarType(playerid, "SeedAttachmentIndex"))
                {
                    ApplyAnimation(playerid, "CARRY", "LIFTUP", 4.0, 0, 0, 0, 0,0);
                    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
                    SetPVarInt(playerid, "SeedType", listitem);
                    SetPVarInt(playerid, "SeedLiftingTimer", SetTimerEx("OnSeedLiftingAnimated", 400, false, "ii", playerid, 0));
                }
            }
            // retrun Y_HOOKS_BREAK_RETURN_1;
        }
        case DIALOG_TRADING_WHISK_CONFIRM:
        {
            if(response)
            {
                if(seedStorage < 5.0)
                    return 1;

                if(!IsPlayerInAnyVehicle(playerid))
                    return 1;

                new vehicleid = GetPlayerVehicleID(playerid);
                if(vehicleid != Character[playerid][char_Farmer_Tractor_Id])
                    return 1;

                if(FarmerVehicles[vehicleid][veh_Trailer_Is_Vehicle] || !FarmerVehicles[vehicleid][veh_Trailer_Is_Attached])
                    return SendClientMessage(playerid, -1, "Ban can phai gan trailer phu hop.");

                for(new i = 0; i < MAX_HS_SLOTS_PER_VEHICLE; i++)
                {
                    if(FarmerVehicles[vehicleid][veh_HS_Objects][i] != 0)
                    {
                        return SendClientMessage(playerid, -1, "Phuong tien chi co the chua bo rom hoac cay trong cung mot luc.");
                    }
                }

                new index = GetFreeVehicleWhiskIndex(vehicleid);
                if(index == -1)
                    return SendClientMessage(playerid, -1, "Phuong tien cua ban da chua toi da bo rom.");

                seedStorage -= 5.0;
                FarmerVehicles[vehicleid][veh_Whisk_Objects][index] = CreateDynamicObject(2901, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
                AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Whisk_Objects][index], vehicleid, VehicleWhiskAttachments[index][0], VehicleWhiskAttachments[index][1], VehicleWhiskAttachments[index][2], 0.0, 0.0, 0.0);
            }
            // retrun Y_HOOKS_BREAK_RETURN_1;
        }
        case DIALOG_FARMER_MENU:
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // thue xe
                    {
                        new vehicleid = CreateVehicle(VEHICLE_TRACTOR, -376.0420, -1446.6180, 25.6921, 0.0, 1, 1, -1, 0);
                        FarmerVehicles[vehicleid][veh_Owner_Id] = playerid;
                        FarmerVehicles[vehicleid][veh_Trailer_Id] = 0;
                        FarmerVehicles[vehicleid][veh_Trailer_Is_Attached] = false;
                        FarmerVehicles[vehicleid][veh_Water_Can_Object] = CreateDynamicObject(FARMER_WATER_CAN_MODEL, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 50.0);
                        FarmerVehicles[vehicleid][veh_Water_Can_Capacity] = 0.00;
                        Character[playerid][char_Farmer_Tractor_Id] = vehicleid;

                        AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Water_Can_Object], vehicleid, VehicleWCDefaultAttachment[0], VehicleWCDefaultAttachment[1], VehicleWCDefaultAttachment[2], VehicleWCDefaultAttachment[3], VehicleWCDefaultAttachment[4], VehicleWCDefaultAttachment[5]);
                        PutPlayerInVehicle(playerid, vehicleid, 0);
                    }
                    case 1: // lay trailer
                    {
                        if(!IsPlayerInAnyVehicle(playerid))
                        {
                            return SendClientMessage(playerid, -1, "Can phai o tren xe Tractor de lay trailer.");
                        }

                        new vehicleid = GetPlayerVehicleID(playerid);
                        if(GetVehicleModel(vehicleid) != 531)
                        {
                            return SendClientMessage(playerid, -1, "Can phai o tren xe Tractor de lay trailer.");
                        }

                        if(FarmerVehicles[vehicleid][veh_Owner_Id] != playerid)
                        {
                            return SendClientMessage(playerid, -1, "Ban khong thuoc so huu xe tractor nay.");
                        }

                        if(FarmerVehicles[vehicleid][veh_Trailer_Id] == 0)
                        {
                            TrailerSelectionShowForPlayer(playerid);
                            SetPVarInt(playerid, "Trailer_Selection_Vehicle_Id", vehicleid);
                            SelectTextDraw(playerid, 0xFFFFFFAA);
                            return 1;
                        }
                        else
                        {
                            if(FarmerVehicles[vehicleid][veh_Trailer_Is_Vehicle])
                            {
                                new trailerid = GetVehicleTrailer(vehicleid);
                                if(trailerid == 0)
                                {
                                    return SendClientMessage(playerid, -1, "Phuong tien can phai gan trailer");
                                }

                                if(FarmerVehicles[vehicleid][veh_Trailer_Id] != trailerid)
                                {
                                    return SendClientMessage(playerid, -1, "Day khong phai la trailer ban da lay truoc do, khong the tra lai.");
                                }

                                DestroyVehicle(FarmerVehicles[vehicleid][veh_Trailer_Id]);
                                FarmerVehicles[vehicleid][veh_Trailer_Id] = 0;
                                return 1;
                            }
                            else
                            {
                                DestroyDynamicObject(FarmerVehicles[vehicleid][veh_Trailer_Id]);
                                FarmerVehicles[vehicleid][veh_Trailer_Id] = 0;
                                return 1;
                            }
                        }
                    }
                    case 2: // cham soc bo
                    {
                        new cow = GetPlayerCow(playerid);
                        if(cow == -1)
                        {
                            foreach(new i : I_Cows)
                            {
                                if(Cows[i][cow_Owner_Id] == -1)
                                {
                                    new Float:pos[3],
                                        string[90];
                                    Cows[i][cow_Owner_Id] = playerid;
                                    GetDynamicObjectPos(Cows[i][cow_Object_Id], pos[0], pos[1], pos[2]);
                                    SetPlayerCheckpoint(playerid, pos[0], pos[1], pos[2], 2.0);
                                    format(string, sizeof(string), "Ban da nhan cham soc con bo o chuong bo so %d, hay tien hanh cong viec.", i);
                                    SendClientMessage(playerid, -1, string);
                                    break;
                                }
                            }
                        }
                        else
                        {
                            new Float:pos[3],
                                string[110];
                            GetDynamicObjectPos(Cows[cow][cow_Object_Id], pos[0], pos[1], pos[2]);
                            SetPlayerCheckpoint(playerid, pos[0], pos[1], pos[2], 2.0);
                            format(string, sizeof(string), "Ban dang cham soc con bo o chuong bo so %d, hay hoan thanh truoc khi muon cham soc con khac.", cow);
                            SendClientMessage(playerid, -1, string);
                        }
                    }
                    case 3: // ban bo
                    {
                        if(!IsPlayerInAnyVehicle(playerid))
                        {
                            return SendClientMessage(playerid, -1, "Ban can phai o tren xe dang chua bo.");
                        }

                        new vehicleid = GetPlayerVehicleID(playerid);
                        if(FarmerVehicles[vehicleid][veh_Owner_Id] != playerid)
                        {
                            return SendClientMessage(playerid, -1, "Xe nay khong thuoc so huu cua ban.");
                        }

                        if(FarmerVehicles[vehicleid][veh_Cow_Object_Id] == 0)
                        {
                            return SendClientMessage(playerid, -1, "Xe khong co bo.");
                        }

                        if(GetVehicleModel(vehicleid) == 531)
                        {
                            if(FarmerVehicles[vehicleid][veh_Trailer_Is_Vehicle] || !FarmerVehicles[vehicleid][veh_Trailer_Is_Attached])
                            {
                                return SendClientMessage(playerid, -1, "Xe chua gan trailer.");
                            }
                        }

                        new string[90];
                        format(string, sizeof(string), "Con bo truong thanh %.1f%s, ban nhan duoc %d$.", FarmerVehicles[vehicleid][veh_Cow_Progress], "%%", floatround(FarmerVehicles[vehicleid][veh_Cow_Progress] * 200) + 500);
                        SendClientMessage(playerid, -1, string);

                        DestroyDynamicObject(FarmerVehicles[vehicleid][veh_Cow_Object_Id]);
                        FarmerVehicles[vehicleid][veh_Cow_Object_Id] = 0;
                        FarmerVehicles[vehicleid][veh_Cow_Progress] = 0.0;
                    }
                }
            }
            // retrun Y_HOOKS_BREAK_RETURN_1;
        }
    }
    return 1;
}

forward GiveVehicleSeeds(vehicleid, seed_type);
public GiveVehicleSeeds(vehicleid, seed_type)
{
    new index = Iter_Free(I_VehicleSeeds[vehicleid]);
    printf("index %d", index);
    if(index != cellmin)
    {
        VehicleSeeds[vehicleid][index] = seed_type;
        Iter_Add(I_VehicleSeeds[vehicleid], index);
    }
    return index;
}

forward OnSeedLiftingAnimated(playerid, lifting_type);
public OnSeedLiftingAnimated(playerid, lifting_type)
{
    if(lifting_type == 0) // lift up
    {
        new index = GetFreeCharacterAttachmentIdx(playerid);
        if(index != -1)
        {
            SetPlayerAttachedObject(playerid, index, 2060, 1, 0.09600, 0.52400, 0.00000, 0.00000, 95.20000, 0.00000);
            SetPVarInt(playerid, "SeedAttachmentIndex", index);
        }
    }
    else if(lifting_type == 1) // lift down
    {
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        if(GetPVarType(playerid, "SeedAttachmentIndex"))
        {
            RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "SeedAttachmentIndex"));
        }
        DeletePVar(playerid, "SeedAttachmentIndex");
        DeletePVar(playerid, "SeedType");
    }
    DeletePVar(playerid, "SeedLiftingTimer");
    return 1;
}

forward OnHSLiftingAnimated(playerid, seed_index, lifting_type);
public OnHSLiftingAnimated(playerid, seed_index, lifting_type)
{
    if(lifting_type == 0) // lift up
    {
        new attach_index = GetFreeCharacterAttachmentIdx(playerid);
        if(attach_index == -1)
            return SendClientMessage(playerid, -1, "Ban da het attachment index.");
        DestroyDynamicObject(Seeds[seed_index][seed_Object]);
        DestroyDynamic3DTextLabel(Seeds[seed_index][seed_Text3D]);
        SetPlayerAttachedObject(playerid, attach_index, DefaultSeedInfo[Seeds[seed_index][seed_Type]][seed_Model], 1, PlayerHSAttachmentCoords[Seeds[seed_index][seed_Type]][0], PlayerHSAttachmentCoords[Seeds[seed_index][seed_Type]][1], PlayerHSAttachmentCoords[Seeds[seed_index][seed_Type]][2], PlayerHSAttachmentCoords[Seeds[seed_index][seed_Type]][3], PlayerHSAttachmentCoords[Seeds[seed_index][seed_Type]][4], PlayerHSAttachmentCoords[Seeds[seed_index][seed_Type]][5]);

        SetPVarFloat(playerid, "HS_Progress", Seeds[seed_index][seed_Progress]);
        SetPVarInt(playerid, "HS_Type", Seeds[seed_index][seed_Type]);
        SetPVarInt(playerid, "HS_AttachmentIndex", attach_index);

        Seeds[seed_index][seed_Owner] = -1;
        Seeds[seed_index][seed_Timestamp] = 0;
        Seeds[seed_index][seed_Object] = 0;
        Seeds[seed_index][seed_Text3D] = Text3D:INVALID_3DTEXT_ID;
        Seeds[seed_index][seed_Water] = 0.0;
        Seeds[seed_index][seed_Quantity] = 0.0;
        Seeds[seed_index][seed_Progress] = 0.0;
        Seeds[seed_index][seed_Harvested] = false;
        Iter_Remove(I_Seeds, seed_index);
        DeletePVar(playerid, "HS_LiftingTimer");
    }
    else if(lifting_type == 1) // lift down
    {

    }
    return 1;
}

// forward AnimIndex(playerid);
// public AnimIndex(playerid)
// {
//     new lib[64],
//         name[64],
//         index = GetPlayerAnimationIndex(playerid);
//     GetAnimationName(index, lib, sizeof(lib), name, sizeof(name));
//     printf("animation index: %d, lib %s, name %s", index, lib, name);
//     return 1;
// }

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    printf("%d, %d, %d, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f", index, modelid, boneid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);
    return 1;
}

public OnDynamicObjectMoved(objectid)
{
    switch(Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID))
    {
        case STREAMER_CONVEYOR_OBJECT_EX_ID:
        {
            for(new i = 0; i < MAX_SEEDS_PER_CONVEYOR; i++)
            {
                if(SeedConveyor[conveyor_Objects][i] == objectid)
                {
                    new string[80];
                    format(string, sizeof(string), "Cay truong thanh co san luong %.1fkg, ban nhan duoc %d$.", SeedConveyor[conveyor_Progress][i] * floatabs(DefaultSeedInfo[SeedConveyor[conveyor_Types][i]][seed_Max_Height] - DefaultSeedInfo[SeedConveyor[conveyor_Types][i]][seed_Min_Height]) / DefaultSeedInfo[SeedConveyor[conveyor_Types][i]][seed_Progress_Velocity] / 150.0, floatround(SeedConveyor[conveyor_Progress][i] * SeedCurrencyRate[SeedConveyor[conveyor_Types][i]]));
                    SendClientMessage(SeedConveyor[conveyor_Owners][i], -1, string);

                    Character[SeedConveyor[conveyor_Owners][i]][char_Outputs] += SeedConveyor[conveyor_Progress][i];
                    seedStorage += SeedConveyor[conveyor_Progress][i];

                    DestroyDynamicObject(SeedConveyor[conveyor_Objects][i]);
                    SeedConveyor[conveyor_Objects][i] = 0;
                    SeedConveyor[conveyor_Types][i] = -1;
                    SeedConveyor[conveyor_Progress][i] = 0.0;
                    SeedConveyor[conveyor_Owners][i] = -1;
                    return 1;
                }
            }
        }
    }
    return 1;
}

forward AttachTrailer(trailerid, vehicleid);
public AttachTrailer(trailerid, vehicleid)
{
    AttachTrailerToVehicle(trailerid, vehicleid);
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetupPlayerForClassSelection(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
    RemoveBuildingForPlayer(playerid, 17005, -391.1406, -1432.9922, 32.4297, 0.25);
    RemoveBuildingForPlayer(playerid, 17006, -394.9609, -1433.9688, 32.4453, 0.25);
    RemoveBuildingForPlayer(playerid, 3425, -370.3750, -1446.9688, 35.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 790, -396.6484, -1482.0078, 29.6484, 0.25);
    RemoveBuildingForPlayer(playerid, 17000, -406.9141, -1448.9688, 24.6406, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -378.7734, -1459.0234, 25.4766, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -384.2344, -1455.8281, 25.4766, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -368.7813, -1454.3672, 25.4766, 0.25);

    Character[playerid][char_Farmer_Tractor_Id] = -1;
    Character[playerid][char_Outputs] = 0.0;
    return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
	TogglePlayerClock(playerid, 0);
    SetPlayerPos(playerid, SeedBuyCoords[0], SeedBuyCoords[1], SeedBuyCoords[2]);
    SetPlayerSkin(playerid, 280);
	return 1;
}


public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	SetPlayerPosFindZ(playerid, fX, fY, fZ);
	return 1;
}

CMD:duabolenxe(playerid, params[])
{
    new vehicleid = strval(params);
    if(!IsValidVehicle(vehicleid))
    {
        return SendClientMessage(playerid, -1, "vehicle khong hop le.");
    }

    switch(GetVehicleModel(vehicleid))
    {
        case 422, 543, 600, 478:
        {
            // do nothing
        }
        case 531:
        {
            if(FarmerVehicles[vehicleid][veh_Trailer_Is_Vehicle] || !FarmerVehicles[vehicleid][veh_Trailer_Is_Attached])
            {
                return SendClientMessage(playerid, -1, "Tractor phai gan trailer phu hop.");
            }
        }
        default:
        {
            return SendClientMessage(playerid, -1, "Phuong tien phai la bobcat, sadler, picador hoac tractor.");
        }
    }

    new Float:pos[3];
    GetVehiclePos(vehicleid, pos[0], pos[1], pos[2]);
    if(!IsPointInDynamicArea(CowArea, pos[0], pos[1], pos[2]))
    {
        return SendClientMessage(playerid, -1, "phuong tien khong nam trong khu vuc chan nuoi.");
    }

    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    new cow_idx = GetClosestCowIndexToPoint(3.0, pos[0], pos[1], pos[2]);

    if(cow_idx == -1)
    {
        return SendClientMessage(playerid, -1, "Ban can phai o gan mot con bo.");
    }

    if(Cows[cow_idx][cow_Owner_Id] != playerid)
    {
        return SendClientMessage(playerid, -1, "Ban khong phai la nguoi cham soc con bo.");
    }

    if(Cows[cow_idx][cow_Progress] < 0.8)
    {
        return SendClientMessage(playerid, -1, "Con bo chua du truong thanh.");
    }

    if(Cows[cow_idx][cow_Cleanness] < 0.8)
    {
        return SendClientMessage(playerid, -1, "Con bo can phai duoc tam sach truoc khi dua di ban.");
    }

    ApplyAnimation(playerid, "PED", "WALK_old", 2.1, 1, 1, 1, 1, 1, 1);

    switch(GetVehicleModel(vehicleid))
    {
        case 422, 543, 600, 478:
        {
            GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], 0.0, -3.0, 0.0);
        }
        case 531:
        {
            GetVehicleRelativePos(vehicleid, pos[0], pos[1], pos[2], 0.0, -6.0, 0.0);
        }
        default:
        {
            return SendClientMessage(playerid, -1, "Phuong tien phai la bobcat, sadler, picador hoac tractor.");
        }
    }

    SetPlayerCheckpoint(playerid, pos[0], pos[1], pos[2], 1.0);

    Cows[cow_idx][cow_Being_Dragged] = true;
    SetPVarInt(playerid, "DraggingCow_Timer", SetTimerEx("PlayerDraggingCow", 200, true, "ii", playerid, cow_idx));
    SetPVarInt(playerid, "DraggingCow_Index", cow_idx);
    SetPVarInt(playerid, "DraggingCow_Vehicle_Id", vehicleid);
    return 1;
}

CMD:createcow(player)
{
    CreateCow();
    return 1;
}

// CMD:cheat(playerid)
// {
//     foreach(new i : I_Seeds)
//     {
//         Seeds[i][seed_Water] = 1.0;
//     }
//     foreach(new i : I_Cows)
//     {
//         Cows[i][cow_Fullness] = 1.0;
//         Cows[i][cow_Water] = 1.0;
//     }
//     return 1;
// }

// CMD:veh(playerid, params[])
// {
// 	new Float:pos[3];
// 	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
// 	CreateVehicle(strval(params), pos[0], pos[1], pos[2], 0.0, 1, 1, -1, 1);
// 	return 1;
// }

// CMD:w(playerid, params[])
// {
// 	GivePlayerWeapon(playerid, strval(params), 100);
// 	return 1;
// }

// CMD:trailer(playerid)
// {
//     if(IsPlayerInAnyVehicle(playerid))
//     {
//         new vehicleid = GetPlayerVehicleID(playerid);
//         if(GetVehicleTrailer(vehicleid) != 0)
//         {
//             return DetachTrailerFromVehicle(vehicleid);
//         }

//         new Float:pos[3],
//             trailer;
//         GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
//         trailer = CreateVehicle(VEHICLE_FARM_TRAILER, pos[0], pos[1]+2.0, pos[2], 0.0, 1, 1, -1, 0);
//         SetTimerEx("AttachTrailer", 1000, false, "ii", trailer, vehicleid);
//     }
//     return 1;
// }

// CMD:edit(playerid, params[])
// {
//     new model,
//         bone;
//     if(sscanf(params, "ii", model, bone))
//         return 0;

//     SetPlayerAttachedObject(playerid, 1, model, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0);
//     EditAttachedObject(playerid, 1);
//     return 1;
// }

// CMD:carry(playerid)
// {
//     SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
//     return 1;
// }

// CMD:none(playerid)
// {
//     SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
//     return 1;
// }

// CMD:countseeds(playerid, params[])
// {
//     if(!IsPlayerInAnyVehicle(playerid))
//         return 0;

//     new string[64];
//     format(string, sizeof(string), "vehicle %d, total seeds %d", strval(params), Iter_Count(I_VehicleSeeds[strval(params)]));
//     SendClientMessage(playerid, -1, string);
//     return 1;
// }

// CMD:object(playerid, params[])
// {
//     new model,
//         Float:height;
//     if(sscanf(params, "if", model, height))
//         return 0;

//     if(temp_object != 0)
//     {
//         DestroyDynamicObject(temp_object);
//     }
//     new Float:x,
//         Float:y,
//         Float:z;
//     GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
//     temp_object = CreateDynamicObject(model, x, y, z + height, 0.0, 0.0, 0.0);
//     return 1;
// }

// CMD:attachveh(playerid, params[])
// {
//     new model,
//         Float:x,
//         Float:y,
//         Float:z,
//         Float:rx,
//         Float:ry,
//         Float:rz;
//     if(sscanf(params, "iF(0.0)F(0.0)F(0.0)F(0.0)F(0.0)F(0.0)", model, x, y, z, rx, ry, rz))
//         return 0;
//     if(temp_object != 0)
//     {
//         DestroyDynamicObject(temp_object);
//     }
//     temp_object = CreateDynamicObject(model, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
//     AttachDynamicObjectToVehicle(temp_object, GetPlayerVehicleID(playerid), x, y, z, rx, ry, rz);
//     return 1;
// }

// CMD:water(playerid, params[])
// {
//     new seed_index,
//         Float:water;
//     if(sscanf(params, "if", seed_index, water))
//         return 0;
//     Seeds[seed_index][seed_Water] = water;
//     return 1;
// }

CMD:maygat(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, -1, "Can o tren phuong tien Tractor");

    new vehicleid = GetPlayerVehicleID(playerid);
    if(GetVehicleModel(vehicleid) != VEHICLE_TRACTOR)
        return SendClientMessage(playerid, -1, "Can o tren phuong tien Tractor");

    new trailerid = GetVehicleTrailer(vehicleid);
    if(trailerid == 0)
        return SendClientMessage(playerid, -1, "Tractor phai gan trailer.");

    if(trailerid != FarmerVehicles[vehicleid][veh_Trailer_Id])
        return SendClientMessage(playerid, -1, "Day khong phai trailer thuoc ve Tractor cua ban.");

    if(GetVehicleModel(trailerid) != VEHICLE_FARM_TRAILER)
        return SendClientMessage(playerid, -1, "Trailer cua Tractor khong phu hop.");

    if(FarmerVehicles[vehicleid][veh_Trailer_Smoke_Object] == 0)
    {
        FarmerVehicles[vehicleid][veh_Trailer_Smoke_Object] = CreateDynamicObject(18736, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1);
        AttachDynamicObjectToVehicle(FarmerVehicles[vehicleid][veh_Trailer_Smoke_Object], FarmerVehicles[vehicleid][veh_Trailer_Id], 0.0, -0.5, -1.7, 0.0, 0.0, 0.0);
        SendClientMessage(playerid, -1, "Ban da khoi dong che do may gat.");

        if(FarmerVehicles[vehicleid][veh_Harvest_Timer] != 0)
        {
            KillTimer(FarmerVehicles[vehicleid][veh_Harvest_Timer]);
        }

        for(new i = 0, j = sizeof(FarmAreas); i < j; i++)
        {
            if(IsPlayerInDynamicArea(playerid, FarmAreas[i]))
            {
                FarmerVehicles[vehicleid][veh_Harvest_Timer] = SetTimerEx("VehicleHarvestTimer", 200, true, "i", vehicleid);
                break;
            }
        }
    }
    else
    {
        if(FarmerVehicles[vehicleid][veh_Harvest_Timer] != 0)
        {
            KillTimer(FarmerVehicles[vehicleid][veh_Harvest_Timer]);
        }

        DestroyDynamicObject(FarmerVehicles[vehicleid][veh_Trailer_Smoke_Object]);
        FarmerVehicles[vehicleid][veh_Trailer_Smoke_Object] = 0;
        FarmerVehicles[vehicleid][veh_Harvest_Timer] = 0;
        SendClientMessage(playerid, -1, "Ban da tat che do may gat.");
    }
    return 1;
}

// CMD:animindex(playerid)
// {
//     SetTimerEx("AnimIndex", 1000, false, "i", playerid);
//     return 1;
// }

// CMD:test(playerid)
// {
//     new Float:pos[3],
//         Float:new_pos[3];
//     GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
//     GetPointInFront3D(pos[0], pos[1], pos[2], 0.0, 90.0, 3.0, new_pos[0], new_pos[1], new_pos[2]);
//     SetPlayerCheckpoint(playerid, new_pos[0], new_pos[1], new_pos[2], 1.0);
//     return 1;
// }

// CMD:test2(playerid)
// {
//     new Float:pos[3],
//         Float:new_pos[3];
//     GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
//     GetPointInFront3D(pos[0], pos[1], pos[2], 0.0, 90.0, 3.0, new_pos[0], new_pos[1], new_pos[2]);
//     SetPlayerCheckpoint(playerid, new_pos[0], new_pos[1], pos[2], 1.0);
//     return 1;
// }

// CMD:csaw(playerid)
// {
//     ApplyAnimation(playerid, "PED", "IDLE_CSAW", 4.0,1,0,0,1,1);
//     return 1;
// }

// CMD:whisk(playerid)
// {
//     if(GetPVarType(playerid, "Whisk_AttachmentIndex"))
//     {
//         RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "Whisk_AttachmentIndex"));
//     }
//     new attach_index = GetFreeCharacterAttachmentIdx(playerid);
//     SetPVarInt(playerid, "Whisk_AttachmentIndex", attach_index);

//     SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
//     ApplyAnimation(playerid, "CARRY", "liftup105", 4.0, 0, 0, 0, 0,0); // datxuongkieu1
//     SetPlayerAttachedObject(playerid, attach_index, 2901, 1, 0.12000, 0.41200, 0.02100, 0.20000, -82.70000, -0.90000);
//     return 1;
// }