(
/*
Description:
Sinusoidal Oscillator
*/

SynthDef(\Sin, {
	arg freq=440,phase=0.0,mul=0.5,add=0.0,out=0;
	var sig;

	sig = SinOsc.ar(
		VarLag.kr(freq,0.1), 
		VarLag.kr(phase,0.1), 
		VarLag.kr(mul,0.1), 
		VarLag.kr(add,0.1)
	);
	Out.ar(out,sig);
}).add;
)