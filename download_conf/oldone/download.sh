CONF_DIR="C:/Users/VT/Desktop/CM/SCRIPT/download_conf"
PACK_DIR="C:/Users/VT/Downloads/build2"

select_country () {    
    PS3="Select Country : "
    select COUNTRY in KR NA EU AU CN ME GEN
    do
        echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
        break;
    done
    # 경로 생성부분
    mkdir -p $PACK_DIR\\${COUNTRY}
}

download_vr () {
    # Link 다운로드 불가시 에러처리 어떻게 해야하나
    . ${CONF_DIR}/${COUNTRY}.conf
    VR_IMAGE="${PACK_DIR}/VR_${COUNTRY}"
    wget -O ${VR_IMAGE}.tar.bz2  $VR_LINK
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
        7z.exe x ${SYS_IMAGE}.tar.bz2 -o${PACK_DIR}  && rm -rf ${SYS_IMAGE}.tar.bz2
    fi
}

select_country
download_vr
download_navi
download_system_image
#     echo $NAVI_LINK
#     echo $VR_LINK