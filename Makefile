SHELL=/bin/bash

test:
	@[ -t 1 ] && flags=-c ; \
	./test-bitsh.sh $$flags t
