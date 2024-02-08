#!/bin/bash

# TODO: All this code needs to be platform specific!

cp $BASIC_AUTH_DIR/conf/basic-auth /etc/pam.d/

# Install dependencies and build PAM module
sudo apt-get install -y $PACKAGES

cargo build --manifest-path $BASIC_AUTH_DIR/Cargo.toml
mv $ROOT_DIR/target/debug/libbasic_auth.so /lib/aarch64-linux-gnu/security/basic_auth.so

# Compile the test program
g++ -o $BASIC_AUTH_DIR/test_pam $BASIC_AUTH_DIR/test.c -lpam -lpam_misc

# Create data for testing
test_data=("user_1 password" "user_1 incorrect_password" "user_2 password" "user_2 incorrect_password")

# Run the tests
# Loop through the test data
for tuple in "${test_data[@]}"
do
  # Use read to split the tuple into two variables
  read -r user pass <<< "$tuple"
  
  # Now $user and $pass can be used as separate variables
  echo  $pass | $BASIC_AUTH_DIR/test_pam $user
  echo "-----------------------------------"
done