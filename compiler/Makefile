#----------------------------------------------------------------------
# Makefile
# for AddmusicK
#
# since 2017/01/26
#
#----------------------------------------
# history
#----------------------------------------
#   v0.01[2017/01/26]  ...  base create. [ boldowa ]
#----------------------------------------------------------------------
#CLANG=1

#----------------------------------------
# Target option
#----------------------------------------
TARGETS = AddmusicK

#----------------------------------------
# Compiler setup
#----------------------------------------

ifdef CLANG
	CC_PRG= clang
	CXX_PRG= clang++
else
	CC_PRG= gcc
	CXX_PRG= g++
endif

PLATFORM := unix
ifdef WIN32
	BINPREFIX := .exe
	PLATFORM_ := windows
	CXXFLAGS += -DWIN32 -D_WIN32 #--exec-charset=cp932
	CFLAGS += -DWIN32 -D_WIN32 #--exec-charset=cp932
	LDFLAGS += -static-libgcc -static-libstdc++
ifdef x64
	PLATFORM := $(addsuffix /x64,$(PLATFORM_))
	PREFIX := x86_64-w64-mingw32-
else
	PLATFORM := $(addsuffix /x86,$(PLATFORM_))
	PREFIX := i686-w64-mingw32-
endif
endif

ifndef x64
	LDFLAGS += -m32
	CXXFLAGS += -m32
	CFLAGS += -m32
endif

#----------------------------------------
# Compile Option
#----------------------------------------
CC		:= $(PREFIX)$(CC_PRG)
CXX		:= $(PREFIX)$(CXX_PRG)

# Include header ... 
#CXXFLAGS	+= -std=c++11 -ffast-math -ffunction-sections -fdata-sections
CXXFLAGS	+= -std=c++11 -ffast-math -ffunction-sections
#CXXFLAGS	+= -std=c++11
CFLAGS		+= -ffast-math -ffunction-sections -fdata-sections

# precompile header
#PRECOMPILE_HEADER := gstdafx.hpp

#ifdef PRECOMPILE_HEADER
#	CXXFLAGS += -include $(PRECOMPILE_HEADER)
#	CFLAGS += -include $(PRECOMPILE_HEADER)
#endif


#----------------------------------------
# Link Option
#----------------------------------------
LD		= ${CXX}
LDFLAGS		+= -L.
LDFLAGS		+= -Wl,--gc-sections,--discard-all
_BOOST_LIB	= boost_filesystem boost_system
ifdef WIN32
BOOST_LIB	:= $(addsuffix -mt,$(_BOOST_LIB))
LDLIBS		+= -Wl,-dn,-lpthread,-lpng,-lz $(foreach lib,$(BOOST_LIB),-Wl,-l$(lib))
else
BOOST_LIB	:= $(_BOOST_LIB)
LDLIBS		+= -lasar -ldl
LDLIBS		+= -Wl,-dy,-lpng,-lz $(foreach lib,$(BOOST_LIB),-Wl,-l$(lib))
endif
LDLIBS		+= -Wl,-dy,-lam4remover


#--------------------------------------------------
# Main ...
#--------------------------------------------------

.PHONY: all clean FORCE

# compile option & dest dir
buildtype := release
ifeq ($(buildtype),release)
  CXXFLAGS += -O2
  CFLAGS += -O2
  LDFLAGS  += -s
else ifeq ($(buildtype),debug)
  CXXFLAGS += -DDEBUG -O0 -g -Wall
else
  $(error buildtype is illegal.)
endif
OUTDIR := build/$(buildtype)/$(PLATFORM)

LDFLAGS := -L../AM405Remover/$(OUTDIR)/bin $(LDFLAGS)

# Compile program
define build-rule
$1_cppsrc := $$(wildcard *.cpp)
$1_csrc := $$(wildcard *.c)
ifdef PRECOMPILE_HEADER
$1_pch := $$(wildcard $$(PRECOMPILE_HEADER))
$1_gch := $$(OUTDIR)/obj/$$($1_pch).gch
endif
-include $$($1_cppsrc:%.cpp=$$(OUTDIR)/obj/%.d)
-include $$($1_csrc:%.c=$$(OUTDIR)/obj/%.d)
$$(OUTDIR)/bin/$1$$(BINPREFIX): ../AM405Remover/$(OUTDIR)/bin/libam4remover.a $$($1_gch) $$($1_cppsrc:%.cpp=$$(OUTDIR)/obj/%.o) $$($1_csrc:%.c=$$(OUTDIR)/obj/%.o)
	@if [ ! -e `dirname $$@` ]; then mkdir -p `dirname $$@`; fi;
	$$(CXX) $$(LDFLAGS) -o $$@ $$(filter %.o,$$^) $$(LDLIBS)
tags: $$($1_pch) $$($1_cppsrc) $$($1_csrc)
	@if which ctags >/dev/null ; then \
	echo -n "Making tags file ... " ;\
	cd `dirname $$@` ;\
	ctags -R ;\
	echo "done";\
	fi
endef


#----------------------------------------
# build
#----------------------------------------
all: ../AM405Remover/$(OUTDIR)/bin/libam4remover.a $(foreach i,$(TARGETS),$(OUTDIR)/bin/$i$(BINPREFIX)) tags

$(foreach i,$(TARGETS),$(eval $(call build-rule,$i)))

# cpp sources
$(OUTDIR)/obj/%.o:%.cpp Makefile
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(CXX) $(CXXFLAGS) -o $@ -c -MMD -MP -MF $(@:%.o=%.d) $<

# c sources
$(OUTDIR)/obj/%.o:%.c Makefile
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(CC) $(CFLAGS) -o $@ -c -MMD -MP -MF $(@:%.o=%.d) $<

# precompile header
$(OUTDIR)/obj/%.hpp.gch:%.hpp Makefile
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(CXX) $(CXXFLAGS) -o $@ $<
$(OUTDIR)/obj/%.h.gch:%.h Makefile
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(CC) $(CFLAGS) -o $@ $<

../AM405Remover/$(OUTDIR)/bin/libam4remover.a: FORCE
ifdef WIN32
ifdef x64
	make -C ../AM405Remover/ WIN32=1 x64=1
else
	make -C ../AM405Remover/ WIN32=1
endif
else
	make -C ../AM405Remover/ x64=1
endif

#----------------------------------------
# etc...
#----------------------------------------
clean:
	rm -rf ${OUTDIR}
distclean:
	rm -rf build

# debug build
debug:
	make buildtype=debug

