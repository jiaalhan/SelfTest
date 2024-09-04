## About me
本程式碼為相機校正內\外部參數取得，影像校正(去扭曲)指引

Set Path工具包: lib_MultiDIC | lib_ext | GIBBON


# STEP1_Phd_getCaliDone
透過拍攝CircleGrid Board進行單台相機的扭曲校正。Run 程式後，按照跳出的視窗進行分析，資料夾選擇要注意的是要將兩台相機的folder一同選取並按Add後，會出現在右邊方框中，確認資料夾無誤後，選擇done! 

![image](https://github.com/user-attachments/assets/ae0c02bb-ade5-4a7c-9ad2-4e69b7561a10)

接著，會跳出是否要儲存校正參數，選擇YES。 再來，會跳出輸入Input的參數，根據CircleGrid Board資訊輸入。

![image](https://github.com/user-attachments/assets/e4708b4f-43f7-40b6-9aed-6b2f68bd3886)

後續會跳出需要計算哪些變數，基本上此視窗不需要更改參數，按OK即可。

![image](https://github.com/user-attachments/assets/d0082138-262f-4e58-931a-6a41b2c11cad)


圈選ROI，使影像mask之後減少偵測錯誤
![image](https://github.com/user-attachments/assets/ee1ae93f-1984-4067-84a9-bf786a5f597e)

偵測影像中圓點座標點，檢查圓點編號是否按照順序排列
![image](https://github.com/user-attachments/assets/c445780f-cd1e-4755-9dfc-47a00500f77e)


StereoCalibration_ Phd_getcalibrateTwoCameras
透過拍攝CircleGrid Board進行兩台或兩台以上相機的校正，可以透過此步驟得到的校正結果得知兩台相機之間的關係。要注意的是，此步驟所使用的影像需為undistorted的。因此在讀取檔案時，要選取上個步驟所校正完輸出的影像。

![image](https://github.com/user-attachments/assets/5911f1f3-fdfa-4a67-b97d-54c2874a6553)
![image](https://github.com/user-attachments/assets/58ff602a-63f3-4956-9aba-929dd886f8b3)





Phd_getCGParameters: 基於MATLAB function 計算相機內部參數.

Phd_getCGPoints_version3: 偵測校正版圓點座標.

Phd_getcalibrateTwoCameras: 雙相機立體校正，重建空間中相機相對位置.


