(
/*
Description:
8 band Equalizer
*/

SynthDef(\EqEight, {
	arg amp1=1, amp2=1, amp3=1, amp4=1,
	amp5=1, amp6=1, amp7=1, amp8=1, amp=1,
	drywet=1, in=0, out=0;
	var freq1=40, freq2=80, freq3=200, freq4=400, freq5=800, 
	freq6=1600, freq7=3200, freq8=6400;
	var band1, band2, band3, band4, band5, band6, band7, band8;
	var sig, dry, wet;

	sig = In.ar(in) ;

	band1 = BPeakEQ.ar(sig, freq1, 1, 
		VarLag.kr(amp1.ampdb, 0.1));
	band2 = BPeakEQ.ar(band1, freq2, 1, 
		VarLag.kr(amp2.ampdb, 0.1));
	band3 = BPeakEQ.ar(band2, freq3, 1,
		VarLag.kr(amp3.ampdb, 0.1));
	band4 = BPeakEQ.ar(band3, freq4, 1, 
		VarLag.kr(amp4.ampdb, 0.1));
	band5 = BPeakEQ.ar(band4, freq5, 1, 
		VarLag.kr(amp5.ampdb, 0.1));
	band6 = BPeakEQ.ar(band5, freq6, 1, 
		VarLag.kr(amp6.ampdb, 0.1));
	band7 = BPeakEQ.ar(band6, freq7, 1, 
		VarLag.kr(amp7.ampdb, 0.1));
	band8 = BPeakEQ.ar(band7, freq8, 1, 
		VarLag.kr(amp8.ampdb, 0.1));
	
	wet = band8 * drywet;
	dry = sig * (1 - drywet);
	sig = wet + dry;

	Out.ar(out, sig * amp);
}).add;
)