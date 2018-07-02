## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2016.11.17
## Default source Directory
#!/bin/bash

#RTS_HOMES=/home/maxgauge/rts
RTS_HOMES=/home/gitlab-runner/rts
PJS_HOME=/home/gitlab-runner/pjs8080
#DG_HOMES 하위경로에 DGServer_M, DGServer_S1 폴더가 있다고 가정함
DG_HOMES=/home/gitlab-runner/dg7000
DGM_HOME=/home/gitlab-runner/dg7000/DGServer_M
DGS_HOME=/home/gitlab-runner/dg7000/DGServer_S1
OLDONE=/home/gitlab-runner/.oldone
WORKING_DIR=`pwd`

USERS_CONF()
{
case $1 in
FDG) RTSES_CONF="FDG20 FDG24" ;;
dev) RTSES_CONF="DEVQA1 DEVQA2 DEVQA3 DEVQA4 DEVQA5" ;;
*) echo -e " \"$1\" is not registered CONF_NAME."; exit ;;
esac
}

USER_INFO()
{
WHO=QA_BSH
PART=REPO
}

MFO_TAG_INFO()
{
MFONP unipjs_170720.02 170720_13:20:59 U
MFOWEB mfoweb_170725.01 170725_14:44:18 U
MFOSQL mfosql_170721.02 170725_14:44:18 U
MFODG mfodg_170920.01 171012_10:36:43 H
}

SET_INSTALL_VARIABLES_DG ()
{
#DEFAULT ARRAY START AT 0
#DGM_INFO
VALUE_NAME[1]="DGM_CONF_NAME" ;     DEFAULT_SET[1]="DG_NAME=DG_M";
VALUE_NAME[2]="DGS_CONF_NAME" ;     DEFAULT_SET[2]="DG_NAME=DG_S1";
VALUE_NAME[3]="DGM_PORT" ;          DEFAULT_SET[3]="7000";
VALUE_NAME[4]="DGS_LIST" ;          DEFAULT_SET[4]="127.0.0.1:7001";
VALUE_NAME[5]="REPO_TYPE" ;         DEFAULT_SET[5]="oracle";
VALUE_NAME[6]="REPO_IP" ;           DEFAULT_SET[6]="127.0.0.1";
VALUE_NAME[7]="REPO_PORT";          DEFAULT_SET[7]="1521";
VALUE_NAME[8]="REPO_SID" ;          DEFAULT_SET[8]=`env | grep ORACLE_SID | awk -F "=" '{print $2}'`;
VALUE_NAME[9]="REPO_USER_ID";       DEFAULT_SET[9]="c##maxgauge";
VALUE_NAME[10]="REPO_USER_PASSWORD";DEFAULT_SET[10]="maxgauge";
VALUE_NAME[11]="TABLESPACE" ;       DEFAULT_SET[11]="USERS";
VALUE_NAME[12]="INDEX_TABLESPACE" ; DEFAULT_SET[12]="USERS";
#DGS_INFO
VALUE_NAME[13]="DGS_PORT" ;         DEFAULT_SET[13]="7001";
#MXGRC_INFO
VALUE_NAME[14]="DGM_HOME" ;         DEFAULT_SET[14]="MXG_HOME=/home/maxgauge/DGServer_M/";
VALUE_NAME[15]="DGS_HOME" ;         DEFAULT_SET[15]="MXG_HOME=/home/maxgauge/DGServer_S1/";
VALUE_NAME[16]="OS_TYPE" ;          DEFAULT_SET[16]="OS_TYPE=linux64";
}

PARSING_DATA_FOR_DG_PATCH()
{
# FIND_KEYWORD will be parsed in the .mxgrc & DGServer.xml when processing patch.
#DGM_INFO
FIND_KEYWORD[3]="gather_port";        #DGM_IP
FIND_KEYWORD[4]="slave_gather_list";  #DGS_LIST
FIND_KEYWORD[5]="database_type";      #DB_TYPE
FIND_KEYWORD[6]="database_ip";        #REPO_IP
FIND_KEYWORD[7]="database_port";      #REPO_PORT
FIND_KEYWORD[8]="database_sid";       #REPO_SID
FIND_KEYWORD[9]="database_user";      #REPO_USER_ID
FIND_KEYWORD[10]="database_password"; #REPO_USER_PW
FIND_KEYWORD[11]="tablespace";        #TABLESPACE
FIND_KEYWORD[12]="index_tablespace";  #INDEX_TABLESPACE
#DGS_INFO
FIND_KEYWORD[13]="gather_port";       #DGS_PORT
#MXGRC_INFO
FIND_KEYWORD[1]="DG_NAME=";           #DG_M_NAME
FIND_KEYWORD[2]="DG_NAME=";  	      #DG_S1_NAME
FIND_KEYWORD[14]="MXG_HOME=";         #DGM_HOME
FIND_KEYWORD[15]="MXG_HOME=";         #DGS_HOME
FIND_KEYWORD[16]="OS_TYPE=";          #OS_TYPE


# FIND_KEYWORD will be parsed in DGServer.xml(DGM) when processing patch.
for i in 3 4 5 6 7 8 9 10 11 12
do
	CHECK_VAR=`cat $DGM_HOME/conf/DGServer.xml | grep -w ${FIND_KEYWORD[$i]} | awk -F ">" '{print $2}' | awk -F "<" '{print $1}'`; ## sed s/${FIND_KEYWORD[$i]}/*/g | tr -d '</*>' | tr -d ' '`
	if [ ${CHECK_VAR} ]; then DEFAULT_SET[$i]=$CHECK_VAR; fi;
done

# FIND_KEYWORD will be parsed in DGServer.xml(DGS) when processing patch.
	DEFAULT_SET[13]=`cat $DGS_HOME/conf/DGServer.xml | grep -w ${FIND_KEYWORD[13]} | sed s/${FIND_KEYWORD[13]}/*/g | tr -d '</*>' | tr -d ' '`
# FIND_KEYWORD will be parsed in .mxgrc when processing patch.
	DEFAULT_SET[1]=`cat $DGM_HOME/.mxgrc | grep ${FIND_KEYWORD[1]}`
	DEFAULT_SET[2]=`cat $DGS_HOME/.mxgrc  | grep ${FIND_KEYWORD[2]}`
	DEFAULT_SET[14]=`cat $DGM_HOME/.mxgrc | grep ${FIND_KEYWORD[14]}`
	DEFAULT_SET[15]=`cat $DGS_HOME/.mxgrc  | grep ${FIND_KEYWORD[15]}`
	DEFAULT_SET[16]=`cat $DGM_HOME/.mxgrc  | grep ${FIND_KEYWORD[16]}`
}

SET_INSTALL_VARIABLES_RTS ()
{
#DEFAULT ARRAY START AT 0
VALUE_NAME[1]="ORACLE_OWNER" ;   DEFAULT_SET[1]="oracle";
VALUE_NAME[2]="CONFIG_NAME" ;    DEFAULT_SET[2]="$ONE_OF_CONFS";
VALUE_NAME[3]="IPC_KEY" ;        DEFAULT_SET[3]="4";
VALUE_NAME[4]="PMON" ;        	 DEFAULT_SET[4]="1";
VALUE_NAME[5]="LISTNER_CHECK" ;  DEFAULT_SET[5]=":::1521";
VALUE_NAME[6]="RTS_PORT" ;       DEFAULT_SET[6]="5080";
VALUE_NAME[7]="DGS_IP";   		 DEFAULT_SET[7]="127.0.0.1";
VALUE_NAME[8]="DGS_PORT" ;    	 DEFAULT_SET[8]="7001";
VALUE_NAME[9]="ORACLE_PW" ;      DEFAULT_SET[9]="oracle";
VALUE_NAME[10]="MAXGAUGE_USER" ; DEFAULT_SET[10]="c##maxgauge";
VALUE_NAME[11]="MAXGAUGE_PW" ;   DEFAULT_SET[11]="maxgauge";
VALUE_NAME[12]="TABLESPACE" ;    DEFAULT_SET[12]="USERS";
VALUE_NAME[13]="TEMP_TABLESPACE";DEFAULT_SET[13]="TEMP";
VALUE_NAME[14]="XM_VIEW" ; 		 DEFAULT_SET[14]="y";
VALUE_NAME[15]="RTS_CONF" ;      DEFAULT_SET[15]="y";
VALUE_NAME[16]="PASSWD_FILE";    DEFAULT_SET[16]="2";
VALUE_NAME[17]="RUN_BY_SYS" ;    DEFAULT_SET[17]="y";
VALUE_NAME[18]="EXPKG" ;     	 DEFAULT_SET[18]="y";
VALUE_NAME[19]="MAKE_ENV" ;    	 DEFAULT_SET[19]="y";
VALUE_NAME[20]="LIST_CONF" ;     DEFAULT_SET[20]="y";
}

SET_INSTALL_VARIABLES_PJS ()
{
#DEFAULT ARRAY START AT 0
VALUE_NAME[1]="DGM_IP" ;             DEFAULT_SET[1]="127.0.0.1";
VALUE_NAME[2]="DGM_PORT" ;           DEFAULT_SET[2]="7000";
VALUE_NAME[3]="DB_TYPE(1:PG/2:ORA)"; DEFAULT_SET[3]="2";
VALUE_NAME[4]="REPO_IP" ;            DEFAULT_SET[4]="127.0.0.1";
VALUE_NAME[5]="REPO_PORT" ;          DEFAULT_SET[5]="1521";
VALUE_NAME[6]="REPO_SID" ;           DEFAULT_SET[6]=`env | grep ORACLE_SID | awk -F= '{print $2}'`;
VALUE_NAME[7]="MAXGAUGE_USER";       DEFAULT_SET[7]="c##maxgauge";
VALUE_NAME[8]="MAXGAUGE_PW" ;        DEFAULT_SET[8]="maxgauge";
VALUE_NAME[9]="SERV_PORT" ;          DEFAULT_SET[9]="8080";

# FIND_KEYWORD will be parsed in the config.json when processing patch.
FIND_KEYWORD[1]="datagather_ip";     #DGM_IP
FIND_KEYWORD[2]="datagather_port";   #DGM_PORT
FIND_KEYWORD[3]="database_type";     #DB_TYPE
FIND_KEYWORD[4]="database_server";   #REPO_IP
FIND_KEYWORD[5]="database_port";     #REPO_PORT
FIND_KEYWORD[6]="database_database"; #REPO_SID

for i in 1 2 3 4 5 6
do
	CHECK_VAR=`cat $PJS_HOME/config/config.json | grep ${FIND_KEYWORD[$i]} | awk -F ":" '{print $2}' | tr -d ' ' | tr -d '"' | tr -d ','`
	if [ ${CHECK_VAR} ]; then DEFAULT_SET[$i]=$CHECK_VAR; fi;
done

if [ "${DEFAULT_SET[3]}" = "Postgresql" ]; then DEFAULT_SET[3]=1; else DEFAULT_SET[3]=2; fi
}

PARSING_DATA_FOR_RTS_PATCH()
{
# FIND_KEYWORD will be parsed in the config.json when processing patch.
FIND_KEYWORD[6]="daemon_port";     #RTS_PORT
FIND_KEYWORD[8]="wr_port";         #DGS_PORT
FIND_KEYWORD[7]="wr_host";         #DGS_IP

# FIND_KEYWORD will be parsed in rts.conf when processing patch.
for i in 6 7 8
do
	CHECK_VAR=`cat $THIS_RTS_HOME/conf/$ONE_OF_CONFS/rts.conf | grep -w ${FIND_KEYWORD[$i]} | awk -F "=" '{print $2}' | tr -d ' '`
	if [ ${CHECK_VAR} ]; then DEFAULT_SET[$i]=$CHECK_VAR; fi;
done
}

SET_INSTALL_VARIABLES_RTS_MULTI_REGISTER ()
{
#DEFAULT ARRAY START AT 0
VALUE_NAME[1]="NAME_RTSES[At_least_3_Character]";  DEFAULT_SET[1]="TEST";
VALUE_NAME[2]="COUNT_OF_RTSES";                    DEFAULT_SET[2]="3";
VALUE_NAME[3]="RTS_PORT_OF_FIRST_ONE";             DEFAULT_SET[3]="5081";
}

SET_INSTALL_VARIABLES_MFOTAG ()
{
# DEFAULT ARRAY START AT 0              
VALUE_NAME[1]="MFONP" ;                 DEFAULT_SET[1]="x";
VALUE_NAME[2]="MFOWEB" ;                DEFAULT_SET[2]="x";
VALUE_NAME[3]="MFOSQL";                 DEFAULT_SET[3]="x";
VALUE_NAME[4]="MFODG" ;                 DEFAULT_SET[4]="x";
VALUE_NAME[5]="ONLY_[U]_UPDATE";        DEFAULT_SET[5]="x";
VALUE_NAME[6]="SELECT_PACKAGE_VERSION"; DEFAULT_SET[6]="x";
VALUE_NAME[7]="CONFIG_UPDATE_SETTING";  DEFAULT_SET[7]="x";
VALUE_NAME[8]="MAKE_BASELINE" ;         DEFAULT_SET[8]="x";

# FIND_KEYWORD will be parsed in the config.json when processing patch.
FIND_KEYWORD[1]="MFONP";
FIND_KEYWORD[2]="MFOWEB";
FIND_KEYWORD[3]="MFOSQL";
FIND_KEYWORD[4]="MFODG";

for i in 1 2 3 4
do      
        CHECK_VAR=`head -$END_L $0 | tail -$PAGES_L | grep "${FIND_KEYWORD[$i]}" | awk '{print $2}'`
        if [ ${CHECK_VAR} ]; then DEFAULT_SET[$i]=$CHECK_VAR; INIT_VAR[$i]=$CHECK_VAR; fi;
done
}

SET_INSTALL_VARIABLES_MFO_BASELINE ()
{
# DEFAULT ARRAY START AT 0              
VALUE_NAME[1]="MFONP" ;                 DEFAULT_SET[1]="x";
VALUE_NAME[2]="MFOWEB" ;                DEFAULT_SET[2]="x";
VALUE_NAME[3]="MFOSQL";                 DEFAULT_SET[3]="x";
VALUE_NAME[4]="MFODG" ;                 DEFAULT_SET[4]="x";
VALUE_NAME[5]="MFORTS";                 DEFAULT_SET[5]="x";
VALUE_NAME[6]="MFOBUILD";               DEFAULT_SET[6]="x";
VALUE_NAME[7]="5_6_NOT_CHANAGEABLE";   DEFAULT_SET[7]="x";
VALUE_NAME[8]="MAKE_BASELINE" ;         DEFAULT_SET[8]="x";
}

SHOW_MFO_ENVIROMENT_INFO()
{
TAG_KEY[1]="MFONP"
TAG_KEY[2]="MFOWEB"
TAG_KEY[3]="MFOSQL"
TAG_KEY[4]="MFODG"
START_L=`grep -n "MFO_TAG_INFO" -m 1 $0 | awk -F ":" '{print $1}'`
START_L=`expr $START_L + 1`
END_L=`expr $START_L + 4`
PAGES_L=`expr $END_L - $START_L`

echo -e "\n\t\t\t\033[33m<MFO Environment Info>\033[m\n \033[36mCOMP_PART\tTAG_VALUE \t\t\t[PATCH DATE]\t  [H/U]\033[m"
for i in 1 2 3 4
do
        TAG_VALUE[$i]=`head -$END_L $0 | tail -$PAGES_L  | grep ${TAG_KEY[$i]} | awk '{print $2}'`;
        DATE_VALUE[$i]=`head -$END_L $0 | tail -$PAGES_L | grep ${TAG_KEY[$i]} | awk '{print $3}'`;
        HOLD_OR_UP_TO_DATE[$i]=`head -$END_L $0 | tail -$PAGES_L | grep ${TAG_KEY[$i]} | awk '{print $4}'`;
        if [ ${#TAG_VALUE[$i]} -gt 17 ]; then TAG_GAP=""; else TAG_GAP="\t";  fi
        echo -e " [$i] ${TAG_KEY[$i]}\t[ ${TAG_VALUE[$i]} ]\t$TAG_GAP[${DATE_VALUE[$i]}] [ ${HOLD_OR_UP_TO_DATE[$i]} ]";
done
}

MAKE_USER_CONF()
{
SHOW_AND_CHOICE_RTSES
START_L=`grep -n "USERS_CONF" -m 1 $0 | awk -F ":" '{print $1}'`
START_L=`expr $START_L + 2`

	echo -e " NAME YOUR CONFS..!"
	read USER_CONF_NAME
	echo -e  "$USER_CONF_NAME=\"${USER_CONF[@]}\""
	ATTACHMENT="$USER_CONF_NAME) RTSES_CONF=\"${USER_CONF[@]}\" ;;"
	sed -e "$START_L a$ATTACHMENT" $0 > .mxctl.sh
	echo -e "SAVING CONF_NAME Start ======================= ";
	echo -e  "sleep 1\nmv .mxctl.sh $0\nrm -rf mxctlsaver.sh" >> mxctlsaver.sh
	echo -e  "chmod 775 $0" >> mxctlsaver.sh
	echo -e  "echo -e  SAVING CONF_NAME FINISH ======================" >> mxctlsaver.sh
	echo -e  "sh $0" >> mxctlsaver.sh
	sh mxctlsaver.sh
#to escape error, not found confname just made.	
	exit;
}

SHOW_AND_CHOICE_RTSES()
{
GET_TOTAL_RTS_LIST
CHOICE=" "
unset USER_CONF
	while true
	do
		if [ "${CHOICE}" = "" ]; then
		break
		fi

		echo -e  "\n Select RTS DAEMONS YOU NEED..! from the list.":
		for i in `seq 1 ${#cnt[@]}`
		do
			echo -e  " [ ${SELECT[$i]} ]\t[$i]\t${UR_CONF_NAME[$i]}";
		done

		echo -e " 1. Choice the number of confnames with space ' ' between each one"
		echo -e " 2. After choice, then Press 'ENTER'"
		read -a CHOICE
		for (( x=0; x<=${#cnt[@]}; x++));
		do
				SELECT[${CHOICE[$x]}]='V'
		done;
	done

	for z in `seq 1 ${#cnt[@]}`
	do
		if [ "${SELECT[$z]}" = "V" ]; then
			USER_CONF+=(${UR_CONF_NAME[$z]})
		fi
	done
}

GET_TOTAL_RTS_LIST()
{
	unset cnt
	unset SELECT
	RTS_HOME=' '
	SELECT=' '
	for UR_CONF_NAME in `ls $RTS_HOMES`
	do
		if [ -d $RTS_HOMES/$UR_CONF_NAME/conf/$UR_CONF_NAME ];
		then
			UR_CONF_NAME+=($UR_CONF_NAME)
			RTS_HOME+=($RTS_HOMES/$UR_CONF_NAME)
			SELECT+=(' ')
			cnt+=(' ')
		fi
	done
}

RTS_STATUS_CHECK()
{
	GET_TOTAL_RTS_LIST
	UNSET_STATUS_CHECK_VAR
	echo -e  "\n\t\t\t\033[33m<RTS STATUS CHECK>\033[m\n \033[36mCONF NAME\t\tSPACE  STATUS  PID  Serv_PORT\tDGS_INFO\033[m"
	for i in `seq 1 ${#cnt[@]}`
	do
		SERVICE_PORT=`cat ${RTS_HOME[$i]}/conf/${UR_CONF_NAME[$i]}/rts.conf | grep -w daemon_port | awk -F "=" '{print $2}' | tr -d ' '`
		DGS_PORT=`cat ${RTS_HOME[$i]}/conf/${UR_CONF_NAME[$i]}/rts.conf | grep -w wr_port | awk -F "=" '{print $2}' | tr -d ' '`
		DGS_IP=`cat ${RTS_HOME[$i]}/conf/${UR_CONF_NAME[$i]}/rts.conf | grep -w wr_host | awk -F "=" '{print $2}' | tr -d ' '`
		PID=`ps -ef | grep -w ${UR_CONF_NAME[$i]} | grep -w mxg_rts | awk '{print $2}'`
		SPACE=`du -sh  $RTS_HOMES/${UR_CONF_NAME[$i]} | awk '{print $1}'`
		if [ "$SPACE" = "1.1G" ]; then SPACE="\033[33m$SPACE\033[m"; fi
		if [ -z "$PID" ]; then STATUS="X"; PID="     "; else STATUS="O" ; fi
		if [ ${#PID} -lt 5 ]; then GAB=0  PID=($GAB$PID); fi
		if [ ${#UR_CONF_NAME[$i]} -lt 10 ]; then tab='\t\t'; else tab='\t'; fi
		if [ $i -lt 10 ]; then GAP2=" "; else GAP2="";  fi
		echo -e  " [$i]$GAP2 ${UR_CONF_NAME[$i]}$tab[$SPACE]\t[ $STATUS ][${PID}] [${SERVICE_PORT}] [$DGS_IP:$DGS_PORT]";
	done
}

GET_TOTAL_DG_LIST()
{
	unset cnt
	unset SELECT
	DG_HOME=' '
	for DG_COMF_NAME in `ls $DG_HOMES`
	do
		if [ -f $DG_HOMES/$DG_COMF_NAME/conf/DGServer.xml ];
		then
			DG_COMF_NAME+=($DG_COMF_NAME)
			DG_HOME+=($DG_HOMES/$DG_COMF_NAME)
			cnt+=(' ')
		fi
	done
}

UNSET_STATUS_CHECK_VAR()
{
unset STATUS
unset PID
unset SERVICE_PORT
unset REPO_IP
unset REPO_PORT
unset REPO_SID
unset REPO_TYPE
}

DG_STATUS_CHECK()
{
	GET_TOTAL_DG_LIST
	UNSET_STATUS_CHECK_VAR
	echo -e  "\n\t\t\t\033[33m<DG STATUS CHECK>\033[m\n \033[36mCOMP PART\t\tSTATUS  PID  Serv_PORT\t\tREPO_INFO\033[m"
	for i in `seq 1 ${#cnt[@]}`
	do
		CONF_NAME=`cat ${DG_HOME[$i]}/.mxgrc | grep NAME | grep -v export | awk -F "=" '{print $2}'`
		PID=`ps -ef | grep -w $CONF_NAME | grep -w DGServer.jar | grep -v grep | awk '{print $2}'`
		SERVICE_PORT=`cat ${DG_HOME[$i]}/conf/DGServer.xml | grep gather_port | awk -F "<gather_port>" '{print $2}' | awk -F "</gather_port>" '{print $1}'`
		REPO_TYPE=`cat ${DG_HOME[$i]}/conf/DGServer.xml | grep database_type | awk -F "<database_type>" '{print $2}' | awk -F "</database_type>" '{print $1}'`
		REPO_PORT=`cat ${DG_HOME[$i]}/conf/DGServer.xml | grep database_port | awk -F "<database_port>" '{print $2}' | awk -F "</database_port>" '{print $1}'`
		REPO_IP=`cat ${DG_HOME[$i]}/conf/DGServer.xml | grep database_ip | awk -F "<database_ip>" '{print $2}' | awk -F "</database_ip>" '{print $1}'`
		REPO_SID=`cat ${DG_HOME[$i]}/conf/DGServer.xml | grep database_sid | awk -F "<database_sid>" '{print $2}' | awk -F "</database_sid>" '{print $1}'`
		if [ -z "$PID" ]; then STATUS="X"; PID="     "; else STATUS="O" ; fi
		if [ ${#PID} -lt 5 ]; then GAB=0  PID=($GAB$PID); fi
		if [ "${DG_COMF_NAME[$i]}" = "DGServer_M" ]; then DG_COMP="DataGather Master"; else DG_COMP="DataGather Slave"; fi;
		echo -e  " [$i] $DG_COMP \t[ $STATUS ] [${PID}] [${SERVICE_PORT}] [$REPO_IP:$REPO_PORT:$REPO_SID($REPO_TYPE)]";
	done
}

PJS_STATUS_CHECK()
{
	UNSET_STATUS_CHECK_VAR
		echo -e  "\n\t\t\t\033[33m<PJS STATUS CHECK>\033[m\n \033[36mCOMP PART\t\tSTATUS  PID  Serv_PORT\tDGM_INFO\t\tREPO_INFO\t\033[m"
		SERVICE_PORT=`cat $PJS_HOME/config/config.json | grep service_port | awk -F ":" '{print $2}' | tr -d ' ' | tr -d '"' | tr -d ','`
		PID=`ps -ef | grep DPJS$SERVICE_PORT | grep -v grep | grep -v mxg_obsd | awk '{print $2}'`
		REPO_TYPE=`cat $PJS_HOME/config/config.json  | grep database_type | awk -F ":" '{print $2}' | tr -d ' ' | tr -d '"' | tr -d ','`
		REPO_PORT=`cat $PJS_HOME/config/config.json | grep database_port | awk -F ":" '{print $2}' | tr -d ' ' | tr -d '"' | tr -d ','`
		REPO_IP=`cat $PJS_HOME/config/config.json | grep database_server | awk -F ":" '{print $2}' | tr -d ' ' | tr -d '"' | tr -d ','`
		REPO_SID=`cat $PJS_HOME/config/config.json | grep database_database | awk -F ":" '{print $2}' | tr -d ' ' | tr -d '"' | tr -d ','`
		DGM_PORT=`cat $PJS_HOME/config/config.json | grep datagather_port | awk -F ":" '{print $2}' | tr -d ' ' | tr -d '"' | tr -d ','`
		DGM_IP=`cat $PJS_HOME/config/config.json | grep datagather_ip | awk -F ":" '{print $2}' | tr -d ' ' | tr -d '"' | tr -d ','`
		if [ -z "$PID" ]; then STATUS="X"; PID="     "; else STATUS="O" ; fi
		if [ ${#PID} -lt 5 ]; then GAB=0  PID=($GAB$PID); fi
		echo -e  " [1] JAVA PlatformJS \t[ $STATUS ] [${PID}] [${SERVICE_PORT}] [$DGM_IP:$DGM_PORT] [$REPO_IP:$REPO_PORT:$REPO_SID($REPO_TYPE)]";
}

PATCH_RTS()
{
	UNSET_DEFAULT_SETUP_VARIABLES
#core of the installation logic.
	SET_INSTALL_VARIABLES_RTS
	PARSING_DATA_FOR_RTS_PATCH
	COLLECT_USER_DECISION_1ST_DEPTH
#core of the installation logic.
	REMOVE_AND_REPLACE_RTS
	CHANGE_TO_VAR_WITH_ENTER
	echo -e "$VAR_WITH_ENTER"|sh $THIS_RTS_HOME/install/install.sh
	echo -e "\n\t\t\t\033[33m<The RTS Daemon Patch end..!>\033[m"
}

REMOVE_AND_REPLACE_RTS()
{
	SETUP_FILE=/home/maxgauge/rts/maxgauge
	MXG_HOME_COPIED=`cat $THIS_RTS_HOME/.mxgrc | grep -w MXG_HOME=` 
	DEFAULT_HOME_KEYWORD="MXG_HOME=/home/maxgauge"
	rm -rf $THIS_RTS_HOME
	if [ -d $THIS_RTS_HOME ]; then
		echo -e "The old version conf,$THIS_RTS_HOME,wasn't deleted..!! problem here here..!!";
	else
		echo -e "The old version conf,$THIS_RTS_HOME,is deleted";
	fi

	cp -a $SETUP_FILE $THIS_RTS_HOME
	if [ -d $THIS_RTS_HOME ]; then
		 echo -e "The version conf,$THIS_RTS_HOME,is added";
	fi
	sed -i s:$DEFAULT_HOME_KEYWORD:$MXG_HOME_COPIED:g  $THIS_RTS_HOME/.mxgrc
	. $THIS_RTS_HOME/.mxgrc
}

UNZIP_RTS_FILE()
{
cd $RTS_HOMES
tar -xvf $SETUP_FILE
cp $LICENSE_KEY $RTS_HOMES/maxgauge/bin/
}

RTS_FILES_VALID_CHECK()
{
	echo -e " Where is the setup file?"
	read SETUP_FILE
	if [ -f $SETUP_FILE ]&&[ "$SETUP_FILE" != "" ]; then
		echo -e " CHECK SETUP_FILE...OK ";
	else
		echo -e  " Not Found SETUP_FILE, from \"$SETUP_FILE\"";
		exit;
	fi

	echo -e " Where is the License_key?"
	read LICENSE_KEY
	if [ -f $LICENSE_KEY ]&&[ "$LICENSE_KEY" != "" ]; then
		echo -e " CHECK LICENSE_KEY...OK ";
	else
		echo -e  " Not Found LICENSE_KEY, from \"$LICENSE_KEY\"";
		exit;
	fi
}

REGISTER_RTS_FOR_MULTI()
{
		UNSET_DEFAULT_SETUP_VARIABLES
	#core of the installation logic.
		SET_INSTALL_VARIABLES_RTS_MULTI_REGISTER
	## ONLY WHEN NEW INSTALLATION 
		NEW_INSTALLATION=ON; CHECK_INSTALL_VARIABLES $NEW_INSTALLATION; unset NEW_INSTALLATION;
		COLLECT_USER_DECISION_1ST_DEPTH
	#core of the installation logic.
	RTS_PORT=${DEFAULT_SET[3]}
	for i in `seq 1 ${DEFAULT_SET[2]}`
	do
		USER_NAMED_RTS_NAMES+=(${DEFAULT_SET[1]}$i)
	done	
	
	for ONE_OF_CONFS in ${USER_NAMED_RTS_NAMES[@]}
	do
		UNSET_DEFAULT_SETUP_VARIABLES
		unset THIS_RTS_HOME
		DEFAULT_HOME_KEYWORD="MXG_HOME=/home/maxgauge"
		THIS_RTS_HOME=($RTS_HOMES/$ONE_OF_CONFS)
		MXG_HOME_COPIED="MXG_HOME=$THIS_RTS_HOME"
		cp -av $RTS_HOMES/maxgauge $THIS_RTS_HOME
			if [ -d $THIS_RTS_HOME ]; then
				 echo -e "The RTS HOME,$THIS_RTS_HOME,is added";
			fi
		sed -i s:$DEFAULT_HOME_KEYWORD:$MXG_HOME_COPIED:g  $THIS_RTS_HOME/.mxgrc
		. $THIS_RTS_HOME/.mxgrc
		
		UNSET_DEFAULT_SETUP_VARIABLES
	#UNSET_PJS_DEFAULT_SETUP
		echo -e "\n\t\t\t\033[33m<RTS Daemon Install>\033[m"
	#core of the installation logic.
		SET_INSTALL_VARIABLES_RTS
		COLLECT_USER_DECISION_1ST_DEPTH
	#core of the installation logic.
		DEFAULT_SET[6]=$RTS_PORT
		CHANGE_TO_VAR_WITH_ENTER
		echo -e  "$VAR_WITH_ENTER"| sh $THIS_RTS_HOME/install/install.sh
		RTS_PORT=`expr $RTS_PORT + 1`
		sleep 3
		echo -e " The RTS Daemon SETUP end..! ";
	done
	
	#ATTACHMENT="${DEFAULT_SET[1]}) RTSES_CONF=\"${USER_NAMED_RTS_NAMES[@]}\" ;;"
	#sed -e "5 a$ATTACHMENT" $0 > .mxctl.sh	
}

UNSET_DEFAULT_SETUP_VARIABLES()
{
unset VALUE_NAME
unset DEFAULT_SET
unset FIND_KEYWORD
unset Replace_V
unset MXG_HOME_COPIED
# To need Keep RTS_PORT value in the function,REGISTER_RTS_FOR_MULTI.
#unset RTS_PORT
}

UNSET_DEFAULT_SET_2ND_DEPTH()
{
unset VALUE_NAME_2ND
unset DEFAULT_SET_2ND
unset FIND_KEYWORD_2ND
unset Replace_V_2ND
}

UNZIP_PJS_FILE()
{
	cd $PJS_HOME
	PJS_FILE=`ls $PJS_HOME/PlatformJS*.zip`
	PJS_FILE=`basename $PJS_FILE`
	rm -rf `ls | grep -v $PJS_FILE`
	unzip $PJS_FILE 1> /dev/null
	rm $PJS_FILE
}

MV_DUPL_PJS_FILE()
{
	cd $PJS_HOME
	PJS_FILE=`ls $PJS_HOME/PlatformJS*.zip 2>/dev/null &`
	PJS_FILE=`basename $PJS_FILE 2>/dev/null &`
	if [ -f $PJS_HOME/$PJS_FILE ]; then
	mv $PJS_HOME/$PJS_FILE $OLDONE 
	fi
}

UNZIP_PJS_FILE_FOR_PATCH_SQL()
{
	cd $PJS_HOME
	PJS_FILE=`ls $PJS_HOME/PlatformJS*.zip`
	PJS_FILE=`basename $PJS_FILE`
	mkdir test
	mv $PJS_FILE test/
	rm -rf sql
	cd test
	unzip $PJS_FILE 1> /dev/null
	mv sql ../
	cd ..
	rm -rf test
}

UNZIP_PJS_FILE_FOR_PATCH_JS()
{
	cd $PJS_HOME
	PJS_FILE=`ls $PJS_HOME/PlatformJS*.zip`
	PJS_FILE=`basename $PJS_FILE`
	mkdir test
	mv $PJS_FILE test/
	rm -rf svc/www/
	cd test
	unzip $PJS_FILE 1> /dev/null
	mv svc/www/ ../svc/
	cd ..
	rm -rf test
}

REPO_RESET_BY_DATAGATHER ()
{
cd $DGM_HOME/bin
echo -e "2\ny\ny\n1\n0\n" | java -jar DGServer.jar install
}

REPO_REDEFINITE_BY_DATAGATHER ()
{
cd $DGM_HOME/bin
echo -e "1\n0\n" | java -jar DGServer.jar install
}

SHOW_TAG_LIST_FROM_DB ()
{
QUERY_TAG[1]=unipjs;
QUERY_TAG[2]=mfoweb;
QUERY_TAG[3]=mfosql;
QUERY_TAG[4]=mfodg;
QUERY_TAG[5]=mforts;
QUERY_TAG[6]=mfobuild;

case $Replace_V in
1|2|3|4)
	DEFAULT_SET[5]="x"
	DEFAULT_SET[6]="x"
	echo -e "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;" > insert_tag.sql
	echo -e "select TAG_INFO from mfo_tag_part where tag_info like '${QUERY_TAG[$Replace_V]}%';" >> insert_tag.sql
	TAG_LIST=`echo -e exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
	rm insert_tag.sql
	echo -e $BARRIRER
	echo -e "\033[36m\t\t\t TAG_VALUE\033[m"
	unset THIS_TAG
	unset VALUE_NAME_2ND
	TAG_CNT=0
	THIS_TAG=' '
	for THIS_TAG in $TAG_LIST
	do
		THIS_TAG+=(${THIS_TAG})
		VALUE_NAME_2ND+=(${THIS_TAG})
		TAG_CNT=`expr $TAG_CNT + 1`
		echo -e " \t\t\t [${TAG_CNT}] ${THIS_TAG[$TAG_CNT]} "
	done;
	echo -e $BARRIRER
	REPLACE_INSTALL_VARIABLES_2ND
	if [ "$Replace_V_2ND" != "OK" ]; then
		DEFAULT_SET[$Replace_V]=${THIS_TAG[$Replace_V_2ND]}; 
	fi;
	VIEW_OF_TAG_CHANGES
	break;
;;

5)
	SET_INSTALL_VARIABLES_MFOTAG
	DEFAULT_SET[5]="USER_DEFINED";
	echo -e " \033[33m* TAGs are set as User Update setting. [ U - Up to date / H - Hold ]\033[m "
	for i in 1 2 3 4
	do
		if [ ${HOLD_OR_UP_TO_DATE[$i]} = "U" ]; then
			echo -e "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;" > insert_tag.sql
			echo -e "select TAG_INFO from mfo_tag_part where tag_info like '${QUERY_TAG[$i]}%';" >> insert_tag.sql
			TAG_LIST=`echo -e exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
			rm insert_tag.sql
		for THIS_TAG in $TAG_LIST
		do
			## Last one is the latest one.
			DEFAULT_SET[$i]=$THIS_TAG;
		done
		fi
	done
	VIEW_OF_TAG_CHANGES
	break;
;;

6)
	UNSET_DEFAULT_SET_2ND_DEPTH
	DEFAULT_SET[5]="x";
	echo -e " \033[33m* TAGs are set as BaseLine selected. [ BaseLine = Package version]\033[m "
	GET_PACKAGE_VERSION
	REPLACE_INSTALL_VARIABLES_2ND
	if [ "$Replace_V_2ND" = "OK" ]; then 
		Replace_V_2ND=1;
		echo -e " \033[33m'The Latest one'\033[m is selected in the Package Version list";
	fi;
	DEFAULT_SET[1]=${MTO_NP[$Replace_V_2ND]};
	DEFAULT_SET[2]=${MTO_WEB[$Replace_V_2ND]};
	DEFAULT_SET[3]=${MTO_SQL[$Replace_V_2ND]};
	DEFAULT_SET[4]=${MTO_DG[$Replace_V_2ND]};
	DEFAULT_SET[6]=${THIS_TAG[$Replace_V_2ND]};
	VIEW_OF_TAG_CHANGES
	break;
;;

7)
	echo -e " \033[33m * Keyword Meaning [ U - Up to date / H - Hold] \033[m "
		UNSET_DEFAULT_SET_2ND_DEPTH
		SET_INSTALL_VARIABLES_TAG_FLAG_2ND
		COLLECT_USER_DECISION_2ND_DEPTH
	i=0
	for i in 4 3 2 1
	do
		ATTACHMENT="${TAG_KEY[$i]} ${INIT_VAR[$i]} ${DATE_VALUE[$i]} ${DEFAULT_SET_2ND[$i]}\n$ATTACHMENT";
	done
		SAVE_MFO_TAG_VALUE
	exit;
;;

8)
	SET_INSTALL_VARIABLES_MFO_BASELINE
	#SET_INSTALL_VARIABLES_MFOTAG
        DEFAULT_SET[8]="BASELINE_AS_NEWEST_TAGS";
        echo -e " \033[33m* TAGs are set as User Update setting. [ U - Up to date / H - Hold ]\033[m "
        for i in 1 2 3 4 5 6
        do
                        echo -e "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;" > insert_tag.sql
                        echo -e "select TAG_INFO from mfo_tag_part where tag_info like '${QUERY_TAG[$i]}%';" >> insert_tag.sql
                        TAG_LIST=`echo -e exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
                        rm insert_tag.sql
                for THIS_TAG in $TAG_LIST
                do
                        ## Last one is the latest one.
                        DEFAULT_SET[$i]=$THIS_TAG;
                done
        done
        VIEW_OF_TAG_CHANGES
#       break;
	GET_PACKAGE_VERSION
	echo ${THIS_TAG[1]}
	echo go on?
	read BASELINE
		if [ "$BASELINE" != "" ]; then
			THIS_TAG[1]="$BASELINE"
        	fi
	TEMP_UPDATE_BASELINE_QUERY
	MFO_BUILD_PART
        i=0
        for i in 4 3 2 1
        do
        ATTACHMENT="${TAG_KEY[$i]} ${DEFAULT_SET[$i]} ${DATE_VALUE[$i]} ${HOLD_OR_UP_TO_DATE[$i]}\n$ATTACHMENT";
        done
	SAVE_MFO_TAG_VALUE
        sleep 1
	exit;
;;

*)
	echo -e " \033[36m '$1' is invalid number.\033[m";
;;
esac
}

TEMP_UPDATE_BASELINE_QUERY()
{
for i in 1 2 3 4
        do
        if [ ${INIT_VAR[$i]} != ${DEFAULT_SET[$i]} ]; then
                case $i in
                1) REQ_SPEC="${REQ_SPEC}n";;
                2) REQ_SPEC="${REQ_SPEC}w";;
                3) REQ_SPEC="${REQ_SPEC}s";;
                4) REQ_SPEC="${REQ_SPEC}d";;
                esac
                DATE_VALUE[$i]=`date "+%y%m%d_%H:%M:%S"`;
        fi
done

        if [ "$BASELINE" != "" ]; then
		echo -e "insert into mfo_tag values('${THIS_TAG[1]}',null,null,null,null,null,null,null,null);"             > insert_tag.sql
        fi
        echo -e "insert into requirer values('QA','REPO','total','${DEFAULT_SET[6]}');"             >> insert_tag.sql
	echo -e "update ipaddress set WHO='QA' where WHO='QA_BSH';"                                                  >> insert_tag.sql
        echo -e "update runner_stat set total_ver='${THIS_TAG[1]}' where run_comp='mfototal_win';"                   >> insert_tag.sql
        echo -e "update runner_stat set value='1' where run_comp='mfototal_win';"                          	     >> insert_tag.sql
        echo -e "update mfo_tag set mfonp_tag='${DEFAULT_SET[1]}' where mfo_release_ver='${THIS_TAG[1]}';"           >> insert_tag.sql
        echo -e "update mfo_tag set mfoweb_tag='${DEFAULT_SET[2]}' where mfo_release_ver='${THIS_TAG[1]}';"          >> insert_tag.sql
        echo -e "update mfo_tag set mfosql_tag='${DEFAULT_SET[3]}' where mfo_release_ver='${THIS_TAG[1]}';"          >> insert_tag.sql
        echo -e "update mfo_tag set mfodg_tag='${DEFAULT_SET[4]}' where mfo_release_ver='${THIS_TAG[1]}';"           >> insert_tag.sql
	echo -e "update mfo_tag set mforts_tag='${DEFAULT_SET[5]}' where mfo_release_ver='${THIS_TAG[1]}';"           >> insert_tag.sql
        echo -e "update mfo_tag set mfobuild_tag='${DEFAULT_SET[6]}' where mfo_release_ver='${THIS_TAG[1]}';"                >> insert_tag.sql
        echo -e exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql >> /dev/null
        sleep 1
        rm insert_tag.sql

        WORKING_DIR=`pwd`
}

MFO_BUILD_PART ()
{
PIPELINE_NUM=`curl --silent --request POST --header "PRIVATE-TOKEN: Rf3Gmpkc68Z6W5M7vjtS" "http://10.10.32.101/api/v3/projects/49/pipeline?ref=master" | awk -F "," '{print $1}' | awk -F ":" '{print $2}'`
}


SAVE_MFO_TAG_VALUE()
{
	START_L=`grep -n "MFO_TAG_INFO" -m 1 $0 | awk -F ":" '{print $1}'`
	START_L=`expr $START_L + 1 `
	sed -e "$START_L a$ATTACHMENT" $0 > .mxctl2.sh;
	START_L=`expr $START_L + 4 `
	TOTAL_L=`wc -l $0 | awk '{print $1}'`
	TOTAL_L=`expr $TOTAL_L + 4 `
	END_L=`expr $START_L + 4 `
	TAIL_L=`expr $TOTAL_L - $END_L `
	
	head -$START_L .mxctl2.sh > .mxctl.sh;
	tail -$TAIL_L .mxctl2.sh >> .mxctl.sh;
	echo -e "CHANGING tag flag START ======================= ";
	echo -e "sleep 1\nmv .mxctl.sh $0\nrm -rf mxctlsaver.sh\nrm -rf .mxctl2.sh" > mxctlsaver.sh
	echo -e  "chmod 775 $0" >> mxctlsaver.sh
	echo -e "echo -e CHANGING tag flag FINISH ======================" >> mxctlsaver.sh;
	echo -e "sh $0" >> mxctlsaver.sh;
	sh mxctlsaver.sh;
}

REQUIRER_CHECK()
{
echo -e "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;" > insert_tag.sql
echo -e "select WHO, PART, REQ_TAG from requirer;" >> insert_tag.sql
REQUIRER_INFO=`echo -e exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
rm insert_tag.sql

USING_USER=`echo -e $REQUIRER_INFO | awk '{print $1}'`
FOR_WHAT=`echo -e $REQUIRER_INFO | awk '{print $2}'`
REQ_TAG=`echo -e $REQUIRER_INFO | awk '{print $3}'`


case $REQ_TAG in
nwsd|nwd|nsd|nd|wsd|wd|sd)
REQ_TAG="PlatformJS & DataGahter";;
nws|nw|ns|n|ws|w|s)
REQ_TAG="Only PlatformJS";;
d)
REQ_TAG="Only DataGather";;
esac

if [ $USING_USER ]; then
echo -e $BARRIRER$BARRIRER
echo -e " * The system is now working for \033[33m${USING_USER}'s ${FOR_WHAT} ($REQ_TAG)\033[m..!"
echo -e " * Please wait until \033[33m${USING_USER}\033[m's work finish."
echo -e $BARRIRER$BARRIRER
fi
}

TAG_INSERT_QUERY()
{
unset REQ_SPEC
if [ "${DEFAULT_SET[6]}" != "x" ]; then
	MFOBUILD="$MFOBUILD"
	else
	echo -e "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;" > insert_tag.sql
	echo -e "select BUILD_REF from mfo_tag_part where tag_info like '${DEFAULT_SET[1]}';" >> insert_tag.sql
	MFOBUILD=`echo -e exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
	rm insert_tag.sql
fi

for i in 1 2 3 4
	do
	if [ ${INIT_VAR[$i]} != ${DEFAULT_SET[$i]} ]; then
		case $i in
		1) REQ_SPEC="${REQ_SPEC}n";;
		2) REQ_SPEC="${REQ_SPEC}w";;
		3) REQ_SPEC="${REQ_SPEC}s";;
		4) REQ_SPEC="${REQ_SPEC}d";;
		esac
		DATE_VALUE[$i]=`date "+%y%m%d_%H:%M:%S"`;
	fi
done

if [ ${REQ_SPEC} ]; then
	## TEMP
	echo -e "update ipaddress set WHO='QA_BSH' where IPADDR='10.10.32.21';"                           >> insert_tag.sql
	## TEMP
	echo -e "insert into requirer values('$WHO','$PART','$REQ_SPEC','${DEFAULT_SET[6]}');"             >> insert_tag.sql
	echo -e "update runner_stat set total_ver='$WHO' where run_comp='mfototal_win';"                   >> insert_tag.sql
	echo -e "update runner_stat set value='1' where run_comp='mfototal_win';"                          >> insert_tag.sql
	echo -e "update mfo_tag set mfonp_tag='${DEFAULT_SET[1]}' where mfo_release_ver='$WHO';"           >> insert_tag.sql
	echo -e "update mfo_tag set mfoweb_tag='${DEFAULT_SET[2]}' where mfo_release_ver='$WHO';"          >> insert_tag.sql
	echo -e "update mfo_tag set mfosql_tag='${DEFAULT_SET[3]}' where mfo_release_ver='$WHO';"          >> insert_tag.sql
	echo -e "update mfo_tag set mfodg_tag='${DEFAULT_SET[4]}' where mfo_release_ver='$WHO';"           >> insert_tag.sql
	echo -e "update mfo_tag set mfobuild_tag='$MFOBUILD' where mfo_release_ver='$WHO';"                >> insert_tag.sql
	echo -e exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql >> /dev/null
	sleep 1
	rm insert_tag.sql
	
	WORKING_DIR=`pwd`
	curl --request POST --header "PRIVATE-TOKEN: sG2UzXShy7HyuXN8GSR5" "http://10.10.32.101/api/v3/projects/49/builds/4291/retry" 1>/dev/null 2>&1 &
	sleep 1
	curl --request POST --header "PRIVATE-TOKEN: sG2UzXShy7HyuXN8GSR5" "http://10.10.32.101/api/v3/projects/49/builds/4294/retry" 1>/dev/null 2>&1 &
	MV_DUPL_PJS_FILE
	MV_DUPL_DG_FILE
	cd $WORKING_DIR
	
	### VALUE=1 require, 2 Compile&Build, 3 Send File to requirer, 0 Waiting
	echo -e "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;"                             > insert_tag.sql
	echo -e "select value from runner_stat where run_comp='mfototal_win';"                             >> insert_tag.sql
	while true 
	do
		STATUS_VALUE=`echo -e exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
		sleep 1

		case `echo -e $STATUS_VALUE` in
			1) STAT_INFO="REQUIERING";;
			2) STAT_INFO="COMPILING & BUILDING";;
			3) STAT_INFO="SENDING FILES";;
			0) echo -e "MOVE PATCH & NEW INSTALLING"; 
			   rm insert_tag.sql; 
				i=0
				for i in 4 3 2 1
				do
				ATTACHMENT="${TAG_KEY[$i]} ${DEFAULT_SET[$i]} ${DATE_VALUE[$i]} ${HOLD_OR_UP_TO_DATE[$i]}\n$ATTACHMENT";
				done
				sh /home/gitlab-runner/build_test.sh ${REQ_SPEC}; 
				SAVE_MFO_TAG_VALUE
				sleep 1
			   exit; 
			;;
		esac

		echo -e "\033[33m UPDATE START..!  [ $STAT_INFO ] .. BUILD SERVER\033[m"
	done
else
	echo -e " * NOTHING TO UPDATE";
fi
}

VIEW_OF_TAG_CHANGES()
{
echo -e $BARRIRER
echo -e "\033[36m\tPART\t\t[U/H]\t   BEFORE\t\t   AFTER\033[m"
for i in 1 2 3 4
do

     if [ ${HOLD_OR_UP_TO_DATE[$i]} = "U" ]; then
         MIDDLE_PART="[ \033[33m${HOLD_OR_UP_TO_DATE[$i]}\033[m ]\t ";
     else
         MIDDLE_PART="[ \033[34m${HOLD_OR_UP_TO_DATE[$i]}\033[m ]\t ";
     fi;

     if [ ${INIT_VAR[$i]} != ${DEFAULT_SET[$i]} ]; then
         TAIL_PART=" ${INIT_VAR[$i]}\t\033[41m=>\033[m ${DEFAULT_SET[$i]}"
     else
         TAIL_PART=" ${DEFAULT_SET[$i]}"
     fi;

     echo -e "\t$i) ${VALUE_NAME[$i]}\t$MIDDLE_PART:$TAIL_PART"
done;
echo -e $BARRIRER
}

GET_PACKAGE_VERSION()
{
echo -e $BARRIRER$BARRIRER
echo -e "\033[36m PACKAGE_VER\t\t\t  NP_TAG\t\tWEB_TAG\t\t  SQL_TAG\t\tDG_TAG\033[m"
echo -e "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;" > insert_tag.sql
echo -e "select MFO_RELEASE_VER, MFONP_TAG, MFOWEB_TAG, MFOSQL_TAG, MFODG_TAG, MFOBUILD_TAG from mfo_tag where MFO_RELEASE_VER like '%mfo%' order by 1 desc ;" >> insert_tag.sql
	TAG_LIST=`echo -e exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
	rm insert_tag.sql
	TAG_CNT=0
for THIS_TAG in $TAG_LIST
    do
        TO_CNT=`expr $TAG_CNT / 6 + 1`
        case `expr $TAG_CNT % 6` in
        0)
        THIS_TAG[$TO_CNT]=$THIS_TAG
        VALUE_NAME_2ND[$TO_CNT]=$TO_CNT
        ;;
        1)
        MTO_NP[$TO_CNT]=$THIS_TAG
        ;;
        2)
        MTO_WEB[$TO_CNT]=$THIS_TAG
        ;;
        3)
        MTO_SQL[$TO_CNT]=$THIS_TAG
        ;;
        4)
        MTO_DG[$TO_CNT]=$THIS_TAG
        if [ ${#THIS_TAG[$TO_CNT]} -lt 4 ]; then tab='\t\t\t\t'; elif [ ${#THIS_TAG[$TO_CNT]} -lt 11 ]; then tab='\t\t\t'; elif [ ${#THIS_TAG[$TO_CNT]} -lt 19 ]; then tab='\t\t'; else tab='\t'; fi;
        echo -e " [$TO_CNT] ${THIS_TAG[$TO_CNT]}$tab[ ${MTO_NP[$TO_CNT]} : ${MTO_WEB[$TO_CNT]} : ${MTO_SQL[$TO_CNT]} : ${MTO_DG[$TO_CNT]}] "
        ;;
        5)
        MFOBUILD=$THIS_TAG
        ;;
        esac
        TAG_CNT=`expr $TAG_CNT + 1`
    done
echo -e $BARRIRER$BARRIRER
}

SET_INSTALL_VARIABLES_TAG_FLAG_2ND ()
{
# DEFAULT ARRAY START AT 0
VALUE_NAME_2ND[1]="MFONP" ;                 DEFAULT_SET_2ND[1]="${HOLD_OR_UP_TO_DATE[1]}";
VALUE_NAME_2ND[2]="MFOWEB" ;                DEFAULT_SET_2ND[2]="${HOLD_OR_UP_TO_DATE[2]}";
VALUE_NAME_2ND[3]="MFOSQL";                 DEFAULT_SET_2ND[3]="${HOLD_OR_UP_TO_DATE[3]}";
VALUE_NAME_2ND[4]="MFODG" ;                 DEFAULT_SET_2ND[4]="${HOLD_OR_UP_TO_DATE[4]}";
}

CHECK_INSTALL_VARIABLES ()
{
STEP=0
for MEANINGLESS_JUST_WANT_LOOP in ${VALUE_NAME[@]}
do
	STEP=`expr $STEP + 1`
	if [ $# -eq 0 ]; then
		if [ ${#VALUE_NAME[$STEP]} -lt 11 ]; then tab='\t\t\t'; elif [ ${#VALUE_NAME[$STEP]} -lt 19 ]; then tab='\t\t'; else tab='\t'; fi;
		if [ "$STEP" = "$Replace_V" ]; then
		echo -e " \033[41m[$STEP] ${VALUE_NAME[$STEP]}$tab : ${DEFAULT_SET[$STEP]}\033[m";
		else
		echo -e " [$STEP] ${VALUE_NAME[$STEP]}$tab : ${DEFAULT_SET[$STEP]}";
		fi
	elif [ "$STEP" = "$Replace_V" ]||[ "$NEW_INSTALLATION" = "ON" ]; then
		if [ "$NEW_INSTALLATION" = "ON" ]; then echo -e " [$STEP] Input ${VALUE_NAME[$STEP]} [ Default : ${DEFAULT_SET[$STEP]} ]\t:"; fi;
		if [ "$TAG_CHANGE" = "ON" ]; then SHOW_TAG_LIST_FROM_DB; fi;
		DEFAULT_KEEP=${DEFAULT_SET[$STEP]};
		read DEFAULT_SET[$STEP];
		if [ ${#DEFAULT_SET[$STEP]} = 0 ]; then DEFAULT_SET[$STEP]=$DEFAULT_KEEP; fi;
	fi
done
}

CHECK_INSTALL_VARIABLES_2ND ()
{
STEP_2ND=0
BARRIRER="--------------------------------------------------"
echo -e $BARRIRER
for MEANINGLESS_JUST_WANT_LOOP in ${VALUE_NAME_2ND[@]}
do
	STEP_2ND=`expr $STEP_2ND + 1`
	if [ $# -eq 0 ]; then
		case ${DEFAULT_SET_2ND[$STEP_2ND]} in
			H)
			echo -e "\t$STEP_2ND) ${VALUE_NAME_2ND[$STEP_2ND]}\t[${DEFAULT_SET_2ND[$STEP_2ND]}]"
			;;
			U)
			echo -e "\t$STEP_2ND) ${VALUE_NAME_2ND[$STEP_2ND]}\t[\033[33m${DEFAULT_SET_2ND[$STEP_2ND]}\033[m]"
			;;
		esac
	elif [ "$STEP_2ND" = "$Replace_V_2ND" ]||[ "$NEW_INSTALLATION" = "ON" ]; then
		if [ "$NEW_INSTALLATION" = "ON" ]; then echo -e " [$STEP_2ND] Input ${VALUE_NAME_2ND[$STEP_2ND]} [ Default : ${DEFAULT_SET_2ND[$STEP_2ND]} ]\t:"; fi;
		DEFAULT_KEEP=${DEFAULT_SET_2ND[$STEP_2ND]};
		read DEFAULT_SET_2ND[$STEP_2ND];
		if [ ${#DEFAULT_SET_2ND[$STEP_2ND]} = 0 ]; then DEFAULT_SET_2ND[$STEP_2ND]=$DEFAULT_KEEP; fi;
	fi
done
echo -e $BARRIRER
}

REPLACE_INSTALL_VARIABLES ()
{
	echo -e " \033[33mPress enter to move ahead or Put the number to change value [ Default : OK, Example : 1 ]\033[m ";
	read Replace_V;
	if [ ${#Replace_V} = 0 ]; then
		Replace_V=OK;
	elif [ `echo -e $Replace_V | tr -d '[0-9]'` ]||[ "$Replace_V" = "0" ]; then
		echo -e "\033[36m '$Replace_V' is invalid cmd.\033[m"; REPLACE_INSTALL_VARIABLES;
	elif [ ${#VALUE_NAME[@]} -lt $Replace_V ]; then
		echo -e "\033[36m '$Replace_V' is invalid number.\033[m"; REPLACE_INSTALL_VARIABLES;
	else
		echo -e " [$Replace_V] Input ${VALUE_NAME[$Replace_V]} [ Default : ${DEFAULT_SET[$Replace_V]} ]\t:"
		CHECK_INSTALL_VARIABLES $Replace_V;
	fi
}

REPLACE_INSTALL_VARIABLES_2ND ()
{
	echo -e " \033[33mPut the number or Press enter to move ahead. [ Default : OK, Example : 1 ]\033[m ";
	read Replace_V_2ND;
	if [ ${#Replace_V_2ND} = 0 ]; then
		Replace_V_2ND=OK;
	elif [ `echo -e $Replace_V_2ND | tr -d '[0-9]'` ]||[ "$Replace_V_2ND" = "0" ]; then
		echo -e "\033[36m '$Replace_V_2ND' is invalid cmd.\033[m"; REPLACE_INSTALL_VARIABLES_2ND;
	elif [ ${#VALUE_NAME_2ND[@]} -lt $Replace_V_2ND ]; then
		echo -e "\033[36m '$Replace_V_2ND' is invalid number.\033[m"; REPLACE_INSTALL_VARIABLES_2ND;
	else
		case ${DEFAULT_SET_2ND[$Replace_V_2ND]} in
		H)      DEFAULT_SET_2ND[$Replace_V_2ND]="U";
		;;
		U)      DEFAULT_SET_2ND[$Replace_V_2ND]="H";
		;;
		esac
	fi
}

CHANGE_TO_VAR_WITH_ENTER ()
{
	unset VAR_WITH_ENTER
	for i in `echo -e ${DEFAULT_SET[@]}`; do VAR_WITH_ENTER="$VAR_WITH_ENTER$i\n"; done
	echo -e $VAR_WITH_ENTER
}

UNZIP_DG_FILE()
{
	cd $DG_HOMES
	DG_FILE=`ls $DG_HOMES/MaxGauge*.tar`
	DG_FILE=`basename $DG_FILE`
	rm -rf `ls | grep -v $DG_FILE`
	tar -xvf $DG_FILE
	rm $DG_FILE
}

MV_DUPL_DG_FILE()
{
	cd $DG_HOMES
	DG_FILE=`ls $DG_HOMES/MaxGauge*.tar 2>/dev/null &`
	DG_FILE=`basename $DG_FILE 2>/dev/null &`
	if [ -f $DG_HOMES/$DG_FILE ]; then
	mv $DG_FILE $OLDONE
	fi
}

TEMP_DG_INSTALL_SH()
{
#DGM_INFO
	sed -i 's:<gather_port.*>.*</gather_port>:<gather_port>'${DEFAULT_SET[3]}'</gather_port>:g'  $DGM_HOME/conf/DGServer.xml
	sed -i 's#<slave_gather_list.*>.*</slave_gather_list>#<slave_gather_list>'${DEFAULT_SET[4]}'</slave_gather_list>#g'  $DGM_HOME/conf/DGServer.xml
	sed -i 's:<database_type.*>.*</database_type>:<database_type>'${DEFAULT_SET[5]}'</database_type>:g'  $DGM_HOME/conf/DGServer.xml
	sed -i 's:<database_ip.*>.*</database_ip>:<database_ip>'${DEFAULT_SET[6]}'</database_ip>:g'  $DGM_HOME/conf/DGServer.xml
	sed -i 's:<database_port.*>.*</database_port>:<database_port>'${DEFAULT_SET[7]}'</database_port>:g'  $DGM_HOME/conf/DGServer.xml
	sed -i 's:<database_sid.*>.*</database_sid>:<database_sid>'${DEFAULT_SET[8]}'</database_sid>:g'  $DGM_HOME/conf/DGServer.xml
	sed -i 's:<database_user.*>.*</database_user>:<database_user>'${DEFAULT_SET[9]}'</database_user>:g'  $DGM_HOME/conf/DGServer.xml
	sed -i 's:<database_password.*>.*</database_password>:<database_password>'${DEFAULT_SET[10]}'</database_password>:g'  $DGM_HOME/conf/DGServer.xml
	sed -i 's:<tablespace.*>.*</tablespace>:<tablespace>'${DEFAULT_SET[11]}'</tablespace>:g'  $DGM_HOME/conf/DGServer.xml
	sed -i 's:<index_tablespace.*>.*</index_tablespace>:<index_tablespace>'${DEFAULT_SET[12]}'</index_tablespace>:g'  $DGM_HOME/conf/DGServer.xml

#DGS_INFO
	sed -i 's:<gather_port.*>.*</gather_port>:<gather_port>'${DEFAULT_SET[13]}'</gather_port>:g'  $DGS_HOME/conf/DGServer.xml
	sed -i 's:<database_type.*>.*</database_type>:<database_type>'${DEFAULT_SET[5]}'</database_type>:g'  $DGS_HOME/conf/DGServer.xml
	sed -i 's:<database_ip.*>.*</database_ip>:<database_ip>'${DEFAULT_SET[6]}'</database_ip>:g'  $DGS_HOME/conf/DGServer.xml
	sed -i 's:<database_port.*>.*</database_port>:<database_port>'${DEFAULT_SET[7]}'</database_port>:g'  $DGS_HOME/conf/DGServer.xml
	sed -i 's:<database_sid.*>.*</database_sid>:<database_sid>'${DEFAULT_SET[8]}'</database_sid>:g'  $DGS_HOME/conf/DGServer.xml
	sed -i 's:<database_user.*>.*</database_user>:<database_user>'${DEFAULT_SET[9]}'</database_user>:g'  $DGS_HOME/conf/DGServer.xml
	sed -i 's:<database_password.*>.*</database_password>:<database_password>'${DEFAULT_SET[10]}'</database_password>:g'  $DGS_HOME/conf/DGServer.xml
	
# MXGRC_INFO
        DGM_CONF=`cat $DGM_HOME/.mxgrc | grep  DG_NAME=`
        DGS_CONF=`cat $DGS_HOME/.mxgrc | grep  DG_NAME=`
        DGM_HOME_KEYWORD=`cat $DGM_HOME/.mxgrc | grep  MXG_HOME=`
        DGS_HOME_KEYWORD=`cat $DGS_HOME/.mxgrc | grep  MXG_HOME=`
        OS_TYPE_KEYWORD=`cat $DGS_HOME/.mxgrc | grep  OS_TYPE=`

        sed -i s:$DGM_CONF:${DEFAULT_SET[1]}:g  $DGM_HOME/.mxgrc
        sed -i s:$DGS_CONF:${DEFAULT_SET[2]}:g  $DGS_HOME/.mxgrc
        sed -i s:$DGM_HOME_KEYWORD:${DEFAULT_SET[14]}:g  $DGM_HOME/.mxgrc
        sed -i s:$DGS_HOME_KEYWORD:${DEFAULT_SET[15]}:g  $DGS_HOME/.mxgrc
        sed -i s:$OS_TYPE_KEYWORD:${DEFAULT_SET[16]}:g  $DGS_HOME/.mxgrc
        sed -i s:$OS_TYPE_KEYWORD:${DEFAULT_SET[16]}:g  $DGM_HOME/.mxgrc

#  
}

COLLECT_USER_DECISION_1ST_DEPTH()
{
	while true
	do
		if [ "$Replace_V" = "OK" ]; then
		break
		fi
		CHECK_INSTALL_VARIABLES;
		REPLACE_INSTALL_VARIABLES;
	done
}

COLLECT_USER_DECISION_2ND_DEPTH()
{
        while true
        do
                if [ "$Replace_V_2ND" = "OK" ]; then
                break
                fi
                CHECK_INSTALL_VARIABLES_2ND;
                REPLACE_INSTALL_VARIABLES_2ND;
        done
}

DG_START()
{
	. $DGM_HOME/.mxgrc
	cd $DGM_HOME/bin
	sh dgsctl start
	cd $DGS_HOME/bin
	. $DGS_HOME/.mxgrc
	sh dgsctl start
}

DG_STOP()
{
	cd $DGM_HOME/bin
	. $DGM_HOME/.mxgrc
	sh dgsctl stop
	cd $DGS_HOME/bin
	. $DGS_HOME/.mxgrc
	sh dgsctl stop
}

PJS_START()
{
	cd $PJS_HOME
	sh pjsctl start
}

PJS_STOP()
{
	cd $PJS_HOME
	sh pjsctl stop
}

CHECK_RTS_AFTER_INSTALL ()
{
	LISTENER_CHECK_KEYWORD=`cat $THIS_RTS_HOME/conf/$ONE_OF_CONFS/rts.conf | grep -w 'listener' | grep -v '#'`
	CHAR_START_POINT=10
	LISTENER_CHECK_KEYWORD=`expr substr $LISTENER_CHECK_KEYWORD $CHAR_START_POINT 50`;
	if [ `netstat -an | grep "$LISTENER_CHECK_KEYWORD" | wc -l` -gt 0 ]; then
		echo -e " $ONE_OF_CONFS LISTENER CHECK SUCCESS..! ";
	else
		echo -e  " $ONE_OF_CONFS LISTENER CHECK FAILED..!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ";
	fi
	COMMONFILE_CHECK_KEYWORD=`cat $THIS_RTS_HOME/conf/$ONE_OF_CONFS/common.conf | grep obs1_keyword2`
	CHAR_START_POINT2=15
	COMMONFILE_CHECK_KEYWORD=`expr substr $COMMONFILE_CHECK_KEYWORD $CHAR_START_POINT2 50`;
	if [ "$COMMONFILE_CHECK_KEYWORD" != "$ONE_OF_CONFS" ]; then
		echo -e  -e " $ONE_OF_CONFS common file Keyword \"$COMMONFILE_CHECK_KEYWORD\" doesn't match!!!!!!!!!! ";
	fi
}

PATCH_PJS ()
{
UNSET_DEFAULT_SETUP_VARIABLES
	echo -e "\n\t\t\t\033[33m<JAVA PlatformJS Install>\033[m"
#core of the installation logic.
	SET_INSTALL_VARIABLES_PJS
	COLLECT_USER_DECISION_1ST_DEPTH
#core of the installation logic.
	UNZIP_PJS_FILE
	CHANGE_TO_VAR_WITH_ENTER
	echo -e  "1\n$VAR_WITH_ENTER\n1\n\n0\n\n\n"|sh $PJS_HOME/configuration.bat
	cd $PJS_HOME
	echo -e "exit\n" | sh pjsctl
	echo -e " The JAVA PJS Patch end..! ";
}

PATCH_DG ()
{
UNSET_DEFAULT_SETUP_VARIABLES
#START DataGather INSTALL..!
	echo -e "\n\t\t\t\033[33m<Data Gatgher Slave & Master Install>\033[m"
#core of the installation logic.
	SET_INSTALL_VARIABLES_DG
	PARSING_DATA_FOR_DG_PATCH
	COLLECT_USER_DECISION_1ST_DEPTH
#core of the installation logic.
	UNZIP_DG_FILE	
#install.sh이 없어서 임시로 하나의 함수를 만들었음
	TEMP_DG_INSTALL_SH
	. $DGM_HOME/.mxgrc
	cd $DGM_HOME/bin
	echo -e "exit\n" | sh dgsctl
	cd $DGS_HOME/bin
	. $DGS_HOME/.mxgrc
	echo -e "exit\n" | sh dgsctl

	echo -e "\n\t\t\t\033[33m<The DG Master & Slave Patch end..!>\033[m"
}

PATCH_MFO ()
{
USER_INFO
cd $WORKING_DIR
BARRIRER="--------------------------------------------------"
UNSET_DEFAULT_SETUP_VARIABLES
	echo -e "\n\t\t\t\033[33m< AUTO UPDATE MFO ENVIRONMENT >\033[m\n \033[36mCOMP_PART\t\t\t TAG_VALUE\t\033[m"
#core of the installation logic.
	SET_INSTALL_VARIABLES_MFOTAG
	TAG_CHANGE="ON"
	while true
	do
		if [ "$Replace_V" = "OK" ]; then
		break
		fi
		CHECK_INSTALL_VARIABLES;
		REQUIRER_CHECK
		REPLACE_INSTALL_VARIABLES;
	done
#core of the installation logic.
        unset TAG_CHANGE
if [ $USING_USER ]; then
	echo -e " * CANNOT UPDATE ENVIRONMENT DUE TO THE SYSTEM IS USING. "
else
	TAG_INSERT_QUERY;
fi
}

PRINT_MENU()
{
	echo -e " =========================================================================="
	echo -e " \033[33m[0] update                : to update MFO ENV.\033[m "
	echo -e " [1] start                 : to start multi rtses. "
	echo -e " [2] stop                  : to stop multi rtses. "
	echo -e " [3] check                 : to check multi rtses."
	echo -e " [4] patch                 : to patch multi rtses."
	echo -e " [5] conf                  : to make user conf for multi rtses."
	echo -e " [6] dgs                   : to change DGSlave port, IP."
	echo -e " [7] license               : to change LICENSE_KEY."
	echo -e " [8] register              : to register multi rtses."
	echo -e " [9] quit|q|exit|e         : to exit MXCTL"
	echo -e " [h] hidden                : to show you extra options"
	echo -e " =========================================================================="
}

PRINT_HIDDEN_MENU()
{
	echo -e " =========================================================================="
	echo -e " [1.1] check db_id         : to check rts db_id"
	echo -e " [1d] start dg             : to start dgm & dgs. "
	echo -e " [1p] start pjs            : to start pjs. "
	echo -e " [2.1] stop + clean        : to stop and rm -rf sndf and set db_id = 0 "
	echo -e " [2d] stop dg              : to stop dgm & dgs. "
	echo -e " [2p] stop pjs             : to stop pjs. "
	echo -e " [4d]  patch dg            : to patch dg without cmd 'dg install' "
	echo -e " [4dd] patch dg            : to patch dg with redefinite repo table&index."
	echo -e " [4ds] patch dg            : to patch dg with reset repo."
	echo -e " [4p]  patch pjs           : to patch pjs only sql dir."
	echo -e " [4ps] patch pjs           : to patch pjs only /www/www (java script)dir."
	echo -e " [4pj] patch pjs           : to patch pjs."
	echo -e " [11] clean                : to remove sndf of multi rtses. "
	echo -e " [12] conf check           : to check unmached values. "
	echo -e " [13] rts version check    : to check version of rts. "
	echo -e " [14] rts cpu              : to check cpu of rts. "
	echo -e " [9] quit|q|exit|e         : to exit MXCTL"
	echo -e " =========================================================================="
}

INTERACTIVE_MODE()
{
SHOW_MFO_ENVIROMENT_INFO
PJS_STATUS_CHECK
DG_STATUS_CHECK
echo -e " WELCOME TO MXCTL!"
PRINT_MENU
while true
do
	printf "%s " " MXCTL>"
	read cmd userconfname
		case "$cmd" in
			0|update)
				PATCH_MFO
			;;
			1|start|2|stop|2.1|11|clean|13|14)
				FUNCTION_TREATER $cmd
			;;
			1.1)
			while true
			do
			FUNCTION_TREATER $cmd
			sleep 1
			done
			;;
			1d)
				DG_START
			;;
			1p)
				PJS_START
			;;
			2d)
				DG_STOP
			;;
			2p)
				PJS_STOP
			;;
			3|check)
				RTS_STATUS_CHECK
			;;
			4|patch)
				echo -e " Where is the patch file?"
				read SETUP_FILE
				if [ -f $SETUP_FILE ]&&[ "$SETUP_FILE" != "" ]; then
					echo -e " CHECK patch file...OK ";
				else
					echo -e  " Not Found patch file, from \"$SETUP_FILE\"";
					break;
				fi
				
				echo -e " Where is the License_key?"
				read LICENSE_KEY
				if [ -f $LICENSE_KEY ]&&[ "$LICENSE_KEY" != "" ]; then
					echo -e " CHECK LICENSE_KEY...OK ";
					UNZIP_RTS_FILE
					FUNCTION_TREATER $cmd;
				else
					echo -e  " Not Found LICENSE_KEY, from \"$LICENSE_KEY\"";
				fi
				### maxgauge 폴더 체크만 추가 후 위 내용 제거
				FUNCTION_TREATER $cmd
			;;
			4dd)
				PATCH_DG
				REPO_REDEFINITE_BY_DATAGATHER		
			;;
			4ds)
				PATCH_DG
				REPO_RESET_BY_DATAGATHER
			;;
			4d)
				PATCH_DG
			;;
			4p)
				PATCH_PJS
			;;
			4ps)
				UNZIP_PJS_FILE_FOR_PATCH_SQL
			;;
			4pj)
				UNZIP_PJS_FILE_FOR_PATCH_JS
			;;
			5|conf)
				MAKE_USER_CONF
			;;
			6|dgs)
				echo -e " Please input the IP you want to change to " 
				read NEW_DGS_IP
				echo -e " Please input the PORT you want to change to " 
				read NEW_DGS_PORT
				if [ "$NEW_DGS_IP" != "" ]&&[ "$NEW_DGS_PORT" != "" ]; then
				FUNCTION_TREATER $cmd;
				fi
			;;
			7|license)
				echo -e " Where is the License_key?"
				read LICENSE_KEY
				if [ -e $LICENSE_KEY ]&&[ "$LICENSE_KEY" != "" ]; then
					echo -e " CHECK LICENSE_KEY...OK ";
					FUNCTION_TREATER $cmd;
				else
					echo -e  " Not Found LICENSE_KEY, from \"$LICENSE_KEY\"";
				fi
			;;
			8|register)
				RTS_FILES_VALID_CHECK
				# If there is no files or license then exit. 
				REGISTER_RTS_FOR_MULTI;
			;;
			9|quit|exit|q|e)
				break;
			;;
			h|hidden)
				PRINT_HIDDEN_MENU
			;;
			12)
				if [ `lsnrctl status | grep 'status READY' | wc -l` -gt 0 ]; then
					echo -e " LISTENER STATUS IS READY ";
				else
					echo -e  " LISTENER DOESN'T WOKR ";
				fi
				FUNCTION_TREATER
			;;
			*)
				if [ "$cmd" = "" ];
				then continue;
				fi;
				PRINT_MENU
				echo -e " '$cmd' is invalid command. in the rts interactive mode";
				continue
			;;
		 esac
done
}

FUNCTION_TREATER ()
{
	if [ -z  $userconfname ]; then
	SHOW_AND_CHOICE_RTSES;
	RTSES_CONF=${USER_CONF[@]};
	else
	USERS_CONF $userconfname;
	fi

for ONE_OF_CONFS in $RTSES_CONF
do
THIS_RTS_HOME=$RTS_HOMES/$ONE_OF_CONFS
. $THIS_RTS_HOME/.mxgrc
# "cmd" come from  INTERACTIVE_MODE function.
	case "$cmd" in
		1|start)
		rtsctl start
		;;
		1.1)
		echo -e " $ONE_OF_CONFS is set `cat $THIS_RTS_HOME/conf/$ONE_OF_CONFS/rts.conf| grep db_id | grep -v "#" | awk -F "=" '{print $2}'`"
		;;
		2|stop)
		rtsctl stop
		;;
		2.1)
		rtsctl stop
		rm -rf $THIS_RTS_HOME/log/$ONE_OF_CONFS/Sqlt*
		rm -rf $THIS_RTS_HOME/log/$ONE_OF_CONFS/SND/*
		echo -e  " rm -rf $THIS_RTS_HOME/log/$ONE_OF_CONFS/Sqlt*\n rm -rf $THIS_RTS_HOME/log/$ONE_OF_CONFS/SND/* has been treated."
		sed -i s/db_id\ =\ [0-99]/db_id\ =\ 0/g $THIS_RTS_HOME/conf/$ONE_OF_CONFS/rts.conf
		echo -e  " $ONE_OF_CONFS has been set `cat $THIS_RTS_HOME/conf/$ONE_OF_CONFS/rts.conf|grep "db_id ="`"
		;;
		3|check)
		;;
		4|patch)
		PATCH_RTS
		sleep 3	
		;;
		6|dgs)
		sed -i s/wr_port=[0-9]*[0-9]/wr_port=$NEW_DGS_PORT/g $THIS_RTS_HOME/conf/$ONE_OF_CONFS/rts.conf
		sed -i s/wr_host=[0-9].*[0-9]/wr_host=$NEW_DGS_IP/g $THIS_RTS_HOME/conf/$ONE_OF_CONFS/rts.conf
		 echo -e  " $THIS_RTS_HOME/conf/$ONE_OF_CONFS/rts.conf has been changed "
		;;
		7|license)
		cp $LICENSE_KEY $THIS_RTS_HOME/bin/
		echo -e  " Renewed LICENSE_KEY is located at $THIS_RTS_HOME/bin/..!"
		;;
		11|clean)
		rm -rf $THIS_RTS_HOME/log/$ONE_OF_CONFS/Sqlt*
		rm -rf $THIS_RTS_HOME/log/$ONE_OF_CONFS/SND/*
		echo -e  "rm -rf $THIS_RTS_HOME/log/$ONE_OF_CONFS/Sqlt*\n rm -rf $THIS_RTS_HOME/log/$ONE_OF_CONFS/SND/* has been treated."
		;;
		12)
		CHECK_RTS_AFTER_INSTALL
		;;
		13)
		VERS_IS=`rtsctl version | tr -d '\n'`
		echo -e "$ONE_OF_CONFS\t=> $VERS_IS"
		;;
		14)		
		PID=`ps -ef | grep -w $ONE_OF_CONFS | grep -w mxg_rts | awk '{print $2}'`							
		if [ "$ONE_OF_CONFS" == "${USER_CONF[0]}" ]; then
			echo -e  "   [Time]\t[PID]\t[%usr] [%system][%guest][%CPU] [CPU] [minflt/s][majflt/s] [VSZ]\t[RSS]\t[%MEM][kB_rd/s] [kB_wr/s][kB_ccwr/s][Command]";
		fi		
		pidstat -rud -h | grep $PID		
		;;
	esac
done
}

INTERACTIVE_MODE
