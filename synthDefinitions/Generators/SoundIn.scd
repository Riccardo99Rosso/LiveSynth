(
/*
Description:

*/

SynthDef(\SoundIn, {
	arg out=0, amp=1;
	var sig;
	
	sig = SoundIn.ar(0);
	Out.ar(out, sig * amp);
}).add;
)