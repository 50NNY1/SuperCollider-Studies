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
		Dust.ar(32!2),
		LFNoise1.kr(0.3!2).exprange(1/8,0.2),
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

//real time granulation...
s.meter; // check we have input, if nothing shows, we can use ServerOptions.devices to get a list of available devices, onwards of this we can set ins and outs with s.options.inDevice_ or s.options.outDevice_

(
x = {
	var sig;
	sig = SoundIn.ar(0!2);
	sig = sig + CombN.ar(sig, decaytime:3, mul:0.5);
}.play; //test sound in and out with a simple delay
)

//build time!
(b = Buffer.alloc(s,
	s.sampleRate * 5 /* multiply by amount of seconds buf shud be */,
	1);
)

(
~micBus = Bus.audio(s,1);
~ptrBus = Bus.audio(s,1);
)

(
SynthDef.new(\mic, {
	arg in=0, out=0, amp=1;
	var sig;
	sig = SoundIn.ar(in) * amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\ptr, {
	arg out=0, buf=0, rate=1;
	var sig;
	sig = Phasor.ar(0, BufRateScale.kr(buf) * rate, 0, BufFrames.kr(buf));
	Out.ar(out, sig);
}).add;

SynthDef.new(\rec, {
	arg ptrIn=0, micIn=0, buf=0;
	var ptr, sig;
	ptr = In.ar(ptrIn, 1);
	sig = In.ar(micIn, 1);
	BufWr.ar(sig, buf, ptr);
}).add;

SynthDef.new(\gran, {
	arg amp=0.5, buf=0, out=0,
	atk=1, rel=1, gate=1,
	sync=1, dens=40,
	baseDur=0.05, durRand=1,
	rate=1, rateRand=1,
	pan=0, panRand=0,
	grainEnv=(-1), ptrBus=0, ptrSampleDelay=20000,
	ptrRandSamples=5000, minPtrDelay=1000;

	var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl,
	ptr, ptrRand, totalDelay, maxGrainDur;

	env = EnvGen.kr(Env.asr(atk,1,rel), gate, doneAction:2);
	densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	durCtrl = baseDur * LFNoise1.ar(100).exprange(1/durRand, durRand);
	rateCtrl = rate * LFNoise1.ar(100).exprange(1/rateRand, rateRand);
	panCtrl =  pan + LFNoise1.kr(100).bipolar(panRand);

	ptrRand = LFNoise1.ar(100).bipolar(ptrRandSamples);
	totalDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);

	ptr = In.ar(ptrBus, 1);
	ptr = ptr - totalDelay;
	ptr = ptr / BufFrames.kr(buf);

	maxGrainDur = (totalDelay / rateCtrl) / SampleRate.ir;
	durCtrl = min(durCtrl, maxGrainDur);

	sig = GrainBuf.ar(
		2,
		densCtrl,
		durCtrl,
		buf,
		rateCtrl,
		ptr,
		2,
		panCtrl,
		grainEnv
	);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

(
~micGrp = Group.new;
~ptrGrp = Group.after(~micGrp);
~recGrp = Group.after(~ptrGrp);
~granGrp = Group.after(~recGrp);
)

(
Synth(\mic, [\in, 0, \out, ~micBus], ~micGrp);
Synth(\ptr, [\buf, b, \out, ~ptrBus, \rate, 1], ~ptrGrp);
Synth(\rec, [\ptrIn, ~ptrBus, \micIn,~micBus, \buf, b], ~recGrp);
)

(
b.zero;
~g = 5.collect({
	arg n;
	Synth(\gran, [
	\amp, n.linlin(0,4,-3,-20).dbamp,
	\buf, b,
	\out, 0,
	\atk, 1,
	\rel, 1,
	\gate, 1,
	\sync, 0,
	\dens, 200,
	\baseDur, 0.2,
	\durRand, 1,
	\rate, -3.midiratio,
	\rateRand, 1,
	\pan, 0,
	\panRand, 1,
	\grainEnv, -1,
	\ptrBus, ~ptrBus,
	\ptrSampleDelay, n.linlin(0,4, 20, s.sampleRate*0.2),
	\ptrRandSamples, 10 ,
	\minPtrDelay, 1000,
], ~granGrp);})
)

~g.do({arg n; n.set(\gate, 0)});
~g.do({arg n; n.set(\rateRand, 10)});
~ptrGrp.set(\rate, 1);
s.defaultGroup.deepFree;
