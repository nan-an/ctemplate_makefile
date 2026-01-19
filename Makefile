# Project identifiers
PROJECT = ctemplate 
PROJECT_VERSION = 1.0.0

# Toolchain details
CC = gcc
LD = gcc
MC = /usr/bin/valgrind
MACMC = /usr/bin/leaks

# Folder structure
INCLUDE_DIR = include

# main builds 
SRC_DIR = src
OBJ_DIR = dist
DEP_DIR = .dep

# test build structure
TEST_DIR = tests
TEST_SRC_DIR = $(TEST_DIR)/src
TEST_OBJ_DIR = $(TEST_DIR)/dist
TEST_DEP_DIR = $(TEST_DIR)/.dep

# project preferences for building
CFLAGS = -Wall -Wextra -g -pedantic -pthread -std=c11 -I./$(INCLUDE_DIR)

# passing the version of the project as a preprocessor macro definition.
CFLAGS += -DPROJECT_VERSION=\"$(PROJECT_VERSION)\"

# Linker flags can be added here if needed.
LDFLAGS = -lpthread

# Include external dependencies if any in here.
include depends.mk

# Single out the main file and obj, so that it can be removed when building library only.
MAIN_FILE := $(SRC_DIR)/main.c
MAIN_OBJ := $(OBJ_DIR)/main.o

# build out the source and obj lists.
SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))
LIB_SRCS := $(filter-out $(MAIN_FILE),$(SRCS))
LIB_OBJS := $(filter-out $(MAIN_OBJ),$(OBJS))

# used for dependency tracking - for efficient rebuilds.
DEPS := $(patsubst $(SRC_DIR)/%.c,$(DEP_DIR)/%.d,$(SRCS))
DEPFLAGS = -MMD -MP -MF $(DEP_DIR)/$*.d


# mark the planned targets
TARGET = $(OBJ_DIR)/$(PROJECT)
SHARED_TARGET = $(OBJ_DIR)/$(PROJECT)-shared
LIB_TARGET = $(OBJ_DIR)/lib$(PROJECT).a
LIB_SHARED_TARGET = $(OBJ_DIR)/lib$(PROJECT).so

# do the same for the test folder structure.
TEST_SRCS := $(wildcard $(TEST_SRC_DIR)/*.c)
TEST_OBJS := $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(TEST_SRCS))
TEST_DEPS := $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_DEP_DIR)/%.d,$(TEST_SRCS))
TEST_TARGETS = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%_tests,$(TEST_SRCS))
TEST_CFLAGS = $(CFLAGS) -I./$(TEST_DIR)/include -DTEST
TEST_DEPFLAGS = -MMD -MP -MF $(TEST_DEP_DIR)/$*.d
TEST_LDFLAGS =


# declare the never ready, in-tangible targets
.PHONY: all clean vars bear mc macmc

all: $(OBJ_DIR) $(TARGET) $(SHARED_TARGET) $(LIB_TARGET) $(LIB_SHARED_TARGET)
	@echo "Build complete. Executable is $(TARGET)"

# Linking step, so Linker and Linker flags are used here.
$(TARGET): $(LIB_TARGET)
	$(LD) -o $@ $(CFLAGS) $(LDFLAGS) $(MAIN_FILE) $(LIB_TARGET)

$(SHARED_TARGET): $(LIB_SHARED_TARGET)
	$(LD) -o $@ $(CFLAGS) $(LDFLAGS) $(MAIN_FILE) -L./$(OBJ_DIR) -l$(PROJECT)

$(LIB_TARGET): $(LIB_OBJS)
	ar rcs $@ $^

$(LIB_SHARED_TARGET): $(LIB_SRCS)
	$(CC) $(CFLAGS) -shared -fPIC -o $@ $^


# This should be individual file pattern then only $< will work.
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR) $(DEP_DIR)
	$(CC) -c $(CFLAGS) $(DEPFLAGS) -o $@ $<


$(OBJ_DIR) $(DEP_DIR):
	mkdir -p $@

$(DEP_DIR)/%.d:
	

# This shouls set up correct dependency between .o and .h files.
include $(DEPS)

mc: $(TEST_OBJS) $(TEST_TARGETS)
	@echo "All tests built."
	@for test in $(TEST_TARGETS); do \
		echo "Running memory check on $$test..."; \
		$(MC) --tool=memcheck --gen-suppressions=all --leak-check=full --leak-resolution=med --track-origins=yes --vgdb=no ./$$test;	 \
	done

# Mac OS specific memory check using Leaks tool.
macmc: $(TEST_OBJS) $(TEST_TARGETS)
	@echo "All tests built."
	@for test in $(TEST_TARGETS); do \
		echo "Running memory check with Mac OS Leaks on $$test..."; \
		$(MACMC) --atExit --list -- ./$$test;	 \
	done

# Test targets
tests: $(TEST_OBJS) $(TEST_TARGETS)
	@echo "All tests built."
	@for test in $(TEST_TARGETS); do \
		echo "Running $$test..."; \
		./$$test; \
	done

$(TEST_OBJ_DIR) $(TEST_DEP_DIR):
	mkdir -p $@

$(TEST_OBJ_DIR)/%_tests: $(TEST_OBJ_DIR)/%.o $(LIB_TARGET)
	$(LD) $(TEST_LDFLAGS) -o $@ $< $(LIB_TARGET)

$(TEST_OBJ_DIR)/%.o: $(TEST_SRC_DIR)/%.c | $(TEST_OBJ_DIR) $(TEST_DEP_DIR)
	$(CC) -c $(TEST_CFLAGS) $(TEST_DEPFLAGS) -o $@ $<

$(TEST_DEP_DIR)/%.d:
	# Dependency files for test sources will be generated here.

include $(TEST_DEPS)

clean:
	rm -rf $(OBJ_DIR) $(DEP_DIR) $(TARGET) $(LIB_TARGET) $(LIB_SHARED_TARGET) $(TEST_OBJ_DIR) $(TEST_DEP_DIR) $(TEST_TARGETS)
	@echo "Cleaned up build artifacts."

bear: clean
	@echo "Generating compile_commands.json using bear..."
	bear -- $(MAKE) all tests



