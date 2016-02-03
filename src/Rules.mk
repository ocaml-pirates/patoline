# Standard things which help keeping track of the current directory
# while include all Rules.mk.
d := $(if $(d),$(d)/,)$(mod)

# Useful directories, to be referenced from other Rules.ml
SRC_DIR := $(d)
PATOLINE_IN_SRC := $(d)/Patoline/patoline
PA_PATOLINE_IN_SRC := $(d)/Patoline/pa_patoline
PATOLINE_DIR := $(d)/Patoline
TYPOGRAPHY_DIR := $(d)/Typography
RAWLIB_DIR := $(d)/rawlib
DB_DIR := $(d)/db
DRIVERS_DIR := $(d)/Drivers
FORMAT_DIR := $(d)/Format
UTIL_DIR := $(d)/patutil
RBUFFER_DIR := $(d)/rbuffer
LIBFONTS_DIR := $(d)/patfonts
CESURE_DIR := $(d)/cesure
PA_OCAML_DIR := $(d)/decap
UNICODE_DIR := $(d)/unicodelib
PA_OCAML := $(PA_OCAML_DIR)/pa_ocaml

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(MAKECMDGOALS),distclean)
DUMMY := $(shell if [ ! -x $(PA_OCAML_DIR)/pa_ocaml ]; then $(MAKE) -e -j 1 -C $(PA_OCAML_DIR) pa_ocaml; fi; $(MAKE) -e -j 1 -C $(PA_OCAML_DIR) decap.cmxa decap_ocaml.cmxa decap.cma decap_ocaml.cma pa_ocaml)
endif
endif

ifeq ($(MAKECMDGOALS),clean)
DUMMY := $(shell $(MAKE) -e -C $(PA_OCAML_DIR) clean)
endif

ifeq ($(MAKECMDGOALS),distclean)
DUMMY := $(shell $(MAKE) -e -C $(PA_OCAML_DIR) distclean)
endif

$(d)/Patoline/Rules.mk: $(UNICODELIB_CMX)

# Visit subdirectories
MODULES := unicodelib rbuffer patutil patfonts rawlib db \
  Typography Drivers Pdf cesure Format \
  $(OCAML_BIBI) plot proof plugins Patoline


$(foreach mod,$(MODULES),$(eval include $(d)/$$(mod)/Rules.mk))

# Building Patoline's grammar
all: $(d)/DefaultGrammar.txp $(d)/DefaultGrammar.tgx $(d)/_patobuild/DefaultGrammar.tgy
$(d)/DefaultGrammar.tgx: $(d)/DefaultGrammar.pdf

$(d)/_patobuild/DefaultGrammar.tgy: $(d)/DefaultGrammar.txp $(PA_PATOLINE_IN_SRC)
	$(ECHO) "[PAT]    $< -> $@"
	$(Q)$(PA_PATOLINE_IN_SRC) --ascii --no-default-grammar $< > /dev/null

$(d)/quail.el: $(d)/DefaultGrammar.ttml ;
$(d)/DefaultGrammar_.tml: $(d)/DefaultGrammar.txp $(PATOLINE_IN_SRC)
	$(ECHO) "[PAT]    $< -> $@"
	$(Q)$(PATOLINE_IN_SRC) --no-build-dir --main-ml --driver Pdf -o $@ $<

$(d)/DefaultGrammar.ttml: $(d)/DefaultGrammar.txp $(PATOLINE_IN_SRC)
	$(ECHO) "[PAT]    $< -> $@"
	$(Q)$(PATOLINE_IN_SRC) --no-build-dir --ml --driver Pdf -o $@ $<

$(d)/DefaultGrammar.cmx: $(d)/DefaultGrammar.ttml $(TYPOGRAPHY_DIR)/ParseMainArgs.cmx $(TYPOGRAPHY_DIR)/Typography.cmxa $(TYPOGRAPHY_DIR)/DefaultFormat.cmxa
	$(ECHO) "[OPT]    ... -> $@"
	$(Q)$(OCAMLOPT_NOINTF) $(PACK_FORMAT) -c -o $@ -impl $<

$(d)/DefaultGrammar.tmx: $(d)/DefaultGrammar_.tml $(d)/DefaultGrammar.cmx \
  $(RBUFFER_DIR)/rbuffer.cmxa \
  $(UTIL_DIR)/patutil.cmxa $(LIBFONTS_DIR)/fonts.cmxa $(TYPOGRAPHY_DIR)/Typography.cmxa \
  $(TYPOGRAPHY_DIR)/DefaultFormat.cmxa $(DRIVERS_DIR)/Pdf/Pdf.cmxa \
  $(TYPOGRAPHY_DIR)/ParseMainArgs.cmx
	$(ECHO) "[OPT]    $< -> $@"
	$(Q)$(OCAMLOPT_NOINTF) $(PACK_FORMAT) $(PACK_DRIVER_Pdf) -I $(<D) -I $(DRIVERS_DIR)/Pdf Pdf.cmxa $(CESURE_DIR)/cesure.cmxa $(TYPOGRAPHY_DIR)/DefaultFormat.cmxa -linkpkg -o $@ $(@:.tmx=.cmx) -impl $<

$(d)/DefaultGrammar.pdf: $(d)/DefaultGrammar.tmx $(PATOLINE_IN_SRC) $(HYPHENATION_DIR)/hyph-en-us.hdict
	$(ECHO) "[TMX]    $< -> $@"
	$(Q)$< --extra-fonts-dir $(FONTS_DIR) --unicode-data $(UNICODE_DIR)/UnicodeData.data --extra-hyph-dir $(HYPHENATION_DIR) --extra-driver-dir $(DRIVERS_DIR)/Pdf --driver Pdf

CLEAN += $(d)/DefaultGrammar.tgx $(d)/DefaultGrammar_.tml $(d)/DefaultGrammar.ttml \
	 $(d)/DefaultGrammar.pdf $(d)/DefaultGrammar.tdx  $(d)/DefaultGrammar.tmx \
	 $(d)/DefaultGrammar.cmi $(d)/DefaultGrammar.cmx $(d)/DefaultGrammar.o \
	 $(d)/DefaultGrammar_.cmi $(d)/DefaultGrammar_.cmx $(d)/DefaultGrammar_.o \
	 $(d)/DefaultGrammar_.dep $(d)/DefaultGrammar.tdep $(d)/quail.el

# Installing
install: install-grammars
.PHONY: install-grammars

install-grammars: $(d)/DefaultGrammar.txp $(d)/DefaultGrammar.tgx
	install -p -m 755 -d $(DESTDIR)/$(INSTALL_GRAMMARS_DIR)
	install -p -m 644 $(SRC_DIR)/DefaultGrammar.txp $(DESTDIR)/$(INSTALL_GRAMMARS_DIR)/
	install -p -m 644 $(SRC_DIR)/DefaultGrammar.tgx $(DESTDIR)/$(INSTALL_GRAMMARS_DIR)/
	install -p -m 644 $(SRC_DIR)/_patobuild/DefaultGrammar.tgy $(DESTDIR)/$(INSTALL_GRAMMARS_DIR)/

# Rolling back changes made at the top
d := $(patsubst %/,%,$(dir $(d)))
