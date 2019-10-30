# Makefile for steam docker containers.
STAGING_DIR = staging

help:
	@echo 'USAGE:'
	@echo
	@echo 'make steam'
	@echo '      Build latest steam dedicated docker container.'

.PHONY: help Makefile

steam:
	@echo 'Building steam ubuntu container ...'
	@mkdir -p $(STAGING_DIR)
	@cp Dockerfile $(STAGING_DIR)/Dockerfile
	@cp -R docker $(STAGING_DIR)
	@cd $(STAGING_DIR) && \
	 docker build \
		-t rpufky/steam:latest \
		.
	@echo
	@echo 'Remember to push to hub: docker push rpufky/steam:latest'

clean:
	@echo 'Cleaning build files ...'
	@rm -rfv $(STAGING_DIR)
