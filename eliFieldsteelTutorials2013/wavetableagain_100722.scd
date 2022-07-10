~sig = Signal.sineFill(1024, [1], [0]);
//here we have plotted a sine wave signal, however to use wavetable audio generating UGENS, we need to convert supercolliders specific wave table format

~wt = ~sig.asWavetable;
~wt.plot;

b = Buffer.alloc(s, 2048);
b.loadCollection(~wt);

{Osc.ar(b, MouseX.kr(100,1000), mul:0.2!2)}.play;
//here we have plotted a signal, converted it to wavetable format, put the wavetable inside a buffer, and are using OSC to play this buffer (wave table format player ugen). if we dont convert to wavetable format, it does sound awesome however, is incompatible and very glitchy.

(
~amps = [1] ++ ({[0.05, 0.5].choose}!31); //randomise amplitudes, choose random between 0.05 and 0.5
~sig = Signal.sineFill(
	1024,
	~amps,
	0!4 // all are at equal phase now
);
~wt = ~sig.asWavetable;
b.loadCollection(~wt);
)

//more randomness!
(3.do{
//calling sine3 is a shortcut to load in a wavetable to a already allocated buffer
b.sine3(
	({exprand(0.75, 40)}!16).sort,
	({exprand(0.05, 0.9)}!16).sort.reverse,
	{rrand(0,2pi)}!16
);
{Osc.ar(b, MouseX.kr(10,10000,1) * [1, 2.01], mul:0.2!2)}.play;
}
)

//with env we can be more specific on our wave shape.
(
var env, sig, wt;
env = Env([0, 0.6, -0.4, 0.9, -0.5], [1,2,3,4], \lin);
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
{Osc.ar(b, MouseX.kr(10,10000,1) * [1, 2.01], mul:0.2!2)}.play;
)

//for demo purposes ill make a sine wave like this
(
var env, sig, wt;
env = Env([0, 1, 0, -1, 0], [1,1], \sin); //a messy sine of sorts
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
{Osc.ar(b, MouseX.kr(10,10000,1) * [1, 2.01], mul:0.2!2)}.play;
)

//lastly we can use a signal class method called wavefill, allows u to apply a mathmatical function on each sample.

//heres a sine again, much neater and intuitive this way
(
var sig, wt;
sig = Signal.newClear(1024);
sig.waveFill(
	{
		arg x, old, i;
		sin(x)
	}, 0, 2pi);
sig.plot;
)

(
var sig, wt;
sig = Signal.newClear(1024);
sig.waveFill(
	{
		arg x, old, i;
		var out;
		out = sin(x.pow(1.5));
		out = out * 1.5;
		out = out.fold(-1,1);
		out = out.cubed;
	}, 0, 2pi);
wt = sig.asWavetable;
b.loadCollection(wt);
{Osc.ar(b, MouseX.kr(10,10000,1) * [1, 2.01], mul:0.2!2)}.play;
)

//we can interpolate between two different wavetables, using a VARIABLE WAVE TABLE OSCILATIOR, or vosc ugen!

//generate our wavetables first
(
~wt0 = Signal.sineFill(
	1024,
	1 / (1..8),
	0!8
).asWavetable;

~wt1 = Signal.sineFill(
	1024,
	[1,0,1/2,1,1/4],
	[0,0,pi,0,pi]
).asWavetable;
~b0 = Buffer.loadCollection(s, ~wt0);
~b1 = Buffer.loadCollection(s, ~wt1);
)

(
SynthDef.new(\vosc, {
	arg out=0;
	var sig, bufpos;
	bufpos = MouseX.kr(0,1); // this line of code works as wt0 is assigned to buffer 0 on the server and 1 to 1. however this hard wiring is bad practice, we would normally like to use some arguement arithmitic to get the buf server numbers.
	sig = VOsc.ar(bufpos, 300, mul:0.2!2);
	Out.ar(out, sig);
}).add;
)
Synth(\vosc);

//above we already diagnosed an issue that may arrise with buffers not being consecutive or the wrong ones being indexed by vosc. tutorial reccomends we do this instead.

(
~wt = Array.fill(4, {
	var numSegs = rrand(4, 20);
	Env(
		[0] ++ (({rrand(0.0,1.0)}!(numSegs-1)) * [1,-1]).scramble ++ [0],
		{exprand(1,20)}!numSegs,
		{rrand(-20, 20)}!numSegs
	).asSignal(1024).asWavetable;
});

~buf = Buffer.allocConsecutive(4, s, 2048); //now we created 4 empty buffers for the array to fit into
~buf.do({
	arg buf, i;
	buf.loadCollection(~wt[i]);
});
)

//NEW SYNTH DEF TO WORK WITH THIS.

(
SynthDef.new(\vosc, {
	arg out=0, buf=0, numBufs=2, freq=440;
	var sig, bufpos, detunefreq;
	bufpos = buf + LFNoise1.kr(0.5).range(0, numBufs -1);
	detunefreq = LFNoise1.kr(0.2!8).bipolar(0.2).midiratio;
	sig = VOsc.ar(bufpos, freq * detunefreq, mul:0.2!2);
	sig = Splay.ar(sig);
	sig = LeakDC.ar(sig);
	Out.ar(out, sig);
}).add;
)

Synth(\vosc, [\buf, ~buf[0].bufnum, \numBufs, 4, \freq, 29.midicps]);

//for waveshaping, morphing to undefined wavetable as a result of mathmatical processing. we use shaper.

(
~tf = Env([-0.8,0,0.8], [1,1], [8,-8]).asSignal(1025).asWavetableNoWrap;
~tfBuf = Buffer.loadCollection(s, ~tf); //make and load transfer function to buf.
)

{Shaper.ar(~tfBuf, SinOsc.ar(440)) * 0.2!2}.play; //sounds more square like for a sine!

//end of tutorial demo

(
SynthDef.new(\shaper, {
	arg buf=0, freq=440, amp=0.2, out=0,
	atk=1, sus=0, rel=5, curvemax=1;
	var sig, input,curve, env;
	env = EnvGen.kr(
		Env.linen(atk,sus,rel,1, [1.0,-1]),
		doneAction:2);
	curve = LFNoise1.kr(0.5!8).bipolar(curvemax);
	input = LFTri.ar({freq* Rand(-0.1,0.1).midiratio}!8);
	input = input.lincurve(-1,1,-1,1,curve);
	sig = Shaper.ar(buf, input);
	sig = Splay.ar(sig) * amp * env;
	sig = LeakDC.ar(sig);
	Out.ar(out, sig);
}).add;
)
(
({rrand(40,90)}!4).do({
	arg n;
	Synth(\shaper, [
		\buf, ~tfBuf,
		\freq, n.nearestInScale([0, 7, 9,10]).midicps,
		\amp, n.lincurve(40,90, 0.3, 0.1, -2),
		\curvemax, 0
	]);
});)