#!/bin/bash

OS_NAME=$(uname -s)

if [ "$OS_NAME" = "Linux" ] || [ "$OS_NAME" = "Darwin" ]; then
    BASE_PATH="$HOME/.mt5/drive_c"
else
    BASE_PATH="$HOME/C"
fi
BASE_DIR="$BASE_PATH"/Program\ Files/MetaTrader\ 5/MQL5

echo "🚚 deploy to mql directory..."

find "$PWD"/Include -mindepth 1 -maxdepth 1 -type d | while IFS= read -r dir; do
    dir_name=$(basename "$dir")
    
    escaped_src=$(echo "$dir" | sed 's/ /\\ /g')
    escaped_dest=$(echo "$BASE_DIR/Include/$dir_name" | sed 's/ /\\ /g')
    echo $escaped_dest
    echo $escaped_src
    eval "ln -snvf $escaped_src $escaped_dest"
    echo "🚚 Created symlink: $dir -> $BASE_DIR/Include/$dir_name"
done

find "$PWD"/Scripts -mindepth 1 -maxdepth 1 -type d | while IFS= read -r dir; do
    dir_name=$(basename "$dir")
    escaped_src=$(echo "$dir" | sed 's/ /\\ /g')
    escaped_dest=$(echo "$BASE_DIR/Scripts/$dir_name" | sed 's/ /\\ /g')
    echo $escaped_dest
    echo $escaped_src
    
    eval "ln -snvf $escaped_src $escaped_dest"
    echo "🚚 Created symlink: $dir -> $BASE_DIR/Scripts/$dir_name"
done

echo "🎉 deploy finished."
