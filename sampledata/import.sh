tar -zxf mailboxes.tar.gz
rake --trace import:dirs rootdir=sampledata/mailboxes
rm -fR mailboxes