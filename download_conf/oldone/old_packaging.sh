CONF_DIR="."
MAIN_DIR="D:\build"
DATE="180503"
SW_VERSION="RJ.KR.PV.04.1804.03-NA"
VR_SET_DIR="y:"
NAVI_SET_DIR="x:"
PACKAGING_DIR="D:\build\\${DATE}"
IMAGE_DIR="${PACKAGING_DIR}\\${SW_VERSION}\\HU\\images"

requisites_check_origin () {    
    PS3="Select Origin : "
    select COUNTRY in KR NA EU AU CN ME NORMAL WEEKLY_RELEASE
    do
        echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
        break;
    done
}

requisites_check_navi () {
    cd x:
    # 디렉토리 예제 ./KR/w03_180116_0001__KOR_11_41_55_000_001/navi_kr
    if [ -z `find ./${COUNTRY}/*18* -name "navi_*" | tail -1` ]; then
        echo no navi files
        exit
    fi

    PS3="Select Navi Dirtory : "
    select NAVI_DIR in `find ./${COUNTRY}/*18* -name "navi_*" | tail -10`
    do
        echo -e "'\033[33m${NAVI_DIR}\033[m' selected. \n"
        break;
    done
}


requisites_check_vr () {
    cd y:
    # temp 다음주에 파일이 나와바야 네이밍 규칙을 잡을 수 있을 듯 하다
    if [ -z `find ./${COUNTRY} -name "vr*.bz2" | tail -10` ]; then
        echo no vr files
        exit
    fi

    PS3="Select VR Dirtory : "
    select VR_DIR in `find ./${COUNTRY} -name "vr*.bz2" | tail -10`
    do
        echo -e "'\033[33m${VR_DIR}\033[m' selected.\n"
        break;
    done
}

pre_setup (){
    if [ -d ${PACKAGING_DIR} ]; then
        rm -rf ${PACKAGING_DIR};
    fi
    mkdir -p ${PACKAGING_DIR};
}

get_base_images () {
    print_status "01_get_base_images"
    # IMAGE_NUMBER="17118"
    echo " INPUT the Build_Image Number : "
    read IMAGE_NUMBER
    cd $PACKAGING_DIR
    BASE_FILE="hkmc-master-verify-gr-mrb-flash-usb-${IMAGE_NUMBER}.tar.bz2"
    echo -e " Start getting image \033[33m'${BASE_FILE}'\033[m "
    wget -qO $BASE_FILE http://10.178.85.23/hkcm/hkmc-master-verify-gr-mrb/${IMAGE_NUMBER}/${BASE_FILE}
}

extract_base_image () {
    print_status "02_extract_base_image"
    cd $PACKAGING_DIR
    7z.exe x hkmc*.bz2
    7z.exe x hkmc*.tar -o${SW_VERSION}
    if [ -d $IMAGE_DIR\\vrkr ]; then 
        rm -rf $IMAGE_DIR\\vrkr
        echo Delete remain vrkr Directory..!
    else
        echo "Stop this process.. because vrkr Directory doesn't exist, "
        exit
    fi
}

get_files_vr () {
    print_status "03_get_files_vr"
    cd $VR_SET_DIR
    cp -v  $VR_DIR $IMAGE_DIR
}

extract_vr () {
    print_status "04_extract_vr"
    cd $IMAGE_DIR
    7z.exe x vr*.bz2
    7z.exe x vr*.tar
    rm -rf vr*.bz2
}

get_files_navi () {
    print_status "05_get_files_navi"
    cd $NAVI_SET_DIR
    cp -av $NAVI_DIR $IMAGE_DIR
}


make_segment_zip_file () {
    echo $COUNTRY 
}

print_status () {
    BUILD_TIMESTAMP=`date +%y%m%d_%H:%M:%S`
    echo -e "\n \033[33m[Current Status]\t [TIME]\033[36m\n ${1}\t ${BUILD_TIMESTAMP}\033[m\n\n"
}

requisites_check_origin
pre_setup

case $COUNTRY in
    KR|NA|EU|AU|CN|ME|NORMAL)
        requisites_check_navi $COUNTRY
        requisites_check_vr $COUNTRY
        get_base_images
        extract_base_image
        get_files_vr $COUNTRY
        extract_vr
        get_files_navi $COUNTRY
        make_segment_zip_file
    ;;
    WEEKLY_RELEASE)
        echo hi;
    ;;
esac