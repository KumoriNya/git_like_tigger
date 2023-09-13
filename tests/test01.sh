#! /usr/bin/env dash

# ==============================================================================
# test01.sh
# Test the tigger-log command.
#
# Written by: Claude Sun <z5314102@ad.unsw.edu.au>
# Date: 2022-07-08
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

# Test if tigger-log detects that tigger-init is not ran

cat > "$expected_output" <<EOF
tigger-log: error: tigger repository directory .tigger not found
EOF

tigger-log > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Create tigger repository

cat > "$expected_output" <<EOF
Initialized empty tigger repository in .tigger
EOF

tigger-init > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi


# Create a simple file.

echo "line 1" > a

# Try to log a, which should fail

cat > "$expected_output" <<EOF
tigger-show: error: invalid object a
EOF

tigger-show a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
tigger-show: error: 'a' not found in index
EOF

tigger-show :a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
tigger-show: error: unknown commit '0'
EOF

tigger-show 0:a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# add a file to the repository staging area

cat > "$expected_output" <<EOF
EOF

tigger-add a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# a is now in the index, but no commit history

cat > "$expected_output" <<EOF
line 1
EOF

tigger-show :a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
tigger-show: error: unknown commit '0'
EOF

tigger-show 0:a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# commit the file to the repository history

cat > "$expected_output" <<EOF
Committed as commit 0
EOF


tigger-commit -m 'first commit' > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# 0:a should work now

cat > "$expected_output" <<EOF
line 1
EOF

tigger-show 0:a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0