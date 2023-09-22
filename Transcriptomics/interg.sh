#!/usr/bin/env bash

set +H

empty="Empty input!"
error="Error!"

declare -a dependencies=("fastqc" "STAR" "rsem-calculate-expression")

function checker(){
    if [ -n "$1" ]
    then
        if command -v $1 &> /dev/null
        then
            printf "%s placed in %s will be used.\n" $1 $(command -v $1)
        else
            printf "$1 is not found.\n"
        fi
    elif [[ $1 == "" ]]
    then
        echo ${empty}
    else
        echo ${error}
    fi
}

function checker_info(){
    case $1 in
        "")
            echo "Empty input!"
            ;;
        "fastqc"|"FastQC")
            printf "You can get FastQC from the link below.\nhttps://www.bioinformatics.babraham.ac.uk/projects/fastqc/\n"
            ;;
        "STAR"|"star")
            printf "You can get STAR from the link below.\nhttps://github.com/alexdobin/STAR\n"
            ;;
        "RSEM"|"rsem"|"rsem-calculate-expression")
            printf "You can get RSEM from the link below.\nhttps://github.com/deweylab/RSEM\n"
            ;;
        *)
            echo "The input is neither FastQC, STAR, nor RSEM."
            ;;
    esac
}


for i in ${dependencies[@]}
do
    if [[ $(checker ${i}) == ${empty} ]]
    then
        echo ${empty}
    elif [[ $(checker ${i}) == ${error} ]]
    then
        echo ${error}
    elif [[ $(checker ${i}) != ${empty} ]] && [[ $(checker ${i}) != ${error} ]]
    then
        if [[ $(checker ${i}) == "$i is not found.\n" ]]
        then
            checker_info ${i}
        else
            checker ${i}
        fi
    else
        echo ${error}
    fi
done