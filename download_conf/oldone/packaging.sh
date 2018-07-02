PACK_DIR="C:/Users/VT/Downloads/build2"
CONF_DIR="C:/Users/VT/Desktop/CM/SCRIPT/download_conf"
VERSION="RJ.XX.P5.000.011.180205_gang"

select_country () {    
    PS3="Select Country : "
    select COUNTRY in KR NA EU AU CN ME GEN
    do
        echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
        break;
    done
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

select_country
extract_sys_image
mv_vr_navi
split_compress