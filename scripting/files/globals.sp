bool g_bDataSynced = false;
bool g_bCurrentWeapon[MAXPLAYERS + 1] = {false,...};
bool g_bLateLoaded = false;
bool g_bHasAccess[MAXPLAYERS + 1] = {false,...};
bool g_bApplyingPatch[MAXPLAYERS + 1] = {false,...};
bool g_bRemovingSticker[MAXPLAYERS + 1] = {false,...};

int g_iStoredWeaponNum[MAXPLAYERS + 1] = {0,...};
int g_iStoredStickerSetNum[MAXPLAYERS + 1] = {0,...};
int g_iStoredStickerNum[MAXPLAYERS + 1] = {0,...};
int g_iLastMenuPosition[MAXPLAYERS + 1] = {0,...};
int g_iClientKey[MAXPLAYERS + 1] = {-1,...};

StringMap g_smWeaponStickers[MAXPLAYERS + 1] = {null,...};

enum struct eWeaponStickers
{
    int Sticker[4];
    bool Changed;

    void Reset()
    {
        this.Changed = false;
        this.Sticker[0] = 0;
        this.Sticker[1] = 0;
        this.Sticker[2] = 0;
        this.Sticker[3] = 0;
    }
}


char g_szServerTagColored[64];
char g_szServerTag[64];
char g_szVIPFlags[22];
char g_szSteamID64[MAXPLAYERS + 1][18];

ConVar g_cvServerTagColored;
ConVar g_cvServerTag;
ConVar g_cvForceUpdate;
ConVar g_cvVIPFlags;

Database g_hDatabase = null;