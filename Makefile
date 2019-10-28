
help:
	@echo 'USAGE:'
	@echo
	@echo 'make steam'
	@echo '      Build latest steam dedicated docker container.'

debian:
	@docker build \
		-t rpufky/steam:latest \
		.
	@echo
	@echo 'Remember to push to hub: docker push rpufky/steam:latest'
