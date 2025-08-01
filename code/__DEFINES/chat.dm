/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/// How many chat payloads to keep in history
#define CHAT_RELIABILITY_HISTORY_SIZE 5
/// How many resends to allow before giving up
#define CHAT_RELIABILITY_MAX_RESENDS 3

#define MESSAGE_TYPE_SYSTEM "system"
#define MESSAGE_TYPE_LOCALCHAT "localchat"
#define MESSAGE_TYPE_RADIO "radio"
#define MESSAGE_TYPE_ENTERTAINMENT "entertainment"
#define MESSAGE_TYPE_INFO "info"
#define MESSAGE_TYPE_WARNING "warning"
#define MESSAGE_TYPE_DEADCHAT "deadchat"
#define MESSAGE_TYPE_OOC "ooc"
#define MESSAGE_TYPE_ADMINPM "adminpm"
#define MESSAGE_TYPE_COMBAT "combat"
#define MESSAGE_TYPE_ADMINCHAT "adminchat"
#define MESSAGE_TYPE_PRAYER "prayer"
#define MESSAGE_TYPE_MODCHAT "modchat"
#define MESSAGE_TYPE_EVENTCHAT "eventchat"
#define MESSAGE_TYPE_ADMINLOG "adminlog"
#define MESSAGE_TYPE_ATTACKLOG "attacklog"
#define MESSAGE_TYPE_DEBUG "debug"

#define EXTERNALREPLYCOUNT 2 // monkestation edit
/// Max length of chat message in characters
#define CHAT_MESSAGE_MAX_LENGTH 110

//debug printing macros (for development and testing)
/// Used for debug messages to the world
#define debug_world(msg) if (GLOB.Debug2) to_chat(world, \
	type = MESSAGE_TYPE_DEBUG, \
	text = "DEBUG: [msg]")
/// Used for debug messages to the player
#define debug_usr(msg) if (GLOB.Debug2 && usr) to_chat(usr, \
	type = MESSAGE_TYPE_DEBUG, \
	text = "DEBUG: [msg]")
/// Used for debug messages to the admins
#define debug_admins(msg) if (GLOB.Debug2) to_chat(GLOB.admins, \
	type = MESSAGE_TYPE_DEBUG, \
	text = "DEBUG: [msg]")
/// Used for debug messages to the server
#define debug_world_log(msg) if (GLOB.Debug2) log_world("DEBUG: [msg]")
/// Adds a generic box around whatever message you're sending in chat. Really makes things stand out.
#define boxed_message(str) ("<div class='boxed_message'>" + str + "</div>")
/// Adds a box around whatever message you're sending in chat. Can apply color and/or additional classes. Available colors: red, green, blue, purple. Use it like red_box
#define custom_boxed_message(classes, str) ("<div class='boxed_message " + classes + "'>" + str + "</div>")
/// Makes a fieldset with a neaty styled name. Can apply additional classes.
#define fieldset_block(title, content, classes) ("<fieldset class='fieldset " + classes + "'><legend class='fieldset_legend'>" + title + "</legend>" + content + "</fieldset>")
/// Makes a horizontal line with text in the middle
#define separator_hr(str) ("<div class='separator'>" + str + "</div>")
/// Emboldens runechat messages
#define RUNECHAT_BOLD(str) "+[str]+"
/// Helper which creates a chat message which may have a tooltip in some contexts, but not others.
#define conditional_tooltip(normal_text, tooltip_text, condition) ((condition) ? (span_tooltip(tooltip_text, normal_text)) : (normal_text))
/// No italics
#define conditional_tooltip_alt(normal_text, tooltip_text, condition) ((condition) ? (span_tooltip_alt(tooltip_text, normal_text)) : (normal_text))
