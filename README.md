StataRLink: Stata commands (.ado files) for easy interactive work with R
================
Aleksander Rutkowski

2016-08-16

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
   di "Dealing with file `f'"
   copy "`gh'`f'" "`c(sysdir_personal)'`f'", text public
}
```

If you **re-install** *StataRLink*, add the word `replace` at the end of the
penultimate line (the one inside the `foreach` loop,
which starts with `copy`), that should look like this:

```
   copy "`gh'`f'" "`c(sysdir_personal)'`f'", text public replace
```

If you **un-install** *StataRLink*, replace the
penultimate line (the one inside the `foreach` loop,
which starts with `copy`) with the following code:

```
   rm "`c(sysdir_personal)'`f'"
```

#### Manually

Download <https://github.com/alekrutkowski/StataRLink/archive/master.zip>
and open (unzip) it. Then, copy the unzipped contents
(the contents of the `StataRLink-master` subdirectory) into your "personal"
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

### Simple usage examples

*`// Start R "server":`*

**`startr`**

```
R "server" started successfully
```

*`// Open an example dataset available in Stata (built-in):`*

**`sysuse auto, clear`**

```
(1978 Automobile Data)
```

*`// Keep only some columns (variables) for clarity:`*

**`keep make price mpg rep78`**

*`// Command "tor" = "to R" -- export data to R;`*

*`// by default, the dataset is put into R object called "StataData":`*

**`tor`**

```
Exporting data from Stata...
Importng data into R object 'StataData'...
------------------------------- R output start ---------------------------------
> str(StataData)
'data.frame':   74 obs. of  4 variables:
 $ make : Factor w/ 74 levels "AMC Concord",..: 1 2 3 7 8 9 10 11 12 13 ...
 $ price: int  4099 4749 3799 4816 7827 5788 4453 5189 10372 4082 ...
 $ mpg  : int  22 17 22 20 15 18 26 20 16 19 ...
 $ rep78: int  3 3 NA 3 4 3 NA 3 3 3 ...
-------------------------------- R output end ----------------------------------
```

*`// The "r" command executes R functions interactively:`*

**`r StataData <- within(StataData, new <- price/100)`**

```
------------------------------- R output start ---------------------------------
> StataData <- within(StataData, new <- price/100)
-------------------------------- R output end ----------------------------------
```

*`// Import modified data ("StataData" object) back into Stata:`*

**`fromr, clear`**

```
Exportng 'StataData' from R...
Importing data into Stata...
(5 vars, 74 obs)
```

*`// Have a look at the top of the data:`*

**`list in 1/5, clean`**

```
                make   price   mpg   rep78     new  
  1.     AMC Concord    4099    22       3   40.99  
  2.       AMC Pacer    4749    17       3   47.49  
  3.      AMC Spirit    3799    22       .   37.99  
  4.   Buick Century    4816    20       3   48.16  
  5.   Buick Electra    7827    15       4   78.27  
```

*`// Do some manipulations again in R:`*

**`r StataData <- within(StataData, new2 <- rep78/100)`**

```
------------------------------- R output start ---------------------------------
> StataData <- within(StataData, new2 <- rep78/100)
-------------------------------- R output end ----------------------------------
```

*`// Import the latest version of the "StataData" object:`*

**`fromr, clear`**

```
Exportng 'StataData' from R...
Importing data into Stata...
(6 vars, 74 obs)
```

*`// Have a look at the top of the data:`*

**`list in 1/5, clean`**

```
                make   price   mpg   rep78     new   new2  
  1.     AMC Concord    4099    22       3   40.99    .03  
  2.       AMC Pacer    4749    17       3   47.49    .03  
  3.      AMC Spirit    3799    22       .   37.99      .  
  4.   Buick Century    4816    20       3   48.16    .03  
  5.   Buick Electra    7827    15       4   78.27    .04  
```

*`// You can export observation subsets with "if" and "in"`*

*`// (put option "replace" to replace the current "StataData")`*

**`tor in 1/3, replace`**

```
Exporting data from Stata...
Importng data into R object 'StataData'...
------------------------------- R output start ---------------------------------
> str(StataData)
'data.frame':   3 obs. of  6 variables:
 $ make : Factor w/ 3 levels "AMC Concord",..: 1 2 3
 $ price: int  4099 4749 3799
 $ mpg  : int  22 17 22
 $ rep78: int  3 3 NA
 $ new  : num  41 47.5 38
 $ new2 : num  0.03 0.03 NA
-------------------------------- R output end ----------------------------------
```

*`// See how the data now looks inside R:`*

**`r StataData`**

```
------------------------------- R output start ---------------------------------
> StataData
         make price mpg rep78   new new2
1 AMC Concord  4099  22     3 40.99 0.03
2   AMC Pacer  4749  17     3 47.49 0.03
3  AMC Spirit  3799  22    NA 37.99   NA
-------------------------------- R output end ----------------------------------
```

*`// You can also export column (variable) subsets:`*

**`tor m* in 1/3, replace`**

```
Exporting data from Stata...
Importng data into R object 'StataData'...
------------------------------- R output start ---------------------------------
> str(StataData)
'data.frame':   3 obs. of  2 variables:
 $ make: Factor w/ 3 levels "AMC Concord",..: 1 2 3
 $ mpg : int  22 17 22
-------------------------------- R output end ----------------------------------
```

*`// Again, see how the data now looks inside R:`*

**`r StataData`**

```
------------------------------- R output start ---------------------------------
> StataData
         make mpg
1 AMC Concord  22
2   AMC Pacer  17
3  AMC Spirit  22
-------------------------------- R output end ----------------------------------
```

*`// You can also export to and import from a different object than`*

*`// the default "StataData"`*

**`tor m* in 1/3, name(myOtherName)`**

```
Exporting data from Stata...
Importng data into R object 'myOtherName'...
------------------------------- R output start ---------------------------------
> str(myOtherName)
'data.frame':   3 obs. of  2 variables:
 $ make: Factor w/ 3 levels "AMC Concord",..: 1 2 3
 $ mpg : int  22 17 22
-------------------------------- R output end ----------------------------------
```

*`// Escape the dollar character with a backslash to avoid`*

*`// interpreting it in Stata as a global macro`*

**`r myOtherName\$new_column <- 11:13`**

```
------------------------------- R output start ---------------------------------
> myOtherName$new_column <- 11:13
-------------------------------- R output end ----------------------------------
```

**`fromr, name(myOtherName) clear`**

```
Exportng 'myOtherName' from R...
Importing data into Stata...
(3 vars, 3 obs)
```

**`list, clean abbreviate(11)`**

```
              make   mpg   new_column  
  1.   AMC Concord    22           11  
  2.     AMC Pacer    17           12  
  3.    AMC Spirit    22           13  
```

*`// Close the R "server":`*

**`stopr`**

### Details

The Stata command `r` returns the displayed R output in r-class Stata macros
plus a scalar indicating the number of lines returned. Type `return list`
after `r ...` to see it.

In addition, if the line of R code is executed with an error, `r` returns Stata error
number 675.
