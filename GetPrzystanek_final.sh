#!/bin/bash

#$1 przystanek | stop
#$2 czas w formacie hh:mm | time
#$3 data w formacie dd.mm.yyyy | date
#$4 maksymalna ilosc zwracanych wynikow (w formacie n) | max. # of returned results

if [ -z "$4" ]
then
  echo "Usage: `basename $0` stop_name time date max_res"
  echo "   stop_name - the name of the stop"
  echo "   time      - in hh:mm format"
  echo "   date      - in dd.mm.yyyy format"
  echo "   max_res   - the maximum number of results returned"
  exit 1
fi

sn=$(echo "$1" | tr 'a-z' 'A-Z')
STEPONE=$(wget -O- -q "http://wyszukiwarka.ztm.waw.pl/bin/stboard.exe/pnx?input=$sn&boardType=dep&time=$2%2B1&productsFilter=1111110111\&date=$3&maxJourneys=$4&start=yes" | head -n-15 )
#echo "$STEPONE" > STEPONE.txt
STEPONEHALF=$(echo "$STEPONE" | wget --ignore-tags=link,img -i- -q --force-html -r -O- -np | sed -e ':a;N;$!ba;s/ <\/td>\n/ /g' -e 's/<[^>]*>//g' -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&amp;/\&/g' -e 's/&#322;/l/g' -e 's/ \{1,\}/ /g' -e 's/&#379;/Z/g' -e 's/&#321;/L/g' -e 's/&#323;/N/g' -e 's/&#280;/E/g' -e 's/&#211;/O/g' -e 's/&#260;/A/g' -e 's/&#346;/S/g' | egrep -a -e "N*[0-9]{1,} do [A-Z0-9 +.-]*" -e "$sn")
#echo "$STEPONEHALF" > STEPONEHALF.txt
STEPTWO=$(echo "$STEPONE" | sed -e 's/<[^>]*>//g' -e 's/ $//g' -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&amp;/&/g' -e 's/&#322;/l/g' -e 's/ \{1,\}/ /g' -e 's/&#379;/Z/g' -e 's/&#321;/L/g' -e 's/&#323;/N/g' -e 's/&#280;/E/g' -e 's/&#211;/O/g' -e 's/&#260;/A/g' -e 's/&#346;/S/g' -e 's/>>/do/g')
#echo "$STEPTWO" > STEPTWO.txt
#echo "$(echo "$STEPTWO" | uniq | tac | head -n-7 | tac | grep -v "^$" | sed -r -e 's/[0-2][0-3][:][0-5][0-9]/&=/g')" > 3int.txt
STEPTHREE=$(echo "$STEPTWO" | uniq | tac | head -n-7 | tac | grep -v '^$' | sed -r -e 's/[0-2][0-3]:[0-5][0-9]/\(\&\)=/g' | tr "\n" " " | egrep -r -o -e 'N?[0-9]{1,3}[^:]*:[0-5][0-9]')
#echo "$STEPTHREE" > STEPTHREE.txt
#res=$(echo "$( echo "$STEPONEHALF" ; echo '##FEED##'; echo "$STEPTHREE")" | ./ListRep.exe )
res=$(echo "$( echo "$STEPONEHALF" ; echo '##FEED##'; echo "$STEPTHREE")")
echo "$res"
