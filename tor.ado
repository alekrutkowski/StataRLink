prog tor
	syntax [varlist] [if] [in] [, name(string asis) replace]
	if mi(`"`name'"') loc name "StataData"
	if mi("`replace'") {
		qui r exists('`name'')
		if strmatch(`"`r(r2)'"',"*TRUE") {
			noi di as err `"Object "`name'" already exists in R!"' _n /*
				*/ "Specify option {bf:replace} if you want to replace it or" _n /*
				*/ "specify a new object name inside option {bf:name()}."
			err 675
		}
	}
	tempfile d
	loc d "`d'.tor"
	di as txt "Exporting data from Stata..."
	qui outsheet `varlist' using "`d'" `if' `in', replace
	loc d = subinstr("`d'","\","/",.)
	di as txt "Importng data into R object " as res `"'`name''"' as txt "..."
	qui r \``name'\` <- read.delim('`d''); file.remove('`d'')
	r str(\``name'\`)
end

