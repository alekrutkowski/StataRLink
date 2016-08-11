StataRLink: Stata commands (.ado files) for easy interactive work with R
================
Aleksander Rutkowski
2016-08-11

The available Stata commands -- very simple API:

- `r` -- allows for the execution of a line of arbitrary R expressions
- `startr` -- starts a local R "server"
- `stopr` -- stops a local R "server"
- `tor` -- exports the current dataset (sitting in Stata memory) into R (`tor` = to R) to a data.fame named *StataData*
- `fromr` -- import the *StataData* data.frame from R into Stata

### Installation

Either automatically (from Stata) or manually (e.g. if Stata cannot download via HTTPS
due to a web proxy configuration resulting in Stata error number 672 -- see
<http://www.stata.com/support/faqs/web/common-connection-error-messages/>,
paragraph on r(672), point 2):

#### Automatically

Stata code:

```
cap mkdir "`c(sysdir_personal)'", public
loc gh "https://raw.githubusercontent.com/alekrutkowski/StataRLink/master/"
loc F1 r.ado startr.ado stopr.ado tor.ado fromr.ado
loc F2 StataRLink_server.R dicen.ado filewrap.ado waitforfile.ado
foreach f in `F1' `F2' {
   copy "`gh'`f'" "`c(sysdir_personal)'`f'", text public
}
```

#### Manually

Download <https://github.com/alekrutkowski/StataRLink/archive/master.zip>
and open (unzip) it. Then, copy the unzipped contents into your "personal"
Stata directory. You can find out where your "personal" Stata directory is by
typing in Stata command `personal`. This directory may actually not exist yet --
you may have to create it first (you can do it from Stata:
``mkdir "`c(sysdir_personal)'", public``).

### Configuration

Important! Before starting the R "server" with command `startr`,
you have tell Stata where to find it. Put the nested quotes
inside the `rscript_path` global macro if the path contains
one or more spaces:

E.g., on Windows:

```
global rscript_path `""C:\Program Files\R\R-3.2.0\bin\x64\Rscript.exe""'
```

or for a more complicated case (R as a virtualised app):

```
global rscript_path `""C:\Program Files (x86)\Microsoft Application Virtualization Client\sfttray.exe" /launch "Rscript [V] 3.24bd001""'
```

E.g., on Linux (Ubuntu) it may be:

```
global rscript_path "/usr/lib/R/bin/Rscript"
```

### Usage examples

```
. startr  // start R "server"
R "server" started successfully

. sysuse auto, clear  // open example datasets available in Stata (built-in)
(1978 Automobile Data)

. tor  // i.e. "to R" -- export data to R; as a convention the dataset is put into R object called `StataData`
------------------------------------------------------------- R output start ---------------------------------------------------------------
> str(StataData)
'data.frame':   74 obs. of  12 variables:
 $ make        : Factor w/ 74 levels "AMC Concord",..: 1 2 3 7 8 9 10 11 12 13 ...
 $ price       : int  4099 4749 3799 4816 7827 5788 4453 5189 10372 4082 ...
 $ mpg         : int  22 17 22 20 15 18 26 20 16 19 ...
 $ rep78       : int  3 3 NA 3 4 3 NA 3 3 3 ...
 $ headroom    : num  2.5 3 3 4.5 4 4 3 2 3.5 3.5 ...
 $ trunk       : int  11 11 12 16 20 21 10 16 17 13 ...
 $ weight      : int  2930 3350 2640 3250 4080 3670 2230 3280 3880 3400 ...
 $ length      : int  186 173 168 196 222 218 170 200 207 200 ...
 $ turn        : int  40 40 35 40 43 43 34 42 43 42 ...
 $ displacement: int  121 258 121 196 350 231 304 196 231 231 ...
 $ gear_ratio  : num  3.58 2.53 3.08 2.93 2.41 2.73 2.87 2.93 2.93 3.08 ...
 $ foreign     : Factor w/ 2 levels "Domestic","Foreign": 1 1 1 1 1 1 1 1 1 1 ...
-------------------------------------------------------------- R output end ----------------------------------------------------------------

. r StataData <- within(StataData, new <- price/100)  // `r` command allows to execute R functions interactively
------------------------------------------------------------- R output start ---------------------------------------------------------------
> StataData <- within(StataData, new <- price/100)
-------------------------------------------------------------- R output end ----------------------------------------------------------------

. fromr  // import modified data (`StataData` object) back into Stata
(13 vars, 74 obs)

. list in 1/5, clean  // have a look at the top of the data

                make   price   mpg   rep78   headroom   trunk   weight   length   turn   displa~t   gear_r~o    foreign     new  
  1.     AMC Concord    4099    22       3        2.5      11     2930      186     40        121       3.58   Domestic   40.99  
  2.       AMC Pacer    4749    17       3          3      11     3350      173     40        258       2.53   Domestic   47.49  
  3.      AMC Spirit    3799    22       .          3      12     2640      168     35        121       3.08   Domestic   37.99  
  4.   Buick Century    4816    20       3        4.5      16     3250      196     40        196       2.93   Domestic   48.16  
  5.   Buick Electra    7827    15       4          4      20     4080      222     43        350       2.41   Domestic   78.27  

. r StataData <- within(StataData, new2 <- rep78/100)  // do some manipulations again in R
------------------------------------------------------------- R output start ---------------------------------------------------------------
> StataData <- within(StataData, new2 <- rep78/100)
-------------------------------------------------------------- R output end ----------------------------------------------------------------

. fromr, clear  // import the latest version of the `StataData` object
(14 vars, 74 obs)

. list in 1/5, clean  // have a look at the top of the data

                make   price   mpg   rep78   headroom   trunk   weight   length   turn   displa~t   gear_r~o    foreign     new   new2  
  1.     AMC Concord    4099    22       3        2.5      11     2930      186     40        121       3.58   Domestic   40.99    .03  
  2.       AMC Pacer    4749    17       3          3      11     3350      173     40        258       2.53   Domestic   47.49    .03  
  3.      AMC Spirit    3799    22       .          3      12     2640      168     35        121       3.08   Domestic   37.99      .  
  4.   Buick Century    4816    20       3        4.5      16     3250      196     40        196       2.93   Domestic   48.16    .03  
  5.   Buick Electra    7827    15       4          4      20     4080      222     43        350       2.41   Domestic   78.27    .04  

. tor in 1/3  // you can export observation subsets with `if` and `in`
------------------------------------------------------------- R output start ---------------------------------------------------------------
> str(StataData)
'data.frame':   3 obs. of  14 variables:
 $ make        : Factor w/ 3 levels "AMC Concord",..: 1 2 3
 $ price       : int  4099 4749 3799
 $ mpg         : int  22 17 22
 $ rep78       : int  3 3 NA
 $ headroom    : num  2.5 3 3
 $ trunk       : int  11 11 12
 $ weight      : int  2930 3350 2640
 $ length      : int  186 173 168
 $ turn        : int  40 40 35
 $ displacement: int  121 258 121
 $ gear_ratio  : num  3.58 2.53 3.08
 $ foreign     : Factor w/ 1 level "Domestic": 1 1 1
 $ new         : num  41 47.5 38
 $ new2        : num  0.03 0.03 NA
-------------------------------------------------------------- R output end ----------------------------------------------------------------

. r StataData  // see how the data now looks inside R
------------------------------------------------------------- R output start ---------------------------------------------------------------
> StataData
         make price mpg rep78 headroom trunk weight length turn displacement gear_ratio  foreign   new new2
1 AMC Concord  4099  22     3      2.5    11   2930    186   40          121       3.58 Domestic 40.99 0.03
2   AMC Pacer  4749  17     3      3.0    11   3350    173   40          258       2.53 Domestic 47.49 0.03
3  AMC Spirit  3799  22    NA      3.0    12   2640    168   35          121       3.08 Domestic 37.99   NA
-------------------------------------------------------------- R output end ----------------------------------------------------------------

. tor m* in 1/3  // you can also export column (variable) subsets
------------------------------------------------------------- R output start ---------------------------------------------------------------
> str(StataData)
'data.frame':   3 obs. of  2 variables:
 $ make: Factor w/ 3 levels "AMC Concord",..: 1 2 3
 $ mpg : int  22 17 22
-------------------------------------------------------------- R output end ----------------------------------------------------------------

. r StataData  // again, see how the data now looks inside R
------------------------------------------------------------- R output start ---------------------------------------------------------------
> StataData
         make mpg
1 AMC Concord  22
2   AMC Pacer  17
3  AMC Spirit  22
-------------------------------------------------------------- R output end ----------------------------------------------------------------

. stopr  // close the R "server"
```
