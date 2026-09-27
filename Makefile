CXX ?= g++
PKG_CONFIG ?= pkg-config
CXXFLAGS += -std=c++17 -O2 $(shell $(PKG_CONFIG) --cflags gtk+-3.0 gio-unix-2.0)
LDLIBS += $(shell $(PKG_CONFIG) --libs gtk+-3.0 gio-unix-2.0)

all: light-launcher

light-launcher: launcher.cpp
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDLIBS)

clean:
	rm -f light-launcher
