---
title: Control Panel
description: Quickshell kontrol paneli kartlarını kullanın.
---

Kontrol Paneli, aktif oturum için hızlı erişim Quickshell yüzeyidir. Durumu incelemek veya sık yapılan bir işlemi tam ayarlar uygulamasını açmadan gerçekleştirmek için kullanılan yerdir.

Panel, paylaşılan `argvus-i18n` kataloglarını kullanır. **Kontrol Merkezi → Bölge ve Dil** bölümünde farklı bir dil uygulandığında, Kontrol Paneli servisi otomatik olarak yeniden başlatılır, böylece seçilen katalog yüklenir.

Kontrol Paneli, görev çubuğu kenarını ARGVUS Focus ve ARGVUS Clock ile paylaşır. Panel açıldığında her iki açılır pencere önce kapatılır; Focus veya Clock açıldığında panel kapanır.

## Denetim Masası mı yoksa Kontrol Merkezi mi?

Mevcut durumu ve hızlı işlemleri görmek için paneli kullanın. Kalıcı masaüstü yapılandırmasını değiştirmek istediğinizde [Denetim Merkezi](/docs/components/argvus-control-center/) kullanın. Örneğin, panel görünüm, ekran, ağ, ses, parlaklık, bildirim, güç ve oturum kontrollerini gösterebilir; detaylı görsel ve düzen yapılandırması **Denetim Merkezi → Görünüm** içinde yer alır.

## Cards

Mevcut kart kaydı şunları içerir:

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

Bazı kartlar koşulludur. Bluetooth özelliği mevcut olmadığında Bluetooth gizlenir. Ne desteklenen arka ışık ne de monitör kontrol aracı mevcut olduğunda Parlaklık gizlenir. Bu nedenle, kart listesi her makinenin sağlayabileceği kontrolleri garanti etmek yerine mevcut makineyi yansıtır.

## Görünürlük ve sıra

Panelin **Görünüm → Denetim Masası** sayfası, kartları etkinleştirmenize, devre dışı bırakmanıza ve yeniden sıralamanıza olanak tanır. Paketlenmiş yardımcı da aynı durumu gösterir:

```sh
cards-config.sh status
cards-config.sh set <card> enabled
cards-config.sh set <card> disabled
cards-config.sh move <card> <index>
```

Mümkün olduğunda UI'yi kullanın. Panel durumu kullanıcı yapılandırması olarak saklanır; oluşturulan Hyprland yerleşim dosyalarından ayrıdır.

Bir kartı devre dışı bırakmak, onu panelden gizler; arkasındaki sağlayıcıyı kaldırmaz. Yeniden sıralama kartların sunulma sırasını değiştirir. Mevcut yardımcıda `reset` alt komutu yoktur. Kullanıcı kartı tercihi kaldırılırsa, sağlayıcı durumu bilinen kartlara döndürür; varsayılan olarak etkin ve paketlenmiş sırada.

Kontrol Paneli görünüm kartı artık genel bir Şeffaflık ayarını yönetmiyor. Şeffaflık ve Bulanıklığı Kontrol Paneli için bağımsız olarak yapılandırın: **Kontrol Merkezi → Görünüm → Kontrol Paneli**. Kontrol Paneli ana **Etkinleştir** anahtarı hâlâ tüm yüzeyi ve hizmetini kontrol eder. `cards-config.sh master set` paneli yalnızca anahtar değiştirildiğinde yeniden başlatır veya durdurur; zaten sahip olduğu değeri ayarlamak, yalnızca etkin bir panelin çalışmasını sağlar.

## Klavye navigasyonu

Panel açıldığında, içeriği kaydırmak için **↑/↓** kullanın. **Tab** butonlar, kontroller ve alanlar arasında ileri hareket eder; **Shift+Tab** geri hareket eder. Butonlar, vurgulanmış bir çerçeve ile odaklanmayı gösterir ve **Enter** veya **Space** ile etkinleştirilebilir. Kaydırıcılar ve metin alanları bu tuşları kendi ayarları veya düzenlemeleri için kullanır. **Esc** paneli kapatır.

## Masaüstünün geri kalanı ile senkronize kalmak

Bildirimler kartı, Rahatsız Etmeyin etkin olduğunda geçmişini gizler. Bu süre zarfında alınan bildirimler Dunst'ta kalır ve Rahatsız Etmeyin kapatıldıktan sonra kartta tekrar görünür.

Kartlar masaüstünün canlı durumunu gösterir. Başka bir yerde yapılan bir değişiklik (Kontrol Merkezi, görev çubuğu, bir klavye kısayolu veya `argvus` komut satırı) paneli yeniden başlatmadan gösterir:

| Kart | Durumun kaynağı | Ne zaman yenilenir |
| --- | --- | --- |
| User | `getent passwd` | every 3 s while the panel is open |
| Ses Düzeyi | PipeWire varsayılan çıkışı (`wpctl`) and `pactl subscribe`olaylar | her ses olayında hemen; güvenlik ağı olarak her 2 s |
| Görünüm (Telemetri, Animasyonlar ve Efektler) | the `/effects`bölümü`argvus config`| panel açıkken her 2 saniyede bir |
| Power | `powerprofilesctl` | every 3 s while the panel is open |
| Hava Durumu | konum dosyası ve wttr.in/Open-Meteo sağlayıcıları | panel açıldığında ve her 15 dakikada bir; sekmeler mevcut koşullar ile önümüzdeki yedi gün için günlük tahmin arasında geçiş yapar |

Görünüm kartının iki bağımsız anahtarı vardır. **Animasyonlar** `argvus effects-toggle animations toggle` çalıştırır ve hareket eden her şeyi kontrol eder. **Efektler** `argvus effects-toggle effects toggle` çalıştırır ve Terminal, Başlatıcı, Widget Telemetri, Denetim Masası ve Görev Çubuğu’nun bulanıklığını ve şeffaflığını birlikte değiştirir; bunlardan en az biri açıksa açık olarak görünür. **SUPER + F6** (`argvus effects-toggle toggle`) ikisini birden değiştirir. Herhangi birini değiştirmek, Hyprland’i ve tema tüketicilerini yerinde yeniden yükler: Waybar stillerini yeniden okur, panel IPC üzerinden yeniden yüklenir ve Dunst, Rahatsız Etmeyin aktif değilse yapılandırmasını yeniden yükler; aktifse, yeniden yükleme DND kapatılana kadar ertelenir. Hiçbir şey yeniden başlatılmaz ve hiçbir yükleme ekranı görünmez.

Scrolling on the taskbar volume icon and the media keys use 

, which applies the change to PipeWire and also records the volume in `argvus config audio`. A configuration reload therefore does not restore an old volume.

## Oturum davranışı

 is started by `/audio` argvus-session  `argvus-control-panel.service` . Opening and closing the panel changes the session panel state, but does not mean that every card action is persistent configuration. Network, audio, power and display actions may be handed to their providers or to the current desktop session.

Panel, görev çubuğu kenar boşlukları ve pencere düzeni arasındaki ilişki için [görev çubuğu ve panellere](/docs/argvus-taskbar/taskbar/) bakın.

## Gece Lambası

Görüntü kartı, bir Gece Lambası açma/kapama anahtarı ve aktif sıcaklığı gösterir. Köşeleri ve animasyonları, Sticky ve Spaced düzenleri de dahil olmak üzere diğer panel anahtarlarıyla aynı tema öğelerini takip eder. Anahtarın bir sınırı yoktur ve diğer panel anahtarları gibi bir işaretçi-el imleci kullanır.  `argvus-session` `argvus config display night-light status|toggle` kullanır, açıkken her iki saniyede bir yoklama yapar ve bir işlemden sonra tekrar veri çeker. Arka uç kullanılamadığında satır gizlenir; bir işlem başarısız olursa bir hata gösterilir. Zamanlama ve sıcaklık **Kontrol Merkezi > Masaüstü & Giriş > Görüntüler > Gece Lambası** bölümünden yapılandırılır. Planlanmış manuel geçiş, bir sonraki geçişe kadar sürer; aksi takdirde etkinleştirme kalıcıdır.

Görev çubuğu takvimi, ARGVUS Odak, ARGVUS Saat ve Denetim Masası birbirini dışlar: birini açmak diğerlerini kapatır.

## Kompakt çok dilli etiketler

Hava durumu sekmeleri ortak kataloğu kullanır (mevcut koşullar ve yedi gün). Hava durumu
ölçümleri eşit genişlikte sütunlar kaplar; etiketler kayar ve değerler hizalı kalır.
Takvim hafta günü kısaltmaları bölgeye özgüdür ve Pazar-önceliklidir,
tahmin günü etiketlerini içerir. Bunlar İngilizce kısaltmaların kelime kelime çevirisi değildir.

Düğmeler simge/etiket grubunu kullanılabilir genişliğe bağladı. Bir etiketin
üç nokta (...) gerektirmesi durumunda, düğmenin üzerine gelmek veya odaklanmak tam metni gösterir. Güç profili
düğmeler ayrıca açıklayıcı metinlerini bir araç ipucunda gösterir. Uzun anahtar açıklamaları
Satır kaydırma ve sayısal alanlar ile kullanıcı girdileri, seçilen font için yeterli alan ayırır.
Kart yüksekliği sarılmış metinle artar; alt kartları görmek için dikey kaydırmayı kullanın.
Bu değişiklikler seçili yazı tipini ve mevcut kart eylemlerini korur.
