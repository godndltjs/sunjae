FIBO_LIST[0]=0
FIBO_LIST[1]=1
i=0
NEXT_FIBO=0

next_fivo () {
    shift $i
    i=`expr $i + 1`
    NEXT_FIBO=`expr $1 + $2`
    FIBO_LIST+=($NEXT_FIBO)
    if [ $(( $NEXT_FIBO & 1 )) -eq 0 ]; then 
        SUM=`expr $SUM + $NEXT_FIBO` ; 
    fi
}

until [ $NEXT_FIBO -gt $1 ]
do
    unset NEXT_FIBO
    next_fivo  ${FIBO_LIST[@]}
done

echo $SUM