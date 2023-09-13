#! /usr/bin/env dash

# ==============================================================================
# test00.sh
# Test the tigger-add, tigger-commit and tigger-show commands.
#
# Written by: Dylan Brotherston <d.brotherston@unsw.edu.au>
# Modified by: Claude Sun
# Date: 2022-07-07
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

# Test if tigger-add detects that tigger-init is not ran

cat > "$expected_output" <<EOF
tigger-add: error: tigger repository directory .tigger not found
EOF

tigger-add a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Test if tigger-commit detects that tigger-init is not ran

cat > "$expected_output" <<EOF
tigger-commit: error: tigger repository directory .tigger not found
EOF

tigger-commit > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Test if tigger-show detects that tigger-init is not ran

cat > "$expected_output" <<EOF
tigger-show: error: tigger repository directory .tigger not found
EOF

tigger-show > "$received_output" 2>&1

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

# Test tigger-init for existing .tigger folder

cat > "$expected_output" <<EOF
tigger-init: error: .tigger already exists
EOF

tigger-init > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Test if tigger-add reponses for non-existing files

cat > "$expected_output" <<EOF
tigger-add: error: can not open 'a'
EOF

tigger-add a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Test if tigger-commit reponses for nothing to commit

cat > "$expected_output" <<EOF
nothing to commit
EOF

tigger-commit -m a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Create a simple file.

echo "line 1" > a

# add a file to the repository staging area

cat > "$expected_output" <<EOF
EOF


tigger-add a > "$received_output" 2>&1

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

# Update the file.

echo "line 2" >> a

# update the file in the repository staging area

cat > "$expected_output" <<EOF
EOF


tigger-add a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Update the file.

echo "line 3" >> a

# BELOW IS FOR SHOW
# Check that the file that has been commited hasn't been updated

cat > "$expected_output" <<EOF
line 1
EOF

tigger-show 0:a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi


# Check that the file that is in the staging area hasn't been updated

cat > "$expected_output" <<EOF
line 1
line 2
EOF


tigger-show :a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Check that invalid use of tigger-show give an error

cat > "$expected_output" <<EOF
tigger-show: error: invalid object a
EOF


tigger-show a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
tigger-show: error: unknown commit '2'
EOF

tigger-show 2:a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
tigger-show: error: unknown commit 'hello'
EOF

tigger-show hello:a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
tigger-show: error: 'b' not found in commit 0
EOF

tigger-show 0:b > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
tigger-show: error: 'b' not found in index
EOF

tigger-show :b > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
usage: tigger-show <commit>:<filename>
EOF

tigger-show > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
usage: tigger-show <commit>:<filename>
EOF

tigger-show 0:a 0:a > "$received_output" 2>&1

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0