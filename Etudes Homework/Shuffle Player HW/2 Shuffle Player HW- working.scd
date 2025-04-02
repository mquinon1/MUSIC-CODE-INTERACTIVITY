(
~dirpath = "MySounds/*".resolveRelative; //when you load up a folder, you gotta have the slash after it!
~filepaths = ~dirpath.pathMatch;
//~buffers = ~filepaths.collect { |path|  Buffer.read(s, path) };
~buffers = ~filepaths.collect { |path|  Buffer.readChannel(s, path, channels: [0]);};
~waitTime=0.1;

s.boot;

s.waitForBoot({
  ~np = NodeProxy.audio(s, 2);
  ~np.source = nil;
  ~np.play;
});


~checkAndClearServer = {
    // Check if we're getting close to the SynthDef limit
    var defCount = s.numSynthDefs;
    var maxDefs = s.options.maxSynthDefs;

    if(defCount > (maxDefs * 0.9)) { // If we're at 90% capacity
        "WARNING: SynthDef count high (%/%), clearing NodeProxy...".format(defCount, maxDefs).postln;
       ~np[2..1024]=nil;
        0.1.wait; // Give the server a moment to process the clearing
        "NodeProxy cleared.".postln;
        true
    } {
        false
    };
};



// Define the slow section
~slow = {
    "Playing slow section...".postln;
    20.do { |i|
        var buf = ~buffers.choose;
        ~np.add({
            Pan2.ar(
                PlayBuf.ar(buf.numChannels, buf.bufnum,
                    rate: (1..12).choose.midiratio,
                    doneAction: 2) * rrand(-40, 0).dbamp,
                Rand(-1.0, 1.0)
            )
        });
        (buf.duration/4).wait;
    };
};

// Define the speedy section
~fast = {
    "Playing speedy section...".postln;
    100.do { |i|
        var buf = ~buffers.choose;
        ~np.add({
            Pan2.ar(
                PlayBuf.ar(buf.numChannels, buf.bufnum,
                    rate: (3..9).choose.midiratio,
                    doneAction: 2) * rrand(-40, 0).dbamp,
                Rand(-1.0, 1.0)
            )
        });
        rrand(0.05, 0.3).wait;
    };
};


~fastnew = {
    "Playing modulated speedy section...".postln;
    200.do {
        var buf = ~buffers.choose;
     //   var modRate = SinOsc.kr(rrand(0.1, 1)).range(0.5, 1.5); // Slow modulation

        ~np.add({
            Pan2.ar(
                PlayBuf.ar(buf.numChannels, buf.bufnum,
                    rate: (3..9).choose.midiratio,
                    doneAction: 2
                ) * rrand(-70, 0).dbamp,
                Rand(-1.0, 1.0)
            )
        });

        rrand(0.05, 0.3).wait;
    };
};


~glitchy= {
        "Playing glitchy section...".postln;
        80.do { |i|
            var buf = ~buffers.choose;
            var rate = [-2, -1, 1, 2, 4].choose; //negative rates play backward. may result in some frames dropped. see earlier example for hack to fix
            var start = rrand(0, 0.4);
            ~np.add({
                Pan2.ar(
                    PlayBuf.ar(buf.numChannels, buf.bufnum,
                        rate: rate,
                        startPos: start * buf.numFrames,
                        doneAction: 2) * rrand(-30, -5).dbamp,
                    Rand(-1.0, 1.0)
                )
            });
            rrand(0.1, 0.4).wait;
        };
        "Glitchy section complete.".postln;
    }
;

~slendroglitchy={
        "Playing SLENDRO section...".postln;

	~slendro = Tuning.new(Tuning.calcET(5));
        100.do { |i|
		var buf = ~buffers.at(0);
            var start = rrand(0, 0.8);
			var tuningIndex = (0..~slendro.ratios.size-1).choose;  // Choose a random index from the 5-ET tuning
			var rate = ~slendro.ratios[tuningIndex];  // Use the ratio from your 5-ET tuning
		    var octaverate = [-2, -1, 1, 2, 4].choose; //negative rates play backward. may result in some frames dropped. see earlier example for hack to fix
			var amp = rrand(-40, 0).dbamp; //random dynamics
            ~np.add({
                Pan2.ar(
                    PlayBuf.ar(buf.numChannels, buf.bufnum,
                        rate: rate,
                        startPos: start * buf.numFrames,
                        doneAction: 2) * amp,
                    Rand(-1.0, 1.0)
                )
            });
        rrand(0.1, 0.4)*~waitTime.wait;
        };
        "SLENDRO section complete.".postln;
    };


// Sparse section with lower pitches
~sparse = {
    "Playing sparse section...".postln;
    30.do { |i|
        var buf = ~buffers.choose;
        ~np.add({
            Pan2.ar(
                PlayBuf.ar(buf.numChannels, buf.bufnum,
                    rate: [0.5, 0.25, 0.125].choose,
                    doneAction: 2) * rrand(-30, -10).dbamp,
                Rand(-1.0, 1.0)
            )
        });
        rrand(1.0, 2.5).wait;
    };
};


~slownew = { |rateMin = 1, rateMax = 10|
    inf.do { |i| //x.do is how long it runs
        var buf = ~buffers.choose;
        ~np.add({
            Pan2.ar(
                PlayBuf.ar(buf.numChannels, buf.bufnum,
					rate: rrand(rateMin, rateMax).midiratio,
                    doneAction: 2) * rrand(-40, 0).dbamp,
                Rand(-1.0, 1.0)
            )
        });
        (buf.duration/2).wait;
    };
};




// Create the looping task
~loopingTask = Task({
    inf.do { |cycle|
        "Starting cycle %...".format(cycle + 1).postln;

		   // Play slendroGLITCHY section
//		~sparse.value;

		 // Play slendroGLITCHY section
	//	~slendroglitchy.value;
        ~checkAndClearServer.value;

        // Play slow section
	//	~slow.value;
		~slownew.value;
		~checkAndClearServer.value;

        // Play slow section
	//	~fastnew.value;
        ~checkAndClearServer.value;

		// Play glitchy section
      //  ~glitchy.value;

        // Play fast section
       // ~fast.value;

        "Completed cycle %".format(cycle + 1).postln;
    };
});


// Simple controls
~start = { ~loopingTask.play; "Starting the loop...".postln; };
~stop = { ~loopingTask.stop; "Stopping the loop...".postln; };
)
// Show instructions
"SIMPLE CONTROLS:".postln;
"~start.value - Start the loop".postln;
"~stop.value - Stop the loop".postln;

~start.value
~stop.value
~waitTime=0.01
~np.source=nil  //run this in case your server overflows

