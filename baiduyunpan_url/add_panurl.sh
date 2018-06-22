#!/bin/sh
file_pan_output=$2
file_no_pan_url=$1
ROM_OUTPUT_FILE_INFO=${file_no_pan_url:0:-4}_pan.txt
ROM_OUTPUT_FILE_INFO_NOPAN=${file_no_pan_url:0:-4}_nopan.txt

function get_pan_url()
{
	rom_name=$1
	echo `grep "$rom_name"  "$file_pan_output" | awk '{print $2}' | head -1 `
}


if [[ $# -lt 2 ]];then
	echo "This is used to add baidu yun url to the original size_md5 file"
	echo "usage: $0 <md5 file> <pan url file>"
	exit 1
fi

echo "md5 file: $file_no_pan_url"
echo "pan file: $file_pan_output"

if [[ ! -f $file_pan_output || ! -f $file_no_pan_url ]];then
	echo "wrong arguments"
	exit 1
fi

dos2unix $file_no_pan_url $file_pan_output

cat $file_no_pan_url | while read line
do
	rom_size=`echo "$line" | awk '{print $1}'`
	rom_md5=`echo "$line" | awk '{print $2}'`
	rom_infokey=`echo "$line" | awk '{print $3}'`
	rom_androidversion=`echo "$line" | awk '{print $4}' `
	rom_systemversion=`echo "$line" | awk '{print $5}' `
	rom_versionstatus=`echo "$line" | awk '{print $6}' `
	rom_date=`echo "$line" | awk '{print $7}' `
	rom_filename=`echo "$line" | awk '{print $8}' `
	rom_platform=`echo "$line" | awk '{print $9}' `
	rom_pan_url=`echo "$line" | awk '{print $10}' `
	if [[ "$rom_pan_url" = "" ]];then
		rom_pan_url=$(get_pan_url "$rom_filename")
	fi
	if [[ "$rom_infokey" = "NULL" ]];then
		continue
	fi

	if [[ "$rom_pan_url" = "" ]];then
		printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$rom_size"	"$rom_md5" "$rom_infokey" "$rom_androidversion" "$rom_systemversion" "$rom_versionstatus" "$rom_date" "$rom_filename" "$rom_platform">>$ROM_OUTPUT_FILE_INFO_NOPAN
	fi

	printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$rom_size"	"$rom_md5" "$rom_infokey" "$rom_androidversion" "$rom_systemversion" "$rom_versionstatus" "$rom_date" "$rom_filename" "$rom_platform" "$rom_pan_url">>$ROM_OUTPUT_FILE_INFO
done


