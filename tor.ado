prog tor
	syntax [varlist] [if] [in]
	tempfile d
	loc d "`d'.tor"
	qui outsheet `varlist' using "`d'" `if' `in', replace
	loc d = subinstr("`d'","\","/",.)
	qui r StataData <- read.delim('`d''); file.remove('`d'')
	r str(StataData)
end

