#! /usr/bin/env dash

# ==============================================================================
# test04.sh
# Test the tigger-rm command with options.
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

# Add a file, do tigger-rm -> error
# Then remove it from the index
touch a
tigger-add a
cat > "$expected_output"<<EOF
tigger-rm: error: 'a' has staged changes in the index
EOF
tigger-rm a > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

cat > "$expected_output"<<EOF
a - added to index
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

# Commit the file.
# Update the file and the index, remove from the index
# add again, update the file, remove from the index -> error
# rm -> error
# rm with force
tigger-commit -m 'commit' >>/dev/null
echo more >> a
tigger-add a
cat > "$expected_output"<<EOF
a - file changed, changes staged for commit
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

tigger-rm --cached a
cat > "$expected_output"<<EOF
a - untracked
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi


tigger-add a
cat > "$expected_output"<<EOF
a - file changed, changes staged for commit
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

echo even more >> a
cat > "$expected_output"<<EOF
a - file changed, different changes staged for commit
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

cat > "$expected_output"<<EOF
tigger-rm: error: 'a' in index is different to both the working file and the repository
EOF
tigger-rm --cached a > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

cat > "$expected_output"<<EOF
EOF
tigger-rm --force --cached a > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

cat > "$expected_output"<<EOF
a - untracked
EOF
tigger-status > "$received_output"
if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!"
    exit 1
fi

echo "Passed test"
exit 0