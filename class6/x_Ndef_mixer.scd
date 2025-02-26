
//here's a simple synth engine programmed as an Ndef.
(
Ndef(\aaaaaa, { |freq=250, intv=19, timescale=1, curve=0, loopnode=0|
    var env = EnvGen.kr(
        Env({ 1.0.rand2 }!11, {1.0.rand}!10, curve, releaseNode: 9, loopNode: loopnode),
        timeScale: timescale);
    var pitch = (env * [1, 0.33, -1] * intv).midiratio * freq;
    Splay.ar(Formant.ar(pitch, pitch.scramble * 2, pitch.scramble)) * 0.1;
});
)
// you'll notice it looks nearly example like a synthdef.

//we can play it like one
x = Ndef(\aaaaaa).play

//and stop it
x.free

//but we also can easily assign it a gui!
x.gui
//currently all the controls are not useful values and we can adjust that...later.



//Ndef mixer is a neat way to keep track of all your cool synth machines.

(n = NdefMixer(s); //define the mixer
n.parent.alwaysOnTop_(true); // show mixer in front of IDE
s.boot;)

"bcdefghijk".do { |k| Ndef(k.asSymbol).ar };

// if you have JITLibExtensions installed, try ProxyMeter to see the proxy levels:
if (\ProxyMeter.asClass.notNil) { ProxyMeter.addMixer(n); };


//the three sizes define the main branch mixer, associated control proxies, and whatever arguments you built in as defaults or givens to your gui
n.switchSize(2);
n.switchSize(1);
n.switchSize(0);

n.switchSize(2);

//the arguments you defined with the straight brackets (pipes) will be present here!
n.editGui.object_(Ndef(\aaaaaa));

NdefMixer(Server.internal, 24);