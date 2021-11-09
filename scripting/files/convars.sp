public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if(convar == g_cvServerTagColored)
    {
        strcopy(g_szServerTagColored, sizeof(g_szServerTagColored), newValue);
        g_cvServerTagColored.SetString(newValue);
    }
    else if(convar == g_cvServerTag)
    {
        strcopy(g_szServerTag, sizeof(g_szServerTag), newValue);
        g_cvServerTag.SetString(newValue);
    }
    else if(convar == g_cvForceUpdate)
    {
        g_cvForceUpdate.SetBool(view_as<bool>(StringToInt(newValue)));
    }
    else if(convar == g_cvVIPFlags)
    {
        strcopy(g_szVIPFlags, sizeof(g_szVIPFlags), newValue);
        g_cvVIPFlags.SetString(newValue);
    }
}
