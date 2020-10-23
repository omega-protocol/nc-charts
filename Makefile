# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash
TASK  := build
HELM  := helm

EXCLUDES := helm-toolkit doc tests tools logs tmp zuul.d releasenotes
CHARTS := helm-toolkit $(filter-out $(EXCLUDES), $(patsubst %/.,%,$(wildcard */.)))

.PHONY: $(EXCLUDES) $(CHARTS)
all: $(CHARTS)

$(CHARTS):
	@if [ -d $@ ]; then \
		echo; \
		echo "===== Processing [$@] chart ====="; \
		make $(TASK)-$@; \
	fi

init-%:
	if [ -f $*/Makefile ]; then make -C $*; fi
	if [ -f $*/requirements.yaml ]; then $(HELM) dep up $*; fi

lint-%: init-%
	if [ -d $* ]; then $(HELM)  lint $*; fi

build-%: lint-%
	if [ -d $* ]; then $(HELM)  package $*; fi

clean:
	@echo "Clean all build artifacts"
	rm -f */templates/_partials.tpl */templates/_globals.tpl
	rm -f *tgz */charts/*tgz */requirements.lock
	rm -rf */charts */tmpcharts

.PHONY: d t
d:
	$(HELM) template tekton-dashboard tekton-dashboard -n tekton-pipelines
t:
	$(HELM) template tekton-triggers tekton-triggers -n tekton-pipelines

co:
	git add --all && git amend --no-edit && git fp
