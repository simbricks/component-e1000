# Copyright 2026 Max Planck Institute for Software Systems,
# National University of Singapore, and SimBricks UG (haftungsbeschränkt)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Self-contained build for the e1000 (gem5-derived) behavioral model. Meant to
# be run from inside this directory, e.g.:
#   make -C e1000_gem5 all SIMBRICKS_INC_DIR=... SIMBRICKS_LIB_DIR=...
# The top-level Makefile drives it that way; for a bare local build, point
# SIMBRICKS_INC_DIR/SIMBRICKS_LIB_DIR at a simbricks-lib install.

PREFIX            ?= /usr/local
CXX               ?= c++

SIMBRICKS_INC_DIR ?= /usr/local/include
SIMBRICKS_LIB_DIR ?= /usr/local/lib/simbricks
E1000_DEPS        ?= $(SIMBRICKS_LIB_DIR)/libnicbm.a $(SIMBRICKS_LIB_DIR)/libnicif.a \
                     $(SIMBRICKS_LIB_DIR)/libnetwork.a $(SIMBRICKS_LIB_DIR)/libpcie.a \
                     $(SIMBRICKS_LIB_DIR)/libbase.a
E1000_LDLIBS      ?= -lboost_fiber -lboost_context -lpthread

DEPFLAGS   = -MMD -MP
CPPFLAGS  += -I$(SIMBRICKS_INC_DIR) -iquote$(CURDIR) $(EXTRA_CPPFLAGS)
CXXFLAGS  += -Wall -Wextra -Wno-unused-parameter -O3 -fPIC -std=gnu++17 $(EXTRA_CXXFLAGS)

SRCS := e1000_gem5.cc i8254xGBe.cc gem5/bitfield.cc gem5/inet.cc gem5/pktfifo.cc
OBJS := $(SRCS:.cc=.o)
BIN  := simb_e1000_gem5

.PHONY: all
all: $(BIN)

$(BIN): $(OBJS) $(E1000_DEPS)
	$(CXX) $(LDFLAGS) -o $@ $(OBJS) $(E1000_DEPS) $(E1000_LDLIBS)

%.o: %.cc
	$(CXX) $(DEPFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

.PHONY: install-e1000
install-e1000:
	install -d $(PREFIX)/bin
	install -m 755 $(BIN) $(PREFIX)/bin/$(BIN)

.PHONY: clean
clean:
	rm -f $(OBJS) $(OBJS:.o=.d) $(BIN)

-include $(OBJS:.o=.d)
