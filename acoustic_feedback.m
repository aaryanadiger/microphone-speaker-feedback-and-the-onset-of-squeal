clc;
clear;
close all;

syms t s;
syms a w positive;
x1 = exp(-a*t)*cos(w*t);
x2 = exp(a*t)*cos(w*t);
L1 = laplace(x1,t,s);
L2 = laplace(x2,t,s);
disp('Laplace transform below threshold:'); display(L1);
disp('Laplace transform above threshold:'); display(L2);
y1 = ilaplace(L1,s,t);
y2 = ilaplace(L2,s,t);
disp('Inverse Laplace transforms:');
display(y1);
display(y2);

f0 = 1000;
w0 = 2*pi*f0;
b = 250;
A = 0.001;
K1 = input('Enter gain below threshold (example 0.98): ');
K2 = input('Enter gain above threshold (example 1.02): ');
if ~isnumeric(K1) || ~isscalar(K1) || ~isreal(K1) || ...
        ~isfinite(K1) || ~isnumeric(K2) || ~isscalar(K2) || ...
        ~isreal(K2) || ~isfinite(K2)
    disp('Enter one finite real number at each prompt and run again.');
    return;
end
if K1<=0 || K1>=1 || K2<=1 || K2>=1.1
    disp('Use 0 < K1 < 1 and 1 < K2 < 1.1 for this demonstration.');
    return;
end
label1 = ['Below threshold K = ',num2str(K1)];
label2 = ['Above threshold K = ',num2str(K2)];
a1 = b*(1-K1);
a2 = b*(1-K2);
r1 = -a1/2;
r2 = -a2/2;
w1 = sqrt(w0^2-r1^2);
w2 = sqrt(w0^2-r2^2);

t = 0:1/48000:2;
v1 = A*exp(r1*t);
v2 = A*exp(r2*t);
v0 = A*ones(size(t));
y1 = v1.*cos(w1*t);
y2 = v2.*cos(w2*t);
y0 = A*cos(w0*t);
figure('Theme','light');
subplot(3,1,1);
plot(t,y1,'b',t,v1,'k--',t,-v1,'k--');
title(label1); ylabel('Amplitude (a.u.)'); grid on;
subplot(3,1,2);
plot(t,y0,'k',t,v0,'k--',t,-v0,'k--');
title('Threshold K = 1.00'); ylabel('Amplitude (a.u.)'); grid on;
subplot(3,1,3);
plot(t,y2,'r',t,v2,'k--',t,-v2,'k--');
title(label2); ylabel('Amplitude (a.u.)'); grid on;
xlabel('Time (s)');
sgtitle('Small disturbance responses and amplitude envelopes');

figure('Theme','light');
subplot(1,2,1);
semilogy(t,v1,'b',t,v2,'r');
title('Decay versus growth'); xlabel('Time (s)');
ylabel('Amplitude envelope (a.u.)'); legend(label1,label2); grid on;
subplot(1,2,2);
plot(t,20*log10(v1/A),'b',t,20*log10(v0/A),'k',t,20*log10(v2/A),'r');
title('Relative level change'); xlabel('Time (s)');
ylabel('Level change from initial value (dB)');
legend(label1,'Threshold K = 1.00',label2); grid on;

num = [b 0];
H1 = tf(num,[1 a1 w0^2]);
H2 = tf(num,[1 a2 w0^2]);
p1 = pzmap(H1);
p2 = pzmap(H2);
p0 = [1i*w0; -1i*w0];
kg = linspace(K1,K2,101);
rg = -b*(1-kg)/2;
wg = sqrt(w0^2-rg.^2);
xr = 1.5*max(abs([r1 r2]));
figure('Theme','light');
for panel = 1:2
    subplot(1,2,panel);
    plot(rg,wg,'k-',rg,-wg,'k-'); hold on;
    plot(real(p1),imag(p1),'bx','MarkerSize',10);
    plot(real(p0),imag(p0),'kx','MarkerSize',10);
    plot(real(p2),imag(p2),'rx','MarkerSize',10);
    plot([0 0],[-7000 7000],'k--');
    xlim([-xr xr]); xlabel('Real part (1/s)');
    ylabel('Imaginary part (rad/s)'); grid on;
    if panel==1
        ylim([-7000 7000]); title('Closed loop poles in the s plane');
    else
        ylim([min([w1 w2])-0.001 w0+0.001]);
        title('Upper pole enlarged near the crossing');
        text(r1,w1+0.0002,['K = ',num2str(K1)]);
        text(0,w0+0.0002,'K = 1.00');
        text(r2,w2+0.0002,['K = ',num2str(K2)]);
    end
end

figure('Theme','light');
subplot(1,2,1);
ts = 0:1/48000:0.005;
ys = A*exp(r2*ts).*cos(w2*ts);
plot(ts*1000,ys,'r'); grid on;
title('Five cycles in five milliseconds');
xlabel('Time (ms)'); ylabel('Amplitude (a.u.)');
subplot(1,2,2);
f = 500:0.2:1500;
s = 1i*2*pi*f;
G = (b*s)./(s.^2+b*s+w0^2);
plot(f,20*log10(abs(K1*G)),'b',f,20*log10(abs(K2*G)),'r'); hold on;
plot([500 1500],[0 0],'k--'); grid on;
title('Loop resonance near 1 kHz');
xlabel('Frequency (Hz)'); ylabel('Loop magnitude (dB)');
legend(label1,label2,'Unity loop magnitude');

format short g;
disp('Poles below threshold:'); display(p1);
disp('Poles above threshold:'); display(p2);
if all(real(p1)<0)
    disp(['K = ',num2str(K1),': System is STABLE']);
else
    disp('Below-threshold system is not asymptotically stable');
end
if any(real(p2)>0)
    disp(['K = ',num2str(K2),': System is UNSTABLE']);
else
    disp('Check the chosen above-threshold gain');
end
fprintf('Envelope at 2 s: below = %.9f, above = %.9f\n', ...
    v1(end),v2(end));
fprintf('Level change: below = %.4f dB, above = %.4f dB\n', ...
    20*log10(v1(end)/A),20*log10(v2(end)/A));
fprintf('Oscillation frequency: %.6f Hz and %.6f Hz\n', ...
    w1/(2*pi),w2/(2*pi));
