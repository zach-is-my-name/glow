#!/bin/zsh

echo "🔍 Comprehensive Zen-Mode Testing with rg/fd"
echo "=============================================="

cd /Users/zm/Scratch/glow

# Build the current version
echo "\n📦 Building current zen-mode version..."
go build -o glow-fixed > /dev/null 2>&1
echo "✓ Built glow-fixed"

echo "\n🔢 Terminal width: $(tput cols) columns"
echo "🎯 Target: 80-char content width with 18-char margins each side"

# Test the comprehensive file
TEST_FILE="test_comprehensive_zen.md"
OUTPUT_FILE="zen_comprehensive_output.txt"

if [[ ! -f "$TEST_FILE" ]]; then
    echo "❌ Test file $TEST_FILE not found!"
    exit 1
fi

echo "\n📊 Running comprehensive zen-mode test..."
./glow-fixed -z "$TEST_FILE" > "$OUTPUT_FILE" 2>&1

if [[ $? -ne 0 ]]; then
    echo "❌ Glow command failed:"
    cat "$OUTPUT_FILE"
    exit 1
fi

echo "✓ Generated output in $OUTPUT_FILE"

# Analysis using rg for pattern matching
echo "\n📈 COMPREHENSIVE ANALYSIS:"
echo "=========================="

echo "\n🔹 Line length distribution (all non-empty lines):"
rg -v '^\s*$' "$OUTPUT_FILE" | awk '{print length($0)}' | sort -n | uniq -c | sort -n

echo "\n🔹 Length statistics:"
total_lines=$(rg -v '^\s*$' "$OUTPUT_FILE" | wc -l | tr -d ' ')
short_lines=$(rg -v '^\s*$' "$OUTPUT_FILE" | awk 'length($0) < 40' | wc -l | tr -d ' ')
medium_lines=$(rg -v '^\s*$' "$OUTPUT_FILE" | awk 'length($0) >= 40 && length($0) < 70' | wc -l | tr -d ' ')
good_lines=$(rg -v '^\s*$' "$OUTPUT_FILE" | awk 'length($0) >= 70' | wc -l | tr -d ' ')
avg_length=$(rg -v '^\s*$' "$OUTPUT_FILE" | awk '{sum += length($0); count++} END {printf "%.1f", sum/count}')

echo "Total lines: $total_lines"
echo "Short (<40):   $short_lines ($(echo "scale=1; $short_lines * 100 / $total_lines" | bc -l)%)"
echo "Medium (40-70): $medium_lines ($(echo "scale=1; $medium_lines * 100 / $total_lines" | bc -l)%)"
echo "Good (>=70):   $good_lines ($(echo "scale=1; $good_lines * 100 / $total_lines" | bc -l)%)"
echo "Average length: $avg_length chars"

echo "\n🔹 Problematic short lines (<50 chars):"
rg -v '^\s*$' "$OUTPUT_FILE" | awk 'length($0) < 50 {print "LINE " NR " (" length($0) " chars): " $0}' | head -20

echo "\n🔹 Element-specific analysis:"

# Check specific markdown elements using rg patterns
echo "\n📝 Paragraphs (lines starting with letter/number):"
rg '^[a-zA-Z0-9]' "$OUTPUT_FILE" | awk '{print length($0)}' | awk '{
    if (length($0) < 40) short++
    else if (length($0) < 70) medium++
    else good++
} END {
    total = short + medium + good
    if (total > 0) {
        printf "  Short: %d (%.1f%%), Medium: %d (%.1f%%), Good: %d (%.1f%%)\n", 
               short, short*100/total, medium, medium*100/total, good, good*100/total
    }
}'

echo "\n📋 List items (lines starting with -, •, or numbers):"
rg '^(\s*[-•]|\s*\d+\.)' "$OUTPUT_FILE" | awk '{print length($0)}' | awk '{
    if (length($0) < 40) short++
    else if (length($0) < 70) medium++
    else good++
} END {
    total = short + medium + good
    if (total > 0) {
        printf "  Short: %d (%.1f%%), Medium: %d (%.1f%%), Good: %d (%.1f%%)\n", 
               short, short*100/total, medium, medium*100/total, good, good*100/total
    }
}'

echo "\n📊 Tables (lines with |):"
rg '\|' "$OUTPUT_FILE" | awk '{print length($0)}' | awk '{
    if (length($0) < 40) short++
    else if (length($0) < 70) medium++
    else good++
} END {
    total = short + medium + good
    if (total > 0) {
        printf "  Short: %d (%.1f%%), Medium: %d (%.1f%%), Good: %d (%.1f%%)\n", 
               short, short*100/total, medium, medium*100/total, good, good*100/total
    }
}'

echo "\n💻 Code blocks (lines between code fences):"
in_code=0
rg -n '```|^[[:space:]]*[a-zA-Z0-9_].*[;{},]|^[[:space:]]*//|^[[:space:]]*#[[:space:]]' "$OUTPUT_FILE" | while IFS=: read -r line_num content; do
    echo "CODE LINE $line_num ($(echo "$content" | wc -c | tr -d ' ') chars): $content"
done | head -10

echo "\n🔹 Files that might need zen-mode fixes:"
echo "Searching glamour ansi/ directory for rendering files..."

# Use fd to find relevant files and rg to check for width-related code
fd -e go . /Users/zm/Scratch/glamour/ansi/ | while read -r file; do
    if rg -q '(Width|width|wordwrap|margin)' "$file"; then
        echo "📄 $(basename "$file"): $(rg -c '(Width|width|wordwrap|margin)' "$file") width-related lines"
    fi
done

echo "\n✅ RECOMMENDATION:"
if [[ $short_lines -gt $(($total_lines / 4)) ]]; then
    echo "❌ TOO MANY SHORT LINES ($short_lines/$total_lines = $(echo "scale=1; $short_lines * 100 / $total_lines" | bc -l)%)"
    echo "   Need to fix zen-mode detection in glamour rendering files"
    echo "   Focus on files with high width-related code above"
else
    echo "✅ Short line ratio acceptable ($short_lines/$total_lines = $(echo "scale=1; $short_lines * 100 / $total_lines" | bc -l)%)"
fi

if [[ $(echo "$avg_length < 60" | bc -l) -eq 1 ]]; then
    echo "❌ AVERAGE LINE LENGTH TOO SHORT ($avg_length chars)"
    echo "   Target should be ~80 chars for zen-mode"
else
    echo "✅ Average line length acceptable ($avg_length chars)"
fi

echo "\n📋 Next steps:"
echo "1. Review problematic short lines above"
echo "2. Check glamour ansi/ files listed for zen-mode detection"
echo "3. Ensure consistent Width() calculations across all elements"
echo "4. Test individual element types in isolation"

echo "\n📁 Output saved to: $OUTPUT_FILE"
echo "📁 View full output: cat $OUTPUT_FILE"