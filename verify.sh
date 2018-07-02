
gerrit_merge () {
    BRANCH=$1
IFS='
'
    for i in `ssh -p 29411 mod.lge.com gerrit query --format=JSON --current-patch-set status:open project:pap/yocto/vendor/hkmc/meta-mango2  branch:${BRANCH} cccreq=1 verified=1 `
    do
        REVISION=`echo $i | jq .currentPatchSet.revision | tr -d '/"'`
        if [ $REVISION = "null" ]; then
            echo check null point;
            exit;
        fi
        # ssh -p 29411 mod.lge.com gerrit review --code-review +2 --submit $REVISION
        echo "ssh -p 29411 mod.lge.com gerrit review --code-review +2  --submit $REVISION executed"
    done
}


gerrit_merge $1