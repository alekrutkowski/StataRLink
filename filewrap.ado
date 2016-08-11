program filewrap
	version 13
	syntax using/, [PREamble(string asis) ADDendum(string asis)]
	qui {
		tempname lb
		tempfile linebreak
		file open `lb' using "`linebreak'" , write text
			file write `lb' _n
		file close `lb'
		preserve
			clear
			set obs 1
			gen f = fileread("`using'")
			gen lb = fileread("`linebreak'")
			foreach v in preamble addendum {
				gen `v' = ""
				foreach L of loc `v' {
					replace `v' = `v' + `"`L'"' + lb
				}
			}
			replace f = preamble + f + addendum
			gen s = filewrite("`using'",f,1)
			summ s, mean
			if r(mean)<0 err `=-r(mean)'
		restore	
	}
end

