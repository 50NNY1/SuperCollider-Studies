//SYNTH DEFINITION
(
SynthDef.new(\superSaw, {
	arg freq=40, detune = 0.02;
	var temp, sum;
	sum = 0;
	40.do{
		temp = VarSaw.ar(freq.lag(0.5) * {Rand(0,1).linlin(0,1,1-detune,1+detune)}!2,
						{Rand(0.0, 1.0)}!2,
			            {Rand(0.005,0.05)}!2
		);
		sum = sum + temp;
	};
	sum = sum * 0.2;
	Out.ar(0, sum);
}).add;
)

//create window and gui members
(
Window.closeAll;
w = Window.new(\app, Rect.new(800, 800, 300, 90));
w.front;
w.alwaysOnTop = true;

~slider = Slider.new(w.view, Rect.new(20, 20, 150, 30))
.action_({ //create listener
	arg obj; //interprets as gui object instance, represents slider here
	var sliderFreq;
	sliderFreq = obj.value.linexp(0,1,20, 20000);
	if(x.isPlaying)
	{x.set(\freq, sliderFreq)};
	sliderFreq.postln;
	~freqNumBox.value_(sliderFreq);
});

~button = Button.new(w, Rect(220,20,50,30)).states_([
	["Off", Color.black, Color.gray(0.8)],
	["On", Color.white, Color(0.2,0.75,0.95)];])
.action_({
	arg obj;
	if(obj.value == 1)
	{
		x = Synth.new(\superSaw,
			[\freq, ~slider.value(linexp(0, 1,20,20000)),
			\detune, ~knob.value
		]).register;
	}
	{x.free} // else statement here
});

~knob = Knob.new(w.view, Rect.new(180, 20, 30, 30))
.action_({
	arg obj;
	var knobDetune;
	knobDetune = obj.value;
	if(x.isPlaying)
	{x.set(\detune, knobDetune);
	};

});

~freqNumBox = NumberBox(w, Rect(20, 60, 30,20))
.value_(100)
.clipLo(20)
.clipHi(20000);
)

//LISTENERS
(
~knob
~slider.action_({ //create listener
	arg obj; //interprets as gui object instance, represents slider here
	var sliderFreq;
	sliderFreq = obj.value.linexp(0,1,20, 20000);
	if(x.isPlaying)
	{x.set(\freq, sliderFreq)};
	sliderFreq.postln;
	~freqNumBox.value_(sliderFreq);
});
~button;
)