#!/bin/bash 

###Variables about path or file name
CASEPATH=`pwd`
CASECSV=$CASEPATH/caseList.csv #csv file name
LISTTXT='caselist.txt' 
BEAUTY=$CASEPATH/beauty.sh

###Variables about Temporary files
TMP_DIR=$CASEPATH/tmp_$$
TMP_LIST=$TMP_DIR/tmp.caselist.$$
TMP_DIFF=$TMP_DIR/tmp.diff.$$
TMP_FAIL=$TMP_DIR/tmp.fail.$$
TMP_FAIL2=$TMP_DIR/tmp.fail2.$$
TMP_LOGIN=$TMP_DIR/tmp.login.$$

###Variables about Account information
ACCLIFE=1648604
ACCLIERP=5251314
ACCFIRE=1596892
HASHLIFE='38bf944bad42d835f4d3fcd8254aef88351b9b76a84985e6f4aaefb4dbc358ea2477d6bbeca5d42d53404a90215afd50f2d8c2a744b8d57c2909e0a30d3ee866'
HASHERP='2e530a8ecfb3048b01d52553650055cd97fa5f70bb351320b7bff3e879b84ffc0e0cd7f6519179bc08627e51227d28cf8719981ace2af75e3a1d0b1e6d3d6dc1'
HASHFIRE='72d341fc7d29482fa3d3f51ff5e5e2ee6f3e5544f97bba194a3c795defaebbe3365bb4f09a47e8ca16685f684a9f71afe5f4d011898312c4b7ae24d849c95d36'
HASHLIFE2='2e530a8ecfb3048b01d52553650055cd97fa5f70bb351320b7bff3e879b84ffc0e0cd7f6519179bc08627e51227d28cf8719981ace2af75e3a1d0b1e6d3d6dc1'
HASHERP2='569ad3ea0347bad8e042f4f3a11171d4b7ece74745d96892fdc474cb570cf1183aa62762646a4ad291778e5c33a769eeb310393b74d92729a0434b0a829d506d'
HASHFIRE2='f822e61b777f115cde69e154ad0335119590471f8f7d52e46669df64805d0ceb29ca4480be9ba80f7939212292febee0ff05386eeb799b065ff134a255e65eb4'

###Variables about SCP transmission
RUSER='root'
RADDR='10.1.0.177'
RPATH='/data/REPO/casefile'

### Functions for exiting with removing tmp files
function exiting(){
	rm -rf $TMP_DIR
	exit
}

########################
### Functions for Print
########################

function print_login(){
printf "
==================================
  \033[1;31mREDAHT CASE ARRAGNEMENT SCRIPT\033[0m
  	  ver 1.2.2
  	  by OS team
	  Taemoo Heo
==================================\n"

read -p "REDAHT ID : " USERID
printf  "REDHAT PW : "
read -s USERPASS
printf  "\n"

HASHID=`echo $USERID | sha512sum | awk '{print $1}'`
HASHPW=`echo $USERPASS | sha512sum | awk '{print $1}'`
HASHTRY="${HASHID}${HASHPW}"
}

function print_download(){
printf "
=== Start Donwloading Cases ===\n"

}

function print_end(){
printf "\033[1;31mWell Done\033[0m\n"
}

function print_OK(){
	printf "[\033[1;32mOK\033[0m]\n"
}

function print_fail(){
	printf "[\033[1;31mFail\0rr[0m]\n"
}

##########################
### Functions for Checking
##########################

function check_csv(){
	if [ ! -f $CASECSV ]
	then
		printf "
ERROR
You need this file ::: %s\n" $CASECSV
		exiting
	fi
}

function check_account(){
	ACCOUNTNU=`sed '1d' $CASECSV | awk -F "," '{print $1}' | uniq`
	if [ $ACCOUNTNU == $ACCLIERP ]
	then
		CASEDIR="${CASEPATH}/life_erp"
		HASHVAL="${HASHERP2}${HASHERP}"
	elif [ $ACCOUNTNU == $ACCFIRE ]
	then
		CASEDIR="${CASEPATH}/fire"
		HASHVAL="${HASHFIRE}${HASHFIRE2}"
	elif [ $ACCOUNTNU == $ACCLIFE ]
	then
		CASEDIR="${CASEPATH}/life"
		HASHVAL="${HASHLIFE}${HASHLIFE2}"
	else
		printf "
ERROR
Undefined Account number
Check %s\n" $CASECSV
		exiting
	fi
}

function check_login_ok(){
	if [ "${HASHTRY}" != "${HASHVAL}" ]
	then
		printf "\n\033[1;31mLogin Failed!!!!!!!\033[0m\nCheck your ID or PW\n"
		exiting
	else
		printf "\n\033[1;32mLogin Success!!\033[0m\n"
	fi
}

function check_dir(){
	if [ ! -d $CASEDIR ]
	then
		mkdir $CASEDIR
	fi
}

function check_new_case(){
	if [ `cat $TMP_DIFF | wc -l ` -eq 0 ]
	then
		printf "\nNOTICE\nThere are no new closed cases\n"
		exiting
	fi
}

function check_down_ok(){
	if [ ! $? -eq 0 ]
	then
		echo $CASEADDR >> $1
		print_fail
	else
		print_OK
	fi
}

function check_failed(){
	while [ -f $TMP_FAIL ]
	do
		echo "${i} retry..."
		for j in `cat $TMP_FAIL`
		do
		do_download_case $TMP_FAIL $TMP_FAIL2	
		done

		if [ -f $TMP_FAIL2 ]
		then
			mv $TMP_FAIL2 $TMP_FAIL
		else
			mv $TMP_FAIL ${TMP_FAIL}.ok
		fi
	done
}

##############################
### Functions for making files
##############################

function mk_tmpdir(){
	mkdir $TMP_DIR
	chmod 700 $TMP_DIR
}

function mk_listtxt(){
	ls -1 $CASEDIR/*.html 2> /dev/null | awk -F "/" '{print $NF}' | awk -F "." '{print $1}' | sort > $CASEDIR/$LISTTXT
}

function mk_tmpfiles(){
	sed '1d' $CASECSV | grep -v 'Waiting on' | awk -F "," '{print $2}' | sort > $TMP_LIST
	diff $CASEDIR/$LISTTXT $TMP_LIST | sed -n '/>/p' | awk -F " " '{print $2}' > $TMP_DIFF
}

########################
### Functions for action
########################

function do_download_case(){
for i in `cat $1`
do
	printf "${i} Download..."
	CASEADDR=`awk -F "," -v CASE=$i '{if($2==CASE){print $14}}' $CASECSV`
	curl -u ${USERID}:${USERPASS} $CASEADDR -o $TMP_DIR/${i}.html &> /dev/null
	
	check_down_ok $2
done
}

function do_beauty(){
	for i in `cat $TMP_DIFF`
	do
		printf "%s is being arranged..." $i
		$BEAUTY $TMP_DIR/${i}.html
	if [ $? -eq 0 ]
	then
		print_OK
	else
		print_fail
	fi
done
}

function do_scp_transmission(){
#### DO NOT USE this function
#### IF YOU DO NOT COPY YOUR
#### SSH KEYGEN TO SCP SERVER
RDIR=`echo $CASEDIR | awk -F "/" '{print $NF}'`
	printf "CASEs are transmiting to %s..." $RADDR
	scp  $TMP_DIR/*html $RUSER@$RADDR:$RPATH/$RDIR &> /dev/null
	if [ -$? -eq 0 ]
	then
		print_OK
	else
		print_fail
	fi
}

function do_arrange(){
mv $TMP_DIR/*html $CASEDIR
mv $TMP_LIST $LISTTXT
mv $CASECSV $CASEDIR
}

######################
#### Start Script ####
######################

check_csv
mk_tmpdir
check_account
print_login
check_login_ok
check_dir
mk_listtxt
mk_tmpfiles
check_new_case
print_download
do_download_case $TMP_DIFF $TMP_FAIL
check_down_ok
do_beauty
#do_scp_transmission
do_arrange
print_end
exiting

