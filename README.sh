#!/usr/bin/env bash

clear

echo "설명을 원하는 알파벳을 입력 후 엔터를 누르세요."

read sel

case "$sel" in
	"A" | "a" )
		echo "A"
		;;
	"B" | "b" )
		echo "B"
		;;
	* )
		echo "Error!"
		;;
esac

exit 0
