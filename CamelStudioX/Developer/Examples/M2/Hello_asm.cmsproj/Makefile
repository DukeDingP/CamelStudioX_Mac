TARGET_NAME = Hello
OBJ_DIR = release
BIN_DIR = release
LIB_DIR = lib
TARGET_ADDRESS = 10000000
DATA_ADDRESS = 01000010
RODATA_ADDRESS = 

COMPILER_PATH = /Applications/CamelStudioX.app/Contents/Resources/Developer/Toolchains/bin/
GCC = $(COMPILER_PATH)mips-netbsd-elf-gcc
GCC_OPTION = -EL -DPRT_UART -march=mips1 -std=c99 -c -G0 
AS = $(COMPILER_PATH)mips-netbsd-elf-as
AS_OPTION = -EL
LD = $(COMPILER_PATH)mips-netbsd-elf-ld
LD_OPTION = -EL -eentry -s -N -Ttext $(TARGET_ADDRESS) -Tdata $(DATA_ADDRESS) $(if $(RODATA_ADDRESS),--section-start .rodata=$(RODATA_ADDRESS),)
OBJDUMP = $(COMPILER_PATH)mips-netbsd-elf-objdump
AR = $(COMPILER_PATH)mips-netbsd-elf-ar
AR_OPTION = rcs
CONVERTER = $(COMPILER_PATH)../convert
CONVERTER_OPTION = -m

C_SOURCE = interrupt.c
C_OBJECT = $(C_SOURCE:.c=.o)
A_SOURCE = Hello.s
A_OBJECT = $(A_SOURCE:.s=.o)
ENTRY_FILE = /Applications/CamelStudioX.app/Contents/Resources/Developer/OfficialLibrary/lib/M2/entry.o

CHIP_HEADER = /Applications/CamelStudioX.app/Contents/Resources/Developer/OfficialLibrary/include/M2
STD_HEADER = /Applications/CamelStudioX.app/Contents/Resources/Developer/OfficialLibrary/include/std
CORE_HEADER = /Applications/CamelStudioX.app/Contents/Resources/Developer/OfficialLibrary/include/core
HEADER_FLAGS = -I $(CHIP_HEADER) -I $(STD_HEADER) -I $(CORE_HEADER) -I ./

CHIP_LIBRARY = /Applications/CamelStudioX.app/Contents/Resources/Developer/OfficialLibrary/lib/M2
STD_LIBRARY = /Applications/CamelStudioX.app/Contents/Resources/Developer/OfficialLibrary/lib/std
LIBRARY_FLAGS = -L $(STD_LIBRARY) -L $(CHIP_LIBRARY)    -lm2core

all: $(TARGET_NAME)

$(TARGET_NAME):$(C_OBJECT) $(A_OBJECT)
	mkdir -p $(OBJ_DIR);mkdir -p $(BIN_DIR);mkdir -p $(LIB_DIR);
	cd $(OBJ_DIR);$(LD) $(LD_OPTION) -o ../$(BIN_DIR)/$(TARGET_NAME) $(ENTRY_FILE) $^ $(LIBRARY_FLAGS);
	$(CONVERTER) $(CONVERTER_OPTION) $(BIN_DIR)/$(TARGET_NAME)
	echo "Success"

lib:$(C_OBJECT) $(A_OBJECT)
	cd $(OBJ_DIR);$(AR) $(AR_OPTION) ../$(LIB_DIR)/lib$(TARGET_NAME).a $^
	echo "Success"

clean:
	rm -f $(OBJ_DIR)/*
	rm -f $(BIN_DIR)/*
	rm -f $(LIB_DIR)/*

.c.o:
	mkdir -p $(OBJ_DIR);mkdir -p $(BIN_DIR);mkdir -p $(LIB_DIR);
	$(GCC) $(GCC_OPTION) $(HEADER_FLAGS) -o $(OBJ_DIR)/$@ $<
.s.o:
	mkdir -p $(OBJ_DIR);mkdir -p $(BIN_DIR);mkdir -p $(LIB_DIR);
	$(AS) $(AS_OPTION) -o $(OBJ_DIR)/$@ $<