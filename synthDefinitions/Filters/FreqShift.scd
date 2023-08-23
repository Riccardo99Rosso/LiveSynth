(
/*
Description:
Mono FreqShift
*/

SynthDef(\FreqShift, {
	arg in=0, freq=0.0, phase=0.0, mul=1.0, add=0.0, out=0;
	var sig;
	
	sig = In.ar(in);
	sig = FreqShift.ar(sig, 
		VarLag.kr(freq,0.1), 
		VarLag.kr(phase,0.1), 
		VarLag.kr(mul,0.1), 
		VarLag.kr(add,0.1)
	);
	Out.ar(out, sig);

}).add;
)