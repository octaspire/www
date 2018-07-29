SCPFILES=dern-windeps.zip index.html \
         dern-manual.html dern.tar.bz2 dern-dev.tar.bz2 dern.sha512 dern.sha512.sig \
         core-manual.html core.tar.bz2 core-dev.tar.bz2 core.sha512 core.sha512.sig \
         octaspire-pubkey.asc

all: www

core.tar.bz2: external/octaspire_core
	cp -r external/octaspire_core/release core
	tar -cjf core.tar.bz2 core
	sha512sum core.tar.bz2 >> core.sha512
	gpg --yes --default-key 9BD2CCD560E9E29C --output core.sha512.sig --armor --detach-sign core.sha512

core-dev.tar.bz2: external/octaspire_core
	cp -r external/octaspire_core core-dev
	rm -rf core-dev/.git core-dev/.gitignore core-dev/.gitmodules core-dev/.travis.yml
	rm -rf core-dev/dev/external/octaspire_dotfiles/.git
	rm -rf core-dev/dev/external/octaspire_dotfiles/.gitignore
	tar -cjf core-dev.tar.bz2 core-dev
	sha512sum core-dev.tar.bz2 >> core.sha512
	gpg --yes --default-key 9BD2CCD560E9E29C --output core.sha512.sig --armor --detach-sign core.sha512

dern.tar.bz2: external/octaspire_dern
	cp -r external/octaspire_dern/release dern
	tar -cjf dern.tar.bz2 dern
	sha512sum dern.tar.bz2 >> dern.sha512
	gpg --yes --default-key 9BD2CCD560E9E29C --output dern.sha512.sig --armor --detach-sign dern.sha512

dern-dev.tar.bz2: external/octaspire_dern
	cp -r external/octaspire_dern dern-dev
	rm -rf dern-dev/.git dern-dev/.gitignore dern-dev/.gitmodules dern-dev/.travis.yml dern-dev/codecov.yml
	rm -rf dern-dev/dev/external/octaspire_dotfiles/.git
	rm -rf dern-dev/dev/external/octaspire_dotfiles/.gitignore
	rm -rf dern-dev/dev/external/octaspire_core/.git
	rm -rf dern-dev/dev/external/octaspire_core/.gitignore
	rm -rf dern-dev/dev/external/octaspire_core/dev/external/octaspire_dotfiles/.git
	rm -rf dern-dev/dev/external/octaspire_core/dev/external/octaspire_dotfiles/.gitignore
	tar -cjf dern-dev.tar.bz2 dern-dev
	sha512sum dern-dev.tar.bz2 >> dern.sha512
	gpg --yes --default-key 9BD2CCD560E9E29C --output dern.sha512.sig --armor --detach-sign dern.sha512

payload: core.tar.bz2 core-dev.tar.bz2 dern.tar.bz2 dern-dev.tar.bz2

submodules-init:
	@echo "Initializing submodules..."
	@git submodule init
	@git submodule update
	@echo "Done."

submodules-pull:
	@echo "Pulling submodules..."
	@git submodule foreach --recursive git checkout master
	@git submodule foreach --recursive git pull
	@git submodule foreach --recursive git submodule update
	@echo "Done."

www: submodules-pull payload index.html
	touch feed.xml
	cp external/octaspire_dern/release/documentation/dern-manual.html .
	cp external/octaspire_core/release/documentation/core-manual.html .

index.html:

publish: www
	scp $(SCPFILES) $(OCTASPIRE_IO_SCP_TARGET)
	scp io-feed.xml "${OCTASPIRE_IO_SCP_TARGET}feed.xml"
	scp $(SCPFILES) $(OCTASPIRE_COM_SCP_TARGET)
	scp com-feed.xml "${OCTASPIRE_COM_SCP_TARGET}feed.xml"

clean:
	@rm -rf feed.xml
	@rm -rf core dern
	@rm -rf dern-manual.html dern.tar.bz2 dern-dev.tar.bz2 dern.sha512 dern.sha512.sig
	@rm -rf core-manual.html core.tar.bz2 core-dev.tar.bz2 core.sha512 core.sha512.sig
	@rm -rf core-dev dern-dev

verify: clean
	@curl -O https://octaspire.io/dern-manual.html        > /dev/null 2>&1 || (echo "--ERROR-- Loading of Dern manual failed: $$?."; exit 1)
	@curl -O https://octaspire.io/core-manual.html        > /dev/null 2>&1 || (echo "--ERROR-- Loading of Core manual failed: $$?."; exit 1)
	@curl -O https://octaspire.io/dern.tar.bz2            > /dev/null 2>&1 || (echo "--ERROR-- Loading of Dern release failed: $$?."; exit 1)
	@curl -O https://octaspire.io/dern.sha512             > /dev/null 2>&1 || (echo "--ERROR-- Loading of Dern checksums failed: $$?."; exit 1)
	@curl -O https://octaspire.io/dern.sha512.sig         > /dev/null 2>&1 || (echo "--ERROR-- Loading of Dern checksums signature failed: $$?."; exit 1)
	@curl -O https://octaspire.io/dern-dev.tar.bz2        > /dev/null 2>&1 || (echo "--ERROR-- Loading of Dern dev release failed: $$?."; exit 1)
	@curl -O https://octaspire.io/core.tar.bz2            > /dev/null 2>&1 || (echo "--ERROR-- Loading of Core release failed: $$?."; exit 1)
	@curl -O https://octaspire.io/core.sha512             > /dev/null 2>&1 || (echo "--ERROR-- Loading of Core checksums failed: $$?."; exit 1)
	@curl -O https://octaspire.io/core.sha512.sig         > /dev/null 2>&1 || (echo "--ERROR-- Loading of Core checksums signature failed: $$?."; exit 1)
	@curl -O https://octaspire.io/core-dev.tar.bz2        > /dev/null 2>&1 || (echo "--ERROR-- Loading of Core dev release failed: $$?."; exit 1)
	@sha512sum -c dern.sha512                             > /dev/null 2>&1 || (echo "--ERROR-- Dern checksums do not match: $$?."; exit 1)
	@sha512sum -c core.sha512                             > /dev/null 2>&1 || (echo "--ERROR-- Core checksums do not match: $$?."; exit 1)
	@gpg --verify dern.sha512.sig                         > /dev/null 2>&1 || (echo "--ERROR-- Dern checksums signature failed: $$?."; exit 1)
	@gpg --verify core.sha512.sig                         > /dev/null 2>&1 || (echo "--ERROR-- Core checksums signature failed: $$?."; exit 1)
	@echo "*** VERIFICATION OK ***"
