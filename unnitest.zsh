#!/usr/bin/zsh

unnitest(){
    success(){
        echo "ASSERTION SUCCESS"
    }
    failure(){
        echo "ASSERTION FAILURE"
    }
    fatal(){
    }
    zmodload -e zsh/regex || zmodload zsh/regex
    typeset line
    typeset -a allTests
    while read -r line ; do
        allTests+=( "$line" )
    done
    unset match
    if [[ "$1" == "true" ]] ; then
        :
    else
        return 0
    fi
    if [[ "$2" != "{" ]] ; then
        printf "ZTestError : Cant find testing block opening bracket.\n"
        return 2
    else
        shift
    fi
    unsetopt shwordsplit
    typeset oneTest
    typeset testFunction
    for oneTest in $allTests ; do
        typeset -a arrayTest
        read -A arrayTest<<<$oneTest
        if [[ $( whence -w ${arrayTest[1]} ) != "${arrayTest[1]}: function" ]] ; then
            printf "Error : %s is not a ZSH function.\n" "${arraTest[1]}"
	    return 3
        else
            testFunction="${arrayTest[1]}"
	    shift arrayTest
        fi
        if [[ "${arrayTest[1]}" != "{" ]] ; then
            printf "ZTestError : Cant find opening bracket\n"
        else
            shift arrayTest
        fi
        typeset term
        typeset -a testFuctionArgs
        for term in $arrayTest ; do
            if [[ "$term" == "}" ]] ; then
                shift arrayTest
                break
            else
                testFunctionArgs+=( "$term" )
                shift arrayTest
            fi
        done
        typeset testFD
        typeset ret
        ret=false
        case ${arrayTest[1]} in
            'ret'|'return') ret=true
            ;;
            'out'|'output') alias -g §fd=''
            ;;
            'err'|'error')  alias -g §fd='2>&1 1>/dev/null'
            ;;
            fd<->) alias -g §fd="${arrayTest[1]:s/fd/}>&1 1>/dev/null"
            ;;
            *) printf "ZTestError : %s is not a valid FD\n" "${arrayTest[1]}"; return 3
            ;;
        esac
        shift arrayTest
        if $ret ; then
            typeset testExpectedReturn
            testExpectedReturn="${arrayTest[1]}"
            $testFunction $testFunctionArgs 1>/dev/null 2>&1
            testRealReturn="$?"
            if [[ "$testRealReturn" -eq "$testExpectedReturn" ]] ; then
                echo "test réussi"
            else
                echo "test échoué"
            fi
        else
            typeset testTest
            typeset testExpectedData
            typeset testRealData
            testTest="${arrayTest[1]}"
            shift arrayTest
            testExpectedData="${arrayTest[*]}"
            testExpectedData="${testExpectedData:Q}"
            testRealData=$( $testFunction $testFunctionArgs §fd)
            case $testTest in
                '==') [[ "$testRealData" == "$testExpectedData" ]] && success || failure
                ;;
                '!=') [[ "$testRealData" != "$testExpectedData" ]] && success || failure
                ;;
                '=~') [[ "$testRealData" =~ "$testExpectedData" ]] && success || failure
                ;;
                '<') [[ "$testRealData" < "$testExpectedData" ]] && success || failure
                ;;
                '>') [[ "$testRealData" > "$testExpectedData" ]] && success || failure
                ;;
                '-eq') [[ "$testRealData" -eq "$testExpectedData" ]] && success || failure
                ;;
                '-ne') [[ "$testRealData" -ne "$testExpectedData" ]] && success || failure
                ;;
                '-lt') [[ "$testRealData" -lt "$testExpectedData" ]] && success || failure
                ;;
                '-gt') [[ "$testRealData" -gt "$testExpectedData" ]] && success || failure
                ;;
                '-le') [[ "$testRealData" -le "$testExpectedData" ]] && success || failure
                ;;
                '-ge') [[ "$testRealData" -ge "$testExpectedData" ]] && success || failure
                ;;
                *) printf "ZTestError : $testTest is not recognized as a valid test." ; return 2
                ;;
            esac
        fi

        # BEGIN DEBUG
        printf "FU : %s\n" "$testFunction"
        n=1
        for i in $testFunctionArgs ; do echo "ARG_$((n++)): $i" ; done
        echo "FD=$testFD"
        echo "expectedData=$testExpectedData"
        echo "realData=$testRealData"
        echo "expectedReturn=$testExpectedReturn"
        # END DEBUG
        unset arrayTest
        unset testFunctionArgs
     done
}
alias ztest='unnitest<<"}"'
