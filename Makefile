############################################################################
# apps/external/openssl/Makefile
#
#   Copyright 2018 Sony Video & Sound Products Inc.
#   Author: Masayuki Ishikawa <Masayuki.Ishikawa@jp.sony.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name NuttX nor the names of its contributors may be
#    used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
############################################################################

-include $(TOPDIR)/.config
-include $(TOPDIR)/Make.defs
include $(APPDIR)/Make.defs

MBEDTLSDIR = $(APPDIR)/external/mbedtls

CFLAGS += -I ./include -I ./include/internal -I ./include/platform
CFLAGS += -I ./include/openssl
CFLAGS += -I$(MBEDTLSDIR)/include
CFLAGS += -DNUTTX

ASRCS	=
CSRCS	=

ifeq ($(CONFIG_EXTERNAL_OPENSSL),y)
CSRCS += library/ssl_cert.c
CSRCS += library/ssl_lib.c
CSRCS += library/ssl_methods.c
CSRCS += library/ssl_pkey.c
CSRCS += library/ssl_stack.c
CSRCS += library/ssl_x509.c
CSRCS += platform/ssl_pm.c
CSRCS += platform/ssl_port.c
endif

AOBJS		= $(ASRCS:.S=$(OBJEXT))
COBJS		= $(CSRCS:.c=$(OBJEXT))

SRCS		= $(ASRCS) $(CSRCS)
OBJS		= $(AOBJS) $(COBJS)

ifeq ($(CONFIG_WINDOWS_NATIVE),y)
  BIN		= $(TOPDIR)\staging\libopenssl$(LIBEXT)
else
ifeq ($(WINTOOL),y)
  BIN		= $(TOPDIR)\\staging\\libopenssl$(LIBEXT)
else
  BIN		= $(TOPDIR)/staging/libopenssl$(LIBEXT)
endif
endif

ROOTDEPPATH	= --dep-path .

# Common build

VPATH		=

all: .built
.PHONY: context depend clean distclean preconfig
.PRECIOUS: $(TOPDIR)/staging/libopenssl$(LIBEXT)

$(AOBJS): %$(OBJEXT): %.S
	$(call ASSEMBLE, $<, $@)

$(COBJS): %$(OBJEXT): %.c
	$(call COMPILE, $<, $@)

.built: $(OBJS)
	$(call ARCHIVE, $(BIN), $(OBJS))
	$(Q) touch .built

install:

context:

.depend: Makefile $(SRCS)
	$(Q) $(MKDEP) $(ROOTDEPPATH) "$(CC)" -- $(CFLAGS) -- $(SRCS) >Make.dep
	$(Q) touch $@

depend: .depend

clean:
	$(call DELFILE, .built)
	$(call CLEAN)

distclean: clean
	$(call DELFILE, Make.dep)
	$(call DELFILE, .depend)

preconfig:

-include Make.dep
