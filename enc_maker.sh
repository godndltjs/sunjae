#!/bin/bash
## written by P5 CM

check_download_link () {
    DOWNLOAD_LINK=$1
    echo -e " \033[33m DOWNLOAD LINK TEST : ${DOWNLOAD_LINK} \033[m"
    wget --spider ${DOWNLOAD_LINK}
    if [ $? != 0 ]; then
        echo -e " Incorrect Download Link, ${DOWNLOAD_LINK} "; exit;
    else
        echo -e " \033[33m DOWNLOAD LINK TEST : PASS \033[m"
    fi
}

check_file_from_smbserver () {
    SMB_NAVI_DIR=$1
    SMB_FILE_COUNT=`smbclient -U AdminCM%dhavn11 //10.158.4.18/고급형5세대_Navigation/ -c 'cd '${SMB_NAVI_DIR}'; ls' | grep -E navi[0-9].tar | wc -l`
    if [ 0 -ge $SMB_FILE_COUNT ]; then 
        echo -e " Incorrect NAVI DIR, ${SMB_NAVI_DIR}. "; exit; 
    else
        echo -e " \033[33m SAMBA SERVER FILE VALID TEST : PASS \033[m"
    fi
}

download_system_image () {
    SYSTEM_IMAGE_LINK=$1
    SYS_IMAGE=`basename $SYSTEM_IMAGE_LINK`
    if [ -f ${SYS_IMAGE} ]; then rm -rf ${SYS_IMAGE}; echo -e " rm -rf existing system img" ; fi
    wget $SYSTEM_IMAGE_LINK
    echo -e ${SYS_IMAGE}

    # make package dir start
    PACK_DIR=`pwd` # temp

    mkdir -p ${PACK_DIR}/test
    tar xvf ${SYS_IMAGE} -C ${PACK_DIR}/test  && rm -rf ${SYS_IMAGE}

    VERSION=`cat ${PACK_DIR}/test/.lge.upgrade.xml | grep \<version\> | tr -d "\</version\> "`-enc
    if [ -d ${PACK_DIR}/${VERSION} ]; then
        rm -rf ${PACK_DIR}/${VERSION}; 
        echo -e " remove remain package files" 
    fi
    mv ${PACK_DIR}/test ${PACK_DIR}/${VERSION}

    if [ -d ${PACK_DIR}/${VERSION}/HU/images/vrkr ]; then
        rm -rf ${PACK_DIR}/${VERSION}/HU/images/vrkr;
        echo -e "rm -rf existing vrkr";
    fi
}

download_vr () {
    VR_LINK=$1
    VR_IMAGE=`basename $VR_LINK`
    wget  $VR_LINK
    tar -xvf ${VR_IMAGE} -C ${PACK_DIR}/${VERSION}/HU/images && rm -rf ${VR_IMAGE}
}

download_navis () {
    SMB_NAVI_DIR=$1
    # need to make navi download dir in advance
    mkdir -p ${PACK_DIR}/${VERSION}/HU/images/${SELECTED_NAVI_DIR}
    cd ${PACK_DIR}/${VERSION}/HU/images/${SELECTED_NAVI_DIR}
    smbget -q -u=AdminCM -p=dhavn11 -R smb://10.158.4.18/고급형5세대_Navigation/${SMB_NAVI_DIR}
    if [ $? = 1 ]; then echo -e " Incorrect smb download Link, smb://10.158.4.18/고급형5세대_Navigation/${SMB_NAVI_DIR}. "; exit; fi
}

step0_setting_default_values () {
    # CONVERT_COUNTRY_NAME_FOR_SCRIPT
    LOWER_CHAR_COUNTRY=`echo -e ${COUNTRY} | tr -s  '[:upper:]' '[:lower:]'`
    case ${COUNTRY} in
        KOR|CHN|MDE|TUR)
            TWO_CHAR_COUNTRY=`echo -e ${COUNTRY} | cut -c 1,3 | tr -s  '[:upper:]' '[:lower:]'`
            ENCRYPT_KEY="key_premimum5/prm-avn5-${LOWER_CHAR_COUNTRY}"
            if_country_is_tur_or_rus # then, key will be replaced eur one
            SELECTED_NAVI_DIR="navi_${TWO_CHAR_COUNTRY}"
            APPNAVI_FILE="${SELECTED_NAVI_DIR}/appnavi.tar"
            echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
        ;;

        USA|AUS|EUR|RUS)
            TWO_CHAR_COUNTRY=`echo -e ${COUNTRY} | cut -c 1,2 | tr -s  '[:upper:]' '[:lower:]'`
            ENCRYPT_KEY="key_premimum5/prm-avn5-${LOWER_CHAR_COUNTRY}"
            if_country_is_tur_or_rus # then, key will be replaced eur one
            SELECTED_NAVI_DIR="navi_${TWO_CHAR_COUNTRY}"
            APPNAVI_FILE="${SELECTED_NAVI_DIR}/appnavi.tar"
            echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
        ;;

        GEN)
            # GEN doesn't have navi dir except vrme
            ENCRYPT_KEY="key_premimum5/prm-avn5-${LOWER_CHAR_COUNTRY}"
            SELECTED_APPNAVI_FILE="NONE"
        ;;

        *)
            echo -e "'\033[33m$COUNTRY\033[m' is not valid COUNTRY. \n"
            PS3="Select Country (Input the number): "
            select COUNTRY in KOR USA EUR AUS CHN MDE RUS GEN TUR
            do
                echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
                break;
            done
        ;;
    esac

    print_confirm_page
}

if_country_is_tur_or_rus () {
    if [ "${COUNTRY}" = "TUR" ]||[ "${COUNTRY}" = "RUS" ]; then
        ENCRYPT_KEY="key_premimum5/prm-avn5-eur"
    fi
}

print_confirm_page () {
    echo -e "============================="
    echo -e "\033[31m#COUNTRY           is ${COUNTRY}";
    echo -e "\033[31m#Key          file is ${ENCRYPT_KEY}";
    echo -e "\033[31m#appnavi      file is ${APPNAVI_FILE}";
    echo -e "\033[00m============================="
}

encrypt_func () {
    WILL_BE_ENC_FILE=$1
    if [ ! -f ${ENCRYPT_KEY} ]; then
        echo -e "[[Error!!! Please check ${ENCRYPT_KEY} file !!]]";  exit 1;
    fi
    mv ${WILL_BE_ENC_FILE} ${WILL_BE_ENC_FILE}_temp
    ./EncryptLGU -e ${WILL_BE_ENC_FILE}_temp ${WILL_BE_ENC_FILE} ${ENCRYPT_KEY} && rm -rf ${WILL_BE_ENC_FILE}_temp
    if [ $? != 0 ]; then
        echo -e "[[internal error!!!! please contact encrypt expert. (${WILL_BE_ENC_FILE})!!]]";  exit 1;
    fi
}

encrypt_list () {
    ############                STEP 2               ##################
    echo -e "\033[33m Now! make encrypt each files... \033[m"

    # AppUpgrade #.lge.upgrade.xml
    encrypt_func ${PACK_DIR}/${VERSION}/AppUpgrade
    encrypt_func ${PACK_DIR}/${VERSION}/.lge.upgrade.xml

    # update.tar.gz
    encrypt_func ${PACK_DIR}/${VERSION}/HU/firmware/update.tar.gz

    # iasImage, mango-rootfs.tar.gz, mango-rwdata.tar.gz
    encrypt_func ${PACK_DIR}/${VERSION}/HU/images/iasImage
    encrypt_func ${PACK_DIR}/${VERSION}/HU/images/iasImage_p5
    encrypt_func ${PACK_DIR}/${VERSION}/HU/images/iasImage_1280
    encrypt_func ${PACK_DIR}/${VERSION}/HU/images/iasImage_p5_1280
    encrypt_func ${PACK_DIR}/${VERSION}/HU/images/mango-rootfs.tar
    encrypt_func ${PACK_DIR}/${VERSION}/HU/images/mango-rwdata.tar

    # appnavi.tar
    if [ "${COUNTRY}" != "GEN" ]; then 
        # GEN doesn't have navi dir
        encrypt_func ${PACK_DIR}/${VERSION}/HU/images/${APPNAVI_FILE}
    fi

    #modem_xx.tar.gz
    for MODEM_COUNTRY in ca kr ch us eu
    do
        SELECTED_MODEM="${PACK_DIR}/${VERSION}/HU/firmware/modem/${MODEM_COUNTRY}/modem_${MODEM_COUNTRY}.tar.gz"
        if [ -f ${SELECTED_MODEM} ]; then
            encrypt_func ${SELECTED_MODEM}
        fi
    done
}

split_compress () {
    echo -e
}

upload_to_nas () {
    # upload to nas
    echo -e
}

COUNTRY=$1
SYSTEM_IMAGE_LINK=$2
VR_LINK=$3
SMB_NAVI_DIR=$4

step0_setting_default_values ${COUNTRY}
check_download_link ${SYSTEM_IMAGE_LINK}
check_download_link ${VR_LINK}
if [ ! -z ${SMB_NAVI_DIR} ]; then
    check_file_from_smbserver ${SMB_NAVI_DIR}
fi
download_system_image ${SYSTEM_IMAGE_LINK}
download_vr ${VR_LINK}
pushd `pwd`
if [ ! -z ${SMB_NAVI_DIR} ]; then
        download_navis ${SMB_NAVI_DIR}
fi
popd 
encrypt_list
