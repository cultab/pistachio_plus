#!/bin/sh

IFS="
"

tag="$*"

if [ -z "$tag" ]; then
    echo "No tag provided!"
    exit 1

fi

if ! commits=$(git log --pretty="%s" "${tag}..HEAD"); then
    echo "No such tag as '$tag'!"
    exit 1
fi

mods=$(echo "$commits" | grep '^mods' | cut --delimiter ':' --fields 2 | sed 's/^\s//g')
misc=$(echo "$commits" | grep '^fix\|^bug|^chore' | sed 's/.*(//g;s/)//')

mods_list=""
for mod in $mods; do
    if echo "$mod" | grep -E '^(\w|-)+$' > /dev/null 2>&1; then
        mods_list=$(printf "%s\n%s" "$mods_list" "- added $mod")
    else
        mods_list=$(printf "%s\n%s" "$mods_list" "$mod")
    fi
done

misc_list=""
for m in $misc; do
    misc_list=$(printf "%s\n%s" "$misc_list" "- $m")
done

cat << EOF

# Mod changes
${mods_list}

# Misc
${misc_list}




EOF

