//polyphonic synth, midi.
MIDIClient.init;
MIDIIn.connectAll;

(
SynthDef.new(\tone, {
	arg freq=440, amp=0.3, gate=0;
	var sig, env;
	sig = LFTri.ar(freq)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

(
MIDIdef.noteOn(\noteOn, {
	arg vel nn chan, src;
	[vel, nn].postln;
	~notes[nn] = Synth.new(
		\tone,
		[
			\freq, nn.midicps,
			\amp, vel.linexp(1, 127, 0.01, 0.3),
			\gate, 1,
		]
	);
});
)

(
MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
})
)

//Sequencing demo. AWESOME DRONE
(
SynthDef.new(\patternTest, {
	arg freq=440, atk = 0.05, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1,-1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

(
Pdef(
	\sinepat,
	Pbind(
		\instrument, \patternTest,
		\dur, Pwhite(0.05, 0.5, inf),
		\midinote, Pseq([30],inf),
		\harmonic, Pexprand(1, 20, inf).round.trace,
		\atk, Pwhite(0.2,0.4,inf),
		\rel, Pwhite(0.5, 1.0, inf),
		\amp, Pkey(\harmonic).reciprocal * 0.3,
		\pan, Pwhite(0.8, -0.8, inf),
	);
).play;
)

//Drum Sequencing
(
//create dictionary to store URLS for our samples.
d = Dictionary.new;
d.add(\kick ->
	PathName("E:/Digitakt kits/kit_warm_dry 130422/Kick").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
    });
);

d.add(\snare ->
	PathName("E:/Digitakt kits/kit_warm_dry 130422/Sna").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
    });
);

d.add(\hat ->
	PathName("E:/Digitakt kits/kit_warm_dry 130422/Hat").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
    });
);
)

(
SynthDef.new(\bufPlay, {
	arg buf=0, rate=1, amp=1;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, doneAction:2);
	sig = sig*amp;
	Out.ar(0, sig);
})
)


