prog tor
	syntax [varlist] [if] [in]
	tempfile d
	loc d "`d'.tor"
	qui outsheet `varlist' using "`d'" `if' `in', replace
	loc d = subinstr("`d'","\","/",.)
	qui r ..tor..('`d'')
	r str(StataData)
end

