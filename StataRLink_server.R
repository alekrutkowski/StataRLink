(function(server_dir, dt_stamp) {
    # Helpers
    f <- list
    qui <- capture.output
    '%>>>%' <- function(x,y) do.call(y[[1]], c(list(x),tail(y,-1)))
    '%+%' <- function(x,y) paste0(x,y)
    sendMess <- function(path,txt) cat("", file = path %+% '.' %+% txt)
    errHandl <- function(err, newfile) {
        function(err) {
            message('Error!')
            sendMess(newfile, 'error')
            sub(pattern=newfile, replacement="",
                'Error:\n ' %+% geterrmessage(),
                fixed=TRUE) %>>>%
                f(cat, sep='\n')
        }
    }
    execRcmd <- function(newfile)
        `if`(grepl('.*q\\(\\).*',
                   readLines(newfile)),
             {conclude(newfile); q()},
             capture.output(tryCatch(source(newfile,
                                            echo=TRUE,
                                            local=globalenv()),
                                     error = errHandl(err, newfile)),
                            file = newfile %+% '.output'))
    conclude <- function(newfile) {
        sendMess(newfile, 'done')
        file.remove(newfile)
        file.remove(newfile %+% '.job')
    }
    # Core:
    message('StataRLink Rscript "server" started\n',
            'The Stata-R communication directory:\n',
            server_dir)
    message('Deleting old files...')
    qui(list.files(full.names=TRUE,
                   path=server_dir,
                   pattern='^script .*\\.R$' %+%
                       '|^script .*\\.R\\.job$' %+%
                       '|^script .*\\.R\\.done$' %+%
                       '|^script .*\\.R\\.output$' %+%
                       '|.*.server_opened$' %+%
                       '|^server.*\\.R$') %>>>%
            f(setdiff, server_dir %+% 'server ' %+% dt_stamp %+% '.R') %>>>%
            f(file.remove))
    message('Waiting for jobs...')
    sendMess(server_dir %+% dt_stamp, 'server_opened')
    repeat {
        newfile <-
            list.files(path=server_dir,
                       pattern='^script .*\\.R\\.job$',
                       full.names=TRUE)[1]
        if (!is.na(newfile)) {
            newfile <- sub('.job',"",newfile,fixed=TRUE)
            message(Sys.time(), ' Executing:\n', readLines(newfile))
            execRcmd(newfile)
            conclude(newfile)
            message('Waiting for jobs...')
            Sys.sleep(.01)
        }
    }
}  # unbalanced parentheses on purpose: Stata will dynamically modify this
   # file, putting a closing parenthese and argument values (server_dir, dt_stamp)
