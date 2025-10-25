#!/usr/bin/env bash

# Read JSON input from stdin
INPUT=$(cat)

# Extract current working directory
CWD=$(echo "$INPUT" | jq -r '.workspace.current_dir')

# Check for active assistants file (per-directory)
ASSISTANTS_FILE="$CWD/.active-assistants"
ASSISTANTS_LIST=""

if [ -f "$ASSISTANTS_FILE" ]; then
    # Read all active assistants (one per line)
    ASSISTANTS_LIST=$(cat "$ASSISTANTS_FILE" | tr '\n' ', ' | sed 's/, $//')
fi

# Build status line sections
SECTIONS=()

# Active assistants section (if any)
if [ -n "$ASSISTANTS_LIST" ]; then
    SECTIONS+=("{\"text\": \"🤖 $ASSISTANTS_LIST\", \"color\": \"blue\"}")
fi

# Working directory
SECTIONS+=("{\"text\": \"📁 $(basename "$CWD")\"}")

# Combine sections
if [ ${#SECTIONS[@]} -gt 0 ]; then
    IFS=','
    echo "{\"sections\": [${SECTIONS[*]}]}"
else
    echo "{\"sections\": []}"
fi
