s.boot;
Server.killAll
(
s.meter;
s.plotTree;
s.scope;
)

//simple demo! static granulation

(
b = Buffer.readChannel(s,
	"C:/Users/Tired and Sad Club/OneDrive - Goldsmiths College/opn thingy Project/fucking bliss.wav",
	channels:[0]
);
)
b.play;
b1.play;
b.numChannels;

({
	var sig;
	sig = GrainBuf.ar( //N000000!! FUCKING STEREO ahhhhhh
		2, Impulse.ar(10),
		0.9, b,
		1, 0.1,
		2, 0,
		-1, 512
	);
}.play
)

//with randomness, nice texture!
(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(20!2),
		LFNoise1.kr(0.3!2).exprange(0.002,0.2),
		b,
		1,
		(SinOsc.kr(0.01) + 1)/2,
		2,
		0,
		-1,
		512
	);
}.play
)

//scan thru file
({
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(30!2),
		LFNoise1.kr(0.3!2).exprange(1/25,1/4),
		b,
		1,
		(
			Line.ar(0, BufSamples.ir(b)-1, BufDur.ir(b) * 2, doneAction:2)
			+ LFNoise1.ar(100).bipolar(2 * SampleRate.ir )) / BufSamples.ir(b),
		//the noise here is optional but a bit of randomness seems to smooth out our output,
		//the bit after bipolar() is spread in seconds.
		2,
		LFNoise1.kr(100).range(-1,1),
		-1,
		512
	);
}.play;
)

//it is better practice to use a phasor here for grain pos.
({
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(32!2),
		0.2,
		b,
		1.6,
		(
			Phasor.ar(0, 0.8 * BufRateScale.ir(b), 0, BufSamples.ir(b) -1)
			+ LFNoise1.ar(160).bipolar(0.8 * SampleRate.ir )
		) / BufSamples.ir(b),
		//the noise here is optional but a bit of randomness seems to smooth out our output,
		//the bit after bipolar() is spread in seconds.
		1,
		0,
		-1,
		512
	);
}.play;
)

//with new sound??
({
	var b = Buffer.readChannel(s,
		"C:/Users/Tired and Sad Club/OneDrive - Goldsmiths College/opn thingy Project/PLUCKS2.wav",
		channels:[0]
	);
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(8!2),
		0.1,
		b,
		0.4,
		(
			Phasor.ar(0, 0.4 * BufRateScale.ir(b), 0, BufSamples.ir(b) -1)
			+ LFNoise1.ar(1.6).bipolar(0.4 * SampleRate.ir )
		) / BufSamples.ir(b),
		//the noise here is optional but a bit of randomness seems to smooth out our output,
		//the bit after bipolar() is spread in seconds.
		1,
		1,
		-1,
		512
	);
}.play;
)

