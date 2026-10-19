# Microphone Speaker Feedback and the Onset of Squeal

This Signals and Systems mini project compares a fading tone below the feedback threshold with a growing squeal above it. It uses Laplace transforms, inverse Laplace transforms, and pole locations.

## Requirements

- MATLAB with Symbolic Math Toolbox and Control System Toolbox, matching the supplied Laplace laboratory example.
- No microphone, recording, or audio hardware is required. The program does not play sound.

## Run and input

1. Open `acoustic_feedback.m` and click **Run**.
2. In the Command Window, enter `0.98` at the below-threshold gain prompt and press Enter.
3. Enter `1.02` at the above-threshold gain prompt and press Enter.

The program accepts `0 < K1 < 1` and `1 < K2 < 1.1` to keep this demonstration near the threshold. These are demonstration input limits, not universal physical limits. Re-run the script to compare other gain pairs. The prompts take numbers, not audio files or microphone distances.

## Model

The assumed resonant path is `G(s) = b*s/(s^2 + b*s + w0^2)` with `b = 250` per second and `w0 = 2*pi*1000` rad/s. Positive feedback gives:

```text
H(s) = G(s)/(1 - K*G(s))
     = b*s/(s^2 + b*(1-K)*s + w0^2)
```

For the gains used here, set `r = -b*(1-K)/2` and `wd = sqrt(w0^2-r^2)`. The poles are `r +/- j*wd`. The free response from the chosen initial conditions is `y(t) = 0.001*exp(r*t)*cos(wd*t)`. Its peak amplitude envelope is `0.001*exp(r*t)`.

The waveform is the free response from a small initial disturbance; it is not the impulse response of H(s). Peak amplitude indicates the relative volume trend in arbitrary units, not measured sound pressure.

## Example results

| Gain | Pole real part | Envelope at 2 seconds | Behaviour |
| --- | --- | --- | --- |
| 0.98 | -2.5 per second | 0.00000673795 | Decays |
| 1.02 | +2.5 per second | 0.148413159 | Grows |

At `K = 1`, the poles lie on the imaginary axis. The free oscillation persists, but the system is not BIBO stable.

The program displays the transforms, four figures, the poles, and stability decisions. The four figures follow the original project layouts: three time responses, a two-panel volume comparison, a full and enlarged pole plot, and a pitch/resonance comparison. K = 1 is a fixed reference; it is not a third user input.

Relative levels use `20*log10(amplitude ratio)`. At 2 seconds the example level changes are -43.4294 dB and +43.4294 dB. These are changes from the initial amplitude, not calibrated sound pressure levels. The accompanying report contains the complete code, derivation, input instructions, constants, screenshots, results, and conclusions.

## Scope

The project follows elementary signals, LTI system interconnection, and Laplace analysis from the supplied course policy. The acoustic path and its numerical parameters are explicit modelling assumptions. It does not model propagation delay, room reflections, microphone distance, or amplifier clipping. Real hardware eventually limits the growth.
