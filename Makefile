# Makefile for steam docker containers.
STAGING_DIR = staging

help:
	@echo 'USAGE:'
	@echo
	@echo 'make steam'
	@echo '      Build latest steam dedicated docker container.'

.PHONY: help Makefile

steam: clean
	@echo 'Building steam ubuntu container ...'
	@mkdir -p $(STAGING_DIR)
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
	@cp Dockerfile.winehq $(STAGING_DIR)/Dockerfile
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
