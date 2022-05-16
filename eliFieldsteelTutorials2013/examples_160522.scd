(
SynthDef.new(\fm, {
	arg carHz=440, modHz= 2, modAmp=200,
	atk=0.01, rel=1, amp=0.2, pan = 0;
	var car, mod, env;
	env = EnvGen.kr(Env.perc(atk,rel), doneAction:2);
	mod = SinOsc.ar(modHz, mul:modAmp);
	car = SinOsc.ar(carHz + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)

(
p = Pbind(
	\instrument, \fm,
	\dur, Pseq([1/3, 1/8, 1/6], inf),
	\stretch, (60/180 * 4),
	\carHz, Pexprand(20, 10000),
	\modHz, Pexprand(20, 10000),
	\modAmp, Pwhite(0, 10000),
	\amp, Pexprand(0.1, 0.5),
	\atk, Pexprand(0.001, 0.05),
	\rel, Pexprand(0.05, 1.2),
	\pan, Pwhite(-1.0, 1.0),
).play;
)