#!/bin/bash
#
#		DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#			Version 2, December 2004
#
#	Copyright (C) 2011 Branden Harper <bharper@chaosweb.us>
#
#	Everyone is permitted to copy and distribute verbatim or modified
#	copies of this license document, and changing it is allowed as long
#	as the name is changed.
#
#		DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#	TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#	0. You just DO WHAT THE FUCK YOU WANT TO.

if [ ! -z "$1" ]; then
ngrep -q -d any -W byline '' host "$1" and udp port 5060 | egrep -vi "OPTIONS|From|Call-ID|CSeq|Server|Via|Contact|INVITE|Trying|Session\ Progress|100\ Giving\ a\ try|200\ canceling|OK|Proxy\ Authentication\ Required|CANCEL|ACK|Ringing|BYE|User-Agent\:|Supported\:|Content-Length\:|^Record-Route|^c=|^m=|^a=|^\ |^\." |grep -A 3 "SIP/2.0"
else
ngrep -q -d any -W byline '' udp port 5060 | egrep -vi "OPTIONS|From|Call-ID|CSeq|Server|Via|Contact|INVITE|Trying|Session\ Progress|100\ Giving\ a\ try|200\ canceling|OK|Proxy\ Authentication\ Required|CANCEL|ACK|Ringing|BYE|User-Agent\:|Supported\:|Content-Length\:|^Record-Route|^c=|^m=|^a=|^\ |^\." |grep -A 3 "SIP/2.0"
fi
