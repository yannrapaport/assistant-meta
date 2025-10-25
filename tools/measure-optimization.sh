#!/bin/bash
#
# Measure token optimization impact for assistants
#
# Usage:
#   ./measure-optimization.sh ~/Documents/Dev/assistant-git
#   ./measure-optimization.sh ~/Documents/Dev/assistant-*
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

measure_assistant() {
    local assistant_dir="$1"
    local assistant_name=$(basename "$assistant_dir")

    if [ ! -f "$assistant_dir/assistant.md" ]; then
        echo -e "${RED}No assistant.md found in $assistant_dir${NC}"
        return 1
    fi

    cd "$assistant_dir"

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📊 $assistant_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Count words
    local words=$(wc -w < assistant.md)
    local estimated_tokens=$((words * 13 / 10))

    # Count characters
    local chars=$(wc -c < assistant.md)
    local char_estimated_tokens=$((chars / 4))

    # Count lines
    local lines=$(wc -l < assistant.md)

    # Check for docs/ directory
    local has_docs=false
    local docs_count=0
    local docs_words=0

    if [ -d "docs" ]; then
        has_docs=true
        docs_count=$(find docs -name "*.md" -type f | wc -l)
        docs_words=$(find docs -name "*.md" -type f -exec cat {} \; | wc -w)
    fi

    # Check for .meta file
    local has_meta=false
    local is_synced="unknown"

    if [ -f ".meta" ]; then
        has_meta=true
        if command -v jq &> /dev/null; then
            local current_hash=$(git rev-parse HEAD 2>/dev/null || echo "")
            local last_sync=$(jq -r '.last_sync_hash' .meta 2>/dev/null || echo "")

            if [ "$current_hash" = "$last_sync" ] && [ -n "$current_hash" ]; then
                is_synced="✓ synced"
            else
                is_synced="✗ not synced"
            fi
        fi
    fi

    # Optimization status
    local status=""
    local recommendation=""

    if [ "$words" -lt 300 ]; then
        status="${GREEN}✓ Optimized${NC}"
        recommendation=""
    elif [ "$words" -lt 500 ]; then
        status="${YELLOW}△ Could optimize${NC}"
        recommendation="Potential: -30-50% (~$((words / 2)) words)"
    else
        status="${RED}✗ Needs optimization${NC}"
        recommendation="Potential: -50-70% (~$((words * 3 / 10)) words)"
    fi

    # Display results
    echo ""
    echo "Core Assistant (assistant.md):"
    echo "  Words:      $words"
    echo "  Lines:      $lines"
    echo "  Characters: $chars"
    echo ""
    echo "Token Estimates:"
    echo "  Word-based:      ~$estimated_tokens tokens (words × 1.3)"
    echo "  Char-based:      ~$char_estimated_tokens tokens (chars ÷ 4)"
    echo ""

    if [ "$has_docs" = true ]; then
        echo -e "${GREEN}Extracted Documentation:${NC}"
        echo "  Files:      $docs_count in docs/"
        echo "  Words:      $docs_words (extracted)"
        echo "  Total orig: ~$((words + docs_words)) words (estimated)"
        echo ""
    fi

    echo -e "Status:     $status"

    if [ -n "$recommendation" ]; then
        echo -e "${YELLOW}$recommendation${NC}"
    fi

    echo ""
    echo "Tracking:"
    echo "  .meta file: $([ "$has_meta" = true ] && echo "✓ present ($is_synced)" || echo "✗ missing")"
    echo "  Git repo:   $([ -d .git ] && echo "✓ initialized" || echo "✗ not initialized")"
    echo ""

    # Try actual token count if available
    if command -v python3 &> /dev/null && python3 -c "import tiktoken" 2>/dev/null; then
        echo "Actual Token Count (tiktoken):"
        python3 "$SCRIPT_DIR/count-tokens.py" assistant.md 2>/dev/null || echo "  (calculation failed)"
        echo ""
    fi

    return 0
}

compare_before_after() {
    local assistant_dir="$1"
    local before_words="$2"

    cd "$assistant_dir"

    if [ ! -f "assistant.md" ]; then
        echo "Error: assistant.md not found"
        return 1
    fi

    local after_words=$(wc -w < assistant.md)
    local reduction=$((before_words - after_words))
    local reduction_pct=$((reduction * 100 / before_words))
    local before_tokens=$((before_words * 13 / 10))
    local after_tokens=$((after_words * 13 / 10))
    local token_savings=$((before_tokens - after_tokens))

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ Optimization Complete${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Before:  $before_words words (~$before_tokens tokens)"
    echo "After:   $after_words words (~$after_tokens tokens)"
    echo ""
    echo -e "${GREEN}Savings: -$reduction words (-$reduction_pct%)${NC}"
    echo -e "${GREEN}Tokens:  -$token_savings tokens saved per load${NC}"
    echo ""
}

summary_all() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📈 Summary${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    local total_words=0
    local total_tokens=0
    local optimized_count=0
    local needs_opt_count=0

    for dir in ~/Documents/Dev/assistant-*/; do
        if [ -f "$dir/assistant.md" ]; then
            local words=$(wc -w < "$dir/assistant.md")
            local tokens=$((words * 13 / 10))
            total_words=$((total_words + words))
            total_tokens=$((total_tokens + tokens))

            if [ "$words" -lt 300 ]; then
                optimized_count=$((optimized_count + 1))
            else
                needs_opt_count=$((needs_opt_count + 1))
            fi
        fi
    done

    echo "Total assistants analyzed: $((optimized_count + needs_opt_count))"
    echo "  Optimized:      $optimized_count"
    echo "  Need work:      $needs_opt_count"
    echo ""
    echo "Current total:  $total_words words (~$total_tokens tokens)"
    echo ""

    if [ "$needs_opt_count" -gt 0 ]; then
        local potential_savings=$((total_words * 3 / 10))
        local potential_tokens=$((potential_savings * 13 / 10))
        echo -e "${YELLOW}Optimization potential: ~$potential_savings words (~$potential_tokens tokens)${NC}"
    fi

    echo ""
}

# Main execution
if [ $# -eq 0 ]; then
    # No arguments: analyze all assistants
    echo -e "${BLUE}Analyzing all assistants...${NC}"
    echo ""

    for dir in ~/Documents/Dev/assistant-*/; do
        if [ -d "$dir" ]; then
            measure_assistant "$dir"
        fi
    done

    summary_all

elif [ $# -eq 1 ]; then
    # Single argument: analyze one assistant
    measure_assistant "$1"

else
    # Multiple arguments: analyze each
    for dir in "$@"; do
        measure_assistant "$dir"
    done

    echo ""
    summary_all
fi
