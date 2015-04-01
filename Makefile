
SHELL = /bin/bash -o pipefail -o nounset -o errexit

valid_xml = $(wildcard xml/*.xml)
schemas = $(shell find . -type f -name '*.xsd' -print)

reports = \
	$(valid_xml:%=tmp/reports/%.txt) \
	$(schemas:%=tmp/reports/set/%.txt) \
	$(schemas:%=tmp/reports/auto/%.txt) \

all: $(reports)

report: $(reports)
	@ for report in $(reports); \
	do if [[ "pass" != "$$(tail -n 1 $$report)" ]]; \
	   then echo "========================================================================="; \
	        echo "# did not pass: $$report"; \
	        cat $$report; \
	   fi; \
	done

update:
	subset="$(shell find ~/Downloads -type f -name 'Subset *.zip' -print | sort | tail -n 1)"; \
	if [[ ! -f $$subset ]]; \
	then echo "new subset not found"; exit 1; \
	else rm -rf subset; \
	     unzip -d subset "$$subset"; \
	fi


tmp/reports/%.txt: % $(schemas)
	mkdir -p $(dir $@)
	test-run --exit-success --report=$@ \
		-e 0 -1 /dev/null -2 /dev/null \
		xsdvalid -catalog xml-catalog.xml $<

tmp/reports/set/%.txt: %
	mkdir -p $(dir $@)
	test-run --exit-success --report=$@ \
		-e 0 -1 /dev/null -2 /dev/null \
	    get-test-report --rules=set --xml-catalog=xml-catalog.xml $<

tmp/reports/auto/%.txt: %
	mkdir -p $(dir $@)
	test-run --exit-success --report=$@ \
		-e 0 -1 /dev/null -2 /dev/null \
	    get-test-report --auto-rules --xml-catalog=xml-catalog.xml $<

clean:
	$(RM) $(reports)

xmime.xsd:
	curl -o $@ http://www.w3.org/2005/05/xmlmime

xop-include.xsd:
	curl -o $@ http://www.w3.org/2004/08/xop/include
