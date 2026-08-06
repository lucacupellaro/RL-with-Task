function Track = generateTrack(N)
    Track = zeros(N, N);
    width = 3;
    seg   = round(N/3);

    % helper: dipinge un blocco pieno width x width con angolo in (x, y)
    function paintBlock(x, y)
        for dx = 0:width-1
            for dy = 0:width-1
                xx = x + dx;
                yy = y + dy;
                if xx >= 1 && xx <= N && yy >= 1 && yy <= N
                    Track(xx, yy) = 1;
                end
            end
        end
    end

    x = round(N/2);
    y = 1;

    % Segmento 1: destra
    for i = 1:seg
        paintBlock(x, y); y = y + 1;
    end
    y = y - 1;

    % Curva su
    for i = 1:seg
        paintBlock(x, y); x = x - 1;
    end
    x = x + 1;

    % Segmento 2: destra
    for i = 1:seg
        paintBlock(x, y); y = y + 1;
    end
    y = y - 1;

    % Curva giu
    for i = 1:seg
        paintBlock(x, y); x = x + 1;
    end
    x = x - 1;

    % Segmento finale: destra fino alla fine
    while y <= N
        paintBlock(x, y); y = y + 1;
    end
end