#!/bin/zsh

echo "🚀 Glow Zen-Mode Test Runner (No Go Knowledge Required)"
echo "======================================================"

# Change to the glow directory
cd /Users/zm/Scratch/glow

echo "\n📦 Building glow with Go..."
echo "   (This compiles the Go code into an executable)"

# Build the current version
if go build -o glow-fixed; then
    echo "✅ Successfully built glow-fixed executable"
else
    echo "❌ Build failed! Error:"
    go build -o glow-fixed
    exit 1
fi

echo "\n🔢 Your terminal width: $(tput cols) columns"
echo "🎯 Zen-mode target: 80-char content + 18-char margins each side = 116 total"

# Check if test file exists
TEST_FILE="test_comprehensive_zen.md"
if [[ ! -f "$TEST_FILE" ]]; then
    echo "❌ Test file $TEST_FILE not found!"
    echo "   Make sure you're in the right directory with the test file"
    exit 1
fi

echo "\n📊 Running zen-mode test on comprehensive markdown file..."
echo "   Command: ./glow-fixed -z $TEST_FILE"

# Run the test and save output
OUTPUT_FILE="zen_test_results.txt"
./glow-fixed -z "$TEST_FILE" > "$OUTPUT_FILE" 2>&1

if [[ $? -ne 0 ]]; then
    echo "❌ Glow command failed. Error output:"
    cat "$OUTPUT_FILE"
    exit 1
fi

echo "✅ Test completed successfully!"
echo "📁 Results saved to: $OUTPUT_FILE"

echo "\n📈 QUICK ANALYSIS:"
echo "=================="

# Count total lines
total_lines=$(rg -v '^\s*$' "$OUTPUT_FILE" | wc -l | tr -d ' ')
echo "📊 Total content lines: $total_lines"

# Line length analysis
echo "\n🔹 Line length breakdown:"
short_lines=$(rg -v '^\s*$' "$OUTPUT_FILE" | awk 'length($0) < 40' | wc -l | tr -d ' ')
medium_lines=$(rg -v '^\s*$' "$OUTPUT_FILE" | awk 'length($0) >= 40 && length($0) < 70' | wc -l | tr -d ' ')
good_lines=$(rg -v '^\s*$' "$OUTPUT_FILE" | awk 'length($0) >= 70' | wc -l | tr -d ' ')

echo "   📏 Short lines (<40 chars):  $short_lines"
echo "   📏 Medium lines (40-70):     $medium_lines" 
echo "   📏 Good lines (>=70):        $good_lines"

# Calculate percentages
if [[ $total_lines -gt 0 ]]; then
    short_pct=$(echo "scale=1; $short_lines * 100 / $total_lines" | bc -l)
    good_pct=$(echo "scale=1; $good_lines * 100 / $total_lines" | bc -l)
    echo "   📊 Short line percentage:    ${short_pct}%"
    echo "   📊 Good line percentage:     ${good_pct}%"
fi

# Average line length
avg_length=$(rg -v '^\s*$' "$OUTPUT_FILE" | awk '{sum += length($0); count++} END {printf "%.1f", sum/count}')
echo "   📊 Average line length:      $avg_length chars"

echo "\n🔍 PROBLEM DETECTION:"
echo "===================="

# Show some problematic short lines
echo "🚨 Examples of problematic short lines:"
rg -v '^\s*$' "$OUTPUT_FILE" | awk 'length($0) < 50 {print "   Line " NR ": (" length($0) " chars) " $0}' | head -5

echo "\n📋 WHAT TO DO NEXT:"
echo "=================="

if [[ $short_lines -gt $(($total_lines / 4)) ]]; then
    echo "❌ PROBLEM DETECTED: Too many short lines (${short_pct}%)"
    echo "   This means zen-mode isn't working properly for some elements"
    echo "   📧 Copy this entire output and paste it back to Claude"
    echo "   🔧 Claude will analyze and fix the rendering code"
else
    echo "✅ SHORT LINES OK: Only ${short_pct}% are too short"
fi

if [[ $(echo "$avg_length < 60" | bc -l) -eq 1 ]]; then
    echo "❌ AVERAGE LENGTH TOO SHORT: $avg_length chars (target ~80)"
    echo "   📧 Copy this entire output and paste it back to Claude"
else
    echo "✅ AVERAGE LENGTH OK: $avg_length chars"
fi

echo "\n📂 FILES CREATED:"
echo "   • glow-fixed (executable)"
echo "   • $OUTPUT_FILE (test results)"

echo "\n📋 NEXT STEPS:"
echo "1. Copy ALL of this output"
echo "2. Paste it back to Claude"
echo "3. Claude will analyze the results and fix any problems"
echo "4. Run this script again after Claude makes fixes"

echo "\n🔍 To see the full rendered output:"
echo "   cat $OUTPUT_FILE"

echo "\n✅ Test complete! Please copy this output to Claude."