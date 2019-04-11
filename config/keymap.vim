"""""""""""""""""""""""""""""""""""""""""
" 快捷键配置
"""""""""""""""""""""""""""""""""""""""""
" 定义前缀键
let mapleader=";"

"定义快捷键到行首和行尾
nmap LB 0
nmap LE $

" 定义git grep 快捷键
cnoreabbrev grep !git grep

" vim文本选择
" v : 按照字符选择
" V : 按行选择
" Ctrl+v : 按列选择

" 剪切到剪切板
nmap <Leader>d "+d
" 设置快捷键将选中文本块复制至系统剪贴板
nmap <Leader>y "+y
" 设置快捷键将系统剪贴板内容粘贴至 vim
nmap <Leader>p "+p

" 水平窗口:sp
nmap wsp :sp<cr>
" 垂直窗口:vsp
nmap wvsp :vsp<cr>
" 遍历子窗口
nnoremap wn <C-W><C-W>

nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
      \ if ! exists("g:leave_my_cursor_position_alone") |
      \     if line("'\"") > 0 && line ("'\"") <= line("$") |
      \         exe "normal g'\"" |
      \     endif |
      \ endif

" w!! to sudo & write a file
cnoremap w!! call SudoSaveFile()
function! SudoSaveFile() abort
	execute (has('gui_running') ? '' : 'silent') 'write !env SUDO_EDITOR=tee sudo -e % >/dev/null'
	let &modified = v:shell_error
endfunction

" eggcache vim
:command! W w
:command! WQ wq
:command! Q q
:command! QA qa
:command! WQA wqa

"NERDTREE
nnoremap <F5> :NERDTreeToggle<CR>

"taglist
"nnoremap <silent> <F6> :TlistToggle<CR><CR>
"let Tlist_Show_One_File=0                    " 只显示当前文件的tags
"let Tlist_Exit_OnlyWindow=1                  " 如果Taglist窗口是最后一个窗口则退出Vim
"let Tlist_Use_Right_Window=1                 " 在右侧窗口中显示
"let Tlist_File_Fold_Auto_Close=1             " 自动折叠


"cscope
nnoremap <F4> :!cscope -Rbkq <CR>

set nocst    "在cscope数据库添加成功的时候不在命令栏现实提示信息.
set cspc=6 "cscope的查找结果在格式上最多显示6层目录.
let g:autocscope_menus=0 "关闭autocscope插件的快捷健映射.防止和我们定义的快捷键冲突.

"cscope相关的快捷键映射
"ff映射到ctrl+]
nmap ff <c-]>
"ss映射到ctrl+t
nmap ss <c-t>

"s:查找即查找C语言符号出现的地方
nmap fs :cs find s <C-R>=expand("<cword>")<CR><CR>
"g:查找函数、宏、枚举等定义的位置
nmap fg :cs find g <C-R>=expand("<cword>")<CR><CR>
"c:查找光标下的函数被调用的地方
nmap fc :cs find c <C-R>=expand("<cword>")<CR><CR>
"t: 查找指定的字符串出现的地方
nmap ft :cs find t <C-R>=expand("<cword>")<CR><CR>
"e:egrep模式查找,相当于egrep功能
nmap fe :cs find e <C-R>=expand("<cword>")<CR><CR>
"f: 查找文件名,相当于lookupfile
nmap fn :cs find f <C-R>=expand("<cfile>")<CR><CR>
"i: 查找当前文件名出现过的地方
nmap fi :cs find i <C-R>=expand("<cfile>")<CR><CR>
"d: 查找本当前函数调用的函数
nmap fd :cs find d <C-R>=expand("<cword>")<CR><CR>
