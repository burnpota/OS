#!/bin/sh

echo "
===========================
삼성생명 CASE 검색 스크립트
        
		ver 0.1
===========================

제목 검색 : 1
내용 검색 : 2
종료      : q
"


while :
do

	read -p "선택 : " i
	read -p "검색어를 입력하시오 : " SEARCH
	case $i in
	1)
		sed '1d' caseList.csv | grep -v 'Waiting on' | grep $SEARCH | awk -F "," '{print $2 ":" $13}'
		break;;
	2)
		grep $SEARCH ` ls -1 ./casefile/*.html` | awk -F ":" '{print $1}'
		echo "해당 파일로 들어가서 확인하시오"
		break;;
	*)
		echo "exiting"
		break;;
	esac
done


