---
title: Control Panel
description: Sử dụng các thẻ bảng điều khiển Quickshell.
---

Bảng Điều Khiển là giao diện Quickshell truy cập nhanh cho phiên làm việc đang hoạt động. Đây là nơi để kiểm tra trạng thái hoặc thực hiện một hành động thường xuyên mà không cần mở toàn bộ ứng dụng cài đặt.

Bảng điều khiển sử dụng các danh mục `argvus-i18n` chia sẻ. Khi ngôn ngữ khác được áp dụng trong **Trung tâm điều khiển → Ngôn ngữ & Vùng**, dịch vụ Bảng điều khiển sẽ tự động khởi động lại để tải danh mục được chọn.

Bảng điều khiển chia sẻ cạnh thanh tác vụ với ARGVUS Focus và ARGVUS Clock. Mở bảng điều khiển sẽ đóng cả hai cửa sổ bật lên trước; mở Focus hoặc Clock sẽ đóng bảng điều khiển.

## Bảng điều khiển hay Trung tâm điều khiển?


## Cards

Sổ đăng ký thẻ hiện tại bao gồm:

- User;
- Notifications;
- Calendar;
- Weather;
- Volume;
- Brightness;
- Network;
- Bluetooth;
- System;
- Appearance;
- Session;
- Display;
- Power.

Một số thẻ có điều kiện. Bluetooth bị ẩn khi tính năng Bluetooth không khả dụng. Độ sáng bị ẩn khi cả đèn nền được hỗ trợ và công cụ điều khiển màn hình đều không có sẵn. Do đó, danh sách thẻ phản ánh máy hiện tại thay vì hứa hẹn các điều khiển mà mọi máy đều có thể cung cấp.

## Khả năng hiển thị và thứ tự

Trang **Appearance → Control Panel** của bảng điều khiển cho phép bạn bật, tắt và sắp xếp lại các thẻ. Trợ giúp đóng gói cũng cung cấp cùng trạng thái này:

```sh
cards-config.sh status
cards-config.sh set <card> enabled
cards-config.sh set <card> disabled
cards-config.sh move <card> <index>
```

Sử dụng giao diện khi có thể. Trạng thái của bảng điều khiển được lưu dưới dạng cấu hình người dùng; nó tách biệt với các tệp bố cục Hyprland được tạo ra.

Vô hiệu hóa một thẻ sẽ ẩn nó khỏi bảng điều khiển; nó không gỡ cài đặt nhà cung cấp phía sau thẻ đó. Sắp xếp lại thay đổi thứ tự mà các thẻ được trình bày. Không có lệnh phụ `reset` trong trình trợ giúp hiện tại. Nếu sở thích thẻ của người dùng bị xóa, nhà cung cấp sẽ chuẩn hóa trạng thái trở lại các thẻ đã biết, được kích hoạt theo mặc định và theo thứ tự đóng gói.

Thẻ giao diện Bảng điều khiển không còn quản lý cài đặt Độ trong suốt toàn cục. Cấu hình Độ trong suốt và Làm mờ riêng biệt cho Bảng điều khiển trong **Trung tâm điều khiển → Giao diện → Bảng điều khiển**. Công tắc chính **Bật** của Bảng điều khiển vẫn kiểm soát toàn bộ bề mặt và dịch vụ của nó. `cards-config.sh master set` chỉ khởi động lại hoặc dừng bảng khi công tắc thay đổi; đặt giá trị mà nó đã có chỉ đảm bảo một bảng điều khiển đang bật hoạt động.

## Điều hướng bàn phím

Khi bảng mở ra, sử dụng **↑/↓** để cuộn nội dung của nó. **Tab** di chuyển tiến qua các nút, điều khiển và trường; **Shift+Tab** di chuyển lùi. Các nút hiển thị điểm tập trung bằng viền nổi bật và có thể được kích hoạt bằng **Enter** hoặc **Space**. Thanh trượt và các trường văn bản giữ các phím đó để điều chỉnh hoặc chỉnh sửa riêng của chúng. **Esc** đóng bảng.

## Giữ đồng bộ với phần còn lại của desktop

Thẻ Thông báo ẩn lịch sử của nó khi chế độ Không làm phiền đang hoạt động. Các thông báo nhận được trong thời gian đó vẫn nằm trong Dunst và xuất hiện trở lại trên thẻ sau khi chế độ Không làm phiền được tắt.

Các thẻ hiển thị trạng thái trực tiếp của màn hình. Một thay đổi được thực hiện ở nơi khác (Trung tâm điều khiển, thanh tác vụ, phím tắt bàn phím hoặc dòng lệnh `argvus`) sẽ hiển thị trong bảng mà không cần khởi động lại nó:

| Thẻ | Nguồn gốc trạng thái | Khi nào làm mới |
| --- | --- | --- |
| User | `getent passwd` | every 3 s while the panel is open |
| Âm lượng | đầu ra mặc định của PipeWire (`wpctl`) and `pactl subscribe`sự kiện | ngay lập tức trên mỗi sự kiện âm thanh; mỗi 2 giây như một biện pháp an toàn |
| Giao diện (Dữ liệu viễn thám, Hoạt hình và Hiệu ứng) | cái`/effects`phần của`argvus config`| mỗi 2 giây trong khi bảng điều khiển mở |
| Power | `powerprofilesctl` | every 3 s while the panel is open |
| Thời tiết | tệp vị trí và các nhà cung cấp wttr.in/Open-Meteo | khi bảng mở và mỗi 15 phút; các tab chuyển giữa điều kiện hiện tại và dự báo hàng ngày cho bảy ngày tới |

Thẻ Giao diện có hai công tắc độc lập. **Hoạt ảnh** chạy `argvus effects-toggle animations toggle` và điều khiển mọi thứ chuyển động. **Hiệu ứng** chạy `argvus effects-toggle effects toggle` và bật tắt mờ và độ trong suốt của Terminal, Launcher, Widget Telemetry, Control Panel và Taskbar cùng nhau; nó hiển thị là bật khi ít nhất một trong số chúng đang bật. **SUPER + F6** (`argvus effects-toggle toggle`) bật tắt cả hai cùng nhau. Thay đổi bất kỳ cái nào sẽ tải lại Hyprland và các thành phần giao diện ngay lập tức: Waybar đọc lại các bảng kiểu của nó, panel tải lại qua IPC và Dunst tải lại cấu hình trừ khi chế độ Không Làm Phiền đang hoạt động, trong trường hợp đó việc tải lại của nó sẽ bị hoãn cho đến khi tắt DND. Không có gì bị khởi động lại và không có màn hình tải nào xuất hiện.

Cuộn trên biểu tượng âm lượng thanh tác vụ và các phím phương tiện sử dụng `argvus config audio`, điều này áp dụng thay đổi cho PipeWire và cũng ghi lại âm lượng trong `/audio`. Do đó, tải lại cấu hình sẽ không khôi phục âm lượng cũ.

## Hành vi phiên

 is started by `argvus-control-panel.service` `argvus-session` . Opening and closing the panel changes the session panel state, but does not mean that every card action is persistent configuration. Network, audio, power and display actions may be handed to their providers or to the current desktop session.

See taskbar and panels for the relationship between the panel, taskbar margins and window layout.

## Đèn ban đêm

Thẻ Hiển thị cho thấy công tắc Bật/Tắt Đèn ban đêm và nhiệt độ đang hoạt động. Các góc và hoạt ảnh của nó tuân theo cùng một chủ đề với các công tắc bảng điều khiển khác, bao gồm bố cục Dính và Cách đều. Công tắc không có viền và sử dụng con trỏ hình bàn tay chỉ, giống như các công tắc bảng điều khiển khác. Nó sử dụng `argvus config display night-light status|toggle`, lấy dữ liệu mỗi hai giây khi mở và lấy lại sau mỗi hành động. Dòng này bị ẩn khi backend không khả dụng; một hành động thất bại sẽ hiển thị lỗi. Lập lịch và nhiệt độ được cấu hình trong **Trung tâm điều khiển > Máy tính để bàn & Nhập liệu > Hiển thị > Đèn ban đêm**. Một lần chuyển đổi thủ công theo lịch kéo dài đến khi chuyển tiếp tiếp theo; nếu không thì việc kích hoạt sẽ duy trì.

Thanh tác vụ lịch, ARGVUS Focus, ARGVUS Clock và Bảng Điều khiển không thể mở cùng lúc: mở cái này sẽ đóng các cái khác.

## Nhãn ngôn ngữ đa ngắn gọn

Các tab thời tiết sử dụng danh mục chung (tình trạng hiện tại và bảy ngày). Thời tiết
Các phép đo chiếm các cột bằng nhau; nhãn được xuống dòng và giá trị vẫn căn chỉnh.
Viết tắt các ngày trong tuần trên lịch là theo từng địa phương và bắt đầu từ Chủ nhật, bao gồm các nhãn ngày dự báo
. Chúng không phải là bản dịch trực tiếp từ các viết tắt tiếng Anh.

Các nút đã liên kết nhóm biểu tượng/nhãn của chúng với chiều rộng có sẵn. Nếu một nhãn cần
dấu ba chấm, khi di chuột hoặc tập trung vào nút sẽ hiển thị đầy đủ văn bản của nó. Hồ sơ nguồn điện
nút cũng hiển thị văn bản mô tả của chúng trong một tooltip. Mô tả công tắc dài
sẽ được xuống dòng, và các trường số cùng các nhập liệu của người dùng sẽ dành đủ không gian cho phông chữ đã chọn.
Chiều cao thẻ tăng lên với văn bản xuống dòng; sử dụng cuộn theo chiều dọc để xem các thẻ phía dưới.
Những thay đổi này giữ nguyên phông chữ đã chọn và các hành động thẻ hiện có.

See  for the installed and user paths.(/docs/argvus-taskbar/taskbar/) for the installed and user paths.

Sử dụng bảng điều khiển để xem trạng thái hiện tại và các hành động nhanh. Sử dụng [Trung tâm điều khiển](/docs/components/argvus-control-center/)khi bạn muốn thay đổi cấu hình máy tính để bàn bền vững. Ví dụ, thanh tác vụ có thể hiển thị các điều khiển về giao diện, hiển thị, mạng, âm lượng, độ sáng, thông báo, nguồn và phiên; cấu hình chi tiết về giao diện và bố cục thuộc **Trung tâm Điều khiển → Giao diện**.
Xem[thanh tác vụ và các bảng](/docs/argvus-taskbar/taskbar/)cho mối quan hệ giữa bảng điều khiển, lề thanh tác vụ và bố cục cửa sổ.
