#! /usr/bin/env dash

# ==============================================================================
# test07.sh
# Test the tigger-branch command and delete branch.
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

# Test if tigger-branch and checkout detects that tigger-init is not ran

cat > "$expected_output" <<EOF
tigger-branch: error: tigger repository directory .tigger not found
EOF
tigger-branch > "$received_output"
diff "$expected_output" "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

# Create tigger repository
tigger-init >/dev/null

# Test for empty directory
cat > "$expected_output"<<EOF
tigger-branch: error: this command can not be run until after the first commit
EOF
tigger-branch > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

# do a commit
echo a > a
tigger-add a
tigger-commit -m "commit">>/dev/null

cat > "$expected_output"<<EOF
master
EOF
tigger-branch > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

# create a branch, delete it and create another branch
tigger-branch branch1

cat > "$expected_output"<<EOF
branch1
master
EOF
tigger-branch > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

cat > "$expected_output"<<EOF
Deleted branch 'branch1'
EOF
tigger-branch -d branch1 > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

tigger-branch 1branch

cat > "$expected_output"<<EOF
1branch
master
EOF
tigger-branch > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

# check status of master
cat > "$expected_output"<<EOF
a - same as repo
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

cat > "$expected_output"<<EOF
0 commit
EOF
tigger-log > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

echo "Passed test"
exit 0