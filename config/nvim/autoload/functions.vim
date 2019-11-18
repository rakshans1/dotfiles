" load vim-plug if it does not exist in the dotfiles
let s:plugpath = expand('<sfile>:p:h') . '/plug.vim' " this is relative to this file, which is in autoload
function! functions#PlugLoad()
    if !filereadable(s:plugpath)
        if executable('curl')
            echom "Installing vim-plug at " . s:plugpath
            let plugurl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
            call system('curl -fLo ' . shellescape(s:plugpath) . ' --create-dirs ' . plugurl)
            if v:shell_error
                echom "Error downloading vim-plug. Please install it manually.\n"
                exit
            endif
        else
            echom "vim-plug not installed. Please install it manually or install curl.\n"
            exit
        endif
    endif
endfunction
