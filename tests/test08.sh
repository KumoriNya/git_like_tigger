#! /usr/bin/env dash

# ==============================================================================
# test08.sh
# Test the tigger-merge command.
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

# Test if tigger-checkout detects that tigger-init is not ran

cat > "$expected_output" <<EOF
tigger-checkout: error: tigger repository directory .tigger not found
EOF
tigger-checkout > "$received_output"
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
tigger-checkout: error: this command can not be run until after the first commit
EOF
tigger-checkout > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

# do a commit
echo a > a
tigger-add a
tigger-commit -m "commit">>/dev/null

# error case: non-existing branch
cat > "$expected_output"<<EOF
tigger-checkout: error: unknown branch 'branch1'
EOF
tigger-checkout branch1 > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

tigger-branch branch1

# switch to new branch and add a commit, then go back to master
# check that the commit logs on different branches are different.
cat > "$expected_output"<<EOF
Switched to branch 'branch1'
EOF
tigger-checkout branch1 > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

echo b > b
tigger-add b
tigger-commit -m commit2


cat > "$expected_output"<<EOF
1 commit2
0 commit
EOF
tigger-log> "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

tigger-checkout master

cat > "$expected_output"<<EOF
0 commit
EOF
tigger-log> "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

echo "Passed test"
exit 0