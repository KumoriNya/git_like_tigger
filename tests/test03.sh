#! /usr/bin/env dash

# ==============================================================================
# test03.sh
# Test the tigger-rm command without options.
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

# Test if tigger-rm detects that tigger-init is not ran

cat > "$expected_output" <<EOF
tigger-rm: error: tigger repository directory .tigger not found
EOF
tigger-rm > "$received_output"
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

# Test for errors
# 0. usages - insufficient args and incorrect flags
cat > "$expected_output" <<EOF
usage: tigger-rm [--force] [--cached] <filenames>
EOF

tigger-rm > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!"
    exit 1
fi

cat > "$expected_output" <<EOF
usage: tigger-rm [--force] [--cached] <filenames>
EOF

tigger-rm --flag > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!"
    exit 1
fi

cat > "$expected_output" <<EOF
usage: tigger-rm [--force] [--cached] <filenames>
EOF

tigger-rm --flag a > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!"
    exit 1
fi

# 1. no target file

cat > "$expected_output" <<EOF
tigger-rm: error: 'a' is not in the tigger repository
EOF

tigger-rm a > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!"
    exit 1
fi

# Test for regular removes
touch a b c d
# 0. error: not in repo
cat > "$expected_output" <<EOF
tigger-rm: error: 'a' is not in the tigger repository
EOF

tigger-rm a > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!"
    exit 1
fi

# 1.0 added not committed - error: staged
# 2.0 updated not added - error
# 2.1 updated and added not committed - error
# 2.2 updated and added and success

    # 1.0
tigger-add a b c d
cat > "$expected_output" <<EOF
tigger-rm: error: 'a' has staged changes in the index
EOF

tigger-rm a > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!"
    exit 1
fi
    # 2.0
tigger-commit -m "commit all"
echo change b >> b
cat > "$expected_output" <<EOF
tigger-rm: error: 'b' in the repository is different to the working file
EOF

tigger-rm a b > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!"
    exit 1
fi

    # 2.1
tigger-add b
cat > "$expected_output" <<EOF
tigger-rm: error: 'b' has staged changes in the index
EOF

tigger-rm a b > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test"
    exit 1
fi

    # 2.2
tigger-commit -m "commit changes"
cat > "$expected_output" <<EOF
EOF

tigger-rm a b > "$received_output"

if ! diff "$expected_output" "$received_output"; then
    echo "Failed test!!!"
    exit 1
fi

echo "Passed test"
exit 0