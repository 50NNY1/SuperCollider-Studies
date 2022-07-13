s.reboot;
s.meter;
(
SynthDef.new(\additive, {
	var sig, n=0, freqs, numPartials, dur;
	dur = \dur.kr(1);
	numPartials = 60;
	n = (1..numPartials);
	freqs = XLine.kr(\freq1.kr(55), \freq2.kr(90), dur) * n * (1 + (n * n * 0.001)).sqrt;
	sig = SinOsc.ar(freqs);

	//additive stuff pulled from youtube this one is a 3db/octave tilt?, i assume that means there is an emphasis on lower partials
	sig = sig * (log2(n) * \tilt.kr(-3)).dbamp;

	//heres an exponential comb filter
	sig = sig * ((1- log2(n * Line.kr(\comb.kr(1), \comb2.kr(20), dur)).sin.abs) ** 5);
	sig = sig[0,2..].sum + ([-1, 1] * sig[1,3..].sum);
	sig = sig * -5.dbamp;
	sig = sig.tanh;
	sig = sig * Env.asr(0.001, 1, 0.001).ar(Done.freeSelf, \gate.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;
)

(
SynthDef.new(\clap, {
	var sig;
	sig = Hasher.ar(Sweep.ar);
	sig = RHPF.ar(sig, [1320, 1352, 1240], 0.3);
	sig = sig * Env.perc(0.001, 0.2).delay([0, 0.01, 0.02]).ar(
		[Done.none, Done.none, Done.freeSelf],
		\gate.kr(1));
	sig = MoogFF.ar(sig, 8000, 0);
	sig = sig.sum!2;
	Out.ar(\out.kr(0), sig);
}).add;
)

(
SynthDef.new(\fx, {
	var sig;
	sig = In.ar(\out.kr(0), 2);
	sig = (sig * 1.5).fold2;
	sig = Select.ar(ToggleFF.ar(Dust.ar(1)).lag(0.1),
		[sig, CombC.ar(sig, 1/60, 1/60, 0.1)]);
	sig = Select.ar(ToggleFF.ar(Dust.ar(1)).lag(0.1),
		[sig, PitchShift.ar(sig, 0.2, 2)]);
	sig = Limiter.ar(sig, 0.8, 0.01);
	ReplaceOut.ar(\out.kr(0), sig);
}).add;
)

(
Routine {
	var bpm, beat, tatum, s, paramSetA, paramSetB, paramSets;
	s = Server.default;
	bpm = 160;
	beat = 60/ bpm;
	tatum = beat * 0.25;

	Synth.tail(s, \fx);
	s.sync;

	paramSetA = [freq1: 60, freq2: 90, comb1: 1, comb2: 20];
	paramSetB = [freq1: 50, freq2: 10, comb1: 1, comb2: 100];
	paramSets = [
		paramSetA,
		paramSetB,
		[freq1: 50, freq2: 1000, comb1: 0, comb2: 100],
		paramSetA,
		[freq1: 50, freq2: 30, comb1: 0, comb2: 10],
		[freq1: 60, freq2: 40, comb1: 2, comb2: 5]
	];

	inf.do {
		paramSets.do{ |paramSet|
			20.do {
				var synth, dur;
				if(0.9.coin) {
					dur = tatum * [1,2,4].choose;

					s.makeBundle(s.latency, {
						synth = Synth(\additive, [dur: dur] ++ paramSet);
					});
					dur.wait;
					s.makeBundle(s.latency, {
						synth.set(\gate, 0);
					});
				} {
					s.makeBundle(s.latency, {
						Synth(\clap);
					});
					beat.wait;
				};
			};
		};
	};
}.play;

)
