#!/bin/bash
set -e
DMIMG="$0"
DMIMG="${DMIMG%/*}/dmimg"
if [ ! -x "$DMIMG" ]; then
	echo "ERROR: \"$DMIMG\" not found."
	exit 1
fi
if [ $# != 2 ]; then
	echo 'Usage:'
	echo "  $0 IMAGE_FILE SOURCE_DIR"
	echo 'Where:'
	echo "  IMAGE_FILE is an image file, supported by \"$DMIMG\"."
	echo '  SOURCE_DIR is a source directory to add files from.'
	exit 1
fi
IMAGEFILE="$1"
SOURCEDIR="$2"
SOURCEDIR="${SOURCEDIR%%/}/"
SCRIPTFILE=script.tmp
echo "Scanning directory \"$SOURCEDIR\"..."
rm -f "$SCRIPTFILE"
for i in `find "$SOURCEDIR" -depth -type d|sort`; do
	j="${i#$SOURCEDIR}"
	if [ -n "$j" ]; then echo "mkdir /$j">>"$SCRIPTFILE"; fi
done
for i in `find "$SOURCEDIR" -depth -type f|sort`; do
	echo "put $i /${i#$SOURCEDIR}">>"$SCRIPTFILE"
done
if [ -f "$SCRIPTFILE" ]; then
	echo "Adding files from directory \"$SOURCEDIR\" to the image \"$IMAGEFILE\"..."
	"$DMIMG" "$IMAGEFILE" conf "$SCRIPTFILE"
	rm -f "$SCRIPTFILE"
	echo "File \"$IMAGEFILE\" is successfully updated."
else
	echo "Nothing to add - skipping. File \"$IMAGEFILE\" was not modified."
fi
