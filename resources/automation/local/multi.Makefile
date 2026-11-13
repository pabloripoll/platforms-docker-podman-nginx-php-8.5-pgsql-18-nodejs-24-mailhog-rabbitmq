.DEFAULT_GOAL := redirect
%:
	@$(MAKE) -f $(if $(findstring Windows_NT,$(OS)),Makefile.win,Makefile.unix) $(MAKECMDGOALS)
redirect:
	@$(MAKE) -f $(if $(findstring Windows_NT,$(OS)),Makefile.win,Makefile.unix) help
