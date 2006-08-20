#
# This script copies the Nib files from English.lproj folder to all
# localization folders and calls nibtool to localize them
#

# for every language
for LANG in `cat $PROJECT_DIR/Localizations`
do

  # remove from version control
  /usr/local/bin/svn del $PROJECT_DIR/$LANG.lproj/*.nib

  # for every Nib file in English.lproj
  for NIB in `ls -d $PROJECT_DIR/English.lproj/*.nib`
  do
    # copy to language folder
    cp -fR $NIB $PROJECT_DIR/$LANG.lproj/

    # get Nib name
    NIB_NAME=`echo $NIB | awk 'BEGIN { FS = "/|.nib" } \
       { printf $(NF-1) }' -`

    # move to language folder
    cd $PROJECT_DIR/$LANG.lproj

    # localize the file
    nibtool -w _$NIB_NAME.nib -d $NIB_NAME.strings $NIB_NAME.nib

    # remove old Nib
    rm -rf $NIB_NAME.nib

    # rename new Nib
    mv _$NIB_NAME.nib $NIB_NAME.nib
  done

  # put under version control
  /usr/local/bin/svn add $PROJECT_DIR/$LANG.lproj/*.nib

done