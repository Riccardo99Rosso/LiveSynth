(
/*
Description:
Delay implementation
*/

SynthDef(\CDelay, {
	arg drywet=1, delayTime=0.5, feedback=0, in=0, out=0;
	var sig, dry, wet;
	
	sig = In.ar(in);
	wet = sig + (LocalIn.ar(1) * VarLag.kr(feedback,0.1));
	wet = DelayC.ar(wet, 1.0, 
	VarLag.kr(delayTime - ControlDur.ir,0.1));
	LocalOut.ar(wet);
	
	wet = wet * drywet;
	dry = sig * (1 - drywet); 
	sig = wet + dry;
	Out.ar(out, sig);
}).add;
)