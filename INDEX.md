sql explain type:

- all: cho biết toàn bột truy vấn được thực hiện, hoặc chỉ mục không hợp lệ
- system: cho biết chỉ 1 phần dữ liệu trong bảng được truy vấn
- const: truy sql có thể được thực hiện trong các điều kiện truy vấn của câu
  lệnh hiện tại.
- range: phạm vi truy vấn được tìm kiếm trong phạm vi nhât định, trong khoảng
  thời gian nhất định.
- ref: truy vấn chỉ mục thông thường hiện đang được sử dụng.
- index: chỉ mục phụ đang được sử dụng .
