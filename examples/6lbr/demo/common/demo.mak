CONTIKI?=../../../..
SIXLBR?=${CONTIKI}/examples/6lbr
COOJA?=${CONTIKI}/tools/cooja
DEMO=$(SIXLBR)/demo

NODE_FIRMWARE?=node
SLIP_FIRMWARE?=slip-radio
SIXLBR_LIST?=6lbr
TARGET?=cooja
SIXLBR_BIN?=bin/cetic_6lbr_router
SIXLBR_PLUGINS?=${SIXLBR}/plugins/dummy/dummy.so ${SIXLBR}/plugins/lwm2m-client/lwm2m.so

DEV_TAP_IP6?=
DEV_TAP_IP4?=
BRIDGE?=
ROUTE?=
GW?=bbbb::100

export BRIDGE DEV_TAP_IP6 DEV_TAP_IP4 ROUTE GW

help:
	@echo "usage: make <target>"
	@echo
	@echo "The available targets are :"
	@echo "\t run : Run the demo"
	@echo "\t clean : Remove the runtime files"
	@echo "\t clean-firmwares : Clean the node and slip-radio builds"
	@echo "\t clean-cooja : Clean the Cooja simulator build"
	@echo "\t build-cooja : Rebuild the Cooja simulator"
	@echo "\t clean-6lbr : Clean 6LBR and nvm_tool builds"
	@echo "\t build-6lbr : Rebuild 6LBR and nvm_tool"
	@echo "\t clean-net : Clean network interfaces"
	@echo
	@echo "\t all : Clean, rebuild and launch demo"


ifneq ($(SOURCE_CSC),)
CSC?=gensetup.csc
GEN_CSC=$(CSC)
$(CSC): $(SOURCE_CSC)
	sed -e "/\/firmwares\/node\/6lbr-demo.c/ s/node/$(NODE_FIRMWARE)/" -e "/\/firmwares\/slip-radio\/slip-radio.c/ s/\/slip-radio\//\/$(SLIP_FIRMWARE)\//" $(SOURCE_CSC) > $(CSC)
endif

ifeq ($(CSC),)
	$(error "No CSC configuration file specified")
endif

clean-cooja:
	cd ${COOJA} && ant clean

build-cooja:
	cd ${COOJA} && ant jar

clean-6lbr:
	cd $(SIXLBR) && make clean
	cd $(SIXLBR)/tools && make clean

build-6lbr:
	cd $(SIXLBR) && make $(SIXLBR_BIN)
	cd $(SIXLBR)/tools && make

clean-firmwares:
	cd $(DEMO)/firmwares/slip-radio/ && $(MAKE) TARGET=$(TARGET) clean
	cd $(DEMO)/firmwares/$(NODE_FIRMWARE)/ && $(MAKE) TARGET=$(TARGET) clean
	
clean:
ifneq ($(SIXLBR_LIST),-)
	for SIXLBR in $(SIXLBR_LIST); do rm -f $$SIXLBR/6lbr.ip* $$SIXLBR/6lbr.timestamp $$SIXLBR/nvm.dat $$SIXLBR/*.so; done
endif
	rm -rf org
	rm -f COOJA.* *.pcap *.log $(GEN_CSC)

clean-net:
	@$(DEMO)/common/sim.sh --clean $(CSC) $(SIXLBR_LIST)

run: $(CSC)
	@CONTIKI=$(CONTIKI) SIXLBR=$(SIXLBR) COOJA=$(COOJA) SIXLBR_PLUGINS="$(SIXLBR_PLUGINS)" $(DEMO)/common/sim.sh $(CSC) $(SIXLBR_LIST)

all: clean-6lbr clean-firmwares clean build-6lbr run

.PHONY: clean-cooja build-cooja clean-firmwares clean clean-net run clean-all all
