function line_up_and_plot(data_in,Plot_title)


single_line = reshape(data_in,1,[]);

figure('Name',Plot_title)
subplot(1,3,1)
imagesc(data_in)
colormap(gray)
title('Fids in a Block')
subplot(1,3,2)
plot(single_line)
title('All Fids back-to-back')
subplot(1,3,3)
qq_gauss_noise(single_line);
title('QQ Plot')
