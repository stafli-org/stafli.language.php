#!make
#
#    Stafli PHP Language (makefile)
#    Copyright (C) 2016-2017 Stafli
#    Luís Pedro Algarvio
#    This file is part of the Stafli Application Stack.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Load envfile
include .env
export $(shell sed 's/=.*//' .env)

# Format variables
IMAGE_URL_PREFIX := $(shell echo $(IMAGE_URL_PREFIX))
IMAGE_TAG_PREFIX := $(shell echo $(IMAGE_TAG_PREFIX))
CONTAINER_URL_PREFIX := $(shell echo $(CONTAINER_URL_PREFIX))
VOLUME_URL_PREFIX := $(shell echo $(VOLUME_URL_PREFIX))
DISTRO_DEBIAN8_VERSION := $(shell echo $(DISTRO_DEBIAN8_VERSION))
DISTRO_DEBIAN7_VERSION := $(shell echo $(DISTRO_DEBIAN7_VERSION))
DISTRO_CENTOS7_VERSION := $(shell echo $(DISTRO_CENTOS7_VERSION))
DISTRO_CENTOS6_VERSION := $(shell echo $(DISTRO_CENTOS6_VERSION))
PROJECT_NAME := $(shell echo $(PROJECT_NAME))

# If distro is not provided, default to all
ifndef DISTRO
	DISTRO:=all
endif

# Set list of distros
ifeq ($(DISTRO), all)
	DISTROS:=debian8 debian7 centos7 centos6
else
	DISTROS:=$(DISTRO)
endif

all: help

help:
	@echo "\
===============================================================================\n\
$$PROJECT_NAME\n\
===============================================================================\n\
\n\
Syntax:\n\
make <command> DISTRO=<distribution>\n\
\n\
Issuing commands:\n\
By default, the target distribution will be all available.\n\
If you want to target a specific distribution, you will need to specify it.\n\
You can do this by adding DISTRO to the command.\n\
\n\
Available commands:\n\
- help:			This help text.\n\
- quick start:\n\
  - up:			Builds images and creates and starts containers, networks and volumes.\n\
  - down:		Stops and removes containers and networks.\n\
  - purge:		Purges containers, networks, volumes and images.\n\
- for images:\n\
  - img-ls:		Lists images, using docker, using docker.\n\
  - img-build:		Builds images from dockerfiles, using docker-compose.\n\
  - img-pull:		Pulls images from repository, using docker-compose.\n\
  - img-rm:		Removes images, using docker.\n\
- for containers:\n\
  - con-ls:		Lists containers, using docker-compose.\n\
  - con-create:		Creates containers, using docker-compose.\n\
  - con-rm:		Removes containers, using docker-compose.\n\
  - con-start:		Starts containers, using docker-compose.\n\
  - con-stop:		Stops containers, using docker-compose.\n\
  - con-restart:	Restarts containers, using docker-compose.\n\
  - con-pause:		Pauses containers, using docker-compose.\n\
  - con-unpause:	Unpauses containers, using docker-compose.\n\
  - con-inspect:	Inspects containers, using docker.\n\
  - con-ips:		Shows ips of containers, using docker.\n\
  - con-ports:		Shows logs of containers, using docker.\n\
  - con-top:		Shows processes of containers, using docker.\n\
  - con-logs:		Shows logs of containers, using docker-compose.\n\
  - con-events:		Shows events of containers, using docker-compose.\n\
- for volumes:\n\
  - vol-ls:		Lists volumes, using docker volume.\n\
  - vol-create:		Creates volumes, using docker volume.\n\
  - vol-rm:		Removes volumes, using docker volume.\n\
  - vol-inspect:	Inspects volumes, using docker volume.\n\
\n\
Available distributions:\n\
- debian8\n\
- debian7\n\
- centos7\n\
- centos6\n\
\n\
Example #1: quick start, with build\n\
 make up DISTRO=debian8;\n\
\n\
Example #2: quick start, with pull\n\
 make img-pull DISTRO=debian8;\n\
 make up DISTRO=debian8;\n\
\n\
Example #3: manual steps, with build\n\
 make img-build DISTRO=debian8;\n\
 make vol-create DISTRO=debian8;\n\
 make con-create DISTRO=debian8;\n\
 make con-start DISTRO=debian8;\n\
 make con-ls DISTRO=debian8;\n\
"


up:
	@echo
	@echo Building images and creating and starting containers, networks and volumes...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Building images and creates and starts containers, networks and volumes for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose up)"; \
	done


down:
	@echo
	@echo Stopping and removes containers and networks....
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Stopping and removes containers and networks for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose down)"; \
	done


purge:
	@echo
	@echo Purging containers, networks, volumes and images....
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Purging containers, networks, volumes and images for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose down)"; \
		docker volume rm $(VOLUME_URL_PREFIX)$$VERSION"_"$$DISTRO_INDEX"_data"; \
		docker image rm $(IMAGE_URL_PREFIX):$(IMAGE_TAG_PREFIX)$$VERSION"_"$$DISTRO_INDEX; \
	done


img-ls:
	@echo
	@echo Listing images...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Listing images for $$DISTRO_INDEX...; \
		docker image ls | grep -E $(IMAGE_URL_PREFIX).*$$DISTRO_INDEX | sort -n; \
	done


img-build:
	@echo
	@echo Building images...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Building images for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose build)"; \
	done


img-pull:
	@echo
	@echo Pulling images...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Building images for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose pull)"; \
	done


img-rm:
	@echo
	@echo Removing images...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Removing images for $$DISTRO_INDEX...; \
		docker image rm $(IMAGE_URL_PREFIX):$(IMAGE_TAG_PREFIX)$$VERSION"_"$$DISTRO_INDEX; \
	done


con-ls:
	@echo
	@echo Showing containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Showing containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose ps)"; \
	done


con-create:
	@echo
	@echo Creating containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Creating containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose create)"; \
	done


con-rm:
	@echo
	@echo Removing containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Removing containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose rm)"; \
	done


con-start:
	@echo
	@echo Starting containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Starting containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose start)"; \
	done


con-stop:
	@echo
	@echo Stoping containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Stoping containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose stop)"; \
	done


con-restart:
	@echo
	@echo Restarting containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Restarting containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose restart)"; \
	done


con-pause:
	@echo
	@echo Pausing containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Pausing containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose pause)"; \
	done


con-unpause:
	@echo
	@echo Unpausing containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Unpausing containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose unpause)"; \
	done


con-inspect:
	@echo
	@echo Inspecting containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Inspecting containers for $$DISTRO_INDEX...; \
		docker container inspect $(CONTAINER_URL_PREFIX)$$VERSION"_"$$DISTRO_INDEX"_1"; \
	done

con-ips:
	@echo
	@echo Showing IP addresses of containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Showing IP addresses of container for $$DISTRO_INDEX...; \
		docker container inspect $(CONTAINER_URL_PREFIX)$$VERSION"_"$$DISTRO_INDEX"_1" | grep -e "inspect" -e "\"NetworkID\"" -B 0 -A 8; \
	done


con-ports:
	@echo
	@echo Showing ports of containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Showing ports of containers for $$DISTRO_INDEX...; \
		docker container port $(CONTAINER_URL_PREFIX)$$VERSION"_"$$DISTRO_INDEX"_1"; \
	done


con-top:
	@echo
	@echo Showing processes of containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Showing processes of containers for $$DISTRO_INDEX...; \
		docker container top $(CONTAINER_URL_PREFIX)$$VERSION"_"$$DISTRO_INDEX"_1"; \
	done


con-logs:
	@echo
	@echo Showing logs of containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Showing logs of containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose logs)"; \
	done


con-events:
	@echo
	@echo Showing events of containers...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		echo; \
		echo Showing events of containers for $$DISTRO_INDEX...; \
		bash -c "(cd $$DISTRO_INDEX; set -o allexport; source .env; set +o allexport; docker-compose events)"; \
	done


vol-ls:
	@echo
	@echo Listing volumes...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Listing volumes for $$DISTRO_INDEX...; \
		docker volume ls | grep -E "$(VOLUME_URL_PREFIX)$$VERSION" | grep -E "$$DISTRO_INDEX" | sort -n; \
	done


vol-create:
	@echo
	@echo Creating volumes...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Creating volumes for $$DISTRO_INDEX...; \
		docker volume create --driver local --name $(VOLUME_URL_PREFIX)$$VERSION"_"$$DISTRO_INDEX"_data"; \
	done


vol-rm:
	@echo
	@echo Removing volumes...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Removing volumes for $$DISTRO_INDEX...; \
		docker volume rm $(VOLUME_URL_PREFIX)$$VERSION"_"$$DISTRO_INDEX"_data"; \
	done


vol-inspect:
	@echo
	@echo Inspecting volumes...
	@echo
	@for DISTRO_INDEX in $(DISTROS); do \
		if [ $$DISTRO_INDEX = "debian8" ]; then \
			VERSION=$(DISTRO_DEBIAN8_VERSION); \
		elif [ $$DISTRO_INDEX = "debian7" ]; then \
			VERSION=$(DISTRO_DEBIAN7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos7" ]; then \
			VERSION=$(DISTRO_CENTOS7_VERSION); \
		elif [ $$DISTRO_INDEX = "centos6" ]; then \
			VERSION=$(DISTRO_CENTOS6_VERSION); \
		fi; \
		echo; \
		echo Inspecting volumes for $$DISTRO_INDEX...; \
		docker volume inspect $(VOLUME_URL_PREFIX)$$VERSION"_"$$DISTRO_INDEX"_data"; \
	done


.SILENT: help

