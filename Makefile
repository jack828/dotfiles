CC=gcc
CFLAGS=-Wall -Wno-unused-result -s -Os -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -Wl,--gc-sections
STRIP=strip
STRIPFLAGS=-s -R .comment -R .gnu.version --strip-unneeded -R .note.gnu.gold-version -R .note -R .note.gnu.build-id -R .note.ABI-tag
TARGET=statusline

$(TARGET):
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c
	$(STRIP) $(STRIPFLAGS) $(TARGET)

clean:
	rm $(TARGET)
