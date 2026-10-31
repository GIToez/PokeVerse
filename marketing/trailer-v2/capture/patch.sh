#!/bin/bash
# scratch patches for the trailer server in /tmp/pvtrailer (never in the repo)
set -e
d=/tmp/pvtrailer/server/data
sed -i 's/ outfit="[0-9]*"//' $d/XML/groups.xml
cp /tmp/trailer/itch.lua $d/talkactions/scripts/itch.lua
grep -q 'words="/itch"' $d/talkactions/talkactions.xml || sed -i 's#</talkactions>#\t<talkaction words="/itch" access="5" event="script" value="itch.lua"/>\n</talkactions>#' $d/talkactions/talkactions.xml
# gym leaders: no trainer, respect or badge requirements for the takes
for f in $d/npc/scripts/npcbattle_{brock,misty,ltsurge,erika,koga,sabrina,blaine,giovanni}.lua; do
  python3 - "$f" <<'EOF'
import re, sys
p = sys.argv[1]; s = open(p).read()
s = re.sub(r'npcBattle:setRequiredTrainers\(\{.*?\}\)\n', '', s, flags=re.S)
s = re.sub(r'npcBattle:setPayRespect\(\d+\)\n', '', s)
s = re.sub(r'npcBattle:setRequired(Level|Respect|Storage)\([^)]*\)\n', '', s)
open(p, 'w').write(s)
EOF
done
grep -c "setRequiredTrainers\|setPayRespect" $d/npc/scripts/npcbattle_brock.lua || true
