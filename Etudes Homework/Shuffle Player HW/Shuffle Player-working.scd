(
~dirpath = "MySounds/*".resolveRelative;
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


        // Play slow section
	//	~slow.value;
		//~slownew.value;
		~checkAndClearServer.value;

        // Play slow section
		~fastnew.value;
        ~checkAndClearServer.value;

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

