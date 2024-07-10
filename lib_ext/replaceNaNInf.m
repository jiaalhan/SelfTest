function replacedCell = replaceNaNInf(cellArray)

replacedCell = cell(size(cellArray));

for i = 1:numel(cellArray)
  
    currentMatrix = cellArray{i};
    if any(isnan(currentMatrix(:))) || any(isinf(currentMatrix(:)))
      
        replacedMatrix = currentMatrix;
        
        for j = 1:numel(currentMatrix)
            
            if isnan(currentMatrix(j)) || isinf(currentMatrix(j))
                
                neighbors = currentMatrix(max(1,j-1):min(numel(currentMatrix),j+1));
                neighbors(isnan(neighbors) | isinf(neighbors)) = [];
                
                if isempty(neighbors)
                    replacedMatrix(j) = 0;
                
                else
                    replacedMatrix(j) = mean(neighbors);
                end
            end
        end

        replacedCell{i} = replacedMatrix;
    
    else
        replacedCell{i} = currentMatrix;
    end
end

end