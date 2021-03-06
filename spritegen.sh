# Make the script exit if any of the commands executed here return error
set -e

cleanup_names()
{
    rename -v 'y/A-Z/a-z/' *.png
    rename -v 's/ /-/g' *.png
}

generate_src_css()
{
    for file in $(ls *.png)
    do
        filebasename=$(basename $file .png)
        wd=$(pwd)
        dimensions=$(file $file | grep -o '\([0-9]\+\)\ x\ \([0-9]\+\)')
        width=$(echo "${dimensions}" | awk '{print $1}')
        height=$(echo "${dimensions}" | awk '{print $3}')
        echo '.sp-'$filebasename' {'
        echo '  background: url("'$wd'/'$file'") no-repeat;'
        echo '  width: '$width'px;'
        echo '  height: '$height'px;'
        echo '}'\\n
    done
}

if [ $# -eq 0 ]
then
    echo "No arguments passed."
    echo "Usage: sh spritege.sh <path to folder containing source images>"
    exit 1
fi

hash spritemapper 2>&- || {
    echo >&2 "Spritemaper is not installed in your machine.\nIt can be installed from https://github.com/yostudios/Spritemapper.\nAborting."
    exit 1
}
hash trimage 2>&- || {
    echo >&2 "trimage is not installed on your machine.\nSee http://trimage.org/ for the installation procedure.\nAborting."
    exit 1
}

cd $1
path=${PWD}
fname=${PWD##*/}

echo "Source folder: $path"
echo "Cleaning up image filenames to remove whitespaces and make them all-lowercase..."
cleanup_names

echo "Creating source CSS..."
generate_src_css > $fname.css
echo "Source CSS created at $path/$fname.css\n\n"

echo "Creating sprite..."
spritemapper $path/$fname.css
echo "\n\n"

echo 'Compressing sprite image using trimage... (Ignore errors like "<given file> not a supported image file and/or not writeable")'
cd ../
trimage -f $fname.png
echo "\nCompleted!"
