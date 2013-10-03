#!/bin/zsh

# Guide:
# Just use ./lx.zsh to compile to PDF.
# Use +f to force a recompile.
# Modify DOC to change the relevant tex file.
# Modify TMP & BIB to use different temporary storage.
# Use "./lx.zsh clean" to clean up

# set -x

DEFAULTDOC="paper"
COMPILER="pdflatex"

NEEDBIB="yes"
MAKE_PS="no"
MAKE_PDF="no"
FORCE="no"

TMP=.latex.out
BIB=.bibtex.out

for arg in ${*}
  do
  case ${arg} in
      ("+f") FORCE="yes"    ;;
      ("+p") MAKE_PS="yes"  ;;
      ("+d") MAKE_PDF="yes" ;;
      ("-b") NEEDBIB="no"   ;;
      ("+b") NEEDBIB="yes"  ;;
      (*)    DOC="${arg}"   ;;
  esac
done

[[ ${DOC} == "" ]] && DOC=${DEFAULTDOC}
[[ ${MAKE_PDF} == "yes" ]] && MAKE_PS="yes"

clean()
{
    local t
    t=( core* *.aux *.bbl *.blg *.dvi *.latex* *.log *.pdf *.ps )
    t=( ${t} *.toc *.lot *.lof .*.out )
    if [[ ${#t} > 0 ]]
        then
	rm -fv ${t}
    else
	print "Nothing to clean."
    fi
    return 0
}

scan()
{
    [[ $1 == "" ]] && return
    typeset -g -a $1
    local i=1
    while read T
      do
      eval "${1}[${i}]='${T}'"
      (( i++ ))
    done
}

shoot()
# print out an array loaded by scan()
{
  local i
  local N
  N=$( eval print '${#'$1'}' )
    # print N $N
  for (( i=1 ; i <= N ; i++ ))
  do
    eval print -- "$"${1}"["${i}"]"
  done
}

check_bib_missing()
{
  awk '$0 ~ /Warn.*database entry/ { gsub(/\"/, "", $8); print "No entry for: " $8; }'
}

biblio()
{
  if [[ -f ${DOC}.bbl &&
           ${DOC}.bbl -nt $( readlink Wozniak.bib ) ]]
   then
    rm ${DOC}.bbl
  fi
  if { bibtex ${DOC} >& ${BIB} }
   then
    printf "."
    ${COMPILER} ${DOC} >& /dev/null
    printf "."
    ${COMPILER} ${DOC} >& ${TMP}
    printf "."
    check_bib_missing < ${BIB} | scan WARNS
    if (( ${#WARNS} > 0 ))
      then
      printf "\n"
      print "Bibtex:"
      shoot WARNS
    fi
  else
    printf "\n"
    cat ${BIB}
  fi
}

printable()
{
  if [[  ! -f ${DOC}.ps  ||
	 ${DOC}.dvi -nt ${DOC}.ps  ]]
   then
      if [[ ${MAKE_PS} == "yes" ]]
      then
	  dvips  -q -o ${DOC}.ps -t Letter ${DOC}.dvi
	  printf "!"
      fi
  fi

  if [[ ! -f ${DOC}.pdf ||
        ${DOC}.ps -nt ${DOC}.pdf  ]]
  then
      if [[ ${MAKE_PDF} == "yes" ]]
      then
	  ps2pdf ${DOC}.ps ${DOC}.pdf
	  printf "!"
      fi
  fi
}

[[ ${DOC} == "clean" ]] && clean && exit

grep -h includegraphics *.tex | scan A
EPSS=()
for line in ${A}
do
    EPS=( $( print ${${line/'{'/ }/'}'/ } ) )
    EPS=${EPS[2]}.eps
    EPSS=( ${EPSS} ${EPS} )
done
for EPS in ${EPSS}
  do
  [[ ${EPS} -nt ${DOC}.dvi ]] && FORCE="yes"
done

if [[ ! -f ${DOC}.dvi                ||
        -f error                     ||
           ${DOC}.tex -nt ${DOC}.dvi ||
	   lx.zsh     -nt ${DOC}.dvi ||
	   $( readlink Wozniak.bib ) -nt ${DOC}.dvi ||
	   ${FORCE} == "yes" ]]
 then
  if { ${COMPILER} --interaction nonstopmode ${DOC} >& ${TMP} }
   then
    printf "OK"
    rm -f error
    [[ ${NEEDBIB} == "yes" ]] && biblio
  else
    printf "Error! \n"
    egrep '^l.|^!|argument' ${TMP}
    touch error
  fi
fi
[[ ${MAKE_PS} == "yes" ]] && printable
printf "\n"
grep "LaTeX Warning:" ${TMP}

return 0
