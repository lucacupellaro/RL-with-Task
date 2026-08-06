
function r = generateStartCoordinates(track)
    col1    = track(:, 1);
    indices = find(col1 == 1);
    if isempty(indices)
        error('Nessuna cella di partenza trovata nella colonna 1!');
    end
    r = indices(randi(length(indices)));
end
        


        