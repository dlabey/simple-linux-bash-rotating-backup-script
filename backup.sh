#!/bin/sh
# https://github.com/dlabey/Simple-Linux-Bash-Rotating-Backup-Script
# Local Source
SOURCE=/full/path

# Local Destination
DESTINATION=/full/path

# Database Backup User
DATABASE=''
DATABASE_USER=''
DATABASE_PASSWORD=''
DATABASE_HOST=''

# DO NOT EDIT ANYTHING BELOW THIS

# Date Variables
DAY_OF_YEAR=$(date '+%j')
DAY_OF_MONTH=$(date '+%d')
DAY_OF_WEEK_RAW=$(date '+%w')
DAY_OF_WEEK=$((DAY_OF_WEEK_RAW + 1))
MONTH=$(date '+%m')
YEAR=$(date '+%Y')

# Make Temporary Folder
mkdir `dirname $0`/tmp
echo 'Made temporary folder...'

# Make Weekly Folder
mkdir `dirname $0`/tmp/weekly
echo 'Made weekly folder...'

# Make Folder For Current Year
mkdir `dirname $0`/tmp/${YEAR}
echo 'Made folder for current year...'

# Make Folder For Current Month
mkdir `dirname $0`/tmp/${YEAR}/$MONTH
echo 'Made folder for current month...'

# Make Biannual Folder For Current Year
mkdir `dirname $0`/tmp/${YEAR}/biannual
echo 'Made biannual folder for current year...'

# Make The Weekly Backup
tar -zcvf `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_files.tar.gz $SOURCE
mysqldump -h $DATABASE_HOST -u $DATABASE_USER -p$DATABASE_PASSWORD $DATABASE > `dirname $0`/${DAY_OF_WEEK}.sql
tar -zcvf `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_database.tar.gz `dirname $0`/${DAY_OF_WEEK}.sql
rm -rf `dirname $0`/${DAY_OF_WEEK}.sql
echo 'Made weekly backup...'

# Check If It Is The 182nd Or 364th Day Of The Year Then Make A Biannual Backup
# If It Is By Copying The Weekly Backup To The Biannual Folder For The Current
# Year
if [ $DAY_OF_YEAR -eq 182 -o $DAY_OF_YEAR -eq 364 ] ; then
    if [ $DAY_OF_YEAR -eq 182 ] ; then
        cp `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_files.tar.gz `dirname $0`/tmp/${YEAR}/biannual/01_files.tar.gz
        cp `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_database.tar.gz `dirname $0`/tmp/${YEAR}/biannual/01_database.tar.gz
    fi
    if [ $DAY_OF_YEAR -eq 364 ] ; then
        cp `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_files.tar.gz `dirname $0`/tmp/${YEAR}/biannual/02_files.tar.gz
        cp `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_database.tar.gz `dirname $0`/tmp/${YEAR}/biannual/02_database.tar.gz
    fi
    echo 'Made biannual backup...'
fi

# Check If It Is The 14th Or 28th Day Of The Month Then Make A Bimonthly Backup
# If It Is By Copying The Weekly Backup To The Folder For The Current Month
if [ $DAY_OF_MONTH -eq 14 -o $DAY_OF_MONTH -eq 28 ] ; then
    if [ $DAY_OF_MONTH -eq 14 ] ; then
        cp `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_files.tar.gz `dirname $0`/tmp/${YEAR}/${MONTH}/01_files.tar.gz
        cp `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_database.tar.gz `dirname $0`/tmp/${YEAR}/${MONTH}/01_database.tar.gz
    fi
    if [ $DAY_OF_MONTH -eq 28 ] ; then
        cp `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_files.tar.gz `dirname $0`/tmp/${YEAR}/${MONTH}/02_files.tar.gz
        cp `dirname $0`/tmp/weekly/${DAY_OF_WEEK}_database.tar.gz `dirname $0`/tmp/${YEAR}/${MONTH}/02_database.tar.gz
    fi
    echo 'Made monthly backup...'
fi

# Merge The Backup To The Local Destination's Backup Folder
cp -rf `dirname $0`/tmp/* $DESTINATION

# Delete The Temporary Folder
rm -rf `dirname $0`/tmp
echo 'Made backup.'