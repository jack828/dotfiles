# Flags used to compress (because why not) from:
# https://ptspts.blogspot.com/2013/12/how-to-make-smaller-c-and-c-binaries.html
CC=gcc
CFLAGS=-Wall -Wno-unused-result -Os -fno-unwind-tables  -fno-stack-protector -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,-z,norelro -Wl,--build-id=none
STRIP=strip
STRIPFLAGS=-s -R .comment -R .gnu.version --strip-unneeded -R .note.gnu.gold-version -R .note -R .note.gnu.build-id -R .note.ABI-tag
TARGET=statusline

$(TARGET):
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c
	$(STRIP) $(STRIPFLAGS) $(TARGET)

clean:
	rm -f $(TARGET)
