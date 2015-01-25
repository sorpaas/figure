FIGURE_VERSION = master

SSHCOMMAND_URL ?= https://raw.github.com/progrium/sshcommand/master/sshcommand
PLUGINHOOK_URL ?= https://s3.amazonaws.com/progrium-pluginhook/pluginhook_0.1.0_amd64.deb
STACK_URL ?= https://github.com/progrium/buildstep.git
PREBUILT_STACK_URL ?= https://github.com/progrium/buildstep/releases/download/2014-12-16/2014-12-16_42bd9f4aab.tar.gz
PLUGINS_PATH ?= /var/lib/figure/plugins

# If the first argument is "vagrant-figure"...
ifeq (vagrant-figure,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "vagrant-figure"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

.PHONY: all install copyfiles version plugins dependencies sshcommand pluginhook docker aufs stack count vagrant-acl-add vagrant-figure

all:
	# Type "make install" to install.

install: dependencies stack copyfiles plugin-dependencies plugins version

release: deb-all package_cloud packer

packer:
	packer build contrib/packer.json

copyfiles:
	cp figure /usr/local/bin/figure
	mkdir -p ${PLUGINS_PATH}
	find ${PLUGINS_PATH} -mindepth 2 -maxdepth 2 -name '.core' -printf '%h\0' | xargs -0 rm -Rf
	find plugins/ -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | while read plugin; do \
		rm -Rf ${PLUGINS_PATH}/$$plugin && \
		cp -R plugins/$$plugin ${PLUGINS_PATH} && \
		touch ${PLUGINS_PATH}/$$plugin/.core; \
		done
	$(MAKE) addman

fig:
	curl -L https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m` > /usr/local/bin/fig; chmod +x /usr/local/bin/fig

shyaml:
	curl -L https://raw.githubusercontent.com/0k/shyaml/master/shyaml > /usr/local/bin/shyaml; chmod +x /usr/local/bin/shyaml

addman:
	mkdir -p /usr/local/share/man/man1
	help2man -Nh help -v version -n "configure and get information from your figure installation" -o /usr/local/share/man/man1/figure.1 figure
	mandb

version:
	git describe --tags > ~figure/VERSION  2> /dev/null || echo '~${FIGURE_VERSION} ($(shell date -uIminutes))' > ~figure/VERSION

plugin-dependencies: pluginhook
	figure plugins-install-dependencies

plugins: pluginhook docker
	figure plugins-install

dependencies: sshcommand pluginhook docker stack help2man fig shyaml

help2man:
	apt-get install -qq -y help2man

sshcommand:
	wget -qO /usr/local/bin/sshcommand ${SSHCOMMAND_URL}
	chmod +x /usr/local/bin/sshcommand
	sshcommand create figure /usr/local/bin/figure

pluginhook:
	wget -qO /tmp/pluginhook_0.1.0_amd64.deb ${PLUGINHOOK_URL}
	dpkg -i /tmp/pluginhook_0.1.0_amd64.deb

docker: aufs
	apt-get install -qq -y curl
	egrep -i "^docker" /etc/group || groupadd docker
	usermod -aG docker figure
	curl --silent https://get.docker.io/gpg | apt-key add -
	echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
	apt-get update
ifdef DOCKER_VERSION
	apt-get install -qq -y lxc-docker-${DOCKER_VERSION}
else
	apt-get install -qq -y lxc-docker
endif
	sleep 2 # give docker a moment i guess

aufs:
ifndef CI
	lsmod | grep aufs || modprobe aufs || apt-get install -qq -y linux-image-extra-`uname -r` > /dev/null
endif

stack:
	@echo "Start building buildstep"
ifdef BUILD_STACK
	@docker images | grep progrium/buildstep || (git clone ${STACK_URL} /tmp/buildstep && docker build -t progrium/buildstep /tmp/buildstep && rm -rf /tmp/buildstep)
else
	@docker images | grep progrium/buildstep || curl --silent -L ${PREBUILT_STACK_URL} | gunzip -cd | docker import - progrium/buildstep
endif

count:
	@echo "Core lines:"
	@cat figure bootstrap.sh | wc -l
	@echo "Plugin lines:"
	@find plugins -type f | xargs cat | wc -l

vagrant-acl-add:
	vagrant ssh -- sudo sshcommand acl-add figure $(USER)

vagrant-figure:
	vagrant ssh -- "sudo -H -u root bash -c 'figure $(RUN_ARGS)'"
