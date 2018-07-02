DAYS=7
NOTE_DIR="C:/Users/VT/Desktop/CM/02*/MakeReleaseNote/meta-mango"
cd $NOTE_DIR



collect_statement () {
    if [ ${COLLECT_STATEMENT} ]; then
        echo $STATEMENT
    fi
}

IFS='
'

for STATEMENT in `git log --since="${DAYS}days ago" --pretty=format:"%s : %b" `
# for STATEMENT in `cat -E pro.txt `
do
    case `echo "${STATEMENT}" | awk '{print $1}'` in
        @@@*)
            COLLECT_STATEMENT="ON"
        ;;
        !!!)
            collect_statement
            unset COLLECT_STATEMENT
            echo
        ;;
        :Detailed)
            if [ ${COLLECT_STATEMENT} ]; then
                unset COLLECT_STATEMENT
                echo !!!!
                echo "디테일 포인트"
            fi
        ;;
    esac
    collect_statement
done


# git log --since="${DAYS}days ago" --pretty=format:"%s : %b" > log.txt
# mv log.txt ../
# cd ..
# ./MakeReleaseNote.bat