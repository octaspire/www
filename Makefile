EMACS=emacs
FLAGS=--batch

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

git-update:
	git pull origin-gitlab master
	git submodule update --init --recursive --remote
	git submodule foreach git pull origin master

www: git-update payload index.org
	touch feed.xml
	cp external/octaspire_dern/release/documentation/dern-manual.html .
	$(EMACS) --load external/octaspire_dern/external/octaspire_dotfiles/emacs/.emacs.d/init.el $(FLAGS) index.org --funcall org-html-export-to-html --kill

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
