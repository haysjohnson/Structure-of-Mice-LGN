function c = dco(x)
    x = mod(x-1,7) + 1;
    ax = gca;
    ax.ColorOrderIndex = x;
    c = ax.ColorOrder(x,:);
end

