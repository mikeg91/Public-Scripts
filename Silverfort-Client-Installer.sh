#!/bin/sh
#
#########################
#
# Script attempts at making a single deployment script for Silverfort Client
# This script is deisgned to be used with Jamf Pro, but can be covnerted to other 
# MDM platorms with little effort. 
#
# Create a policy with the DMG file being cached on the Mac.
# Add this script to the policy, set it to run after. Enter the required info in the fields. 
#
##### History #####
#
# v1.0 Aug 04 2025 - mikeg91
# Created initial script 
#
#########################

### Variables ###
# SF_MESSAGING_URL
SF_MESSAGING_URL="$4"
# SF_CONNECTION_TOKEN
SF_CONNECTION_TOKEN="$5"
# Cached DMG location
WaitingRoomDMG="/Library/Application Support/JAMF/Waiting Room/$6"
# Mounted DMG name 
mounted_dmg=$(basename /Volumes/Silver*)
# Current logged-in user
loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
# Do not modify below this line
################################

# Quit Silverfort Client if it's running
if pgrep -x "Silverfort Client" > /dev/null; then
  echo "Silverfort Client is currently running. Quitting..."
  osascript -e 'quit app "Silverfort Client"'
  sleep 2  # Give it a moment to close
fi

# Create plist and add messaging URL
/usr/bin/defaults write "/Users/$loggedInUser/Library/Preferences/com.silverfort.client.plist" SF_MESSAGING_URL "$SF_MESSAGING_URL"
echo "$SF_MESSAGING_URL"

# Add connection token to plist
/usr/bin/defaults write "/Users/$loggedInUser/Library/Preferences/com.silverfort.client.plist" SF_CONNECTION_TOKEN "$SF_CONNECTION_TOKEN"
echo "$SF_CONNECTION_TOKEN"

# Ensure permissions are correct
/usr/sbin/chown "$loggedInUser:staff" "/Users/$loggedInUser/Library/Preferences/com.silverfort.client.plist"
echo "Changing Permissions on plist"

# Attach dmg
hdiutil attach "$WaitingRoomDMG" -nobrowse

# Copy Silverfort to Applications folder
cp -Rf "/Volumes/$mounted_dmg/Silverfort Client.app" "/Applications/"

# Unmount DMG
hdiutil detach "/Volumes/$mounted_dmg"

# Suppress the quarantine 
sudo xattr -rd com.apple.quarantine "/Applications/Silverfort Client.app"

# Delete DMGs
rm "$WaitingRoomDMG"

# Open Silverfort Client App
open -a "Silverfort Client"

exit
