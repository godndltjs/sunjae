CONF_DIR="C:/Users/VT/Desktop/CM/SCRIPT/download_conf"
PACK_DIR="C:/Users/VT/Downloads/build2"
NAVIS_DIR="x:"
CAL_DIR="C:/Users/VT/Desktop/CM/SCRIPT"
WHO_AM_I="sunghoon.baek"

step0_select_country () {
    case $COUNTRY in
        KOR|USA|EUR|AUS|CHN|MDE|RUS|GEN|TUR)
            echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
        ;;

        *)
            PS3="Select Country ( Input the number ): "
            select COUNTRY in KOR USA EUR AUS CHN MDE RUS GEN TUR
            do
                echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
                break;
            done
        ;;
    esac
    . ${CONF_DIR}/SYSTEM.conf
    . ${CONF_DIR}/${COUNTRY}.conf
    VERSION="${VERSION_PREFIX}.${COUNTRY}.${VERSION_SUFFIX}"
}

print_status () {
    BUILD_TIMESTAMP=`date +%y%m%d_%H:%M:%S`
    echo -e "\n \033[33m[Current Status]\t [TIME]\033[36m\n ${1}\t ${BUILD_TIMESTAMP}\033[m\n"
    echo -e "\n [Current Status]\t\t   [TIME]\n ${1}\t ${BUILD_TIMESTAMP}" >> ${PACK_DIR}/package_history.txt
    call_google_calendar 3 # need three for status
}

call_google_calendar () {
    T_LINE=${1}
    COMMENT=`tail -${T_LINE} ${PACK_DIR}/package_history.txt`
    python ${CAL_DIR}/cal.py ${VERSION} "${COMMENT}"
}

requisite_navi_dir_check () {
    case $COUNTRY in
        KOR|MDE|EUR|AUS|USA|RUS|CHN|TUR)
            NAVI_FILE="navi_"
            get_navi_dir  
        ;;

        GEN)
            echo "GEN doesn't navi files"
            NAVI_DIR=""
            NAVI_FILE="navi"
        ;;
    esac
}

get_navi_dir () {
    # navi file existing check
    case $COUNTRY in
        MDE)
            NAVI_COUNTRY="MES"
        ;;

        USA)
            NAVI_COUNTRY="NAM"
        ;;

        *)
            NAVI_COUNTRY=${COUNTRY}
        ;;
    esac

    if [ -z `find ${NAVIS_DIR}/${NAVI_COUNTRY}/*18* -name "${NAVI_FILE}*" | tail -1` ]; then
        echo no navi files
        exit
    fi
    PS3="Select Navi Dirtory : "
    select NAVI_DIR in `find ${NAVIS_DIR}/${NAVI_COUNTRY}/*18* -name "*${NAVI_FILE}*" | tail -10 | tr -d '\.'`
    do
        echo -e "'\033[33m${NAVI_DIR}\033[m' selected. \n"
        break;
    done
}

change_download_conf() {
    # GET VR_LINK ADDRESS
    case $COUNTRY in
        KOR|CHN)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep ${COUNTRY} | grep http:// | awk '{print $5}'`
        ;;
        EUR|RUS|TUR)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep EU | grep http:// | awk '{print $5}'`
        ;;
        MDE|GEN)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep ME | grep http:// | awk '{print $5}'`
        ;;
        USA)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep NA | grep http:// | awk '{print $5}' | head -1`
        ;;
        AUS)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep ENA | grep http:// | awk '{print $5}'`
        ;;

    esac
    sed -i 's#NAVI_LINK=.*#NAVI_LINK='$NAVI_DIR'#g' ${CONF_DIR}/${COUNTRY}.conf
    sed -i 's#VR_LINK=.*#VR_LINK='$LATEST_VR_VER'#g' ${CONF_DIR}/${COUNTRY}.conf
    . ${CONF_DIR}/${COUNTRY}.conf
    echo $NAVI_LINK
    echo $VR_LINK
}

remove_country_dir () {
    if [ -d ${PACK_DIR}/${COUNTRY} ]; then
        rm -rf ${PACK_DIR}/${COUNTRY}; 
        echo " remove existing vr_navi files" 
    fi
}

download_vr () {
    VR_IMAGE="${PACK_DIR}/${VR_NAME}"
    wget -O ${VR_IMAGE}.tar.bz2  $VR_LINK
    if [ $? = 1 ]; then echo " Incorrect Download Link, Can't Download VR "; exit; fi
    7z.exe x ${VR_IMAGE}.tar.bz2 -o${PACK_DIR} && rm -rf ${VR_IMAGE}.tar.bz2
    7z.exe x ${VR_IMAGE}.tar     -o${PACK_DIR}/${COUNTRY} && rm -rf ${VR_IMAGE}.tar
}

download_navi () {
    if [ ! -d ${PACK_DIR}/${COUNTRY} ]; then mkdir -p ${PACK_DIR}/${COUNTRY}; fi 
    case $COUNTRY in
        KOR|MDE|EUR|AUS|USA|RUS|CHN|TUR)
            cp -av ${NAVI_LINK} ${PACK_DIR}/${COUNTRY}
        ;;

        GEN)
            echo "GEN doesn't have navi files"
        ;;
    esac
}

download_system_image () {
    SYS_IMAGE=${PACK_DIR}/${SYSTEM_IMAGE_NAME}
    if [ ! -f ${SYS_IMAGE}.tar ]; then 
        wget -O ${SYS_IMAGE}.tar.bz2  $SYSTEM_IMAGE_LINK
        # Link ??????? ?????? ????
        if [ $? = 1 ]; then echo " Try another link with rj or hi keyword "; exit; echo here; fi
        7z.exe x ${SYS_IMAGE}.tar.bz2 -o${PACK_DIR}; #  && rm -rf ${SYS_IMAGE}.tar.bz2
    fi
}

extract_sys_image () {
    SYS_IMAGE=${PACK_DIR}/${SYSTEM_IMAGE_NAME}
    if [ ! -f ${SYS_IMAGE}.tar ]; then echo " No System Image file (${SYS_IMAGE}.tar)" ; exit; fi
    if [ ! -d ${PACK_DIR}/${COUNTRY} ]; then echo " No navi and vr file (${PACK_DIR}/${COUNTRY})" ; exit; fi
    7z.exe x ${SYS_IMAGE}.tar   -o${PACK_DIR}/${VERSION}
}

mv_vr_navi () {
    if [ -d ${PACK_DIR}/${VERSION}/HU/images/vrkr ]; then
        rm -rf ${PACK_DIR}/${VERSION}/HU/images/vrkr;
        echo "rm -rf existing vrkr";
    fi
    mv $PACK_DIR/${COUNTRY}/*   ${PACK_DIR}/${VERSION}/HU/images &&    rm -rf $PACK_DIR/${COUNTRY}
}

split_compress () {
    cd ${PACK_DIR}
    if [ -d ${VERSION} ]; then
        7z.exe -tzip a ${VERSION}.zip -mx0 -v4096m ${VERSION};
    else
        echo " Directory '${VERSION}' does not exist. Pls, Check again "
    fi
}

check_conf_file () {
    . ${CONF_DIR}/SYSTEM.conf
    . ${CONF_DIR}/${COUNTRY}.conf
    echo -e " \033[33mSW_VERSION : $VERSION\033[m"
    echo -e "\n [ PACKAGE VERSION CHECK ]" >> ${PACK_DIR}/package_history.txt
    echo -e " SW_VERSION : $VERSION" >> ${PACK_DIR}/package_history.txt
    echo -e " NAVI_DIR : $NAVI_LINK" | tee -a ${PACK_DIR}/package_history.txt
    echo -e " VR_LINK  : $VR_LINK" | tee -a ${PACK_DIR}/package_history.txt
    echo -e " SYS_IMAGE_NUM : $SYSTEM_IMAGE_LINK" | tee -a ${PACK_DIR}/package_history.txt
    echo -e " Packaged by $WHO_AM_I" | tee -a ${PACK_DIR}/package_history.txt
    call_google_calendar 6 # need five line for version info
}

call_jenkins_api_gang_image_job (){
    step0_select_country
    . ${CONF_DIR}/SYSTEM.conf
    . ${CONF_DIR}/${COUNTRY}.conf

    # MODEL SELECTED
    case $VERSION_PREFIX in
        RJ|FE)
            # FE model have to be written down RJ
            MODEL="RJ_FE";
        ;;

        HI|DH19MY)
            MODEL=$VERSION_PREFIX;
        ;;

        *)
        echo " MODEL NAME dosen't involved RJ,FE,HI,DH19MY, check angin what you write. "
        ;;
    esac

    # CONVERTE COUNTRY NAME FOR GANG IAMGE SCRIPT 
    case $COUNTRY in
        KOR|GEN|USA)
            GANG_COUNTRIES=$COUNTRY
        ;;

        EUR|AUS)
            GANG_COUNTRIES=`echo $COUNTRY | cut -c 1,2`
        ;;

        MDE)
            GANG_COUNTRIES=`echo $COUNTRY | cut -c 1,3`
        ;;
        
        CHN)
            GANG_COUNTRIES="CHINA"
        ;;

        RUS)
            GANG_COUNTRIES="RUSSIA"
        ;;

        TUR)
            GANG_COUNTRIES="TURKEY"
        ;;
    esac

   NAVI_DIR=`echo $NAVI_LINK | tr -d 'x:'`

    DATE=`date +%y%m%d`
    curl -X POST  http://binary.lge.com:8093/lap/build/job/hkmc-gang-country/build \
    --user sunghoon.baek:c823422af798680aff5537a79008aad6 \
    --data-urlencode json='{"parameter": [{"name":"SW_IMG_URL", "value":"'${SYSTEM_IMAGE_LINK}'"}, {"name":"COUNTRIES", "value":"'${GANG_COUNTRIES}'"}, {"name":"MODEL", "value":"'${MODEL}'"}, {"name":"HKMC_NAVI_IMAGE", "value":"'${NAVI_DIR}'"}, {"name":"HKMC_VR_IMAGE", "value":"'${VR_LINK}'"}]}'
    echo "Call jenkins api gang image job"

}

step4_check () {
    step0_select_country
    check_conf_file
}

step1_change_conf_file (){
    step0_select_country
    requisite_navi_dir_check
    change_download_conf
}

step2_download () {
    step0_select_country
    print_status "step2_download_start"
    remove_country_dir
    download_vr
    download_navi
    download_system_image
    print_status "step2_download_finish"
}

step3_package () {
    step0_select_country
    print_status "step3_package_start"
    extract_sys_image
    mv_vr_navi
    split_compress
    print_status "step3_package_finish"
}

step3_2_only_package () {
    step0_select_country
    print_status "step3_package_start"
    split_compress
    print_status "step3_package_finish"
}

step3_1_sys_image_downlaod_and_package () {
    step0_select_country
    print_status "step2_download start"
    download_system_image
    print_status "step3_package start"
    extract_sys_image
    mv_vr_navi
    split_compress
    print_status "step3_package finish"
}

print_menu()
{
	echo -e " =========================================================================="
	echo -e " \033[33m[ 1 ] change conf file      : changes download conf file.\033[m"
    echo -e " \033[33m[ 2 ] download & package    : downloads files & makes package.\033[m "
	echo -e " [2.1] down sys_img & pack   : sys_img & pack."
	echo -e " [ 3 ] download              : downloads files."
	echo -e " [3.1] only sys_img download : only sys_img download."
	echo -e " [3.2] only vr download      : only vr download."
	echo -e " [3.3] only navi download    : only navi download."
	echo -e " [ 4 ] package               : makes package."
	echo -e " [ 5 ] check                 : checks conf files."
	echo -e " [ 6 ] only compress         : compress."
    echo -e " [ 7 ] make gang img         : gang."
    echo -e " [ 0 ] quit|q|exit|e         : exits PACKER"
	echo -e " =========================================================================="
}

interactive_mode()
{
    echo -e " WELCOME TO PACKER!"
    print_menu
    while true
    do
        if [ $# -gt 0 ]; then
            # Non Interactive mode
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
                step4_check
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
                step4_check
            ;;

            6)
                step3_2_only_package
            ;;

            7)
                call_jenkins_api_gang_image_job
            ;;

            2.1)
                step3_1_sys_image_downlaod_and_package
            ;;

            3.1)
                step0_select_country
                download_system_image
            ;;

            3.2)
                step0_select_country
                download_vr
            ;;

            3.3)
                step0_select_country
                download_navi
            ;;

            0|quit|exit|q|e)
                break;
            ;;

            *)
                if [ "$cmd" = "" ]; then 
                    continue;
                fi
                print_menu
                echo -e "\033[31m '$cmd'\033[m is invalid command. in the interactive mode";
            ;;
        esac
        unset COUNTRY
        if [ $# -gt 0 ]; then   break;  fi
    done
}

interactive_mode $1 $2