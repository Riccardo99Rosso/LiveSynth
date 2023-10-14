(
/*
Description:
Harmonized Saw
*/

SynthDef(\HarmSaw, {
	arg drywet=1, in=0, out=0;
	var amp, freq, hasFreq, sigOut, sig, dry, wet;

	sig = In.ar(in);
	amp = Amplitude.kr(sig, 0.05, 0.05);
	# freq, hasFreq = Pitch.kr(sig, ampThreshold: 0.02, median: 7);
	sigOut = Mix(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), amp));
	10.do({
		sigOut = AllpassN.ar(sigOut, 0.040, [0.04.rand,0.04.rand], 2)
	});

	wet = sigOut * drywet;
	dry = sig * (1 - drywet); 
	sigOut = wet + dry;
	
	Out.ar(out, sigOut);
}).add;
)