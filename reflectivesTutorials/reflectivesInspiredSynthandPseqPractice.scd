(
Spec.add(\modindex, [0,10]);
Spec.add(\modindex2, [0,10]);
Spec.add(\modamt, [0,8,\lin]);
Spec.add(\freq, \freq);
Spec.add(\atk, \delayms);
Spec.add(\rel, [0,4]);
Spec.add(\curve, [-10,10]);
Spec.add(\cutoff, [-1, 1]);
)

(
SynthDef(\fm_test, {|gate=1|
	var sig, osc, mod1, mod2, env;

	env = EnvGen.kr(Env.perc(\atk.kr(0.015),
		\rel.kr(2.0),
		curve:\curve.kr(-2)),
	gate: gate,
	doneAction: 2);

	osc = Saw.ar(\freq.kr(100))!2;
	mod1 = LFTri.ar(\freq.kr(100) * \modindex.kr(0.5), mul: \modamt.kr(1));

	osc = osc * 0.5 + (osc * mod1) * 0.5;
	sig = osc * env;
	//sig = LPF.ar(sig, \cutoff.kr(0.5));
	sig = sig * 0.3;
	sig = FreeVerb.ar(sig, 1.0,0.9,0.2);
	Out.ar(0, sig);

}).add;
)

(
p = Pbind(
	\type, \note,
	\instrument, \fm_test,
	\octave, Pwhite(2.0, 6.0, inf).round(1),
	\dur, Pseq([0.6, 0.15, 0.15, 1.2, 0.3].scramble, inf),
	\mtranspose, 2,
	\degree, Pseq([0,2,5,6,8,11,16].scramble, inf),
	\legato, Pfunc({rrand(0.01,1)}),
	\modindex, Pfunc{rrand(0.25, 10).round(0.25)},
	\modamt, Pfunc{rrand(0.1, 1)},
	\atk, Pwhite(0.25, 0.75, inf),
	\rel, Pwhite(0.25, 3.0, inf)
).play;
)