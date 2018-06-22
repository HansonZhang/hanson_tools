#!/bin/sh
####Author: HansonZhang
#This tool is used to delete dumplicate lines in smali files.
#eg: const v0, 0x0
#    const v0, 0x1
#or:
#    const-string v0, ""
#    const-string v0, "Hello"
#

for file_item in `find . -name "*.smali"`
do
	
	lines=`cat "$file_item" | wc -l `
	i=1
	last_line=""
	last_line_number=0
	new_line=""
	echo "Deal $file_item lines=$lines"
	while [ $i -lt $lines ];
	do
		
		cur_line=`sed -n "$i p" "$file_item" | sed -r 's/\s+//g' `
	
		if [[ "$cur_line" = "" ]];then
			#echo "line $i empty"
			i=$((i+1))
			continue
		fi

		last_line_prefix=${last_line:0:5}
		prefix=${cur_line:0:5}
		if [[ "$prefix" != "const"  || "$last_line_prefix" != "const"  ]];then
			last_line="$cur_line"
			last_line_number=$i
			#echo "$prefix != $last_line_prefix "
			#echo "Not equal at lie $i"
			i=$((i+1))
			continue
		fi


		last_part1=`echo "$last_line" |awk -F "," '{print $1}' `
		last_part2=`echo "$last_line" |awk -F "," '{print $2}' `
		new_part1=`echo "$cur_line" |awk -F "," '{print $1}' `
		new_part2=`echo "$cur_line" |awk -F "," '{print $2}' `

		if [[ "$last_line" = "$cur_line" || "$last_part1" = "$new_part1" ]];then
			echo "Found equal line $i = $last_line_number . Remove it."
			echo "EQUAL\\\\\\\\\\\\\\"
			echo "$last_line"
			echo "$cur_line"
			echo "//////////"
			echo "$last_line_number"
			sed -i "$last_line_number d" "$file_item"
			lines=$((lines-1))
			last_line="$cur_line"
			last_line_number=$((i-1))
		fi
		last_line="$cur_line"
		last_line_number=$i
		i=$((i+1))
	done


done