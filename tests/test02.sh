#! /usr/bin/env dash

# ==============================================================================
# test02.sh
# Test the tigger-status command.
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

# Test if tigger-status detects that tigger-init is not ran

cat > "$expected_output" <<EOF
tigger-status: error: tigger repository directory .tigger not found
EOF
tigger-status > "$received_output"
diff "$expected_output" "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Create tigger repository

cat > "$expected_output" <<EOF
Initialized empty tigger repository in .tigger
EOF

tigger-init > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!"
    exit 1
fi

# Test for empty directory
cat > "$expected_output"<<EOF
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

# Test for multiple untracked files
touch a b c d e f g h
cat > "$expected_output"<<EOF
a - untracked
b - untracked
c - untracked
d - untracked
e - untracked
f - untracked
g - untracked
h - untracked
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Test for some added and some untracked
cat > "$expected_output"<<EOF
EOF
tigger-add a b e f  > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output"<<EOF
a - added to index
b - added to index
c - untracked
d - untracked
e - added to index
f - added to index
g - untracked
h - untracked
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Test for removed added and untracked files
rm b f
cat > "$expected_output"<<EOF
a - added to index
b - added to index, file deleted
c - untracked
d - untracked
e - added to index
f - added to index, file deleted
g - untracked
h - untracked
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi
# Test for adding these files back

cat > "$expected_output"<<EOF
EOF
$(tigger-show :b > b) > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi
cat > "$expected_output"<<EOF
EOF
$(tigger-show :f > f) > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output"<<EOF
a - added to index
b - added to index
c - untracked
d - untracked
e - added to index
f - added to index
g - untracked
h - untracked
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0