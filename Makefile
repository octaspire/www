EMACS=emacs
# In batch mode Emacs doesn't load the usual initialization file. To get the correct
# settings and styles in the batch mode, the initialization file must be loaded manually.
# However, there are still some small problems with the Org export when running in batch
# mode using the default version of Org mode, so the export is run without batch mode at
# the moment.
#EMACSFLAGS=--load dev/external/octaspire_dotfiles/emacs/.emacs.d/init.el --batch
EMACSFLAGS=

all: www

core.tar.bz2: external/octaspire_core
	cp -r external/octaspire_core/release core
	tar -cjf core.tar.bz2 core
	sha512sum core.tar.bz2 > core.tar.bz2.sha512
	gpg --default-key 9BD2CCD560E9E29C --output core.tar.bz2.sig --armor --detach-sign core.tar.bz2

dern.tar.bz2: external/octaspire_dern
	cp -r external/octaspire_dern/release dern
	tar -cjf dern.tar.bz2 dern
	sha512sum dern.tar.bz2 > dern.tar.bz2.sha512
	gpg --default-key 9BD2CCD560E9E29C --output dern.tar.bz2.sig --armor --detach-sign dern.tar.bz2

payload: core.tar.bz2 dern.tar.bz2

submodules-init:
	@echo "Initializing submodules..."
	@git submodule init
	@git submodule update
	@echo "Done."

submodules-pull:
	@echo "Pulling submodules..."
	@git submodule update --recursive --remote
	@echo "Done."

www: submodules-pull payload index.org
	touch feed.xml
	cp external/octaspire_dern/release/documentation/dern-manual.html .
	@LANG=eng_US.utf8 $(EMACS) $(EMACSFLAGS) index.org --funcall org-reload --funcall org-html-export-to-html --kill > /dev/null 2>&1

publish: www
	scp dern-windeps.zip external/bundle.min.css external/bundle.min.js index.html dern-manual.html dern.tar.bz2 dern.tar.bz2.sig dern.tar.bz2.sha512 core.tar.bz2 core.tar.bz2.sig core.tar.bz2.sha512 octaspire-pubkey.asc octaspireO128.png $(OCTASPIRE_IO_SCP_TARGET)
	scp io-feed.xml "${OCTASPIRE_IO_SCP_TARGET}feed.xml"
	scp dern-windeps.zip external/bundle.min.css external/bundle.min.js index.html dern-manual.html dern.tar.bz2 dern.tar.bz2.sig dern.tar.bz2.sha512 core.tar.bz2 core.tar.bz2.sig core.tar.bz2.sha512 octaspire-pubkey.asc octaspireO128.png $(OCTASPIRE_COM_SCP_TARGET)
	scp com-feed.xml "${OCTASPIRE_COM_SCP_TARGET}feed.xml"

clean:
	@rm -rf feed.xml
	@rm -rf index.html
	@rm -rf core dern
	@rm -rf dern-manual.html dern.tar.bz2 dern.tar.bz2.sig dern.tar.bz2.sha512
	@rm -rf                  core.tar.bz2 core.tar.bz2.sig core.tar.bz2.sha512

verify: clean
	@curl -O https://octaspire.io/dern-manual.html     > /dev/null 2>&1 || (echo "--ERROR-- Loading of Dern manual failed: $$?."; exit 1)
	@curl -O https://octaspire.io/dern.tar.bz2         > /dev/null 2>&1 || (echo "--ERROR-- Loading of Dern release failed: $$?."; exit 1)
	@curl -O https://octaspire.io/dern.tar.bz2.sig     > /dev/null 2>&1 || (echo "--ERROR-- Loading of Dern release signature failed: $$?."; exit 1)
	@curl -O https://octaspire.io/dern.tar.bz2.sha512  > /dev/null 2>&1 || (echo "--ERROR-- Loading of Dern release checksum  failed: $$?."; exit 1)
	@curl -O https://octaspire.io/core.tar.bz2         > /dev/null 2>&1 || (echo "--ERROR-- Loading of Core release failed: $$?."; exit 1)
	@curl -O https://octaspire.io/core.tar.bz2.sig     > /dev/null 2>&1 || (echo "--ERROR-- Loading of Core release signature failed: $$?."; exit 1)
	@curl -O https://octaspire.io/core.tar.bz2.sha512  > /dev/null 2>&1 || (echo "--ERROR-- Loading of Core release checksum  failed: $$?."; exit 1)
	@sha512sum -c dern.tar.bz2.sha512                  > /dev/null 2>&1 || (echo "--ERROR-- Dern release checksum failed: $$?."; exit 1)
	@sha512sum -c core.tar.bz2.sha512                  > /dev/null 2>&1 || (echo "--ERROR-- Core release checksum failed: $$?."; exit 1)
	@gpg --verify dern.tar.bz2.sig                     > /dev/null 2>&1 || (echo "--ERROR-- Dern release signature failed: $$?."; exit 1)
	@gpg --verify core.tar.bz2.sig                     > /dev/null 2>&1 || (echo "--ERROR-- Core release signature failed: $$?."; exit 1)
	@echo "*** VERIFICATION OK ***"
