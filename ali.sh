# Ali is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ali is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ali. If not, see < http://www.gnu.org/licenses/ >.
#
# (C) 2016- by Adam Tauber, <asciimoo@gmail.com>


ALI_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ali"

[[ -d "$ALI_DIR" ]] || mkdir -p $ALI_DIR

ALI_FUNCTION_DB="$ALI_DIR/functions"

[[ -f "$ALI_FUNCTION_DB" ]] || touch "$ALI_FUNCTION_DB"

ali_delete() {
    sed -i "/^function $1()/ d" "$ALI_FUNCTION_DB"
}

ali_register() {
    local FUNCTION_NAME=$1
    grep -q "^function $FUNCTION_NAME()" "$ALI_FUNCTION_DB" && ali_delete "$FUNCTION_NAME"

    ali_define "$@" >> "$ALI_FUNCTION_DB"
}

ali__get_full_cmd() {
    [[ "$OSTYPE" == linux* ]] \
        && { whereis "$1" | cut -s -d ' ' -f 2; echo "$1"; } | head -1 \
        || whereis "$1"
}

ali_define() {
    local DUPLICATED_FUNCTION=0
    local FUNCTION_NAME=$1 && shift
    local CMD_ARGS=""

    local EXTRA_ARGS_REQUIRED=1
    for i in "$@"; do
        [[ "$i" == *\$* ]] && EXTRA_ARGS_REQUIRED=0 && i="\"$i\""
        [[ "$i" == $FUNCTION_NAME ]] && i=$(ali__get_full_cmd $i)
        CMD_ARGS="$CMD_ARGS $i"
    done

    [[ $EXTRA_ARGS_REQUIRED -eq 1 ]] && CMD_ARGS="$CMD_ARGS \"\$@\""

    local FUNCTION_STRING="function $FUNCTION_NAME() { $CMD_ARGS; }"
    eval "$FUNCTION_STRING" || return 1
    echo "$FUNCTION_STRING"
}

ali_load() {
    local FILE=""
    [[ "$1" != "" ]] \
        && FILE="$1" \
        || FILE="$ALI_FUNCTION_DB"
    local C=0
    source "$FILE"
    [[ "$(alias)" != "" ]] && printf "Warning: Ali will unset your aliases\n" && unalias -a
}

ali_expand() {
    declare -f $1 || whereis $1
}

ali_list() {
    cat "$ALI_FUNCTION_DB"
}

ali_clear() {
    printf "Are you sure? (y/n) "
    read answer
    echo "$answer" | grep -iq "^y\$" && truncate -s 0 "$ALI_FUNCTION_DB"
}

ali() {
    local ALI_METHOD=$1
    shift
    "ali_$ALI_METHOD" $@
}

ali_load
