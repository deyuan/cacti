TARGET = cacti
SHELL = /bin/sh
.PHONY: all depend clean
.SUFFIXES: .cc .o

ifndef NTHREADS
  NTHREADS = 8
endif

# Detect operating system
UNAME_S := $(shell uname -s)

LIBS = 
INCS = -lm

ifeq ($(TAG),dbg)
  DBG = -Wall 
  ifeq ($(UNAME_S),Darwin)
    # macOS: clang doesn't support -gstabs+
    OPT = -ggdb -g -O0 -DNTHREADS=1
  else
    # Linux: original flags
    OPT = -ggdb -g -O0 -DNTHREADS=1 -gstabs+
  endif
else
  DBG = 
  ifeq ($(UNAME_S),Darwin)
    # macOS: clang doesn't support -msse2 -mfpmath=sse (especially on ARM)
    OPT = -g -O3 -DNTHREADS=$(NTHREADS)
  else
    # Linux: original flags
    OPT = -g -msse2 -mfpmath=sse -DNTHREADS=$(NTHREADS)
  endif
endif

#CXXFLAGS = -Wall -Wno-unknown-pragmas -Winline $(DBG) $(OPT) 
CXXFLAGS = -Wno-unknown-pragmas $(DBG) $(OPT) 

ifeq ($(UNAME_S),Darwin)
  # macOS: don't force -m64 (not needed, and problematic on ARM)
  CXX = g++
  CC  = gcc
else
  # Linux: original flags
  CXX = g++ -m64
  CC  = gcc -m64
endif

SRCS  = area.cc bank.cc mat.cc main.cc Ucache.cc io.cc technology.cc basic_circuit.cc parameter.cc \
		decoder.cc component.cc uca.cc subarray.cc wire.cc htree2.cc extio.cc extio_technology.cc \
		cacti_interface.cc router.cc nuca.cc crossbar.cc arbiter.cc powergating.cc TSV.cc memorybus.cc \
		memcad.cc memcad_parameters.cc
		

OBJS = $(patsubst %.cc,obj_$(TAG)/%.o,$(SRCS))
PYTHONLIB_SRCS = $(patsubst main.cc, ,$(SRCS)) obj_$(TAG)/cacti_wrap.cc
PYTHONLIB_OBJS = $(patsubst %.cc,%.o,$(PYTHONLIB_SRCS)) 
INCLUDES       = -I /usr/include/python2.4 -I /usr/lib/python2.4/config

all: obj_$(TAG)/$(TARGET)
	cp -f obj_$(TAG)/$(TARGET) $(TARGET)

obj_$(TAG)/$(TARGET) : $(OBJS)
	$(CXX) $(OBJS) -o $@ $(INCS) $(CXXFLAGS) $(LIBS) -pthread

#obj_$(TAG)/%.o : %.cc
#	$(CXX) -c $(CXXFLAGS) $(INCS) -o $@ $<

obj_$(TAG)/%.o : %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	-rm -f *.o _cacti.so cacti.py $(TARGET)


