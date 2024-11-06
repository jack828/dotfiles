# Flags used to compress (because why not) from:
# https://ptspts.blogspot.com/2013/12/how-to-make-smaller-c-and-c-binaries.html
CC=gcc
CFLAGS=-Wall -Werror -Wno-unused-result -O0 -fno-unwind-tables  -fno-stack-protector -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,-z,norelro -Wl,--build-id=none
LINKFLAGS=-lm
STRIP=strip
STRIPFLAGS=-s -R .comment -R .gnu.version --strip-unneeded -R .note.gnu.gold-version -R .note -R .note.gnu.build-id -R .note.ABI-tag
DEBUGFLAGS=-ggdb -O0
TARGET=statusline

.phony: statusline clean debug deploy valgrind

$(TARGET): $(TARGET).c
	$(CC) $(TARGET).c $(CFLAGS) -o $(TARGET) $(LINKFLAGS)
	$(STRIP) $(STRIPFLAGS) $(TARGET)

# See https://askubuntu.com/a/1349048 for more info
# make debug
# gdb ./statusline_debug
# r
# bt (or `bt full`)
#
# to set breakpoints:
# break statusline.c:45
debug:
	$(CC) $(TARGET).c $(CFLAGS) -o $(TARGET).debug $(LINKFLAGS) $(DEBUGFLAGS)

valgrind: debug
	valgrind \
		--tool=memcheck \
		--leak-check=full \
		--track-origins=yes \
		--leak-resolution=high \
		--show-reachable=yes \
		--trace-children=yes \
		./$(TARGET).debug

clean:
	rm -f $(TARGET)

deploy:
	cp ~/spell/en.utf-8.add ./spell/en.utf-8.add \
		&& ./dotfiles deploy -v \
		&& cp ./statusline ~/statusline
