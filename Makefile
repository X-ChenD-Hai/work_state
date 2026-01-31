CC := $(shell command -v gcc || command -v clang)
CXX = $(shell command -v g++ || command -v clang++)
AR := $(shell command -v ar || command -v ranlib)
LINK := $(shell command -v ${CC} || command -v ${CXX})

LDFLAGS := -Wall -Wextra -Werror
ARFLAGS := rcs
CFLAGS := -Wall -Wextra -Werror -g -O0
CXXFLAGS := -Wall -Wextra -Werror -g -O0
SOURCES_DIR := src
OBJECTS_DIR := build/obj
BIN_DIR := build/bin

CXX_EXT := cc cxx cpp

SOURCES := $(wildcard ${SOURCES_DIR}/*.c ${SOURCES_DIR}/*.cc ${SOURCES_DIR}/*.cxx)
OBJS := $(patsubst ${SOURCES_DIR}/%.c,${OBJECTS_DIR}/%.o,$(filter %.c,$(SOURCES)))
OBJS += $(patsubst ${SOURCES_DIR}/%.cc,${OBJECTS_DIR}/%.o,$(filter %.cc,$(SOURCES)))
OBJS += $(patsubst ${SOURCES_DIR}/%.cxx,${OBJECTS_DIR}/%.o,$(filter %.cxx,$(SOURCES)))
BIN := ${BIN_DIR}/main

all: ${BIN}

${OBJECTS_DIR}: | ${BIN_DIR}
	@mkdir -p ${OBJECTS_DIR}
${BIN_DIR}:
	@mkdir -p ${BIN_DIR}

${BIN}: ${OBJS}
	${LINK} ${LDFLAGS} $^ -o $@

${OBJECTS_DIR}/%.o:${SOURCES_DIR}/%.c | ${OBJECTS_DIR} 
	${CC} ${CFLAGS} -c $< -o $@
${OBJECTS_DIR}/%.d: ${SOURCES_DIR}/%.c | ${OBJECTS_DIR}
	@${CC} ${CFLAGS} -MM $< -MT $@ -MT $(<:.c=.o) -MF $@
define CXX_RULE_TEMPLATE
${OBJECTS_DIR}/%.o:${SOURCES_DIR}/%.$(1) | ${OBJECTS_DIR}
	$(CXX) $(CXXFLAGS) -c $$< -o $$@
${OBJECTS_DIR}/%.d: ${SOURCES_DIR}/%.$(1) | ${OBJECTS_DIR}
	@${CXX} ${CXXFLAGS} -MM $$< -MT $$@ -MT $$(<:.$(1)=.o) -MF $$@
endef
$(foreach ext,$(CXX_EXT), $(eval $(call CXX_RULE_TEMPLATE,$(ext))))
-include $(OBJS:.o=.d)

.PHONY: clean show_src run
clean:
	@rm -rf ${OBJECTS_DIR} ${BIN_DIR}

show_src:
	@echo "SOURCES = ${SOURCES}"
	@echo "OBJS = ${OBJS}"

run: ${BIN}
	@echo "-------------run main----------"
	@./${BIN}
	@echo "-------------run main end----------"