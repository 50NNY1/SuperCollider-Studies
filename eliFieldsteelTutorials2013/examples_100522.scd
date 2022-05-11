//use of synthdef and synth, plus a kind of interesting synth here!
(
SynthDef.new(\pulses, {
	arg ampHz = 4, fund = 40, maxPartial = 4, width = 0.5;
	var amp1, amp2, freq1, freq2, sig1, sig2;
	amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz, 0.5, 0.12) * 0.75;
	freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8, add:1); //this syntax demonstrates how to skip arg order
	freq2 = freq2 * LFPulse.kr(6, add:1);
	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

x = Synth.new(\pulses) // here we could also pass an array of arguements in as the second arguement.
x.set(\width,0.5)
x.set(\ampHz, 2)
x.set(\fund, 30)
x.set(\maxPartial, 100)

x.free;

//excercise of iteration techniques in SC, but with sound!
(
SynthDef.new(\iter, {
	arg freq=40;
	var temp, sum, env;
	env = EnvGen.kr(
		Env.perc(0.01,5, 1, -2),
		doneAction:2);
	sum = 0;
	40.do{ //forloop i < 10
		temp = VarSaw.ar(
			freq * {Rand(0.98, 1.02)}!2, //only 2 frequencys generated, because this ugen is audio aware(?) it knows to split these between our 2 audio channels?
			{Rand(0.0, 1.0)}!2,
			{Rand(0.005,0.05)}!2
		);
		sum = sum + temp;
	};
	sum = sum * 0.2 * env;
	Out.ar(0, sum);
}).add;
)

(
[400, 80, 40, 600].do{
	arg middiNote;
	Synth.new(\iter, [\freq, midiNote]);
}
)