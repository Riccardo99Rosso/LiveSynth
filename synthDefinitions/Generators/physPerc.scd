(
/*
Description:

*/

SynthDef(\physPerc, {
	arg variation=10, minFreq=220, maxFreq=1000, amp=0.1, out=0;
	var sig, env;
	
	sig = DynKlang.ar(`
		[LFNoise0.ar(variation).range(minFreq, maxFreq)*
		[1, 3.2, 6.23, 6.27, 9.92, 14.15],
			nil, nil],
		1, 0);
	sig = sig  * amp;
	Out.ar(out, sig);
	
}).add;
)