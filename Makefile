defalut : all

all : test tools rt-thread-tang9k show_version

.PHONY : clean show_version test tools rt-thread-tang9k

show_version :
	@cat VERSION

test :
	$(MAKE) -C ./test

tools :
	$(MAKE) -C ./tools

rt-thread-tang9k :
	$(MAKE) -C ./os/rt-thread-nano

clean :
	$(MAKE) clean -C ./test
	$(MAKE) clean -C ./tools
	$(MAKE) clean -C ./os/rt-thread-nano
