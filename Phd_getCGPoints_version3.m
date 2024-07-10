% -------------------------------------------------------------------------------
% Chia-Han Hu | National Taiwan University | 20240423
% -------------------------------------------------------------------------------
function [imagePoints, ImageUsed, imgNoUsed] = Phd_getCGPoints_version3(CBimagesInfo)
imagePoints = zeros(108, 2, size(CBimagesInfo.I, 4));
ImageUsed=[];
imgNoUsed=[];
for i = 1:size(CBimagesInfo.I,4)
    img = CBimagesInfo.I(:,:,:,i);   % RBG
    % img =imadjust(CBimagesInfo.I(:,:,:,i),[0.01 0.3],[]);
    figure('Name','Waiting for Drawing ROI...','NumberTitle','off'); imshow(img);hold on;
    title(['Image',sprintf('%d',i)],'FontSize',15)
    h = drawpolygon('label','roi');
    mask = createMask(h);
    cutImage = img;
    cutImage(repmat(~mask, [1 1 size(img, 3)])) = 0;
    figure('Name','Detect White Circle...','NumberTitle','off'); imshow(cutImage);
    title(['Image',sprintf('%d',i)],'FontSize',15);
    %% Find White Circle
    [w_centers, w_radii] = imfindcircles(cutImage, [3 20],'EdgeThreshold',0.1, 'ObjectPolarity', 'bright'); % Decrease the request for the Edge & Circle size
    try 
        if  size(w_centers,1)>3
            try
                % 邊緣模糊的圓形被辨識，或是距離相近的圓心被辨識
                tolerance = 5.0;
                % Number of points and initial keep vector
                nPoints = size(w_centers, 1);
                keep = true(nPoints, 1);
                % Filter points based on closeness
                for j = 1:nPoints
                    for k = j + 1:nPoints
                        if keep(k) && keep(j)
                            distance = norm(w_centers(j,:) - w_centers(k,:));
                            if distance < tolerance
                                keep(k) = false;
                            end
                        end
                    end
                end
                % Apply the filter to both centers and radii
                w_centers = w_centers(keep, :);
                w_radii = w_radii(keep);
                % Ensure only three points are kept
                if size(w_centers, 1) == 3  
                    john = 0;
                    disp(['Get ',  num2str(size(w_centers,1)), ' points in Image ', num2str(i)])
                    ImageUsed(i) = i ;
                    if  isnan(john)
                        message = sprintf('Error');
                        warning(message);
                    end
                elseif size(w_centers, 1) > 3
                    try
                        k = 3; % 設分為3個聚集
                        [idx, ~] = kmeans(w_radii, k);
                        clusterSizes = arrayfun(@(x) sum(idx == x), 1:k);
                        [~, outlierCluster] = min(clusterSizes);
                        outlierIndices = idx == outlierCluster;
                        nonOutlierIndices = ~outlierIndices;
                        w_centers = w_centers(nonOutlierIndices,:);
                        w_radii = w_radii(nonOutlierIndices);
                        ImageUsed(i) = i ;
                    catch
                        error(['Warning: ', num2str(size(w_radii,1)),' points' ,'; Image Num: ', num2str(i)])                        
                    end
                end
            catch
                disp(['Skip image ', num2str(i)])
                imgNoUsed(i) = i;
                continue;
            end
        elseif size(w_centers,1) == 3
            % Double-Check Circle Found 
            differences = abs(diff(w_radii));
            hasLargeGaps = any(differences > 2);  % tolerance setting issue @@
            if hasLargeGaps
                [w_centers, w_radii] = imfindcircles(cutImage, [2 25],'EdgeThreshold',0.6, 'ObjectPolarity', 'bright');  
            else
                ImageUsed(i) = i;
                disp(['Correct: ', num2str(size(w_centers,1)),' points' ,'; Image Num: ', num2str(i)])
            end
        elseif size(w_centers, 1) < 3
            [w_centers, w_radii] = imfindcircles(cutImage, [2 25],'EdgeThreshold',0.3, 'ObjectPolarity', 'bright'); %
            if size(w_centers, 1) == 3
                john = 0;
                disp(['Get ',  num2str(size(w_centers,1)), ' points in Image ', num2str(i)])
                ImageUsed(i) = i ;
                if  isnan(john)
                    message = sprintf('Error');
                    warning(message);
                end
            end
        else
            error(['Wrong: ', num2str(size(w_centers,1)),'; Image Num: ', num2str(i)])
        end
    catch
        disp(['Skip image ', num2str(i) ,', Number of whitePoint = ', num2str(size(w_centers,1))])
        imgNoUsed(i) = i;
        continue;
    end
%     disp(['Correct: ', num2str(size(w_radii,1)),' points' ,'; Image Num: ', num2str(i)])
    input('Press Enter to close all figures and continue... ', 's'); % close all;
    % Arrange 由小排到大sortrows(a, [column1 column 2]),  [優先考慮1, 優先考慮2]
    % idx紀錄原本所在位置給的label，重新排列後順序
    [~, sortIdx] = sortrows(w_centers, [2 1]);
    centersSorted = w_centers(sortIdx, :);
    radiiSorted = w_radii(sortIdx);
    viscircles(centersSorted, radiiSorted, 'EdgeColor','magenta');    %
    x1 = centersSorted; % close all
    %% Find black circle
%     figure;imshow(cutImage)
    [b_centers, b_radii] = imfindcircles(cutImage, [5 20], 'ObjectPolarity','dark');  % [5 15]
    try 
      if size(b_centers,1) ~= 108
          figure('Name','Waiting for Drawing ROI...','NumberTitle','off'); imshow(img)
          title(['Image',sprintf('%d',i)],'FontSize',15)
          m = drawpolygon('Label','roi') ;
          position = h.Position;
          roi = [position(1) position(2) position(3) position(4)];
          I = img(roi(2):(roi(2)+roi(4)), roi(1):(roi(1)+roi(3)));
          figure('Name','Detect White Circle...','NumberTitle','off'); imshow(I)
          title(['Image',sprintf('%d',i)],'FontSize',15);
      end
      if size(b_centers,1) == 108
          [~, b_sortIdx] = sortrows(b_centers, [2 1]);
          b_centersSorted = b_centers(b_sortIdx, :);
          b_radiiSorted = b_radii(b_sortIdx);
          viscircles(b_centersSorted, b_radiiSorted, 'EdgeColor','b');   %
          y1= b_centersSorted;  %
%           figure('Name','Detect Black Circle...','NumberTitle','off'); imshow(cutImage); hold on;
%           viscircles(y1, b_radiiSorted, 'EdgeColor','r');   %
%           for j = 1:size(b_centersSorted, 1)
%               text(y1(j,1), y1(j,2), sprintf('%d', j), ...
%                   'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
%                   'FontSize', 15, 'Color', 'k','FontWeight','bold');
%           end
          input('Press Enter to close all figures and continue... ', 's'); % close all;
          c1 = zeros(108,2);
          [right_top_neighbors] = gridnumbering(y1, x1);
          for m = 1:size(b_centersSorted,1)
              c1(right_top_neighbors(m).new_label,:) =  y1(m,:);
          end
          imagePoints(:,:,i) = c1;   %%
          if find(imagePoints(:,:,i)==0)
              error('No BlackPoints')
          else
              ImageUsed(i) = i;
              figure; imshow(img);
              for j = 1:size(b_centersSorted, 1)
                  text(imagePoints(j,1,i), imagePoints(j,2,i), sprintf('%d', j), ...
                      'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
                      'FontSize', 15, 'Color', 'g','FontWeight','bold'); hold on;
                  plot(imagePoints(j,1,i), imagePoints(j,2,i),'g+')
              end
              input('Press Enter to close all figures and continue... ', 's'); close all;
              fprintf('Finished: Img %d !',i)
          end 
      end
    catch
        disp(['Skip image ', num2str(i) ,', Number of whitePoint = ', num2str(size(w_centers,1))])
        imgNoUsed(i) = i;
    end
end
end