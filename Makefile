AS=as
ASFLAGS=--64 -g

LD=ld

OBJ=build/bf.o build/sys.o build/interpreter.o build/io.o build/filehandler.o

build/%.o: src/%.s
	$(AS) $(ASFLAGS) $< -o $@

bf: $(OBJ)
	$(LD) $(OBJ) -o bf

.PHONY:
clean:
	rm build/*.o
	rm bf
