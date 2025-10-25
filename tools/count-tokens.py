#!/usr/bin/env python3
"""
Count tokens in assistant files using tiktoken (approximation for Claude).

Claude uses a proprietary tokenizer, but tiktoken (GPT) gives a reasonable approximation.
Typically within 5-10% of actual Claude token count.
"""

import sys
import os

try:
    import tiktoken
except ImportError:
    print("Error: tiktoken not installed", file=sys.stderr)
    print("Install with: pip3 install tiktoken", file=sys.stderr)
    sys.exit(1)


def count_tokens(text, model="cl100k_base"):
    """Count tokens in text using tiktoken.

    Args:
        text: Text to tokenize
        model: Tokenizer to use (cl100k_base is GPT-4's tokenizer, close to Claude)

    Returns:
        Number of tokens
    """
    try:
        encoding = tiktoken.get_encoding(model)
        tokens = encoding.encode(text)
        return len(tokens)
    except Exception as e:
        print(f"Error encoding text: {e}", file=sys.stderr)
        sys.exit(1)


def count_file_tokens(filepath):
    """Count tokens in a file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            text = f.read()
        return count_tokens(text)
    except FileNotFoundError:
        print(f"Error: File not found: {filepath}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    if len(sys.argv) < 2:
        print("Usage: count-tokens.py <file1> [file2] [...]")
        print("       cat file.md | count-tokens.py -")
        sys.exit(1)

    total_tokens = 0

    for filepath in sys.argv[1:]:
        if filepath == '-':
            # Read from stdin
            text = sys.stdin.read()
            tokens = count_tokens(text)
            print(f"stdin: {tokens} tokens")
            total_tokens += tokens
        else:
            tokens = count_file_tokens(filepath)
            words = len(open(filepath).read().split())
            chars = os.path.getsize(filepath)

            print(f"{filepath}:")
            print(f"  Tokens: {tokens}")
            print(f"  Words: {words} (≈{words * 1.3:.0f} estimated tokens)")
            print(f"  Chars: {chars} (≈{chars / 4:.0f} estimated tokens)")
            print(f"  Ratio: {tokens / words:.2f} tokens/word")
            print()

            total_tokens += tokens

    if len(sys.argv) > 2:
        print(f"Total: {total_tokens} tokens")


if __name__ == '__main__':
    main()
