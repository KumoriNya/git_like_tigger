#! /usr/bin/env dash

# ==============================================================================
# test09.sh
# Test tigger-merge command.
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

# Test if tigger-merge detects that tigger-init is not ran

cat > "$expected_output" <<EOF
tigger-merge: error: tigger repository directory .tigger not found
EOF
tigger-merge > "$received_output"
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
tigger-merge: error: this command can not be run until after the first commit
EOF
tigger-merge > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

# do a commit
echo a > a
tigger-add a
tigger-commit -m "commit">>/dev/null

# create a branch, go there,
# change a file, go back to master, assure master still access the new file
tigger-branch branch
tigger-checkout branch
echo b > b
tigger-checkout master

echo b > "$expected_output"
cat b > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

# go back to branch, commit the file, check that 
    # 1. branch is more up to date
    # master does not have the file
tigger-checkout branch
tigger-add b
tigger-commit -m "commit b"

cat > "$expected_output"<<EOF
Already up to date
EOF
tigger-merge master -m m > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

tigger-checkout master

cat > "$expected_output"<<EOF
cat: b: No such file or directory
EOF
cat b > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

cat > "$expected_output"<<EOF
Fast-forward: no commit created
EOF
tigger-merge branch -m m >"$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

echo b > "$expected_output"
cat b > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi


echo "Passed test"
exit 0