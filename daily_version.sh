#!/bin/bash
## 1. 초기 ssh 세팅필요 (01. 현 스크립트 수행할 머신의 .ssh/id_rsa.pub -> 리눅스 각 계정 )
##    ssh key 없으면 생성 ssh-keygen.exe -t rsa(win)// ssh-keygen -t rsa(linux)


step0_select_project_branch () {
    case $PROJECT_AND_BRANCH in
        P5M|P5GEN)
            echo -e "'\033[33m$PROJECT_AND_BRANCH\033[m' selected. \n"
        ;;

        *)
            PS3="Select PROJECT_AND_BRANCH (Input the number): "
            select PROJECT_AND_BRANCH in P5M P5GEN
            do
                echo -e "'\033[33m$PROJECT_AND_BRANCH\033[m' selected. \n"
                break;
            done
        ;;
    esac
    set_enviroment_value $PROJECT_AND_BRANCH $VERSION_PREFIX
    ssh_connection_test
}

set_enviroment_value () {
    if [ ! $PROJECT_AND_BRANCH ]; then PROJECT_AND_BRANCH=$1; fi
    if [ ! $VERSION_PREFIX ]; then VERSION_PREFIX=$2; fi

    case $PROJECT_AND_BRANCH in
        P5M)
            SSH_AUTH="jusung87@10.185.7.32"
            BUILD_GIT_DIR="/data001/jusung87/build-mango/"
            META_GIT_DIR="${BUILD_GIT_DIR}/metalayers/meta-mango"
            VERSION_TXT="${META_GIT_DIR}/recipes-core/base-files/base-files/version.txt"
            BRANCH="master"
            VERSION_PREFIX="RJ.KOR.PV.04" ; # + SURFIX such as ".1810.03"
            VERSION=`date +${VERSION_PREFIX}.%y%W.0%w`
            BUILD_TYPE="[DAILY VERSION BUILD REQ]"
        ;;

        P5GEN)
            SSH_AUTH="sunghoon.baek@10.158.4.110"
            BUILD_GIT_DIR="/home/sunghoon.baek/build-mango"
            META_GIT_DIR="${BUILD_GIT_DIR}/metalayers/meta-mango"
            VERSION_TXT="${META_GIT_DIR}/recipes-core/base-files/base-files/version.txt"
            BRANCH="@pgen5_SOP_GEN_180425"
            VERSION_PREFIX="RJ.GEN.P5" ; # + SURFFIX such as ".1810.03"
            VERSION=`date +${VERSION_PREFIX}.001.001.%y%m%d`
            BUILD_TYPE="[EVENT VERSION BUILD REQ]"
        ;;
        
        *)
            echo "PROJECT_AND_BRANCH VAR is null..!!!"
            exit;
        ;;
    esac

}

initialize_git_dir () {
    git reset --hard HEAD~3
    git pull
}

make_baseline () {
    cd ${META_GIT_DIR}
    git fetch
    git checkout ${BRANCH}
    
    initialize_git_dir
    
    PREVIOUS_VERSION=`cat ${VERSION_TXT} | head -1 `
    if [ ${PREVIOUS_VERSION} = ${VERSION} ]; then     # VERSION이 같으면 중복 수행이라 경고 문구 출력 후 종료;
        echo "Already version.txt has been changed, so you need to check if same work do again."  ;
        exit;
    fi

    echo ${VERSION} > ${VERSION_TXT}
    git diff ; # 확인
    git add ${VERSION_TXT}
    git commit  -m "${VERSION}" -m "${BUILD_TYPE}" && git push origin HEAD:refs/for/${BRANCH}
}

make_tag (){
    cd ${META_GIT_DIR} 
    git checkout ${BRANCH}
    initialize_git_dir
    git tag -a ${VERSION} -m "${VERSION}" && git push origin ${VERSION}
}

api_call_jenkins_official_build (){
    case $PROJECT_AND_BRANCH in
        P5M)
            curl -X POST http://binary.lge.com:8093/lap/build/job/hkmc-master-official-gr-mrb-64/build \
            --user sunghoon.baek:c823422af798680aff5537a79008aad6 
            echo "Call jenkins api official build job"
        ;;
        *)
            echo "Call api official build jobs skipped." 
        ;;
    esac
}

execute_spxlayerpin_sh_of_build_mango (){
    cd ${BUILD_GIT_DIR}
    initialize_git_dir
    ./scripts/spxlayerpin.sh 
    git push origin HEAD:refs/for/master 
}

ssh_connection_test (){
    ssh -q -oBatchMode=yes ${SSH_AUTH} exit
    if [ $? = 0 ]; then
        echo SSH connection Test Success..! ;
    else
        echo SSH connection Test Failed!!! ;
        exit
    fi
}

step1_create_baseline (){
    ssh ${SSH_AUTH} "$(typeset -f); set_enviroment_value ${PROJECT_AND_BRANCH} ${VERSION_PREFIX};
                                    make_baseline;"
}

step2_create_tag (){   
    ssh ${SSH_AUTH} "$(typeset -f); set_enviroment_value ${PROJECT_AND_BRANCH} ${VERSION_PREFIX};
                                    make_tag;"
}

step3_build_mango () {
    ssh ${SSH_AUTH} "$(typeset -f); set_enviroment_value ${PROJECT_AND_BRANCH} ${VERSION_PREFIX};
                                    execute_spxlayerpin_sh_of_build_mango;"
}

print_menu () 
{
	echo -e " =========================================================================="
	echo -e " \033[33m[1|b] make baseline          : make baseline. \033[m"
    echo -e " [2|t] make tag               : make tag. "
	echo -e " [3|s] execute spxlayerpin.sh : execute spxlayerpin.sh."
	echo -e " [ 4 ] three action           : make tag & execute spxlayerpin.sh & call official build."
    echo -e " [ 0 ] quit|q|exit|e          : exits DAILY_BUILD_HELPER."
	echo -e " =========================================================================="
}

interactive_mode () 
{
    echo -e " WELCOME TO DAILY_BUILD_HELPER!"
    print_menu
    while true
    do
        if [ $# -gt 0 ]; then
            # Non Interactive mode
            cmd=$1
            PROJECT_AND_BRANCH=$2
            VERSION_PREFIX=$3
        else
            printf "%s " " DAILY_BUILD_HELPER>"
            read cmd
        fi

        case "$cmd" in
            1|b)
                step0_select_project_branch
                step1_create_baseline
            ;;


            2|t)
                step0_select_project_branch
                step2_create_tag
            ;;

            3|s)
                step0_select_project_branch
                step3_build_mango
            ;;

            0|quit|exit|q|e)
                break;
            ;;

            4)
                step0_select_project_branch
                step2_create_tag
                step3_build_mango
                api_call_jenkins_official_build
            ;;

            *)
                if [ "$cmd" = "" ]; then 
                    continue;
                fi
                print_menu
                echo -e " '$cmd' is invalid command. in the interactive mode";
                continue
            ;;
        esac
        unset COUNTRY
        if [ $# -gt 0 ]; then   break;  fi
    done
}

interactive_mode $1 $2 $3