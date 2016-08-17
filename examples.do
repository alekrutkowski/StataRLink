// Compiling the usage examples in README.md
// Run it in Stata with:  run examples.do

cap prog drop ex2md
prog ex2md // = EXample TO MarkDown
	loc comment = strmatch(`"`macval(0)'"',"comment *")
	if `comment' {
		comment `=subinstr(`"`0'"',"comment ","",1)'
	}
	else {
		di ("**" + char(96) + subinstr(`"`macval(0)'"',"\$","\\$",.) + char(96) + "**")
	}
	di
	loc wrap = `"`macval(0)'"' != "stopr" & !strmatch(`"`macval(0)'"',"keep m*")
	if `wrap' & !`comment' di char(96) + char(96) + char(96)
	if !`comment'  {
		`macval(0)'
	}
	if `wrap' & !`comment' di char(96) + char(96) + char(96)
	if `wrap' & !`comment' di
end
cap prog drop comment
prog comment
	di ("*" + char(96) + "// " + `"`0'"' + char(96) + "*")
end

cls
qui set line 80  // line width in Stata in characters
noi ex2md comment Start R "server":
noi ex2md startr
qui r options(width=80) // line width in R in characters
noi ex2md comment Open an example dataset available in Stata (built-in):
noi ex2md sysuse auto, clear
noi ex2md comment Keep only some columns (variables) for clarity:
noi ex2md keep make price mpg rep78
noi ex2md comment Command "tor" = "to R" -- export data to R;
noi ex2md comment by default, the dataset is put into R object called "StataData":
noi ex2md tor
noi ex2md comment The "r" command executes R functions interactively:
noi ex2md r StataData <- within(StataData, new <- price/100)
noi ex2md comment Import modified data ("StataData" object) back into Stata:
noi ex2md fromr, clear
noi ex2md comment Have a look at the top of the data:
noi ex2md list in 1/5, clean
noi ex2md comment Do some manipulations again in R:
noi ex2md r StataData <- within(StataData, new2 <- rep78/100)
noi ex2md comment Import the latest version of the "StataData" object:
noi ex2md fromr, clear
noi ex2md comment Have a look at the top of the data:
noi ex2md list in 1/5, clean
noi ex2md comment You can export observation subsets with "if" and "in"
noi ex2md comment (put option "replace" to replace the current "StataData")
noi ex2md tor in 1/3, replace
noi ex2md comment See how the data now looks inside R:
noi ex2md r StataData
noi ex2md comment You can also export column (variable) subsets:
noi ex2md tor m* in 1/3, replace
noi ex2md comment Again, see how the data now looks inside R:
noi ex2md r StataData
noi ex2md comment You can also export to and import from a different object than
noi ex2md comment the default "StataData"
noi ex2md tor m* in 1/3, name(myOtherName)
noi ex2md comment Escape the dollar character with a backslash to avoid
noi ex2md comment interpreting it in Stata as a global macro
noi ex2md r myOtherName\$new_column <- 11:13
noi ex2md fromr, name(myOtherName) clear
noi ex2md list, clean abbreviate(11)
noi ex2md comment Close the R "server":
noi ex2md stopr

