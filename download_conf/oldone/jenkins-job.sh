#!/bin/bash

# Variables
BUILD_SCRIPT_VERSION="0.2.0"
BUILD_SCRIPT_NAME=`basename ${0}`

BUILD_TOPDIR="${WORKSPACE}/build"
BUILD_MIRROR_ROOT="/mnt/mirror-write/khmc/master"
BUILD_MIRROR_MCF_PREMIRROR="--premirror=file://${BUILD_MIRROR_ROOT}/downloads"
BUILD_MIRROR_MCF_SSTATEMIRROR="--sstatemirror=file://${BUILD_MIRROR_ROOT}/sstate-cache"
BUILD_MIRROR_WRITE_DL_DIR="${BUILD_MIRROR_ROOT}/downloads"
BUILD_MIRROR_WRITE_SSTATE_DIR="${BUILD_MIRROR_ROOT}/sstate-cache"

BUILD_MCF_BITBAKE_THREADS="-b 8"
BUILD_MCF_MAKE_THREADS="-p 16"

BUILD_ENABLE_PREMIRROR="N"
BUILD_ENABLE_SSTATEMIRROR="N"
BUILD_ENABLE_DL_DIR="N"
BUILD_ENABLE_SSTATE_DIR="N"
BUILD_ENABLE_SDK="N"

BUILD_TIMESTAMP_START=`date -u +%s`
BUILD_TIMESTAMP_OLD=${BUILD_TIMESTAMP_START}

BUILD_FETCHDIR="${BUILD_TOPDIR}/metalayers/meta-mango"
BUILD_IMAGE="pap-image-emmc"
BUILD_FLASH="pap-flash"
BUILD_SDK="pap-bdk"

# Enable rsyncing artifacts, disabled by default, to enable you need to set BUILD_ARTIFACTS_TARGET_DIR path as well (e.g. official builds have 'starfish/${BUILD_NUMBER}/')
BUILD_ENABLE_RSYNC_ARTIFACTS_DEFAULT="N"
[ -n "${BUILD_ENABLE_RSYNC_ARTIFACTS}" ] || BUILD_ENABLE_RSYNC_ARTIFACTS="${BUILD_ENABLE_RSYNC_ARTIFACTS_DEFAULT}"

# Path where clean builds will rsync BUILD-ARTIFACTS directory (when not empty - by default disabled)
BUILD_ARTIFACTS_TARGET_DIR_DEFAULT=""
[ -n "${BUILD_ARTIFACTS_TARGET_DIR}" ] || BUILD_ARTIFACTS_TARGET_DIR="${BUILD_ARTIFACTS_TARGET_DIR_DEFAULT}"

BUILD_SSH_FILESERVER_DEFAULT="user@10.178.85.23"
[ -n "${BUILD_SSH_FILESERVER}" ] || BUILD_SSH_FILESERVER="${BUILD_SSH_FILESERVER_DEFAULT}"

BUILD_SSH_FILESERVER_ROOT_DEFAULT="/home/artifacts/spx"
[ -n "${BUILD_SSH_FILESERVER_ROOT}" ] || BUILD_SSH_FILESERVER_ROOT="${BUILD_SSH_FILESERVER_ROOT_DEFAULT}"

BUILD_DOWNLOAD_SITE_SWP_DEFAULT="http://10.178.85.23"
[ -n "${BUILD_DOWNLOAD_SITE_SWP}" ] || BUILD_DOWNLOAD_SITE_SWP="${BUILD_DOWNLOAD_SITE_SWP_DEFAULT}"

BUILD_GERRIT_SITE_DEFAULT="http://binary.lge.com:8093/lap/build/job"
[ -n "${BUILD_GERRIT_SITE}" ] || BUILD_GERRIT_SITE="${BUILD_GERRIT_SITE_DEFAULT}"

# Functions
function print_timestamp {
    BUILD_TIMESTAMP=`date -u +%s`
    BUILD_TIMESTAMPH=`date -u +%Y%m%dT%TZ`

    local BUILD_TIMEDIFF=`expr ${BUILD_TIMESTAMP} - ${BUILD_TIMESTAMP_OLD}`
    local BUILD_TIMEDIFF_START=`expr ${BUILD_TIMESTAMP} - ${BUILD_TIMESTAMP_START}`
    BUILD_TIMESTAMP_OLD=${BUILD_TIMESTAMP}
    printf "TIME: ${BUILD_SCRIPT_NAME}-${BUILD_SCRIPT_VERSION} ${1}: ${BUILD_TIMESTAMP}, +${BUILD_TIMEDIFF}, +${BUILD_TIMEDIFF_START}, ${BUILD_TIMESTAMPH}\n"
}

function parse_job_name {
    case ${JOB_NAME} in
        *-official-*)
            JOB_BUILD_TYPE="official"
        ;;
        *-engineering-*)
            JOB_BUILD_TYPE="engr"
        ;;
        *-verify-*)
            JOB_BUILD_TYPE="verf"
        ;;
        *-integrate-*)
            JOB_BUILD_TYPE="integr"
        ;;
        *-sdk-*)
            JOB_BUILD_TYPE="sdk"
        ;;
        *)
            echo "ERROR: ${BUILD_SCRIPT_NAME}-${BUILD_SCRIPT_VERSION} Unrecognized JOB_BUILE_TYPE in ${JOB_NAME}" && exit 1
        ;;
    esac
    case ${JOB_NAME} in
        *-gr-mrb*)
            JOB_BUILD_MACHINE="gr-mrb-64"
        ;;
        *)
            echo "ERROR: ${BUILD_SCRIPT_NAME}-${BUILD_SCRIPT_VERSION} Unrecognized JOB_BUILE_MACHINE in ${JOB_NAME}" && exit 1
        ;;
    esac
    case ${JOB_NAME} in
    *-master-*)
        JOB_BUILD_BRANCH="master"
    ;;
    *-NOEC16-*)
        JOB_BUILD_BRANCH="@NOEC16"
    ;;
    *)
    echo "ERROR:  ${BUILD_SCRIPT_NAME}-${BUILD_SCRIPT_VERSION} Unrecognized JOB_BUILE_BRANCH in ${JOB_NAME}" && exit 1
    esac

    if [ $GERRIT_BRANCH ]; then
        JOB_BUILD_BRANCH="$GERRIT_BRANCH"
    fi
}

function apply_job_specific_rules() {
    if [ "${JOB_BUILD_TYPE}" = "official" ] ; then
        BUILD_ENABLE_PREMIRROR="Y"
        BUILD_ARTIFACTS_TARGET_DIR="hkmc/${JOB_NAME}/${BUILD_NUMBER}"
        BUILD_ENABLE_RSYNC_ARTIFACTS="Y"
        #BUILD_FLASH="pap-image-emmc"
    elif [ "${JOB_BUILD_TYPE}" = "verf" -o "${JOB_BUILD_TYPE}" = "integr" ]; then
        BUILD_ENABLE_PREMIRROR="Y"
        BUILD_ENABLE_SSTATEMIRROR="Y"
        BUILD_ARTIFACTS_TARGET_DIR="hkcm/${JOB_NAME}/${BUILD_NUMBER}"
        BUILD_ENABLE_RSYNC_ARTIFACTS="Y"
    elif [ "${JOB_BUILD_TYPE}" = "engr" ]; then
        BUILD_ENABLE_PREMIRROR="Y"
        BUILD_ENABLE_SSTATEMIRROR="Y"
        BUILD_ENABLE_DL_DIR="Y"
        BUILD_ENABLE_SSTATE_DIR="Y"
    elif [ "${JOB_BUILD_TYPE}" = "sdk" ]; then
        BUILD_ENABLE_PREMIRROR="Y"
        BUILD_ENABLE_SSTATEMIRROR="Y"
        BUILD_ARTIFACTS_TARGET_DIR="hkcm/${JOB_NAME}/${BUILD_NUMBER}"
        BUILD_ENABLE_RSYNC_ARTIFACTS="Y"
        BUILD_ENABLE_SDK="Y"
    fi
}

function scp_artifacts {
    if [ -z "${BUILD_ARTIFACTS_TARGET_DIR}" ] ; then
        echo "ERROR: ${BUILD_SCRIPT_NAME}-${BUILD_SCRIPT_VERSION} Cannot rsync artifacts when BUILD_ARTIFACTS_TARGET_DIR wasn't set"
        return
    fi

    echo "INFO: ${BUILD_SCRIPT_NAME}-${BUILD_SCRIPT_VERSION} Running ssh ${BUILD_SSH_FILESERVER} mkdir -p ${BUILD_SSH_FILESERVER_ROOT}/${BUILD_ARTIFACTS_TARGET_DIR}/buildhistory"
    /usr/bin/time ssh ${BUILD_SSH_FILESERVER} mkdir -p ${BUILD_SSH_FILESERVER_ROOT}/${BUILD_ARTIFACTS_TARGET_DIR}/buildhistory 2>&1 | tee /dev/stderr

    echo "INFO: ${BUILD_SCRIPT_NAME}-${BUILD_SCRIPT_VERSION} scp build artifacts to ${BUILD_SSH_FILESERVER}:${BUILD_SSH_FILESERVER_ROOT}/${BUILD_ARTIFACTS_TARGET_DIR}"
    /usr/bin/time scp -r ${BUILD_DEPLOYDIR}/pap-flash-usb.tar.bz2 ${BUILD_SSH_FILESERVER}:${BUILD_SSH_FILESERVER_ROOT}/${BUILD_ARTIFACTS_TARGET_DIR}/${JOB_NAME}-flash-usb-${BUILD_NUMBER}.tar.bz2 2>&1 | tee /dev/stderr

    BUILD_ARTIFACTS_BUILD_HISTORY_DIR=${BUILD_SSH_FILESERVER}:${BUILD_SSH_FILESERVER_ROOT}/${BUILD_ARTIFACTS_TARGET_DIR}/buildhistory
    /usr/bin/time scp -r ${BUILD_HISTORY_DIR}/*.txt ${BUILD_ARTIFACTS_BUILD_HISTORY_DIR} 2>&1 | tee /dev/stderr
    BUILD_ARTIFACTS_BUILD_SDK_DIR=${BUILD_SSH_FILESERVER}:${BUILD_SSH_FILESERVER_ROOT}/${BUILD_ARTIFACTS_TARGET_DIR}
    /usr/bin/time scp -r ${BUILD_SDKDIR}/oecore-*.sh ${BUILD_ARTIFACTS_BUILD_SDK_DIR} 2>&1 | tee /dev/stderr
}
# Main
print_timestamp "start"
rm -rf ${BUILD_TOPDIR}
print_timestamp "cleaned"

parse_job_name
apply_job_specific_rules

git clone ssh://mod.lge.com/pap/yocto/hkmc/build-mango -b ${JOB_BUILD_BRANCH} build
pushd ${BUILD_TOPDIR} > /dev/null

print_timestamp "topdir ready"

if [ "${JOB_BUILD_TYPE}" = "integr" ] ; then
    git fetch ssh://mod.lge.com/${GERRIT_PROJECT} $GERRIT_REFSPEC && git checkout FETCH_HEAD
    LAST_COMMIT_ID=`git log -n 1 | head -1 | awk ' {print $2}'`
fi

# don't use mcf params for PREMIRROR and SSTATEMIRROR when they are not enabled
[ "${BUILD_ENABLE_PREMIRROR}" = "Y" ] || BUILD_MIRROR_MCF_PREMIRROR=""
[ "${BUILD_ENABLE_SSTATEMIRROR}" = "Y" ] || BUILD_MIRROR_MCF_SSTATEMIRROR=""

./mcf ${BUILD_MCF_BITBAKE_THREADS} ${BUILD_MCF_MAKE_THREADS} ${BUILD_MIRROR_MCF_PREMIRROR} ${BUILD_MIRROR_MCF_SSTATEMIRROR} ${JOB_BUILD_MACHINE}

print_timestamp "metadata ready"

# Modify spx-local.conf
[ ${BUILD_ENABLE_DL_DIR} = "Y" ] && echo "DL_DIR = \"${BUILD_MIRROR_WRITE_DL_DIR}\"" >> ${BUILD_TOPDIR}/spx-local.conf
[ ${BUILD_ENABLE_DL_DIR} = "Y" ] && echo "INFO: ${BUILD_SCRIPT_NAME}-${BUILD_SCRIPT_VERSION} using shared DL_DIR ${BUILD_MIRROR_WRITE_DL_DIR}"

[ ${BUILD_ENABLE_SSTATE_DIR} = "Y" ] && echo "SSTATE_DIR = \"${BUILD_MIRROR_WRITE_SSTATE_DIR}\"" >> ${BUILD_TOPDIR}/spx-local.conf
[ ${BUILD_ENABLE_SSTATE_DIR} = "Y" ] && echo "INFO: ${BUILD_SCRIPT_NAME}-${BUILD_SCRIPT_VERSION} using shared SSTATE_DIR ${BUILD_MIRROR_WRITE_SSTATE_DIR}"

if [ "${JOB_BUILD_TYPE}" = "verf" ] ; then
    pushd ${BUILD_FETCHDIR} > /dev/null
    git fetch ssh://mod.lge.com/${GERRIT_PROJECT} $GERRIT_REFSPEC && git checkout FETCH_HEAD
    LAST_COMMIT_ID=`git log -n 1 | head -1 | awk ' {print $2}'`
    popd > /dev/null
fi

if [ "${BUILD_ENABLE_SDK}" = "Y" ] ; then
    . oe-init-build-env

    print_timestamp "build start (${BUILD_SDK})"
    bitbake ${BUILD_SDK}

    # after check that build is successful or failed, post job would execute only case of successful.
    if [ $? != 0 ]; then
      exit 1
    fi
    print_timestamp "build end (${BUILD_SDK})"
else
    print_timestamp "build start (${BUILD_IMAGE})"
    . oe-init-build-env
    bitbake ${BUILD_IMAGE}

    if [ $? != 0 ]; then
        exit 1
    fi

    print_timestamp "build end (${BUILD_IMAGE})"

 print_timestamp "build start (${BUILD_FLASH})"
    . oe-init-build-env
    bitbake ${BUILD_FLASH}

    if [ $? != 0 ]; then
        exit 1
    fi

    print_timestamp "build end (${BUILD_FLASH})"


fi

VERSION_DESCRIPTION=`cat ${BUILD_FETCHDIR}/recipes-core/base-files/base-files/version.txt`
DOWNLOAD_DESCRIPTION="<li><a href=\"${BUILD_DOWNLOAD_SITE_SWP}/${BUILD_ARTIFACTS_TARGET_DIR}\" target=\"_blank\">Build results</a></li>"
SET_LI_VERSION_DESCRIPTION="<li>${VERSION_DESCRIPTION}</li>"
DESCRIPTION="${DESCRIPTION}${SET_LI_VERSION_DESCRIPTION}"

## deploy image ###
if [ "${BUILD_ENABLE_RSYNC_ARTIFACTS}" = "Y" ] ; then
    BUILD_DEPLOYDIR="${BUILD_TOPDIR}/BUILD/deploy/images/${JOB_BUILD_MACHINE}"
    BUILD_SDKDIR="${BUILD_TOPDIR}/BUILD/deploy/sdk"

    scp_artifacts
    DESCRIPTION="${DESCRIPTION} ${DOWNLOAD_DESCRIPTION}"
fi
## end deploy image ###

echo "[DESCRIPTION] ${DESCRIPTION}"

print_timestamp "build finished"

popd > /dev/null

print_timestamp "stop"



BUILD_DOWNLOAD_SITE_SWP_DEFAULT="http://10.178.85.23"
[ -n "${BUILD_DOWNLOAD_SITE_SWP}" ] || BUILD_DOWNLOAD_SITE_SWP="${BUILD_DOWNLOAD_SITE_SWP_DEFAULT}"

ssh -p 29411 mod.lge.com gerrit review -m \"Build Successful. Build Image: http://10.178.85.23/${BUILD_ARTIFACTS_TARGET_DIR}\ \(${VERSION_DESCRIPTION}\) Jenkins Link: ${BUILD_GERRIT_SITE}/${JOB_NAME}/${BUILD_NUMBER}\" --verified +1 ${LAST_COMMIT_ID}

exit 0
``