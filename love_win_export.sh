#!/bin/bash

# Check for both arguments: folder name and .love file
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "❌ Error: Missing arguments."
  echo "👉 Usage: $0 <folder_name> <path_to_game.love>"
  exit 1
fi

# Assign variables
FOLDER_NAME="$1"
LOVE_FILE="$2"
LOVE_DIR=~/love
LOVE_EXE="$LOVE_DIR/love.exe"
DEST_DIR="$PWD/$FOLDER_NAME"

# Check if .love file exists
if [ ! -f "$LOVE_FILE" ]; then
  echo "❌ Error: .love file '$LOVE_FILE' does not exist."
  exit 1
fi

# Check if love.exe exists
if [ ! -f "$LOVE_EXE" ]; then
  echo "❌ Error: love.exe not found in $LOVE_DIR"
  exit 1
fi

# Get the base name of the .love file (e.g., SuperGame.love -> SuperGame)
GAME_NAME=$(basename "$LOVE_FILE" .love)

# Create the destination folder
mkdir -p "$DEST_DIR"

# Build the .exe
cat "$LOVE_EXE" "$LOVE_FILE" > "$DEST_DIR/$GAME_NAME.exe"
echo "✅ Built $DEST_DIR/$GAME_NAME.exe"

# List of required files to copy
FILES_TO_COPY=(
  SDL2.dll
  OpenAL32.dll
  license.txt
  love.dll
  lua51.dll
  mpg123.dll
  msvcp120.dll
  msvcr120.dll
)

# Copy each required file from love_11 to the destination folder
for file in "${FILES_TO_COPY[@]}"; do
  src="$LOVE_DIR/$file"
  if [ -f "$src" ]; then
    cp "$src" "$DEST_DIR"
    echo "📦 Copied $file"
  else
    echo "⚠️ Warning: $file not found in $LOVE_DIR"
  fi
done

echo "🎉 Build complete in: $DEST_DIR"
