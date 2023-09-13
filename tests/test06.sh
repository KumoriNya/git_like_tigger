#! /usr/bin/env dash

# ==============================================================================
# test06.sh
# Test the tigger-status command, with working rm, to obtain all 9 types of status.
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

# Create 9 files
# do the same as provided by the spec for the first 8
# add the ninth and modify the ninth.
touch a b c d e f g h
tigger-add a b c d e f
tigger-commit -m 'first commit'>>/dev/null
echo hello >a
echo hello >b
echo hello >c
tigger-add a b
echo world >a
rm d
tigger-rm e
tigger-add g
tigger-add h
echo h>h
touch i
# Test for empty directory
cat > "$expected_output"<<EOF
a - file changed, different changes staged for commit
b - file changed, changes staged for commit
c - file changed, changes not staged for commit
d - file deleted
e - deleted
f - same as repo
g - added to index
h - added to index, file changed
i - untracked
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

echo "Passed test"
exit 0