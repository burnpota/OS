#!/bin/sh

CASEPATH=`pwd`

#grep "case_list_man.sh" /etc/crontab &> /dev/null
#if [ $? -eq 1 ]
#then
#	echo " 00 12 * * 1 root $CASEPATH/case_list_man.sh " >> /etc/crontab
#fi
echo -e "
==============================
\e[1;31mREDAHT CASE ARRAGNEMENT SCRIPT\e[0m
         ver 1.1
		by OS team 
		Taemoo Heo
==============================
"
read -p "REDAHT ID : " USERID
echo -n "REDHAT PW : "
read -s USERPASS
echo ""

if [ ! -f $CASEPATH/caseList.csv ]
then
	echo ""
	echo "ERROR"
	echo "You need this file ::: caseList.csv "
	echo ""
	exit
fi

ACCOUNTNU=`sed '1d' caseList.csv | awk -F "," '{print $1}' | uniq`
if [ $ACCOUNTNU == 5251314 ]
then
	CASEDIR=life_erp
elif [ $ACCOUNTNU == 1596892 ]
then
	CASEDIR=fire
elif [ $ACCOUNTNU == 1648604 ]
then
	CASEDIR=life
else
	echo ""
	echo "ERROR"
	echo "Undefined Account number"
	echo "Check caseList.csv"
	echo ""
fi

if [ ! -d $CASEPATH/$CASEDIR/ ]
then
	mkdir $CASEPATH/$CASEDIR/
fi

if [ ! -f $CASEPATH/caselist.txt ]
then
	if [ -f $CASEPATH/$CASEDIR/*.html ]
	then
		ls -1 $CASEPATH/$CASEDIR/*.html | awk -F "." '{print $1}' | sort >> caselist.txt	
	else
		touch caselist.txt
	fi
fi

sed '1d' caseList.csv | grep -v 'Waiting on' | awk -F "," '{print $2}' | sort > tmp.caselist.txt
diff caselist.txt tmp.caselist.txt | sed -n '/>/p' | awk -F " " '{print $2}' > tmp.difflist.txt

if [ `cat tmp.difflist.txt | wc -l ` -eq 0 ]
then
	echo ""
	echo " NOTICE"
	echo " There are no new closed cases"
	echo ""
	exit
fi

echo ""
echo "=== Start Case donwloading ==="
for i in `cat tmp.difflist.txt`
do
	echo -n "${i} Download..."
	CASEADDR=`awk -F "," -v CASE=$i '{if($2==CASE){print $14}}' caseList.csv`
	curl -u ${USERID}:${USERPASS} $CASEADDR -o $CASEPATH/$CASEDIR/${i}.html &> /dev/null

	if [ ! $? -eq 0 ]
	then
		echo $CASEADDR >> failed_list.txt
		echo -e "[\e[1;31mFail\e[0m]"
	else
		echo -e "[\e[1;32mOK\e[0m]"
	fi

	while [ -f failed_list.txt ]
	do
		echo "${i} retry..."
		for j in `cat failed_list.txt`
		do
			curl -u ${USERID}:${USERPASS} $j -o $CASEPATH/$CASEDIR/${i}.html &> /dev/null
			if [ ! $? -eq 0 ]
			then
				echo $CASEADDR >> failed_list2.txt
				echo -e "[\e[1;31mFail\e[0m]"
			else
				echo -e "[\e[1;32mOK\e[0m]"
			fi
		done

		if [ -f failed_list2.txt ]
		then
			mv failed_list2.txt failed_list.txt
		else
			rm -f failed_list.txt
		fi
	done
done

cd $CASEPATH/$CASEDIR
for i in `ls -1 ./*.html`
do
	sh ../beauty.sh $i
	echo "${i} has been arranged successfully"
done

cd ..
rm -f tmp.difflist.txt
mv tmp.caselist.txt caselist.txt
chmod 600 caselist.txt
mv caseList.csv $CASEPATH/$CASEDIR
echo ""
echo -e "\e[1;31mWell Done\e[0m"
echo ""
