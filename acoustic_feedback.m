%% MICROPHONE SPEAKER FEEDBACK AND THE ONSET OF SQUEAL
% Base MATLAB only. Run this script to reproduce all figures and results.
% The bandpass G(s) represents one dominant acoustic resonance.
clear; clc; close all;
projectDir = fileparts(mfilename('fullpath'));
if isempty(projectDir), projectDir = pwd; end
outDir = fullfile(projectDir,'results');
if ~exist(outDir,'dir'), mkdir(outDir); end
diary off;
logFile = fullfile(outDir,'matlab_execution.txt');
fid = fopen(logFile,'w'); fclose(fid); diary(logFile);
fprintf('MICROPHONE SPEAKER FEEDBACK STABILITY\n');
fprintf('MATLAB %s | %s\n', version, datestr(now,31));
f0 = 1000;                    % Dominant resonance in Hz
w0 = 2*pi*f0;                 % Resonance in rad/s
zeta = 0.02;                  % Damping of the open acoustic path
K = [0.98 1.00 1.02];         % Below, at, and above threshold
fs = 48000; T = 2;            % Sample rate and simulation duration
t = (0:1/fs:T)'; y0 = 1e-3;  % Small initial disturbance
Y = zeros(numel(t),3); E = Y; P = zeros(2,3);
sigma = zeros(1,3); err = sigma;
labels = {'Below threshold K = 0.98','Threshold K = 1.00', ...
          'Above threshold K = 1.02'};
colors = [0 0.35 0.65; 0.35 0.35 0.35; 0.8 0.15 0.12];
fprintf('G(s) = 2*zeta*w0*s / (s^2 + 2*zeta*w0*s + w0^2)\n');
fprintf('Positive feedback: e = r + K*y, H = G/(1-K*G)\n');
fprintf('Critical gain Kcrit = 1; f0 = %.0f Hz\n\n',f0);
for q = 1:3
    % Characteristic polynomial: s^2 + 2*zeta*w0*(1-K)*s + w0^2
    a = 2*zeta*w0*(1-K(q));
    P(:,q) = roots([1 a w0^2]);
    sigma(q) = -a/2;
    wd = sqrt(w0^2-sigma(q)^2);
    % Scaled state x = [y; ydot/w0] avoids poor numerical conditioning.
    A = [0 w0; -w0 -a];
    Phi = expm(A/fs);          % Exact sampled homogeneous state transition
    x = [y0; sigma(q)*y0/w0];
    for n = 1:numel(t)
        Y(n,q) = x(1);
        x = Phi*x;
    end
    E(:,q) = y0*exp(sigma(q)*t);
    exact = E(:,q).*cos(wd*t);
    err(q) = max(abs(Y(:,q)-exact))/max(E(:,q));
    assert(err(q) < 1e-8,'State simulation disagrees with exact solution.');
    assert(max(abs(polyval([1 a w0^2],P(:,q))))/w0^2 < 1e-12);
    fprintf('K=%.2f: poles = %+.6f +/- j%.6f 1/s\n', ...
        K(q),sigma(q),abs(imag(P(1,q))));
    fprintf('  f = %.6f Hz; envelope at 2 s = %.9f\n',wd/(2*pi),E(end,q));
    fprintf('  envelope change = %+.6f dB; relative error = %.3g\n', ...
        20*log10(E(end,q)/y0),err(q));
end
assert(sigma(1)<0 && abs(sigma(2))<1e-12 && sigma(3)>0);
set(groot,'defaultAxesFontSize',11,'defaultLineLineWidth',1.4);
% Figure 1: a genuine MATLAB figure export of the simulated time responses.
fig = figure('Theme','light','Color','w','Position',[80 80 1120 760]);
tiledlayout(3,1,'TileSpacing','compact');
for q=1:3
    nexttile; plot(t,Y(:,q),'Color',colors(q,:)); hold on;
    plot(t,E(:,q),'k--',t,-E(:,q),'k--','LineWidth',1);
    grid on; xlim([0 T]); ylabel('Amplitude (a.u.)'); title(labels{q});
end
xlabel('Time (s)'); sgtitle('Small disturbance response and amplitude envelopes');
exportgraphics(fig,fullfile(outDir,'01_time_responses.png'),'Resolution',180);
savefig(fig,fullfile(outDir,'01_time_responses.fig'));
% Figure 2: the requested volume-over-time comparison.
fig = figure('Theme','light','Color','w','Position',[100 100 1120 650]);
tiledlayout(1,2,'TileSpacing','compact'); nexttile;
for q=[1 3], semilogy(t,E(:,q),'Color',colors(q,:)); hold on; end
grid on; xlabel('Time (s)'); ylabel('Amplitude envelope (a.u.)');
title('Decay versus growth'); legend(labels{[1 3]},'Location','northwest');
nexttile;
for q=1:3
    plot(t,20*log10(E(:,q)/y0),'Color',colors(q,:)); hold on;
end
grid on; xlabel('Time (s)'); ylabel('Level change from initial value (dB)');
title('Relative level change');
legend(labels,'Location','northwest');
exportgraphics(fig,fullfile(outDir,'02_volume_comparison.png'),'Resolution',180);
savefig(fig,fullfile(outDir,'02_volume_comparison.fig'));
% Figure 3: positive-feedback pole trajectories, calculated without rlocus.
fig = figure('Theme','light','Color','w','Position',[120 120 1120 650]);
tiledlayout(1,2,'TileSpacing','compact');
ks = linspace(0.94,1.06,301); pr = zeros(2,numel(ks));
for n=1:numel(ks)
    pr(:,n)=roots([1 2*zeta*w0*(1-ks(n)) w0^2]);
end
for panel=1:2
    nexttile; hold on; grid on;
    plot(real(pr.'),imag(pr.'),'Color',[0.65 0.65 0.65]);
    for q=1:3
        plot(real(P(:,q)),imag(P(:,q)),'x','Color',colors(q,:), ...
            'MarkerSize',12,'LineWidth',2,'DisplayName',labels{q});
    end
    xline(0,'k--','Stability boundary','HandleVisibility','off');
    xlabel('Real part (1/s)'); ylabel('Imaginary part (rad/s)');
    xlim([-8 8]);
    if panel==1
        ylim([-7000 7000]); title('Closed loop poles in the s plane');
    else
        ylim([6283.183 6283.187]); title('Upper pole enlarged near the crossing');
        for q=1:3
            text(sigma(q),abs(imag(P(1,q)))+0.00025, ...
                sprintf('K=%.2f',K(q)),'HorizontalAlignment','center');
        end
    end
end
exportgraphics(fig,fullfile(outDir,'03_pole_locations.png'),'Resolution',180);
savefig(fig,fullfile(outDir,'03_pole_locations.fig'));
% Figure 4: pitch and resonance. One short trace resolves the oscillation.
fig = figure('Theme','light','Color','w','Position',[140 140 1120 650]);
tiledlayout(1,2,'TileSpacing','compact'); nexttile;
ix = t<=0.005;
plot(t(ix)*1000,Y(ix,3),'Color',colors(3,:)); grid on;
xlabel('Time (ms)'); ylabel('Amplitude (a.u.)'); title('Five cycles in five milliseconds');
nexttile; f=linspace(500,1500,5001); s=1i*2*pi*f;
G=(2*zeta*w0*s)./(s.^2+2*zeta*w0*s+w0^2);
for q=[1 3], plot(f,20*log10(abs(K(q)*G)),'Color',colors(q,:)); hold on; end
yline(0,'k--','Unity loop magnitude'); grid on;
xlabel('Frequency (Hz)'); ylabel('Loop magnitude (dB)');
title('Loop resonance near 1 kHz');
legend(labels{[1 3]},'Location','south');
exportgraphics(fig,fullfile(outDir,'04_pitch_and_resonance.png'),'Resolution',180);
savefig(fig,fullfile(outDir,'04_pitch_and_resonance.fig'));
results = table(K',sigma',abs(imag(P(1,:)))'/(2*pi),E(end,:)', ...
    (20*log10(E(end,:)/y0))',err', ...
    'VariableNames',{'K','PoleReal','FrequencyHz','FinalEnvelope','LevelChangeDB','RelativeError'});
writetable(results,fullfile(outDir,'summary.csv'));
save(fullfile(outDir,'simulation_data.mat'),'t','Y','E','P','K','f0','zeta','fs','results');
fprintf('\nVALIDATION PASSED: polynomial residuals, analytic solution, stability signs.\n');
fprintf('Results saved to %s\n',outDir);
fprintf('No audio is played. Amplitudes are arbitrary units, not measured SPL.\n');
diary off;
