# Makefile for steam docker containers.
STAGING_DIR = /tmp/steam-staging
D_DIR       = Dockerfile

help:
	@echo 'USAGE:'
	@echo
	@echo 'make stable'
	@echo '      Build latest steam dedicated docker container.'
	@echo
	@echo 'make latest'
	@echo '      Build latest steam dedicated docker with latest winehq STABLE updates container.'
	@echo
	@echo 'make experimental'
	@echo '      Build latest steam dedicated docker with latest winehq STAGING updates container.'
	@echo
	@echo 'make all'
	@echo '      Build all latest containers.'

.PHONY: help Makefile

all: stable latest experimental

stable: clean
	@echo 'Building steam ubuntu container ...'
	@mkdir -p $(STAGING_DIR)
	@cp ${D_DIR}/BASE ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/LOCALE_BASE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WINE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WINE_TRICKS >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/INSTALL_STEAM >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/STEAM_SERVICE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/SUPERVISORD >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/CLEANUP >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WORKDIR >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/VOLUME >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/ENTRYPOINT >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/EXPOSE >> ${STAGING_DIR}/Dockerfile
	@cp -R source $(STAGING_DIR)
	@cd $(STAGING_DIR) && \
	 docker build \
		-t rpufky/steam:stable \
		.
	@echo
	@echo 'Remember to push to hub: docker push rpufky/steam:stable'

latest: clean
	@echo 'Building steam ubuntu container using wine STABLE latest from winehq repo ...'
	@mkdir -p $(STAGING_DIR)
	@cp ${D_DIR}/BASE ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/LOCALE_BASE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WINEHQ_STABLE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WINE_TRICKS >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/INSTALL_STEAM >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/STEAM_SERVICE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/SUPERVISORD >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/CLEANUP >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WORKDIR >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/VOLUME >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/ENTRYPOINT >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/EXPOSE >> ${STAGING_DIR}/Dockerfile
	@cp -R source $(STAGING_DIR)
	@cd $(STAGING_DIR) && \
	 docker build \
		-t rpufky/steam:latest -t rpufky/steam:winehq \
		.
	@echo
	@echo 'Remember to push to hub: docker push rpufky/steam:latest'

experimental: clean
	@echo 'Building steam ubuntu container using wine STAGING latest from winehq repo ...'
	@mkdir -p $(STAGING_DIR)
	@cp ${D_DIR}/BASE ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/LOCALE_BASE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WINEHQ_STAGING >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WINE_TRICKS >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/INSTALL_STEAM >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/STEAM_SERVICE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/SUPERVISORD >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/CLEANUP >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WORKDIR >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/VOLUME >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/ENTRYPOINT >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/EXPOSE >> ${STAGING_DIR}/Dockerfile
	@cp -R source $(STAGING_DIR)
	@cd $(STAGING_DIR) && \
	 docker build \
		-t rpufky/steam:experimental \
		.
	@echo

clean:
	@echo 'Cleaning build files ...'
	@rm -rfv $(STAGING_DIR)
