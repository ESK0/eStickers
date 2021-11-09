#if defined _sourcecolors_included
    #endinput
#endif
#define _sourcecolors_included

#include <regex>
#define MAX_MESSAGE_LENGTH 256

enum struct ColorInfo
{
	char colorTag[64];
	char colorHex[64];
}

#include <sourcecolors/morecolors>
#include <sourcecolors/colors>

/**
 * Prints a message to a specific client in the chat area.
 * The chat sound is disabled. If teamcolor is used, the client's teamcolor will be displayed.
 * 
 * @param client        Client index.
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 * @error               If the client is not connected or invalid.
 */
stock void CPrintToChat(int client, const char[] format, any ...)
{
	if (client < 1 || client > MaxClients)
	{
		ThrowError("Invalid client index %d", client);
	}
	
	if (!IsClientConnected(client))
	{
		ThrowError("Client %i is not connected", client);
	}
	
	int buffer_index;
	char buffer[MAX_MESSAGE_LENGTH];
	
	SetGlobalTransTarget(client);

	buffer_index = CPreFormat(buffer, sizeof(buffer));
	VFormat(buffer[buffer_index], sizeof(buffer) - buffer_index, format, 3);
	
	CFormat(buffer[buffer_index], sizeof(buffer) - buffer_index);
	CSendMessage(client, buffer);
}

/**
 * Prints a message to a specific client in the chat area.
 * The chat sound is disabled by default. If teamcolor is used, the author's teamcolor will be displayed.
 * Index 0 as author is accepted and the teamcolor will be displayed exactly as in PrintToChat.
 *
 * @param client        Client index.
 * @param author        Author index.
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 * @error               If the client is not connected or invalid.
 * @error               If the author is not connected or invalid.
 */
stock void CPrintToChat_Ex(int client, int author, bool playSound, const char[] format, any ...)
{
	if (client < 1 || client > MaxClients)
	{
		ThrowError("Invalid client index %d", client);
	}
	
	if (!IsClientConnected(client))
	{
		ThrowError("Client %i is not connected", client);
	}
	
	if (author)
	{
		if (author < 1 || author > MaxClients)
		{
			ThrowError("Invalid author index %d", author);
		}
		
		if (!IsClientConnected(author))
		{
			ThrowError("Author %i is not connected", author);
		}
	}
	
	int buffer_index;
	char buffer[MAX_MESSAGE_LENGTH];
	
	SetGlobalTransTarget(client);

	buffer_index = CPreFormat(buffer, sizeof(buffer));
	VFormat(buffer[buffer_index], sizeof(buffer) - buffer_index, format, 5);
	
	CFormat(buffer[buffer_index], sizeof(buffer) - buffer_index);
	CSendMessage(client, buffer, author, playSound);
}

/**
 * Prints a message to all clients in the chat area.
 * The chat sound is disabled. If teamcolor is used, the client's teamcolor will be displayed.
 * 
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 */
stock void CPrintToChatAll(const char[] format, any ...)
{
	int buffer_index;
	char buffer[MAX_MESSAGE_LENGTH];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
		{
			continue;
		}
		
		SetGlobalTransTarget(i);
		
		buffer_index = CPreFormat(buffer, sizeof(buffer));
		VFormat(buffer[buffer_index], sizeof(buffer) - buffer_index, format, 2);
		
		CFormat(buffer[buffer_index], sizeof(buffer) - buffer_index);
		CSendMessage(i, buffer);
	}
}

/**
 * Prints a message to all clients in the chat area.
 * The chat sound is disabled by default. If teamcolor is used, the author's teamcolor will be displayed.
 * Index 0 as author is accepted and the teamcolor will be displayed exactly as in PrintToChat.
 *
 * @param author        Author index.
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 * @error               If the author is not connected or invalid.
 */
stock void CPrintToChatAll_Ex(int author, bool playSound, const char[] format, any ...)
{
	if (author)
	{
		if (author < 1 || author > MaxClients)
		{
			ThrowError("Invalid author index %d", author);
		}
		
		if (!IsClientConnected(author))
		{
			ThrowError("Author %i is not in game", author);
		}
	}
	
	int buffer_index;
	char buffer[MAX_MESSAGE_LENGTH];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
		{
			continue;
		}
		
		SetGlobalTransTarget(i);
		
		buffer_index = CPreFormat(buffer, sizeof(buffer));
		VFormat(buffer[buffer_index], sizeof(buffer) - buffer_index, format, 4);
		
		CFormat(buffer[buffer_index], sizeof(buffer) - buffer_index);
		CSendMessage(i, buffer, author, playSound);
	}
}

/**
 * Prints a message to all clients from a specific team in the chat area.
 * The chat sound is disabled. If teamcolor is used, the client's teamcolor will be displayed.
 * 
 * @param team          Team index.
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 */
stock void CPrintToChatTeam(int team, const char[] format, any ...)
{
	int buffer_index;
	char buffer[MAX_MESSAGE_LENGTH];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != team)
		{
			continue;
		}
		
		SetGlobalTransTarget(i);
		
		buffer_index = CPreFormat(buffer, sizeof(buffer));
		VFormat(buffer[buffer_index], sizeof(buffer) - buffer_index, format, 3);
		
		CFormat(buffer[buffer_index], sizeof(buffer) - buffer_index);
		CSendMessage(i, buffer);
	}
}

/**
 * Prints a message to all clients from a specific team in the chat area.
 * The chat sound is disabled by default. If teamcolor is used, the author's teamcolor will be displayed.
 * Index 0 as author is accepted and the teamcolor will be displayed exactly as in PrintToChat.
 *
 * @param author        Author index.
 * @param team          Team index.
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 * @error               If the author is not connected or invalid.
 */
stock void CPrintToChatTeam_Ex(int author, int team, bool playSound, const char[] format, any ...)
{
	if (author)
	{
		if (author < 1 || author > MaxClients)
		{
			ThrowError("Invalid author index %d", author);
		}
		
		if (!IsClientConnected(author))
		{
			ThrowError("Author %i is not in game", author);
		}
	}
	
	int buffer_index;
	char buffer[MAX_MESSAGE_LENGTH];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != team)
		{
			continue;
		}
		
		SetGlobalTransTarget(i);
		
		buffer_index = CPreFormat(buffer, sizeof(buffer));
		VFormat(buffer[buffer_index], sizeof(buffer) - buffer_index, format, 5);
		
		CFormat(buffer[buffer_index], sizeof(buffer) - buffer_index);
		CSendMessage(i, buffer, author, playSound);
	}
}

/**
 * Replies to a message in a command.
 *
 * A client index of 0 will use PrintToServer().
 * If the command was from the console, PrintToConsole() is used.
 * If the command was from chat, CPrintToChat() is used.
 * The chat sound is disabled. If teamcolor is used, the client's teamcolor will be displayed.

 * @param client        Client index, or 0 for server.
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 * @error               If the client is not connected or invalid.
 */
stock void CReplyToCommand(int client, const char[] format, any ...)
{
	if (client < 0 || client > MaxClients)
	{
		ThrowError("Invalid client index %d", client);
	}
	
	char buffer[MAX_MESSAGE_LENGTH];
	SetGlobalTransTarget(LANG_SERVER);
	
	if (client == 0)
	{
		VFormat(buffer, sizeof(buffer), format, 3);
		CRemoveColors(buffer, sizeof(buffer));
		PrintToServer(buffer);
		return;
	}
	
	if (!IsClientConnected(client))
	{
		ThrowError("Client %i is not in game", client);
	}
	
	SetGlobalTransTarget(client);
	if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		VFormat(buffer, sizeof(buffer), format, 3);
		CRemoveColors(buffer, sizeof(buffer));
		PrintToConsole(client, buffer);
	}
	else
	{
		int buffer_index = CPreFormat(buffer, sizeof(buffer));
		VFormat(buffer[buffer_index], sizeof(buffer) - buffer_index, format, 3);
		CFormat(buffer[buffer_index], sizeof(buffer) - buffer_index);
		CSendMessage(client, buffer);
	}
}

/**
 * Displays usage of an admin command to users depending on the 
 * setting of the sm_show_activity cvar.  All users receive a message 
 * in their chat text, except for the originating client, who receives 
 * the message both in chat and console.
 * The chat sound is enabled. If teamcolor is used, the client's teamcolor will be displayed.
 *
 * @param client        Client index doing the action, or 0 for server.
 * @param tag           Tag to prepend to the message.
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 * @error               If the client is not connected or invalid.
 */
stock void CShowActivity(int client, const char[] tag, const char[] format, any ...)
{
	char clientName[MAX_NAME_LENGTH] = "CONSOLE";
	char signUser[MAX_MESSAGE_LENGTH] = "ADMIN";
	char buffer[MAX_MESSAGE_LENGTH];
	
	// Send message to client
	if (client)
	{
		if (client < 1 || client > MaxClients)
		{
			ThrowError("Invalid client index %d", client);
		}
		
		if (!IsClientConnected(client))
		{
			ThrowError("Client %i is not connected", client);
		}
		
		GetClientName(client, clientName, sizeof(clientName));
		
		AdminId id = GetUserAdmin(client);
		if (id == INVALID_ADMIN_ID || !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			signUser = "PLAYER";
		}
		
		SetGlobalTransTarget(client);

		VFormat(buffer, sizeof(buffer), format, 4);
		if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
		{
			CRemoveColors(buffer, sizeof(buffer));
			PrintToConsole(client, "%s%s", tag, buffer);
		}
		else
		{
			CPrintToChat_Ex(client, client, true, "%s%s", tag, buffer);
		}
	}
	else
	{
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(buffer, sizeof(buffer), format, 4);
		CRemoveColors(buffer, sizeof(buffer));
		PrintToServer("%s%s", tag, buffer);
	}
	
	// Get sm_show_activity convar
	ConVar sm_show_activity = FindConVar("sm_show_activity");
	if (!sm_show_activity || !sm_show_activity.IntValue)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i != client && IsClientInGame(i) && !IsFakeClient(i))
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, sizeof(buffer), format, 4);
			
			AdminId id = GetUserAdmin(i);
			if (id == INVALID_ADMIN_ID || !GetAdminFlag(id, Admin_Generic, Access_Effective))
			{
				if ((sm_show_activity.IntValue & 1) || (sm_show_activity.IntValue & 2))
				{
					if (sm_show_activity.IntValue & 2)
					{
						CPrintToChat_Ex(i, client, true, "%s%s: %s", tag, clientName, buffer);
					}
					else
					{
						CPrintToChat_Ex(i, client, true, "%s%s: %s", tag, signUser, buffer);
					}
				}
			}
			else
			{
				bool is_root = GetAdminFlag(id, Admin_Root, Access_Effective);
				if ((sm_show_activity.IntValue & 4) || (sm_show_activity.IntValue & 8) || ((sm_show_activity.IntValue & 16) && is_root))
				{
					if ((sm_show_activity.IntValue & 8) || ((sm_show_activity.IntValue & 16) && is_root))
					{
						CPrintToChat_Ex(i, client, true, "%s%s: %s", tag, clientName, buffer);
					}
					else
					{
						CPrintToChat_Ex(i, client, true, "%s%s: %s", tag, signUser, buffer);
					}
				}
			}
		}
	}
}

/**
 * Displays usage of an admin command to users depending on the 
 * setting of the sm_show_activity cvar.  All users receive a message 
 * in their chat text, except for the originating client, who receives 
 * the message both in chat and console.
 * The chat sound is enabled. If teamcolor is used, the author's teamcolor will be displayed.
 *
 * @param client        Client index doing the action, or 0 for server.
 * @param tag           Tag to prepend to the message.
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 * @error               If the client is not connected or invalid.
 * @error               If the author is not connected or invalid.
 */
stock void CShowActivity_Ex(int client, int author, const char[] tag, const char[] format, any ...)
{
	if (author)
	{
		if (author < 1 || author > MaxClients)
		{
			ThrowError("Invalid author index %d", author);
		}
		
		if (!IsClientConnected(author))
		{
			ThrowError("Author %i is not in game", author);
		}
	}
	
	char clientName[MAX_NAME_LENGTH] = "CONSOLE";
	char signUser[MAX_MESSAGE_LENGTH] = "ADMIN";
	char buffer[MAX_MESSAGE_LENGTH];
	
	// Send message to client
	if (client)
	{
		if (client < 1 || client > MaxClients)
		{
			ThrowError("Invalid client index %d", client);
		}
		
		if (!IsClientConnected(client))
		{
			ThrowError("Client %i is not connected", client);
		}
		
		GetClientName(client, clientName, sizeof(clientName));
		
		AdminId id = GetUserAdmin(client);
		if (id == INVALID_ADMIN_ID || !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			signUser = "PLAYER";
		}
		
		SetGlobalTransTarget(client);
		
		VFormat(buffer, sizeof(buffer), format, 5);
		if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
		{
			CRemoveColors(buffer, sizeof(buffer));
			PrintToConsole(client, "%s%s", tag, buffer);
		}
		else
		{
			CPrintToChat_Ex(client, author, true, "%s%s", tag, buffer);
		}
	}
	else
	{
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(buffer, sizeof(buffer), format, 5);
		CRemoveColors(buffer, sizeof(buffer));
		PrintToServer("%s%s", tag, buffer);
	}
	
	// Get sm_show_activity convar
	ConVar sm_show_activity = FindConVar("sm_show_activity");
	if (!sm_show_activity || !sm_show_activity.IntValue)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i != client && IsClientInGame(i) && !IsFakeClient(i))
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, sizeof(buffer), format, 5);
			
			AdminId id = GetUserAdmin(i);
			if (id == INVALID_ADMIN_ID || !GetAdminFlag(id, Admin_Generic, Access_Effective))
			{
				if ((sm_show_activity.IntValue & 1) || (sm_show_activity.IntValue & 2))
				{
					if (sm_show_activity.IntValue & 2)
					{
						CPrintToChat_Ex(i, author, true, "%s%s: %s", tag, clientName, buffer);
					}
					else
					{
						CPrintToChat_Ex(i, author, true, "%s%s: %s", tag, signUser, buffer);
					}
				}
			}
			else
			{
				bool is_root = GetAdminFlag(id, Admin_Root, Access_Effective);
				if ((sm_show_activity.IntValue & 4) || (sm_show_activity.IntValue & 8) || ((sm_show_activity.IntValue & 16) && is_root))
				{
					if ((sm_show_activity.IntValue & 8) || ((sm_show_activity.IntValue & 16) && is_root))
					{
						CPrintToChat_Ex(i, author, true, "%s%s: %s", tag, clientName, buffer);
					}
					else
					{
						CPrintToChat_Ex(i, author, true, "%s%s: %s", tag, signUser, buffer);
					}
				}
			}
		}
	}
}

/**
 * Prepares a string to display the message correctly in the chat.
 *
 * @param message   The string.
 * @param maxlen    The maximum length of the string.
 * @return          First free index in the string.
 */
stock int CPreFormat(char[] message, int maxlen)
{
	if (GetEngineVersion() == Engine_CSGO)
	{
		return Format(message, maxlen, " \x01");
	}
	
	return Format(message, maxlen, "\x01");
}

/**
 * Replace color tags from a string with actual color values.
 *
 * @param message   The string.
 * @param maxlen    The maximum length of the string.
 * @return          Number of cells written.
 */
stock int CFormat(char[] format, int maxlen)
{
	if (IsSource2009())
	{
		return MC_Format(format, maxlen);
	}
	
	return C_Format(format, maxlen);
}

/**
 * Remove color tags from a string.
 *
 * @param message   The string.
 * @param maxlen    The maximum length of the string.
 * @return          The new size of the string.
 */
stock int CRemoveColors(char[] format, int maxlen)
{
	if (IsSource2009())
	{
		return MC_RemoveColors(format, maxlen);
	}
	
	return C_RemoveColors(format, maxlen);
}

stock void CSendMessage(int client, const char[] message, int author = -1, bool chatMessage = false)
{
	if (IsSource2009())
	{
		MC_SendMessage(client, message, author, chatMessage);
		return;
	}
	
	C_SendMessage(client, message, author, chatMessage);
}

stock bool IsSource2009()
{
	if (GetEngineVersion() == Engine_CSS || GetEngineVersion() == Engine_HL2DM || GetEngineVersion() == Engine_DODS || GetEngineVersion() == Engine_TF2)
	{
		return true;
	}
	
	return false;
}
