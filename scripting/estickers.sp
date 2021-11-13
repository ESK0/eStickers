#include <sourcemod>
#include <PTaH>
#include <eItems>
#include <cstrike>
#include <sourcecolors>
#include <autoexecconfig>

#pragma newdecls required
#pragma semicolon 1

#define TAG_NCLR "[eStickers]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/database.sp"
#include "files/convars.sp"
#include "files/ptah.sp"
#include "files/func.sp"
#include "files/menus.sp"

#define AUTHOR "ESK0"
#define VERSION "0.4.0"

public Plugin myinfo =
{
    name = "eStickers",
    author = AUTHOR,
    version = VERSION,
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] chError, int iErrMax)
{
	g_bLateLoaded = bLate;
}

public void OnPluginStart()
{
    Database.Connect(Database_OnConnect, "eStickers");

    if(eItems_AreItemsSynced() && !g_bDataSynced)
    {
        eItems_OnItemsSynced();
    }
    else if(!eItems_AreItemsSyncing())
    {
        eItems_ReSync();
    }

    LoadTranslations("estickers.phrases.txt");
    if(g_bLateLoaded)
    {
        for(int client = 1; client <= MaxClients; client++)
        {
            if(!IsValidClient(client))
            {
                continue;
            }

            OnClientPostAdminCheck(client);
        }
    }

    RegConsoleCmd("sm_stickers", Command_Stickers);
    RegConsoleCmd("sm_sticker", Command_Stickers);

    PTaH(PTaH_GiveNamedItemPost, Hook, PTaH_OnGiveNamedItemPost);


    AutoExecConfig_SetFile("eStickers_config");
    g_cvServerTagColored = AutoExecConfig_CreateConVar("sm_estickers_servertag_colored", "[{$lime}eStickers{$default}]", "Colored server tag. Mostly used in chat messages.", FCVAR_PROTECTED);
    g_cvServerTagColored.AddChangeHook(OnConVarChanged);
    g_cvServerTagColored.GetString(g_szServerTagColored, sizeof(g_szServerTagColored));
    
    g_cvServerTag = AutoExecConfig_CreateConVar("sm_estickers_servertag", "[eStickers]", "Server tag. Mostly used in menus.", FCVAR_PROTECTED);
    g_cvServerTag.AddChangeHook(OnConVarChanged);
    g_cvServerTag.GetString(g_szServerTag, sizeof(g_szServerTag));

    g_cvForceUpdate = AutoExecConfig_CreateConVar("sm_estickers_forceupdate", "0", "Send force update packet to client.", FCVAR_PROTECTED, true, 0.0, true, 1.0);
    g_cvForceUpdate.AddChangeHook(OnConVarChanged);

    g_cvVIPFlags = AutoExecConfig_CreateConVar("sm_estickers_vip_flags", "", "VIP Flags e.g 'a'. Leave empty for all access!", FCVAR_PROTECTED);
    g_cvVIPFlags.AddChangeHook(OnConVarChanged);
    g_cvVIPFlags.GetString(g_szVIPFlags, sizeof(g_szVIPFlags));
    

    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();
}

public void OnClientPostAdminCheck(int client)
{
    if(!IsValidClient(client))
    {
        return;
    }

    if(g_smWeaponStickers[client] != null)
    {
        delete g_smWeaponStickers[client];
        g_smWeaponStickers[client] = null;
    }

    g_smWeaponStickers[client] = new StringMap();

    g_bHasAccess[client] = true;
    
    GetClientAuthId(client, AuthId_SteamID64, g_szSteamID64[client], sizeof(g_szSteamID64[]));
    g_iClientKey[client] = -1;

    if(g_bDataSynced)
    {
        char szWeaponNum[12];
        for(int iWeaponNum = 0; iWeaponNum < eItems_GetWeaponCount(); iWeaponNum++)
        {
            IntToString(iWeaponNum, szWeaponNum, sizeof(szWeaponNum));

            eWeaponStickers WeaponStickers;
            WeaponStickers.Reset();

            g_smWeaponStickers[client].SetArray(szWeaponNum, WeaponStickers, sizeof(eWeaponStickers));
        }

        if(!HasVIPAccess(client))
        {
            g_bHasAccess[client] = false;
            return;
            
        }

        Database_OnClientConnect(client);
    }
}

public void OnClientDisconnect(int client)
{
    if(!IsValidClient(client))
    {
        return;
    }

    Databse_SaveClientData(client);

}

public void eItems_OnItemsSynced()
{
    g_bDataSynced = true;
}

public Action Command_Stickers(int client, int args)
{
    if(!IsValidClient(client))
    {
        return Plugin_Handled;
    }

    if(!g_bDataSynced)
    {
        CPrintToChat(client, "%s %t", g_szServerTagColored, "Data not synced");
        return Plugin_Handled;
    }

    if(!g_bHasAccess[client])
    {
        CPrintToChat(client, "%s %t", g_szServerTagColored, "Only For VIP");
        return Plugin_Handled;
    }

    Menu_OpenMainMenu(client);

    return Plugin_Handled;
}
































