(
/*
Description:
Band pass filter
*/

SynthDef(\BPF, {
	arg freq=440, rq=1.0, mul=1, add=0, in=0, out=0;
	var sig;

	sig = In.ar(in);
	sig = BPF.ar(sig, 
		VarLag.kr(freq, 0.1),
		VarLag.kr(rq, 0.1), 
		VarLag.kr(mul, 0.1), 
		VarLag.kr(add, 0.1)
	);

	Out.ar(out, sig);
}).add;
)