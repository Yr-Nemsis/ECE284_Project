all: iveri irun

iveri:
	iverilog -o compiled -c filelist

irun:
	vvp compiled

wave:
	gtkwave core_tb.vcd

clean:
	rm -rf compiled *.vcd