%% 


    hInches = 8.5;
    wInches = 11;
    hNorm = .7;

    aspectRatio = hInches / wInches;

    bottomNorm = (1-hNorm)/2;
    wNorm = hNorm / aspectRatio;

    current_Units = get(0,'Units');
    set(0,'Units','pixels');
    d = get(0,'ScreenSize');
    screenWidthPixels = d(3); screenHeightPixels = d(4);
    screenAspectRatio = screenHeightPixels / screenWidthPixels;
    set(0,'Units', current_Units);

    set(gcf, 'Units', 'normalized');
    set(gcf,'Position', [.05, bottomNorm, wNorm*screenAspectRatio, hNorm]);


    set(gcf, 'PaperUnits', 'inches');


    papersize = get(gcf, 'PaperSize');


    width = 7.5;         % Initialize a variable for width.
    height = 10;          % Initialize a variable for height.


    left = (papersize(1)- width)/2;


    bottom = (papersize(2)- height)/2;


    myfiguresize = [left, bottom, width, height];
    set(gcf, 'PaperPosition', myfiguresize);

    %clf;
