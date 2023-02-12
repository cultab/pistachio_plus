#!/bin/sh

MODRINTH_API='https://api.modrinth.com/v2/'
MODS='./packwiz/mods/*'
DATE=$(date +"%Y-%m-%d")
FILENAME="${DATE}_modlist_0.md"

while [ -f "$FILENAME" ]; do
    printf "%s already exists.\n" "$FILENAME"
    num=$(((num += 1)))
    FILENAME="${DATE}_modlist_${num}.md"
done

if [ ! -d ./cache/ ]; then
    mkdir cache
fi

for file in $MODS; do
    toml=$(cat "$file")
    toml_value() {
        printf "%s" "$toml" | grep "$1" | cut --delimiter '=' --fields 2 | tr --delete ' "'
    }
    id=$(toml_value 'mod-id')

    if [ -f "./cache/$id" ]; then
        printf "Using ./cache/%s\n" "$id"
        json=$(cat "./cache/$id")
    else
        printf "%s not in ./cache\n" "$id"
        json=$(curl --get "$MODRINTH_API"project/"$id")
        printf %s "$json" > "./cache/$id"
    fi

    json_value() {
        ret=$(printf "%s" "$json" | jq ".$1")
        ret="${ret#?}"
        echo "${ret%?}"
    }

    cat >> "$FILENAME" << EOF
## $(json_value 'title')

<img src="$(json_value 'icon_url')" width=250 height=250>

$(json_value 'description' | sed 's/\\"/"/g')

License: $(json_value 'license.name')

------

EOF

# $(json_value 'body' | sed 's/^#/##/g' | sed -e 's/<[^>]*>//g' |  sed 's/\\"/"/g')
#

done

