#!/bin/sh

MODRINTH_API='https://api.modrinth.com/v2/'
MODS='./packwiz/mods/*'
# MODS='./packwiz/mods/indium.pw.toml'

FILENAME="$(date +"%Y-%m-%d-%N")_modlist.md"

for file in $MODS; do
    toml=$(cat "$file")
    toml_value() {
        printf "%s" "$toml" | grep "$1" | cut --delimiter '=' --fields 2 | tr --delete ' "'
    }
    id=$(toml_value 'mod-id')
    json=$(curl --get "$MODRINTH_API"project/"$id")
    # json=$(cat ./test.curl)
    json_value() {
        ret=$(printf "%s" "$json" | jq ".$1")
        ret="${ret#?}"
        echo "${ret%?}"
    }

    cat >> "$FILENAME" << EOF
## $(json_value 'title')

$(json_value 'description' | sed 's/\\"/"/g')

EOF

# $(json_value 'body' | sed 's/^#/##/g' | sed -e 's/<[^>]*>//g' |  sed 's/\\"/"/g')
#
# License: $(json_value 'license.id')

done

