

function Track = generateTrack(N)
    % Inizializza la matrice con tutti zeri
    Track = zeros(N, N);
    
    % Punto di partenza: centro del lato sinistro
    x = round(N/2);
    y = 1;
    
    % Direzioni possibili: destra, su, giù
    % La pista seguirà un percorso con curve
    
    % Segmento 1: vai a destra per N/3 passi
    for i = 1:round(N/3)
        Track(x, y) = 1;
        y = y + 1;
    end
    
    % Curva: vai su per N/3 passi
    for i = 1:round(N/3)
        Track(x, y) = 1;
        x = x - 1;
    end
    
    % Segmento 2: vai a destra per N/3 passi
    for i = 1:round(N/3)
        Track(x, y) = 1;
        y = y + 1;
    end
    
    % Curva: vai giù per N/3 passi
    for i = 1:round(N/3)
        Track(x, y) = 1;
        x = x + 1;
    end
    
    % Segmento 3: vai a destra fino alla fine
    while y <= N
        Track(x, y) = 1;
        y = y + 1;
    end
end


N = 20;
Track = generateTrack(N);
imagesc(Track);
colormap([1 1 1; 0 0 0]); % bianco = 0, nero = 1
axis equal tight;
title('Pista');