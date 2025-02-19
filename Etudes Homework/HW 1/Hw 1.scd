(
{
    var baseFreq = 200;
    var numFreqs = 40; // Reduced from 60 for better balance
    var vowel = Vowel(\a, \bass);
    var startFilterOrder = 3.0;
    var stopFilterOrders = [0.8, 0.60, 0.5, 0.20, 0.1];
    var freqs, evenFreqs, oddFreqs, amps, evenAmps, oddAmps, orders;
    var dur = 12;

    var evenAmpMod = SinOsc.kr(1).exprange(0.04, 1).sqrt;
    var oddAmpMod = SinOsc.kr(1, pi).exprange(0.04, 1).sqrt;

    var ampEnv = Env.linen(0.01, dur, 0.6).kr(doneAction: 2);


    // Generate even and odd harmonics
    evenFreqs = ((1, 3 .. numFreqs) * baseFreq);
    oddFreqs = ((2, 4 .. numFreqs) * baseFreq);

    // Dynamic filter order transitions
    orders = stopFilterOrders.collect { |stop, i|
        XLine.kr(startFilterOrder, stop, dur * (2 + (1.5 * i)/dur))
    };

    // Apply vowel amplitude shaping
    evenAmps = vowel.ampAt(evenFreqs, orders) * evenAmpMod;
    oddAmps = vowel.ampAt(oddFreqs, orders) * oddAmpMod;

    // Combine frequencies and amplitudes
    freqs = evenFreqs ++ oddFreqs;
    amps = (evenAmps ++ oddAmps).normalizeSum;

    // Output with a safer amplitude scaling
    DynKlang.ar(`[freqs, amps, nil]) * 0.05 * ampEnv;
}.play;
)
