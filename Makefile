CC=gcc
CFLAGS=-Wall -Wno-unused-result -s -Os
STRIP=strip
STRIPFLAGS=-s -R .comment -R .gnu.version --strip-unneeded

TARGET=statusline

$(TARGET):
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c
	$(STRIP) $(STRIPFLAGS) $(TARGET)

clean:
	rm $(TARGET)
