# Datagottalen team 42
## Tiền Xử Lý: 
  ### Môi trường làm việc: Python
  ### File dữ liệu xử lý : Xử lý qua jupyter/annaconda 
  ### Quy trình tiền xử lý dữ liệu: 
    Tiền xử lý bằng python trên file jupyter:
      -- Sử dụng ngôn ngữ python và làm việc trên fie jupyter trên annaconda để thực hiện tiền xử lý dữ liệu từ bộ dữ liệu gốc mà ban tổ chức cung cấp. 
      -- Quá trình tiền xử lý bao gồm kiểm tra tính chính xác của các cột dữ liệu nhằm kiểm tra các dòng trùng, missing value, xem xét quan hệ giữa các cột và xem xét các trường hợp ngoại lệ. Kết quả thu được các điểm đáng chú ý sau:
      -- Dòng trùng: 
      Nhóm tác giả thực hiện kiểm tra các dòng dữ liệu có toàn bộ các cột trùng nhau, kết quả thu được cho thấy dữ liệu không chứa dòng trùng.
      -- Missing value:
      Dữ liệu có tồn tại missing value tại cột Cột “Age”. Tuy nhiên khi xét cột Age_Band thì nhận thấy khi cột “Age_Band” mang giá trị là “Unknown” thì cột “Age” sẽ là missing value. Vì vậy ta thực hiện điền missing value ở cột “Age” thành “Unknown”. 
      Dữ liệu có tồn tại missing value tại 4 hạng mục đặt cược. Điều này sẽ được giải thích rõ hơn ở phần trường hợp đặc biệt.
      -- Quan hệ giữa các cột:
      -- Dựa vào mô tả dữ liệu của doanh nghiệp cũng như kết quả kiểm tra thực tế trong bộ dữ liệu, có thể đưa ra các quan hệ giữa các cột của bộ dữ liệu như sau:
      (1) Total Turnover = Tổng 4 hạng mục đặt cược = Turnover = Tiền thật + Các hình thức ưu đãi (Tabtouch không chỉ cung cấp dịch vụ cược bằng tiền thật mà còn có các hình thức cược ưu đãi)
      (2) Dividend paid = Toàn bộ tiền thắng = Total Turnover + Số tiền nhà cái phải trả thêm
      (3) Gross margin = FOB Gross margin + Pari-mutuel Gross margin
          —> FOB Gross margin = Total Turnover (Fixed odd) - Dividend paid
          —> Pari-mutuel Gross margin được tính dựa trên tỉ lệ ăn chia cố định của nhà cái dựa trên tổng cược theo phương pháp cược pari-mutuel.
      -- Trường hợp đặc biệt:
      (1) Các giá trị âm tại FOB_RACING_TURNOVER và FOB_SPORT_TURNOVER là do các các lần đặt cược của khách hàng này trong riêng ngày hôm đó chỉ bao gồm Bonus Bet, không bao gồm các dạng đặt cược bằng tiền thật và các kiểu bonus khác.
      (2) Các missing value tượng trưng cho việc khách hàng không đặt cược tại hạng mục đó vào ngày hôm đó, còn giá trị 0 thể hiện việc khách hàng có đặt cược, nhưng có sử dụng Bonus Bet kèm với tiền thật gây ra việc turnover tích hợp theo ngày bằng 0, hoặc chỉ sử dụng các dạng bonus không tính trực tiếp vào Turnover.
      (3) Các dòng có total turnover <=0 nhưng Ticket>0 và/hoặc Dividend khác 0 là hệ quả của các giá trị 0 trong (2), với việc Total Turnover được tính toán bằng tổng các Turnover của 4 hạng mục. 
      (4) Các dòng có Dividend paid bé hơn 0 do khách hàng sử dụng các dạng bonus tính vào Turnover theo giá trị âm và không tính (giá trị 0). Dividend paid = Total Turnover + Số tiền nhà cái phải trả thêm =  Tiền thật + Các hình thức ưu đãi +  Số tiền nhà cái phải trả thêm. Do đó trong trường hợp tại lần cược đó người chơi thua (Số tiền nhà cái phải trả thêm = 0) và Tiền thật < Các hình thức ưu đãi tính giá trị âm trong Total Turnover thì Dividend paid bé hơn 0.




  ## Trực quan hóa và làm báo cáo :
  ### Môi trường làm việc : Tableau
    Sử dụng môi trường Tableau để trực quan hóa bộ dữ liệu đã qua xử lí. Bắt đầu việc với trực quan hóa nhân khẩu học của khách hàng, tiếp đến là trực quan tổng quát về việc đặt cược. Cuối cùng, nhóm trực quan tổng quát về doanh thu và đưa ra các phân tích. Các bước thực hiện như sau:
     -- Dashboard phân tích Nhân khẩu học:
      Biểu diễn những chỉ số cơ bản: 
      Tổng số khách hàng, Giới tính, Phân bố độ tuổi, Phân bổ địa lí (Bang)
      Biểu đồ cột chồng về phân bố độ tuổi theo giới tính, biểu đồ tròn về phân bổ theo bang.
     -- Dashboard tổng quan việc đặt cược:
      Biểu diễn những chỉ số: Tổng lượt đặt cược, Tổng số vé đặt cược, Lượng vé trung bình đặt cược.
      Biểu đồ cột tròn về lượt đặt cược theo loại.
      Biểu đồ tròn về số vé mua theo loại đặt cược.
      Biểu đồ Time Series về số lượt đặt cược.
      Biểu đồ Time Series về số lượt mua vé.
     -- Dashboard tổng quan về doanh thu
      Biểu diễn những chỉ số: Doanh thu cá cược tổng, Doanh thu cá cược trung bình.
      Biểu đồ tròn về doanh thu từng loại đặt cược.
      Biểu đồ Time Series về doanh thu theo từng loại đặt cược.
     
