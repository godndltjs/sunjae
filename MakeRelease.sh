#1 git log로 merge된 commit에서 필요한 데이터를 뽑아온다
#1.1 정규표현식으로
#1.1 백주임님이 만드신 스크립트처럼
#2 정기릴리즈,이벤트 구분
#2.1 정기릴리즈용 릴리즈노트
#2.2 이벤트용 릴리즈 노트
#3 데이터를 txt파일로 변경한다.
#3.1 2의 데이터를 WORD로 이동시킨다.
#3.1 2의 데이터를 Excel로 이동시킨다.
#3 끝
  
  #!/bin/bash
## 1. 초기 ssh 세팅필요 (01. 현 스크립트 수행할 머신의 .ssh/id_rsa.pub -> 리눅스 각 계정 )
##    ssh key 없으면 생성 ssh-keygen.exe -t rsa(win)// ssh-keygen -t rsa(linux)


step0_select_project_branch () {
    case $PROJECT_AND_BRANCH in
        P5M|P5GEN|P5K2|P5K3|P5P1)
            echo -e "'\033[33m$PROJECT_AND_BRANCH\033[m' selected. \n"
        ;;

        *)
            PS3="Select PROJECT_AND_BRANCH (Input the number): "
            select PROJECT_AND_BRANCH in P5M P5GEN P5K2 P5K3 P5P1
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
            SSH_AUTH="godndltjs.lee@10.185.7.32"
            BUILD_GIT_DIR="/data001/godndltjs.lee/build-mango/"
            META_GIT_DIR="${BUILD_GIT_DIR}/metalayers/meta-mango"
            VERSION_TXT="${META_GIT_DIR}/recipes-core/base-files/base-files/version.txt"
            BRANCH="master"
            VERSION_PREFIX="RJ.KOR.PV.04" ; # + SURFIX such as ".1810.03"
            VERSION=`date +${VERSION_PREFIX}.%y%W.0%w`
            BUILD_TYPE="[DAILY VERSION BUILD REQ]"
        ;;
           P5K2)
            SSH_AUTH="godndltjs.lee@10.185.7.32"
            BUILD_GIT_DIR="/data001/godndltjs.lee/build-mango/"
            META_GIT_DIR="${BUILD_GIT_DIR}/metalayers/meta-mango"
            VERSION_TXT="${META_GIT_DIR}/recipes-core/base-files/base-files/version.txt"
            BRANCH="@pgen5.RUP.KOR.2018.2nd"
            VERSION_PREFIX="RJ.KOR.PV" ; # + SURFFIX such as ".1810.03"
            VERSION=`date +${VERSION_PREFIX}.001.002.%y%m%d`
            BUILD_TYPE="[EVENT VERSION BUILD REQ]"
        ;;
        P5K3)
            SSH_AUTH="godndltjs.lee@10.185.7.32"
            BUILD_GIT_DIR="/data001/godndltjs.lee/build-mango/"
            META_GIT_DIR="${BUILD_GIT_DIR}/metalayers/meta-mango"
            VERSION_TXT="${META_GIT_DIR}/recipes-core/base-files/base-files/version.txt"
            BRANCH="@pgen5_RUP_KOR_180523"
            VERSION_PREFIX="RJ.KOR.PV" ; # + SURFFIX such as ".1810.03"
            VERSION=`date +${VERSION_PREFIX}.001.003.%y%m%d`
            BUILD_TYPE="[EVENT VERSION BUILD REQ]"
        ;;
        P5P1)
            SSH_AUTH="godndltjs.lee@10.185.7.32"
            BUILD_GIT_DIR="/data001/godndltjs.lee/build-mango/"
            META_GIT_DIR="${BUILD_GIT_DIR}/metalayers/meta-mango"
            VERSION_TXT="${META_GIT_DIR}/recipes-core/base-files/base-files/version.txt"
            BRANCH="@pgen5.HIFL.P1.180621"
            VERSION_PREFIX="RJ.KOR.PV" ; # + SURFFIX such as ".1810.03"
            VERSION=`date +${VERSION_PREFIX}.04.1827.P1C` # 년도주차 와 P1X바꿀것
            BUILD_TYPE="[EVENT VERSION BUILD REQ]"
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

make_release () {
    cd ${META_GIT_DIR}
    git fetch
    git checkout ${BRANCH}
    
    initialize_git_dir

    
    git log --since="7days ago" > log.txt # | less  # 수정 예정
    #git command --since="1days ago"
    #git reflog
    #git show :/message
   # git log | less
   
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

step1_create_release (){
 ssh ${SSH_AUTH} "$(typeset -f); set_enviroment_value ${PROJECT_AND_BRANCH} ${VERSION_PREFIX};
                                   make_release;"
}


print_menu () 
{
	echo -e " =========================================================================="
	echo -e " \033[33m[1|b] make release          : make release \033[m"
	echo -e " =========================================================================="
}


interactive_mode () 
{
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
                step1_create_release
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