rem ctags -L cscope_.files --c++-kinds=+p --fields=+iaS --extra=+q .
rem ctags -L cscope_tag.files
rem cscope -b -R -i cscope_full.files
rem
rem cscope -b -R -i cscope.files

rm cscope.*out tags

ctags -a -L cscope_full.files ^
-I __initdata,__exitdata,__initconst, ^
-I __cpuinitdata,__initdata_memblock ^
-I __refdata,__attribute,__maybe_unused,__always_unused ^
-I __acquires,__releases,__deprecated ^
-I __read_mostly,__aligned,____cacheline_aligned ^
-I ____cacheline_aligned_in_smp ^
-I __cacheline_aligned,__cacheline_aligned_in_smp ^
-I ____cacheline_internodealigned_in_smp ^
-I __used,__packed,__packed2__,__must_check,__must_hold ^
-I EXPORT_SYMBOL,EXPORT_SYMBOL_GPL,ACPI_EXPORT_SYMBOL ^
-I DEFINE_TRACE,EXPORT_TRACEPOINT_SYMBOL,EXPORT_TRACEPOINT_SYMBOL_GPL ^
-I static,const ^
--extra=+f --c-kinds=+px ^
--regex-asm="/^(ENTRY|_GLOBAL)\(([^)]*)\).*/\2/" ^
--regex-c="/^SYSCALL_DEFINE[[:digit:]]?\(([^,)]*).*/sys_\1/" ^
--regex-c++="/^TRACE_EVENT\(([^,)]*).*/trace_\1/" ^
--regex-c++="/^DEFINE_EVENT\([^,)]*, *([^,)]*).*/trace_\1/" ^
--regex-c++="/PAGEFLAG\(([^,)]*).*/Page\1/" ^
--regex-c++="/PAGEFLAG\(([^,)]*).*/SetPage\1/" ^
--regex-c++="/PAGEFLAG\(([^,)]*).*/ClearPage\1/" ^
--regex-c++="/TESTSETFLAG\(([^,)]*).*/TestSetPage\1/" ^
--regex-c++="/TESTPAGEFLAG\(([^,)]*).*/Page\1/" ^
--regex-c++="/SETPAGEFLAG\(([^,)]*).*/SetPage\1/" ^
--regex-c++="/__SETPAGEFLAG\(([^,)]*).*/__SetPage\1/" ^
--regex-c++="/TESTCLEARFLAG\(([^,)]*).*/TestClearPage\1/" ^
--regex-c++="/__TESTCLEARFLAG\(([^,)]*).*/TestClearPage\1/" ^
--regex-c++="/CLEARPAGEFLAG\(([^,)]*).*/ClearPage\1/" ^
--regex-c++="/__CLEARPAGEFLAG\(([^,)]*).*/__ClearPage\1/" ^
--regex-c++="/__PAGEFLAG\(([^,)]*).*/__SetPage\1/" ^
--regex-c++="/__PAGEFLAG\(([^,)]*).*/__ClearPage\1/" ^
--regex-c++="/PAGEFLAG_FALSE\(([^,)]*).*/Page\1/" ^
--regex-c++="/TESTSCFLAG\(([^,)]*).*/TestSetPage\1/" ^
--regex-c++="/TESTSCFLAG\(([^,)]*).*/TestClearPage\1/" ^
--regex-c++="/SETPAGEFLAG_NOOP\(([^,)]*).*/SetPage\1/" ^
--regex-c++="/CLEARPAGEFLAG_NOOP\(([^,)]*).*/ClearPage\1/" ^
--regex-c++="/__CLEARPAGEFLAG_NOOP\(([^,)]*).*/__ClearPage\1/" ^
--regex-c++="/TESTCLEARFLAG_FALSE\(([^,)]*).*/TestClearPage\1/" ^
--regex-c++="/__TESTCLEARFLAG_FALSE\(([^,)]*).*/__TestClearPage\1/" ^
--regex-c++="/_PE\(([^,)]*).*/PEVENT_ERRNO__\1/" ^
--regex-c="/PCI_OP_READ\((\w*).*[1-4]\)/pci_bus_read_config_\1/" ^
--regex-c="/PCI_OP_WRITE\((\w*).*[1-4]\)/pci_bus_write_config_\1/" ^
--regex-c="/DEFINE_(MUTEX|SEMAPHORE|SPINLOCK)\((\w*)/\2/v/" ^
--regex-c="/DEFINE_(RAW_SPINLOCK|RWLOCK|SEQLOCK)\((\w*)/\2/v/" ^
--regex-c="/DECLARE_(RWSEM|COMPLETION)\((\w*)/\2/v/" ^
--regex-c="/DECLARE_BITMAP\((\w*)/\1/v/" ^
--regex-c="/(^|\s)(|L|H)LIST_HEAD\((\w*)/\3/v/" ^
--regex-c="/(^|\s)RADIX_TREE\((\w*)/\2/v/" ^
--regex-c="/DEFINE_PER_CPU\(([^,]*,\s*)(\w*).*\)/\2/v/" ^
--regex-c="/DEFINE_PER_CPU_SHARED_ALIGNED\(([^,]*,\s*)(\w*).*\)/\2/v/" ^
--regex-c="/DECLARE_WAIT_QUEUE_HEAD\((\w*)/\1/v/" ^
--regex-c="/DECLARE_(TASKLET|WORK|DELAYED_WORK)\((\w*)/\2/v/" ^
--regex-c="/DEFINE_PCI_DEVICE_TABLE\((\w*)/\1/v/" ^
--regex-c="/(^\s)OFFSET\((\w*)/\2/v/" ^
--regex-c="/(^\s)DEFINE\((\w*)/\2/v/"

ctags -a -L kconfigs.files ^
--langdef=kconfig --language-force=kconfig ^
--regex-kconfig="/^[[:blank:]]*(menu|)config[[:blank:]]+([[:alnum:]_]+)/\2/"

ctags -a -L kconfigs.files ^
--langdef=kconfig --language-force=kconfig ^
--regex-kconfig="/^[[:blank:]]*(menu|)config[[:blank:]]+([[:alnum:]_]+)/CONFIG_\2/"

ctags -a -L defconfigs.files ^
--langdef=dotconfig --language-force=dotconfig ^
--regex-dotconfig="/^#?[[:blank:]]*(CONFIG_[[:alnum:]_]+)/\1/"

cscope -b -R -k -q -i cscope_full.files
gtags -i -f cscope_full.files
