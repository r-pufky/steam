# Makefile for steam docker containers.
STAGING_DIR = staging
D_DIR       = Dockerfile

help:
	@echo 'USAGE:'
	@echo
	@echo 'make steam'
	@echo '      Build latest steam dedicated docker container.'

.PHONY: help Makefile

steam: clean
	@echo 'Building steam ubuntu container ...'
	@mkdir -p $(STAGING_DIR)
	@cp ${D_DIR}/BASE ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/LOCALE_BASE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WINE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/INSTALL_STEAM >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/STEAM_SERVICE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WORKDIR >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/VOLUME >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/ENTRYPOINT >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/EXPOSE >> ${STAGING_DIR}/Dockerfile
	@cp Dockerfile.ubuntu $(STAGING_DIR)/Dockerfile
	@cp -R docker $(STAGING_DIR)
	@cd $(STAGING_DIR) && \
	 docker build \
		-t rpufky/steam:latest \
		.
	@echo
	@echo 'Remember to push to hub: docker push rpufky/steam:latest'

winehq: clean
	@echo 'Building steam ubuntu container using winehq repo ...'
	@mkdir -p $(STAGING_DIR)
	@cp ${D_DIR}/BASE ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/LOCALE_BASE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WINEHQ >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/INSTALL_STEAM >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/STEAM_SERVICE >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/WORKDIR >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/VOLUME >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/ENTRYPOINT >> ${STAGING_DIR}/Dockerfile
	@cat ${D_DIR}/EXPOSE >> ${STAGING_DIR}/Dockerfile
	@cp -R docker $(STAGING_DIR)
	@cd $(STAGING_DIR) && \
	 docker build \
		-t rpufky/steam:winehq \
		.
	@echo
	@echo 'Remember to push to hub: docker push rpufky/steam:winehq'


clean:
	@echo 'Cleaning build files ...'
	@rm -rfv $(STAGING_DIR)
