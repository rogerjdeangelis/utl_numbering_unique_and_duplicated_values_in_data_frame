Numbering unique and duplicated values in data frame

Two solutions
  1. WPS/SAS
  2, WPS/R or IML/R

see
https://goo.gl/VnV4WA
https://stackoverflow.com/questions/48174140/r-numbering-unique-and-duplicated-values-in-data-frame

INPUT
=====

 WORK.HAVE t
            |     RULES
  PLAYER    |
            |
  Joe       |     1 because no preceeding match for joe
  Bill      |     1 because no preceeding match for bill
  Chris     |     1 because no preceeding match for chris
  Bill      |     2 because this is bills second match
  Joe       |     2 because this is joes second match
  Mark      |     1 because no preceeding match for joe
            |

 PROCESSING
 ==========

 WPS/SAS
  proc sort data=have out=havSrt;
  by player;
  run;quit;

  data want;
    retain cnt 0;
    set havSrt;
    by player;
    if first.player then cnt=0;
    cnt=cnt+1;
  run;quit;

 R  (working code - not bad but datatable is almost like another language?)

  have[, PLAYERCNT := 1:.N, by = PLAYER];


OUTPUT
======

SAS/WPS

 WORK.WANT total obs=6 (Even though the oder has changes, this is more usefull output)

   PLAYER    CNT

   Bill       1
   Bill       2
   Chris      1
   Joe        1
   Joe        2
   Mark       1

R

 WORK.WANTWPS TOTAL OBS=6

   PLAYER    PLAYERCNT

   Joe           1
   Bill          1
   Chris         1
   Bill          2
   Joe           2
   Mark          1

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;
input Player$;
cards4;
 Joe
 Bill
 Chris
 Bill
 Joe
 Mark
;;;;
run;quit;
*                      __
__      ___ __  ___   / /__  __ _ ___
\ \ /\ / / '_ \/ __| / / __|/ _` / __|
 \ V  V /| |_) \__ \/ /\__ \ (_| \__ \
  \_/\_/ | .__/|___/_/ |___/\__,_|___/
         |_|
;

%utl_submit_wps64('

libname wrk sas7bdat "%sysfunc(pathname(work))";
libname sd1 sas7bdat "d:/sd1";
proc sort data=sd1.have out=havSrt;
by player;
run;quit;

data wrk.wantwps;
  retain player cnt ;
  set havSrt;
  by player;
  if first.player then cnt=0;
  cnt=cnt+1;
run;quit;

');
*                      ______
__      ___ __  ___   / /  _ \
\ \ /\ / / '_ \/ __| / /| |_) |
 \ V  V /| |_) \__ \/ / |  _ <
  \_/\_/ | .__/|___/_/  |_| \_\
         |_|
;

%utl_submit_wps64('
libname sd1 sas7bdat "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
library(data.table);
have<-read_sas("d:/sd1/have.sas7bdat");
setDT(have);
have[, PLAYERCNT := 1:.N, by = PLAYER];
endsubmit;
import r=have  data=wrk.wantwps;
run;quit;
');



