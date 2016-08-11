prog fromr
	syntax [, clear]
	qui des
	if `r(changed)' & mi("`clear'") err 4
	if !(`r(changed)') loc clear "clear"
	tempfile d
	loc d = subinstr("`d'","\","/",.)
	qui r write.table(StataData,'`d'', sep='\t', row.names=FALSE, na='.')
	insheet using "`d'", tab names `clear'
end
