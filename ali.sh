#!/bin/sh


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


ALI_DIR="$HOME/.config/ali"

[ -d "$ALI_DIR" ] || mkdir -p $ALI_DIR

ALI_FUNCTION_DB="$ALI_DIR/functions"

[ -f "$ALI_FUNCTION_DB" ] || touch "$ALI_FUNCTION_DB"

ali_delete() {
    FUNCTION_NAME=$1
    unset -f $FUNCTION_NAME
    sed -i "/^$FUNCTION_NAME/ d" "$ALI_FUNCTION_DB"
}

ali_register() {
    FUNCTION_NAME=$1
    [ $(grep -c "^$FUNCTION_NAME" "$ALI_FUNCTION_DB") -eq 0 ] \
        || ali_delete "$FUNCTION_NAME"

    FUNCTION_STRING=$(ali_define $@)
    eval "$FUNCTION_STRING"

    echo "$FUNCTION_STRING" >> "$ALI_FUNCTION_DB"
}

ali_define() {
    DUPLICATED_FUNCTION=0
    FUNCTION_NAME=$1 && shift
    CMD_ARGS=""

    EXTRA_ARGS_REQUIRED=1
    for i in "$@"; do
        [[ "$i" == *\$* ]] && EXTRA_ARGS_REQUIRED=0 && i="\"$i\""
        CMD_ARGS="$CMD_ARGS $i"
    done

    [ $EXTRA_ARGS_REQUIRED -eq 1 ] && CMD_ARGS="$CMD_ARGS \"\$@\""

    FUNCTION_STRING="$FUNCTION_NAME() { $CMD_ARGS; }"
    eval "$FUNCTION_STRING"
    echo "$FUNCTION_STRING"
}

ali_load() {
    [ "$1" != "" ] \
        && FILE="$1" \
        || FILE="$ALI_FUNCTION_DB"
    C=0
    while read LINE; do
        eval "$LINE"
        C=$((C+1))
    done < "$FILE"
}

ali_expand() {
    declare -f $1
}

ali_list() {
    cat "$ALI_FUNCTION_DB"
}

ali() {
    ALI_METHOD=$1
    shift
    "ali_$ALI_METHOD" $@
}

ali_load
