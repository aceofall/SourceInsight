rem ctags -L cscope_.files --c++-kinds=+p --fields=+iaS --extra=+q .
rem ctags -L cscope_tag.files
rem cscope -b -R -i cscope_full.files
rem
rem cscope -b -R -i cscope.files

rm cscope.*out tags

ctags -L cscope_tag_new.files
cscope -b -R -k -q -i cscope_full.files
gtags -i -f cscope_full.files
