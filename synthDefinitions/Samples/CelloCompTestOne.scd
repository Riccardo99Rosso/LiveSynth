(
/*
Description:

*/

SynthDef(\CelloCompTestOne, {
	arg mul=1, out=0;
	var path, buf;
	path = "C:/Users/Riccardo/Desktop/STUDIO/METS/Comp3Lezioni/Progetto/Test/cello.wav";
	path = path.asString;
	buf = Buffer.read(s, path);
	Out.ar( out,
		PlayBuf.ar(2, buf, BufRateScale.kr(buf), 			doneAction: 2)
		* VarLag.kr(mul, 0.1)
	)

}).add;
)