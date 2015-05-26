#!/bin/bash
# Android Nbackup version 1.0
# Date 05-26-2015
# Dependencies GNU Bash version 4.3. GNU Coreutils 8.21. Android Debug Bridge
# Android device must be rooted!
# Android Nbackup is a script that backs up your Android device contacts and text messages 

# Location of contact and sms data
smsfile=/data/data/com.android.providers.telephony/databases/mmssms.db
contactsfile=/data/data/com.android.providers.contacts/databases/contacts2.db

# Check to see if Device is connected
devices=$(adb get-serialno)

if [ "unknown" = "$devices" ]
then
echo "Device not connected"
exit 1
fi

#Create .Phone_data dir

if [ -d ~/.Phone_data ]
then 
true
else
mkdir ~/.Phone_data
fi


# Run script with shell as root and copy data

adb shell "su -c cp $smsfile /sdcard/ && su -c cp $contactsfile /sdcard/ && exit"

# Pull data from Android device to PC

adb pull /sdcard/mmssms.db ~/
adb pull /sdcard/contacts2.db ~/

adb shell " rm /sdcard/*.db "

# Check file size, needed in case Android auto deletes part of either file.
# If auto deletion occurs to avoid data loss the new file is copied to the Phone_data dir and dated.


sizenewfilesms=$(stat -c%s ~/mmssms.db)
sizeoldfilesms=$(stat -c%s ~/.Phone_data/mmssms.db)

sizenewfilecon=$(stat -c%s ~/contacts2.db)
sizeoldfilecon=$(stat -c%s ~/.Phone_data/contacts2.db)

if [[ "$sizenewfilesms" -lt "$sizeoldfilesms"  ]]
then
echo "Backup file mmssms.db is missing data do not overwrite! Copying dated file to Phone_data dir."
mv ~/mmssms.db ~/.Phone_data/"mmssms`date`.db"
elif [[ "$sizenewfilecon" -lt "$sizeoldfilecon" ]]
then
echo "Backup file contacts2.db is missing data do not overwrite! Copying dated file to Phone_data dir"
mv ~/contacts2.db ~/.Phone_data/"contacts`date`.db"
else

diff -adq --no-ignore-file-name-case ~/mmssms.db ~/.Phone_data/mmssms.db

if [ $? -eq 0 ]
then
echo "SMS files are equal and up to date"
else
cp ~/mmssms.db ~/.Phone_data/mmssms.db
fi

diff -adq --no-ignore-file-name-case ~/contacts2.db ~/.Phone_data/contacts2.db

if [ $? -eq 0 ]
then
echo "Contact files are equal and up to date"
else
cp ~/contacts2.db ~/.Phone_data/contacts2.db
fi

#clean up
rm ~/*.db

fi

exit 0
