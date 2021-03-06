#!/bin/bash

errmsg(){
[ $# -ne 2 ] && errmsg "errmsg" "missing arguments in call to errmsg: $@" 
echo "$1: ERROR: $2"
}

list(){ # ( {n..m} | {n1,n2,..nk} ) -> an ... am | a1 ... ak  || [a] -> [a]
test "$(echo "$*")" == "{}" -o "$(echo "$*")" == "{..}" && echo "" && return 0
#islist=`echo "$*"| grep -E "[0-9]+[[:space:]]+([0-9]+[[:space:]]+)*[0-9]+|[a-zA-Z]+[[:space:]]+([a-zA-Z]+[[:space:]]+)*[a-zA-Z]+"`
islist=`echo "$*"| grep -E "[[:alnum:]]+[[:space:]]+([[:alnum:]]+[[:space:]]+)*[[:alnum:]]+"`
test "x$islist" == "x" && errmsg "List" ">$*< not a list." && return 1
#echo "List: DEBUG: seeing >$*<" 1>&2
for i in $islist ; do echo $i ; done;
}

isLambda(){
is_lambda="$(echo "$*" | grep -E "\\\[a-zA-Z]+[[:space:]]+\.")" ;
test "x$is_lambda" == "x" && errmsg "map" "$* not a lambda function: >$is_lamda<" && return 1
fnc="$(echo "$is_lambda"| sed 's@^\\[a-zA-Z]\+[[:space:]]\+\.\(.*\)@\1@g')" ;
test "x$fnc" == "x" && errmsg "map" "lambda contains no valid function: >$fnc<" && return 1
return 0
}

map(){ 	# func [a] -> [a]  ## sed uses non-regex pattern where special character + needs to be backspaced.
is_lambda="$(echo "$*" | grep -E "\\\[a-zA-Z]+[[:space:]]+\.")" ;
test "x$is_lambda" == "x" && errmsg "map" "$* missing bound variable in lambda function: >$islamda<" && return 1 
fnc_arg="$(echo "$is_lambda"| sed 's@^\\\([a-zA-Z]\+\)[[:space:]]\+\..*@\1@g')" ;
#echo "map: DEBUG: fnc_arg:>$fnc_arg<" 1>&2
fnc="$(echo "$*"| sed 's@^\\[a-zA-Z]\+[[:space:]]\+\.\(.*\)@\1@g')" ;
#echo "map: DEBUG: func:>$fnc<" 1>&2
test "x$fnc" == "x" && errmsg "map" "missing lambda function: >$fnc<" && return 1 
#fnc="echo $(echo $fnc| sed 's@'$fnc_arg'@\@@g')" ;
fnc="$(echo "$fnc"| sed 's@^[[:space:]]@@g' | sed 's/'$fnc_arg'/@/g' | sed 's@^$((@echo $((@g')"
#fnc="$(echo "$fnc" | sed 's@^$((@echo $((@g')"
echo "map: DEBUG: func:>$fnc<" 1>&2
this_func(){ eval "$fnc" ;} ;
while read i ; do
  echo $( this_func $i )
done
}

filter(){
#isLambda "$*" || errmsg "filter" "expression doesn't resolve to a lambda" && return 1
lambda="$(echo "$*" | grep -E "\\\[a-zA-Z]+[[:space:]]+\.")" ;
fnc_arg="$(echo "$lambda"| sed 's@^\\\([a-zA-Z]\+\)[[:space:]]\+\..*@\1@g')" ;
fnc="$(echo "$lambda"| sed 's@^\\[a-zA-Z]\+[[:space:]]\+\.\(.*\)@\1@g')" ;
test "x$fnc" == "x" && errmsg "filter" "lambda contains no valid function: >$fnc<" && return 1 
fnc="$(echo "$fnc"| sed 's@'$fnc_arg'@\@@g')" ;
echo "filter: DEBUG: func:>$fnc<" 1>&2
this_func(){ eval $fnc >/dev/null ; return $? ;}
while read i ; do
  this_func $i && echo $i	
done
}

# foldl :: (b -> a -> b) -> b -> [a] -> b
foldl(){
fnc="$1"
this_acc=$2
while read i ; do
  this_acc=`eval "$1 $this_acc $i"`
done
echo "$this_acc"
}

#First element of a list (head)
#A pure bash implementation seems more complicated if possible at all:
#>ist {1..14} | lead
#1
#bash: echo: write error: Broken pipe
#>list {1..13} | lead
#1
#if lead is given by
#lead(){
#read lead_i ; echo $lead_i 
#}
#Thus, we'll assume some basic gnu tools available like tail/head
#However, this also has limitations:
#>list {1..300} | head -1
#1
#bash: echo: write error: Broken pipe
lead(){ head -1 ;}
#Remaining part of a list (tail)
remain(){
remain_myfirstln=0; while [ $remain_myfirstln -eq 0 ] ; do remain_myfirstln=$(( $remain_myfirstln + 1 )); read remain_i ; continue; done; while read remain_i ; do echo $remain_i ; done 
}
