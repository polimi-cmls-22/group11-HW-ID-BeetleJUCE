// SERIAL STUFF
(
s.boot;
SerialPort.devices;
)
// Remember to change the port
~port = SerialPort.new("COM4", 9600);

// Receive serial messages
(
~charArray = [ ];
~getValues = Routine.new(
	{ var ascii;
		{ascii = ~port.read.asAscii;
			if(ascii.isDecDigit,{~charArray =
				~charArray.add(ascii)});
			if(ascii == $d,{
				~val1=~charArray.collect(_.digit).convertDigits;
				~val1.postln;
				~charArray = [ ];

				// Map distances to midi note
				if((~val1>0) && (~val1<=10),   {~note=45;});
				if((~val1>10) && (~val1<=20), {~note=47;});
				if((~val1>20) && (~val1<=30), {~note=48;});
				if((~val1>30) && (~val1<=40), {~note=52;});
				if(~val1>40,                                {~note=53;});

			});
			if(ascii == $p,{
				~val2=~charArray.collect(_.digit).convertDigits;
				~val2.postln;
				~charArray = [ ];
			});
	}.loop;}
).play;)

// INITIALIZATION
(
SynthDef(\wetSynth, {
	arg freq, amp=0.5, t_gate = 1, dur = 1.5;
	var sig, sig2, hpf_sig, out;

	sig = Mix.ar(LFPulse.ar(freq * [0.99, 1, 1.01]));
	sig2 = PinkNoise.ar(mul: 1.5, add: 0.0);
    hpf_sig = HPF.ar(sig+sig2, 200);


    out = hpf_sig + BPF.ar(sig+sig2, 500, 5);

	a = EnvGen.kr(Env.asr(0.01,1,dur), gate:t_gate);
	Out.ar(0, Pan2.ar(out*a*amp, 0, 0.5));

}).add;

SynthDef(\drySynth, {
		arg freq=220, amp=1, t_gate = 1;
		var freqBase=freq;
		var freqRes=SinOsc.kr(Rand(0,0.2),0).range(freqBase/2,freqBase*2);
		var pdbase=Impulse.ar(freqBase);
		var pd=Phasor.ar(pdbase,2*pi*freqBase/s.sampleRate,0,2pi);
		var pdres=Phasor.ar(pdbase,2*pi*freqRes/s.sampleRate,0,2pi);
		var pdi=LinLin.ar((2pi-pd).max(0),0,2pi,0,1);
		var snd=Lag.ar(SinOsc.ar(0,pdres)*pdi,1/freqBase).dup;
		snd=Splay.ar(snd);
		snd=snd*EnvGen.ar(Env.perc(0.005,1.5), gate:t_gate);
		Out.ar(0,snd*amp);
	}).add;

~t =Synth(\wetSynth,[\freq,45.midicps]);
~n =Synth(\drySynth,[\freq,40.midicps]);

)

// PLAY AND COMMUNICATE
(
// Initialize network (localhost)
~out_address = NetAddr("127.0.0.1",12000);

// Communicate raw distance values to Processing
~controlDist = Routine.new({ {
	~out_address.sendMsg("/distance", ~val1);
	(1/60).wait;
}.loop;}
).play;

// Trigger pulsating sphere
~controlBpm = Routine.new({ {
	~out_address.sendMsg("/trigger0", 1);
	(60/ ~val2).wait;
}.loop;}
).play;

// Sequence 1
~control1 = Routine.new({ {
	3.do{
		~t.set(\freq, ~note.midicps, \t_gate, 1);
		~out_address.sendMsg("/trigger1", 1);  // Trigger Cube object in Processing
		0.3.wait;
	};
	((3*60)/~val2).wait;
}.loop;}
).play;

// Sequence 2
~control2 = Routine.new({ {
	~n.set(\freq, 40.midicps, \t_gate, 1);
	~out_address.sendMsg("/trigger2", 1); // Trigger Sphere object in Processing
	0.3.wait;
	~n.set(\freq, 40.midicps, \t_gate, 1);
	~out_address.sendMsg("/trigger2", 1);
	0.3.wait;
	~n.set(\freq, 44.midicps, \t_gate, 1);
	~out_address.sendMsg("/trigger2", 1);
	0.3.wait;
	~n.set(\freq, 47.midicps, \t_gate, 1);
	~out_address.sendMsg("/trigger2", 1);
	0.3.wait;
	~n.set(\freq, 44.midicps, \t_gate, 1);
	~out_address.sendMsg("/trigger2", 1);
	0.3.wait;
	((5*60)/~val2).wait;
}.loop;}
).play;
)

// Stop communications and routines
SerialPort.closeAll;
(
~controlDist.stop;
~controlBpm.stop;
~control1.stop;
~control2.stop;
)