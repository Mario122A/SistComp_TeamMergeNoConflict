obj-m := TeamMergeNoConflict-driver.o
KDIR := $(HOME)/rpi-qemu/linux
PWD := $(shell pwd)
ARCH        := arm
CROSS_COMPILE := arm-linux-gnueabihf-
EXTRA_CFLAGS := -I$(KDIR)/include
all:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) EXTRA_CFLAGS="$(EXTRA_CFLAGS)" modules
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean