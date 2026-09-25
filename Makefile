CXX=g++
CXXFLAGS=-std=c++17 -O2 `pkg-config --cflags gtk+-3.0 gdk-3.0 gtk-layer-shell-0`
LIBS=`pkg-config --libs gtk+-3.0 gdk-3.0 gtk-layer-shell-0` -lcurl -ljsoncpp -lssl -lcrypto

all: light-launcher

light-launcher: main.cpp apps.cpp emoji.cpp gif.cpp files.cpp wallpaper.cpp light-launcher.h
	$(CXX) $(CXXFLAGS) -o light-launcher main.cpp $(LIBS)

clean:
	rm -f light-launcher
