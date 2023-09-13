#! /usr/bin/env dash

# ==============================================================================
# test05.sh
# Test the tigger-status command with tigger-commit -a.
#
# Written by: Claude Sun <z5314102@ad.unsw.edu.au>
# Date: 2022-07-10
# For COMP2041/9044 Assignment 1
# ==============================================================================

# Create a temporary directory for the test.

PATH="$PATH:$(pwd)"
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.

expected_output="$(mktemp)"
received_output="$(mktemp)"

# Remove the temporary directory when the test is done.

trap 'rm "$expected_output" "$received_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

# Create tigger repository

cat > "$expected_output" <<EOF
Initialized empty tigger repository in .tigger
EOF

tigger-init > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!"
    exit 1
fi

# Create 3 files
# manually add all of them, and commit
# Create 2 files
# manually add one file
# update all 5 files
# commit all
touch a b c
tigger-add a b c
tigger-commit -m "commit" >>/dev/null
touch d e
echo a > a
echo b > b
echo c > c
echo d > d
tigger-add d

cat > "$expected_output"<<EOF
a - file changed, changes not staged for commit
b - file changed, changes not staged for commit
c - file changed, changes not staged for commit
d - added to index
e - untracked
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

tigger-commit -a -m "commit all" >>/dev/null

cat > "$expected_output"<<EOF
a - same as repo
b - same as repo
c - same as repo
d - same as repo
e - untracked
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

echo "Passed test"
exit 0