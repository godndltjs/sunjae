CONF_DIR="C:/Users/VT/Desktop/CM/SCRIPT/download_conf"
PACK_DIR="C:/Users/VT/Downloads/build2"
NAVIS_DIR="x:"
VERSION="RJ.XX.PV.04.1806.03"

select_country () {
    case $COUNTRY in
        KR|NA|EU|AU|CN|ME|GEN)
            echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
        ;;

        *)
            PS3="Select Country : "
            select COUNTRY in KR NA EU AU CN ME GEN
            do
                echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
                break;
            done
        ;;
    esac
}

print_status () {
    BUILD_TIMESTAMP=`date +%y%m%d_%H:%M:%S`
    echo -e "\n \033[33m[Current Status]\t [TIME]\033[36m\n ${1}\t ${BUILD_TIMESTAMP}\033[m\n"
}

requisite_navi_dir_check () {
    case $COUNTRY in
        KR|ME|EU|AU|NA)
            NAVI_FILE="navi_"
            get_navi_dir  
        ;;
        CN)
            NAVI_FILE="w02"
            get_navi_dir
            
        ;;
        GEN)
            NAVI_DIR=""
            echo "GEN doesn't navi files"
            NAVI_FILE="navi"
        ;;
    esac
}

get_navi_dir () {
    # navi file existing check
    if [ -z `find ${NAVIS_DIR}/${COUNTRY}/*18* -name "${NAVI_FILE}*" | tail -1` ]; then
        echo no navi files
        exit
    fi

    # GET Navi Dir ADDRESS
    PS3="Select Navi Dirtory : "
    select NAVI_DIR in `find ${NAVIS_DIR}/${COUNTRY}/*18* -name "*${NAVI_FILE}*" | tail -10 | tr -d '\.'`
    do
        echo -e "'\033[33m${NAVI_DIR}\033[m' selected. \n"
        break;
    done
}

change_download_conf() {
    # GET VR_LINK ADDRESS
    case $COUNTRY in
        ME|EU)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep ${COUNTRY} | grep http:// | awk '{print $4}'`
        ;;
        NA)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep ${COUNTRY} | grep http:// | awk '{print $4}' | head -1`
        ;;
        KR)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep KOR | grep http:// | awk '{print $4}'`
        ;;
        GEN)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep ME | grep http:// | awk '{print $4}'`
        ;;
        AU)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep ENA | grep http:// | awk '{print $4}'`
        ;;
        CN)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep CHN | grep http:// | awk '{print $4}'`
        ;;
    esac
    sed -i 's#NAVI_LINK=.*#NAVI_LINK='$NAVI_DIR'#g' ${CONF_DIR}/${COUNTRY}.conf
    sed -i 's#VR_LINK=.*#VR_LINK='$LATEST_VR_VER'#g' ${CONF_DIR}/${COUNTRY}.conf
    . ${CONF_DIR}/${COUNTRY}.conf
    echo $NAVI_LINK
    echo $VR_LINK
}

download_vr () {
    # Link 다운로드 불가시 에러처리 어떻게 해야하나
    . ${CONF_DIR}/${COUNTRY}.conf
    VR_IMAGE="${PACK_DIR}/VR_${COUNTRY}"
    wget -O ${VR_IMAGE}.tar.bz2  $VR_LINK
    if [ $? = 1 ]; then echo " Incorrect Download Link, Can't Download VR "; exit; fi
    7z.exe x ${VR_IMAGE}.tar.bz2 -o${PACK_DIR} && rm -rf ${VR_IMAGE}.tar.bz2
    7z.exe x ${VR_IMAGE}.tar     -o${PACK_DIR}/${COUNTRY} && rm -rf ${VR_IMAGE}.tar
}

download_navi () {
    . ${CONF_DIR}/${COUNTRY}.conf
    case $COUNTRY in
        KR|ME|EU|AU|NA)
            cp -av ${NAVI_LINK} ${PACK_DIR}/${COUNTRY}
        ;;
        CN)
            cp -av ${NAVI_LINK}/* ${PACK_DIR}/${COUNTRY}
        ;;
        GEN)
            echo "GEN doesn't have navi files"
        ;;
    esac
}

download_system_image () {
    . ${CONF_DIR}/SYSTEM.conf
    SYS_IMAGE=${PACK_DIR}/${SYSTEM_IMAGE_NAME}
    if [ ! -f ${SYS_IMAGE}.tar ]; then 
        wget -O ${SYS_IMAGE}.tar.bz2  $SYSTEM_IMAGE_LINK
        if [ $? = 1 ]; then echo " Incorrect Download Link, Can't Download SYS Image "; exit; fi
        7z.exe x ${SYS_IMAGE}.tar.bz2 -o${PACK_DIR}  && rm -rf ${SYS_IMAGE}.tar.bz2
    fi
}

extract_sys_image () {
    . ${CONF_DIR}/SYSTEM.conf
    SYS_IMAGE=${PACK_DIR}/${SYSTEM_IMAGE_NAME}
    if [ ! -f ${SYS_IMAGE}.tar ]; then echo "No System Image file" ; exit; fi
    if [ ! -d ${PACK_DIR}/${COUNTRY} ]; then echo "No navi and vr file" ; exit; fi
    7z.exe x ${SYS_IMAGE}.tar   -o${PACK_DIR}/${VERSION}-${COUNTRY}
}

mv_vr_navi () {
    if [ -d ${PACK_DIR}/${VERSION}-${COUNTRY}/HU/images/vrkr ]; then
        rm -rf ${PACK_DIR}/${VERSION}-${COUNTRY}/HU/images/vrkr
        echo "rm -rf existing vrkr"
    fi
    mv $PACK_DIR/${COUNTRY}/*   ${PACK_DIR}/${VERSION}-${COUNTRY}/HU/images &&    rm -rf $PACK_DIR/${COUNTRY}
}

split_compress () {
    cd ${PACK_DIR}
    7z.exe -tzip a ${VERSION}-${COUNTRY}.zip -mx0 -v4096m ${VERSION}-${COUNTRY}
}

check_conf_file () {
    . ${CONF_DIR}/SYSTEM.conf
    . ${CONF_DIR}/${COUNTRY}.conf
    echo -e " LAVI_DIR : $NAVI_LINK"
    echo -e " VR_LINK  : $VR_LINK"
    echo -e " IMAGE_NUM : $IMAGE_NUM"
}

step0_check () {
    select_country
    check_conf_file
}

step1_change_conf_file (){
    select_country
    requisite_navi_dir_check
    change_download_conf
}

step2_download () {
    print_status "step2_download start"
    select_country
    download_vr
    download_navi
    download_system_image
    print_status "step2_download finish"
}

step3_package () {
    print_status "step3_package start"
    select_country
    extract_sys_image
    mv_vr_navi
    split_compress
    print_status "step3_package finish"
}


print_menu()
{
	echo -e " =========================================================================="
	echo -e " [1] change conf file      : changes download conf file."
    echo -e " [2] download & package    : downloads files & makes package. "
	echo -e " [3] download              : downloads files. "
	echo -e " [4] package               : makes package. "
	echo -e " [5] check                 : checks conf files."
    echo -e " [0] quit|q|exit|e         : exits PACKER"
	echo -e " =========================================================================="
}

interactive_mode()
{
    echo -e " WELCOME TO PACKER!"
    print_menu
    while true
    do
        if [ $# -gt 0 ]; then
            cmd=$1
            COUNTRY=$2
        else
            printf "%s " " PACKER>"
            read cmd
        fi

        case "$cmd" in
            1)
                step1_change_conf_file
            ;;

            2)
                step0_check
                step2_download
                step3_package
            ;;

            3)
                step2_download
            ;;

            4)
                step3_package
            ;;

            5)
                step0_check
            ;;

            0|quit|exit|q|e)
                break;
            ;;

            *)
                if [ "$cmd" = "" ]; then 
                    continue;
                fi
                print_menu
                echo -e " '$cmd' is invalid command. in the rts interactive mode";
                continue
            ;;
        esac
        if [ $# -gt 0 ]; then   break;  fi
    done
}

interactive_mode $1 $2