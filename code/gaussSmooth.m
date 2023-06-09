function z = gaussSmooth(x,sig)
% z = gaussSmooth(x,sig)

    x = double(x(:))';

	% gaussin filter
	w = ceil(sig * 5);
    if w < 1
        w = 1;
    end
	t = -w : w;
    if sig == 0
        y = [0 1 0];
    else
        y = normpdf(t,0,sig);
    end
    
	sx = conv(x,y);
	
	% truncate smoothing results
	j = 1 + w : length(sx) - w;
	z = sx(j);
    
%     figure(1);
%     plot(z)
%     hold on;
% 	
	% fix edge effects
	v = ones(1,length(z));
	v = conv(v,y);
	v = v(j);
%     plot(v)
	z = z ./ v;
	

