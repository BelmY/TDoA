## -*- octave -*-

function tdoa=tdoa_plot_dt(input, tdoa, plot_info, dt)
  figure(2, 'position', [200,200, 900,600]);
  colormap('default');

  bin_width = 0.25/12001;

  n = length(input);
  for i=1:n
    for j=i+1:n
      tic;
      subplot(n-1,n-1, (n-1)*(i-1)+j-1);
      ny   = length(tdoa(i,j).t);
      tmm  = [min(tdoa(i,j).t{1}) max(tdoa(i,j).t{1})];
      nx   = round(diff(tmm)/bin_width);
      bins = tmm(1)+bin_width*(0.5+[0:nx-1]);
      a    = zeros(ny,nx);
      for k=1:ny
        a(k,:)  = interp1(tdoa(i,j).t{k}, abs(tdoa(i,j).r{k}), bins);
        a(k,:) /= max(abs(a(k,:)));
      end
      tdoa(i,j).bins = bins;
      imagesc(1e3*bins, tdoa(i,j).gpssec, a);
      ylabel('GPS seconds');
      xlabel('dt (msec)');
      title(sprintf('%s-%s', input(i).name, input(j).name));
      [m,k] = max(mean(a));
      t0    = 1e3*bins(k);
      xlim(t0+1e3*dt*[-1 1]);
      if isfield(tdoa(i,j), 'time_cut')
        line(t0+1e3*dt*[-1 1], tdoa(i,j).time_cut(1), 'color', 'red', 'linewidth', 0.2);
        line(t0+1e3*dt*[-1 1], tdoa(i,j).time_cut(2), 'color', 'red', 'linewidth', 0.2);
      end
      set(gca, 'fontsize', 6);
      tdoa(i,j).a = a;

      hold on;
      b = tdoa(i,j).lags_filter;
      plot(1e3*tdoa(i,j).lags,    tdoa(i,j).gpssec,    '*', 'markeredgecolor', 0.85*[1 1 1]);##, 'markersize', 0.1, 'markerfacecolor', 'none');
      plot(1e3*tdoa(i,j).lags,    tdoa(i,j).gpssec,    '*', 'markeredgecolor', 0.85*[1 1 1]);##, 'markersize', 0.1, 'markerfacecolor', 'none');
      plot(1e3*tdoa(i,j).lags(b), tdoa(i,j).gpssec(b), '*r');#, 'markersize', 0.1, 'markerfacecolor', 'none');
      plot(1e3*tdoa(i,j).lags(b), tdoa(i,j).gpssec(b), '*r');#, 'markersize', 0.1, 'markerfacecolor', 'none');
      hold off;
      printf('tdoa_plot_dt(%d,%d) %.2f sec\n', i,j, toc());
    end
  end
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0  1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 0.98,  plot_info.title, 'fontweight', 'bold', 'horizontalalignment', 'center', 'fontsize', 15);

  print('-dpng','-S900,600', sprintf('png/%s_dt.png', plot_info.plotname));
  print('-dpdf','-S900,600', sprintf('pdf/%s_dt.pdf', plot_info.plotname));
endfunction

