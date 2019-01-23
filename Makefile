IVERILOG = iverilog

IVFLAGS = -y .

VVP = vvp

OBJCOPY = objcopy

INSTRUCTIONS_DEPTH = 1024

%.vvp: %.v
	$(IVERILOG) $(IVFLAGS) $< -o $@

%.vcd: %.vvp
	$(VVP) $(VVPFLAGS) -n $<

%.hex: %.bin
	$(OBJCOPY) -I binary -O verilog $< $@

%.mif: %.bin gen_mif
	./gen_mif $(INSTRUCTIONS_DEPTH) < $< > $@

TD ?= td

TD_SOURCES = bfcpu.v instr_decode.v ip_controller.v stack_ram.v al_ip/i_mem_tang_bram.v al_ip/d_mem_tang_bram.v d_mem_tang.v i_mem_tang.v top_tang.v

.PHONY: sim
sim: instr_decode_tb.vcd top_sim.vcd

.PHONY: bitstream_tang
bitstream_tang: bfcpu_tang.bit

.PHONY: program_tang
program_tang: bfcpu_tang.bit
	$(TD) program_tang.tcl

bfcpu_tang.bit: bfcpu_tang.al td_tang.tcl instructions_tang.mif io_tang.adc timing_tang.sdc $(TD_SOURCES)
	$(TD) td_tang.tcl

instr_decode_tb.vvp: instr_decode_tb.v instr_decode.vvp
top_sim.vvp: top_sim.v i_mem_sim.vvp d_mem_sim.vvp io_sim.vvp bfcpu.vvp
bfcpu.vvp: bfcpu.v ip_controller.vvp instr_decode.vvp stack_ram.vvp

top_sim.vcd: top_sim.vvp instructions_sim.hex

gen_mif: gen_mif.o

clean:
	rm -f *.vvp *.vcd
