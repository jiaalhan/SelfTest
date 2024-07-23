% 資料夾路徑
folder_path = 'E:\chh\for DIC 2\VIC\data\';

% 取得資料夾中的所有檔案名稱
file_list = dir(fullfile(folder_path, 'Cam-101-*.jpg')); % 假設檔案都是 .txt 格式

% 迴圈處理每個檔案
for i = 1:length(file_list)
    % 原始檔案名稱及完整路徑
    original_filename = file_list(i).name;
    original_fullpath = fullfile(folder_path, original_filename);
    
    % 刪除 '-202' 部分
    new_filename = strrep(original_filename, '-101', '');
    new_fullpath = fullfile(folder_path, new_filename);
    
    % 重新命名檔案
    movefile(original_fullpath, new_fullpath);
end

disp('所有檔案已重新命名。');
