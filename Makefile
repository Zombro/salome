all: build

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

CAPABILITIES = \
	--cap-add=SYS_ADMIN

ENV_VARS = \
	--env="USER_UID=$(shell id -u)" \
	--env="USER_GID=$(shell id -g)" \
	--env="DISPLAY" \
	--env="XAUTHORITY=${XAUTH}"

VOLUMES = \
	--volume=${XSOCK}:${XSOCK} \
	--volume=${XAUTH}:${XAUTH}

ENV_INSTL_USER = \
	--env="SALOME_USER=${USER}"

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make build            - build the salome image"
	@echo "   2. make start            - start interactive SALOME session"
	@echo "   2. make shell            - start shell SALOME session"
	@echo "   2. make test             - launch SALOME tests"
	@echo "   2. make bash             - bash login"
	@echo ""

clean:
	@docker rm -f `docker ps -a | grep "${USER}/salome" | awk '{print $$1}'` > /dev/null 2>&1 || exit 0
	@docker rmi `docker images  | grep "${USER}/salome" | awk '{print $$3}'` > /dev/null 2>&1 || exit 0


build:
	@docker build --rm=true --tag=${USER}/salome:$(shell cat VERSION) .

start shell test bash: build
	@touch ${XAUTH}
	@xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f ${XAUTH} nmerge -
	docker run -it --rm \
		${CAPABILITIES} \
		${ENV_VARS} \
		${VOLUMES} \
		${USER}/salome:$(shell cat VERSION) $@
