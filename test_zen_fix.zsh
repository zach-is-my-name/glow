#!/bin/zsh

echo "🔍 Testing Glow Zen-Mode Fix"
echo "=============================="

cd /Users/zm/Scratch/glow

# Build both versions
echo "\n📦 Building versions..."
git stash push -m "temp stash for testing" > /dev/null 2>&1
git checkout master > /dev/null 2>&1
go build -o glow-broken > /dev/null 2>&1
echo "✓ Built broken version (master)"

git checkout zen-mode-margins > /dev/null 2>&1
go build -o glow-fixed > /dev/null 2>&1
echo "✓ Built fixed version (zen-mode-margins)"

# Create test file if it doesn't exist
if [[ ! -f ../test_zen.md ]]; then
    cat > ../test_zen.md << 'EOF'
# Test Zen Mode

This is a test paragraph to verify that zen-mode rendering is working correctly. The text should wrap naturally at word boundaries rather than breaking every word onto a separate line. We want to see comfortable line lengths for reading, similar to what you'd see in VSCode or Neovim zen-mode.

## Another Section

Here's another paragraph with some longer sentences to really test the wrapping behavior. This text should flow naturally across multiple lines without extreme word-by-word breaking that makes it completely unreadable.

The goal is to have text that flows naturally while being centered in the terminal with comfortable margins on both sides.
EOF
fi

echo "\n🔢 Terminal width: $(tput cols) columns"

# Visual comparison
echo "\n📊 BROKEN VERSION OUTPUT:"
echo "========================="
./glow-broken -z ../test_zen.md

echo "\n📊 FIXED VERSION OUTPUT:"
echo "========================"
./glow-fixed -z ../test_zen.md

# Programmatic analysis
echo "\n📈 PROGRAMMATIC ANALYSIS:"
echo "========================="

echo "\n🔹 Line length distribution (first 10 content lines):"
echo "BROKEN: $(./glow-broken -z ../test_zen.md | grep -v '^[[:space:]]*$' | head -10 | awk '{print length}' | tr '\n' ' ')"
echo "FIXED:  $(./glow-fixed -z ../test_zen.md | grep -v '^[[:space:]]*$' | head -10 | awk '{print length}' | tr '\n' ' ')"

echo "\n🔹 Average line lengths:"
broken_avg=$(./glow-broken -z ../test_zen.md | grep -v '^[[:space:]]*$' | awk '{print length}' | awk '{sum+=$1; count++} END {printf "%.1f", sum/count}')
fixed_avg=$(./glow-fixed -z ../test_zen.md | grep -v '^[[:space:]]*$' | awk '{print length}' | awk '{sum+=$1; count++} END {printf "%.1f", sum/count}')
echo "BROKEN: ${broken_avg} chars/line"
echo "FIXED:  ${fixed_avg} chars/line"
echo "IMPROVEMENT: $(echo "scale=1; $fixed_avg / $broken_avg" | bc -l)x longer lines"

echo "\n🔹 Word wrapping analysis (count very short lines < 40 chars):"
broken_short=$(./glow-broken -z ../test_zen.md | grep -v '^[[:space:]]*$' | awk 'length < 40' | wc -l | tr -d ' ')
fixed_short=$(./glow-fixed -z ../test_zen.md | grep -v '^[[:space:]]*$' | awk 'length < 40' | wc -l | tr -d ' ')
echo "BROKEN: ${broken_short} lines under 40 chars"
echo "FIXED:  ${fixed_short} lines under 40 chars"

echo "\n✅ Test complete! The fixed version should show:"
echo "   • Natural paragraph flow (not word-per-line)"
echo "   • ~80 character line lengths"
echo "   • Centered text with comfortable margins"
echo "   • Significantly fewer short lines"