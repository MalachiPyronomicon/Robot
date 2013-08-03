//	------------------------------------------------------------------------------------
//	Filename:		donator.robot.sp
//	Author:			Malachi
//	Version:		(see PLUGIN_VERSION)
//	Description:
//					Plugin allows donators to change to robot skin.
//
// * Changelog (date/version/description):
// * 2013-08-03	-	0.1.1		-	initial version (developed using betherobot.smx v1.3)
//	------------------------------------------------------------------------------------


// INCLUDES
#include <sourcemod>
#include <donator>
#include <clientprefs>				// cookies
#include <betherobot>				// robot skin manager plugin


#pragma semicolon 1


// DEFINES

// Plugin Info
#define PLUGIN_INFO_VERSION			"0.1.1"
#define PLUGIN_INFO_NAME			"Donator Robot"
#define PLUGIN_INFO_AUTHOR			"Malachi"
#define PLUGIN_INFO_DESCRIPTION		"allows donators to change to robot MvM skin"
#define PLUGIN_INFO_URL				"www.necrophix.com"

// Plugin
#define PLUGIN_PRINT_NAME			"[Donator:Robot]"			// Used for self-identification in chat/logging

// These define the text players see in the donator menu
#define MENUTEXT_ROBOT					"Robot Player Skin"
#define MENUTITLE_ROBOT					"Donator: Turn On/Off Robot Skin:"
#define MENUSELECT_ITEM_NULL			"OFF: Normal"
#define MENUSELECT_ITEM_ROBOT_ENABLED	"ON: Robot"

// cookie names
#define COOKIENAME_ROBOT			"donator_robot"
#define COOKIEDESCRIPTION_ROBOT		"Change donator skin using betherobot.smx"


// GLOBALS
new Handle:g_hRobotCookie = INVALID_HANDLE;

enum _:CookieActionType
{
	Action_Null = 0,
	Action_Robot = 1
};


public Plugin:myinfo = 
{
	name = PLUGIN_INFO_NAME,
	author = PLUGIN_INFO_AUTHOR,
	description = PLUGIN_INFO_DESCRIPTION,
	version = PLUGIN_INFO_VERSION,
	url = PLUGIN_INFO_URL
}


public OnPluginStart()
{
	AddCommandListener(EventClassChange, "joinclass");
	g_hRobotCookie = RegClientCookie(COOKIENAME_ROBOT, COOKIEDESCRIPTION_ROBOT, CookieAccess_Private);
}


public OnPluginEnd() 
{
    RemoveCommandListener(EventClassChange, "joinclass");
}


// Required: Basic donator interface, robot plugin
public OnAllPluginsLoaded()
{
	if(!LibraryExists("donator.core"))
		SetFailState("Unable to find plugin: Basic Donator Interface");

	if(!LibraryExists("betherobot"))
		SetFailState("Unable to find plugin: BeTheRobot");
		
	Donator_RegisterMenuItem(MENUTEXT_ROBOT, ChangeRobotCallback);
}


public Action:EventClassChange(iClient, const String:command[], args)
{

	// Is client in game?
	if (IsClientInGame(iClient))
	{
		// Is this client fake?
		if (!IsFakeClient(iClient))
		{
			// Is this client a donator?
			if (IsPlayerDonator(iClient))
			{
				new iSelected;
				decl String:iTmp[32];

				GetClientCookie(iClient, g_hRobotCookie, iTmp, sizeof(iTmp));
				iSelected = StringToInt(iTmp);

				if (_:iSelected == Action_Null)
				{
					if ((BeTheRobot_GetRobotStatus(iClient) == RobotStatus_Robot) || (BeTheRobot_GetRobotStatus(iClient) == RobotStatus_WantsToBeRobot))
					{
						BeTheRobot_SetRobot(iClient, false);
						PrintToChat (iClient, "%s Changing from ROBOT to NORMAL", PLUGIN_PRINT_NAME);
					}
				}
				else
				if (_:iSelected == Action_Robot)
				{
					if (BeTheRobot_GetRobotStatus(iClient) == RobotStatus_Human)
					{
						BeTheRobot_SetRobot(iClient, true);
						PrintToChat (iClient, "%s Changing from NORMAL to ROBOT", PLUGIN_PRINT_NAME);
					}
				}

			}
		}
	}
	
	return Plugin_Continue;
}


public DonatorMenu:ChangeRobotCallback(iClient)
{
	Panel_ChangeRobot(iClient);
}


// Create Menu 
public Action:Panel_ChangeRobot(iClient)
{
	new Handle:menu = CreateMenu(RobotMenuHandler);
	decl String:iTmp[32];
	new iSelected;

	SetMenuTitle(menu, MENUTITLE_ROBOT);

	GetClientCookie(iClient, g_hRobotCookie, iTmp, sizeof(iTmp));
	iSelected = StringToInt(iTmp);

	if (_:iSelected == Action_Null)
	{
		new String:iCompare[32];
		IntToString(Action_Null, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_NULL, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Null, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_NULL, ITEMDRAW_DEFAULT);
	}
	
	// Enable robot
	if (_:iSelected == Action_Robot)
	{
		new String:iCompare[32];
		IntToString(Action_Robot, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_ROBOT_ENABLED, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Robot, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_ROBOT_ENABLED, ITEMDRAW_DEFAULT);
	}
		
	DisplayMenu(menu, iClient, 20);
}


// Menu Handler
public RobotMenuHandler(Handle:menu, MenuAction:action, iClient, param2)
{
	decl String:sSelected[32];
	GetMenuItem(menu, param2, sSelected, sizeof(sSelected));

	switch (action)
	{
		case MenuAction_Select:
		{
			SetClientCookie(iClient, g_hRobotCookie, sSelected);
			
			new iSelected = StringToInt(sSelected);

			if (iSelected == Action_Null)
			{
					BeTheRobot_SetRobot(iClient, false);
					PrintToChat (iClient, "%s Changing from ROBOT to NORMAL", PLUGIN_PRINT_NAME);
			}
			else
			if (iSelected == Action_Robot)
			{
					BeTheRobot_SetRobot(iClient, true);
					PrintToChat (iClient, "%s Changing from NORMAL to ROBOT", PLUGIN_PRINT_NAME);
			}
		}
//		case MenuAction_Cancel: ;
		case MenuAction_End: CloseHandle(menu);
	}
}


