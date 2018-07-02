CONF_DIR="C:/Users/VT/Desktop/CM/SCRIPT/download_conf"
NAVIS_DIR="x:"

select_country () {    
    PS3="Select Country : "
    select COUNTRY in KR NA EU AU CN ME GEN
    do
        echo -e "'\033[33m$COUNTRY\033[m' selected. \n"
        break;
    done
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
        KR|ME|EU)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep ${COUNTRY} | grep http:// | awk '{print $4}'`
        ;;
        NA)
            LATEST_VR_VER=`cat ${CONF_DIR}/VR*.txt | grep ${COUNTRY} | grep http:// | awk '{print $4}' | head -1`
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

select_country
requisite_navi_dir_check
change_download_conf