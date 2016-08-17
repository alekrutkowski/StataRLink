prog r, rclass
	if mi("$rserver") | "$rserver"=="off"  {
		di as err `"R "server" does not seem to be open."' _n /*
			*/ "Set the {bf:rscript_path} global macro (if not set yet)" _n /*
			*/ `"and start the R "server" with the command {bf:startr}"'
		err 691
	}
	loc stmp = strofreal(round(runiform()*1e8),"%9.0f")
	loc dt = subinstr("$S_DATE $S_TIME `stmp'",":",".",.)
	loc server_dir = subinstr("`c(tmpdir)'","\","/",.)
	tempname rs
	file open `rs' using "`server_dir'script `dt'.R", write text
		file write `rs' `"`macval(0)'"' _n
	file close `rs'
	if strtrim(`"`macval(0)'"')!="q()" {
		waitforfile "`server_dir'script `dt'.R.done"
		sleep 10 // to avoid empty output file due to disk I/O delays
		qui rm "`server_dir'script `dt'.R.done"
		dicen "R output start"
		type "`server_dir'script `dt'.R.output"
		dicen "R output end"
		di
		tempname fh
		local linenum = 0
		local rlinenum = 0
		file open `fh' using "`server_dir'script `dt'.R.output", read text
		file read `fh' line
		while r(eof)==0 {
			local linenum = `linenum' + 1
			if !mi(`"`macval(line)'"') {
				local rlinenum = `rlinenum' + 1
				ret loc r`rlinenum' `"`macval(line)'"'
			}
			file read `fh' line
		}
		file close `fh'
		ret sca rn = `rlinenum'
		qui rm "`server_dir'script `dt'.R.output"
		cap conf file "`server_dir'script `dt'.R.error"
		if !_rc {
			qui rm "`server_dir'script `dt'.R.error"
			di as err "R error; see the message above."
			err 675
		}
	}
end

