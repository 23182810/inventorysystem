# inventorysystem
# Zenity ile Basit Envanter Yönetim Sistemi

Bu proje, Zenity araçlarını kullanarak basit bir **Envanter Yönetim Sistemi** geliştirme amacı taşır. Sistemin özellikleri, işlevleri ve kullanım detayları aşağıda açıklanmıştır. Proje, kullanıcı dostu bir grafik arayüz sağlar ve ürün ile kullanıcı yönetimi gibi işlemleri destekler.

---
![image](https://github.com/user-attachments/assets/95ff48a3-2606-4f70-9ad2-43e1628ab35f)


## Özellikler

### 1. Ürün İşlemleri
- **Ürün Ekleme**: Kullanıcı, ürün adı, stok miktarı, birim fiyat ve kategori bilgilerini girerek yeni ürünler ekleyebilir. Aynı isimde bir ürün eklenmek istenirse hata mesajı görüntülenir ve işlem yapılmaz.
- **Ürün Listeleme**: Mevcut ürünler bir tablo halinde gösterilir.
 ![image](https://github.com/user-attachments/assets/098f2573-d75d-464f-8fd6-13b9fbc77248)

- **Ürün Güncelleme**: Kullanıcı, bir ürünün stok, fiyat veya kategori bilgilerini güncelleyebilir.
  ![image](https://github.com/user-attachments/assets/fc193935-e76f-47d8-8b03-2c747321a3b3),
  ![image](https://github.com/user-attachments/assets/6a025674-858a-47bb-9497-e29b8860d649)
  ![image](https://github.com/user-attachments/assets/2933de1c-9f2f-485d-b5fb-61990248570e)
    ![image](https://github.com/user-attachments/assets/3775a055-d9f8-428c-a557-2c815b427029)
  





- **Ürün Silme**: Kullanıcı, bir ürünü seçerek silebilir. Silme işlemi öncesinde onay alınır.

### 2. Kullanıcı Yönetimi
- **Yeni Kullanıcı Ekleme**: Kullanıcı adı, şifre ve rol bilgileri alınarak sisteme yeni kullanıcı eklenir.
- **Kullanıcı Listeleme**: Tüm kullanıcıların bilgileri tablo halinde görüntülenir.
- **Şifre Sıfırlama**: Yönetici, herhangi bir kullanıcının şifresini sıfırlayabilir.
- **Kilitli Kullanıcı Açma**: 3 kez hatalı giriş nedeniyle kilitlenmiş kullanıcı hesapları yönetici tarafından aktif hale getirilebilir.
- **Kullanıcı Silme**: Yönetici, belirtilen bir kullanıcıyı sistemden kaldırabilir.
- ![image](https://github.com/user-attachments/assets/6adabbcb-cf83-4910-a218-5c01ff0cf5e1)
-  ![image](https://github.com/user-attachments/assets/de253f8d-2517-41a3-8d79-413c9ce5a037)
-![image](https://github.com/user-attachments/assets/f2fc9d88-a50d-41a8-804e-c9bfea66a334)
![image](https://github.com/user-attachments/assets/453662ec-b3f1-488b-a9a4-4365ee85be42)






### 3. Raporlama
- **Stokta Azalan Ürünler**: Eşik miktarın altındaki ürünler listelenir.
- **En Yüksek Stok Miktarına Sahip Ürünler**: Belirtilen sayıda en yüksek stok miktarına sahip ürünler görüntülenir.
- ![image](https://github.com/user-attachments/assets/9820e6cb-4097-4086-a80c-adc2469fdaac)
- ![image](https://github.com/user-attachments/assets/48ce106d-0274-4192-8eb3-9ea7ef632917)
- ![image](https://github.com/user-attachments/assets/65433313-b5c6-4f99-a780-1c9b4cfd5ea4)




### 4. Program Yönetimi
- **Disk Kullanımı Gösterimi**: Programın kullandığı disk alanını gösterir.
- ![image](https://github.com/user-attachments/assets/3e1a8555-3309-4bc4-af7a-6ba644d8ba4a)

- **Dosya Yedekleme**: Ürün ve kullanıcı bilgilerini içeren dosyaları yedekler.
- ![image](https://github.com/user-attachments/assets/8a1ffc45-af08-44b3-9edd-2ba3a6a8cc48)

- **Hata Kayıtlarını Görüntüleme**: `log.csv` dosyasındaki hata kayıtlarını kullanıcıya sunar.
- ![image](https://github.com/user-attachments/assets/0622b3fb-9982-4814-95a7-ad96899f195e)


---

## Kod Açıklamaları

### Ana Modüller

#### 1. **CSV Dosyalarının Kontrolü (`check_csv_files`)**
- `depo.csv`, `kullanici.csv` ve `log.csv` dosyalarının varlığını kontrol eder.
- Eksik dosya varsa oluşturur ve log dosyasına işlemle ilgili bilgi kaydeder.

#### 2. **Ürün İşlemleri**

##### a) Ürün Ekleme (`add_product`)
- Kullanıcıdan **ürün adı**, **stok miktarı**, **birim fiyat** ve **kategori** bilgilerini alır.
- Veriler doğrulandıktan sonra `depo.csv` dosyasına kaydeder.
- Aynı isimde bir ürün zaten varsa hata mesajı gösterir ve işlem yapılmaz.

##### b) Ürün Listeleme (`list_products`)
- `depo.csv` dosyasındaki ürünleri tablo formatında gösterir.
- Dosyada ürün yoksa kullanıcıya uygun bir mesaj verir.

##### c) Ürün Güncelleme (`update_product`)
- Güncellenmek istenen ürünün adını kullanıcıdan alır.
- Eğer ürün bulunursa stok miktarı, birim fiyat ve kategori bilgileri değiştirilebilir.
- Girilen değerlerin doğruluğu kontrol edilir.

##### d) Ürün Silme (`delete_product`)
- Silinmek istenen ürün adı kullanıcıdan alınır.
- Ürün bulunduğunda Zenity üzerinden onay kutusu gösterilir. Kullanıcı onaylarsa ürün silinir.

#### 3. **Kullanıcı Yönetimi**

##### a) Yeni Kullanıcı Ekleme (`add_user`)
- Kullanıcı adı, şifre ve rol bilgileri alınıp `kullanici.csv` dosyasına kaydedilir.
- Aynı isimde bir kullanıcı zaten varsa hata mesajı gösterilir.

##### b) Kullanıcı Listeleme (`list_users`)
- Tüm kullanıcıların bilgileri tablo formatında görüntülenir.
- Dosyada kullanıcı yoksa uygun bir mesaj gösterilir.

##### c) Kullanıcı Kilitleme (`lock_user`)
- Üç başarısız giriş sonrası kullanıcı hesabını `Kilitli` durumu ile günceller.
- Kilitli kullanıcı giriş yapamaz ve Zenity'de hata mesajı gösterilir.

##### d) Kullanıcı Kilidini Açma (`unlock_user`)
- Yönetici tarafından kilitli kullanıcıların hesapları aktif hale getirilebilir.

##### e) Şifre Sıfırlama (`reset_password`)
- Yönetici, belirtilen bir kullanıcının şifresini sıfırlayabilir.
- Yeni şifre Zenity üzerinden alınır ve şifre hash'lenerek kaydedilir.

##### f) Kullanıcı Silme (`delete_user`)
- Belirtilen bir kullanıcı sistemden tamamen kaldırılır.

#### 4. **Raporlama**

##### a) Stokta Azalan Ürünler (`low_stock_report`)
- Kullanıcıdan bir stok eşiği alır.
- Stok miktarı belirlenen eşikten az olan ürünleri listeler.

##### b) En Yüksek Stok Miktarına Sahip Ürünler (`high_stock_report`)
- Kullanıcıdan bir ürün sayısı alır.
- En yüksek stok miktarına sahip ürünleri sıralar ve listeler.

#### 5. **Program Yönetimi**

##### a) Disk Kullanımı Gösterimi (`show_disk_usage`)
- Programın bulunduğu dizindeki disk kullanımını hesaplar ve kullanıcıya gösterir.

##### b) Dosya Yedekleme (`backup_files`)
- `depo.csv` ve `kullanici.csv` dosyalarının yedeklerini belirli bir dizine alır.
- Yedekleme işlemi hakkında bilgi verir.

##### c) Hata Kayıtlarını Görüntüleme (`view_logs`)
- `log.csv` dosyasındaki hata kayıtlarını kullanıcıya sunar.
- Dosyada hata kaydı yoksa uygun bir mesaj gösterir.

#### 6. **Hata Yönetimi (`log_error`)**
- Herhangi bir hata meydana geldiğinde bu hata, kullanıcı adı ve zaman damgasıyla birlikte `log.csv` dosyasına kaydedilir.

---

## Kullanım Talimatları

1. **Sistemi Çalıştırma**
   ```bash
    envanter_yonetim.sh
   ```

2. **Giriş**
   - Kullanıcı adı ve şifre ile giriş yapılır.
   - Hatalı giriş yapıldığında Zenity hata mesajı gösterir.

3. **Menü Kullanımı**
   - Yönetici: Tüm işlevlere erişebilir.
   - Kullanıcı: Sadece listeleme ve raporlama işlevlerini gerçekleştirebilir.

---

## Teknik Detaylar

- Linux komutları (`awk`, `grep`, `sed`, `df`, `touch`, `cp`) işlevlerine uygun şekilde kullanılmıştır.
- Zenity araçları (`forms`, `list`, `error`, `question`) grafik arayüz için kullanılmıştır.
- Hatalar `log.csv` dosyasına kaydedilir.

---

## Değerlendirme Kriterlerine Uygunluk

### A. Fonksiyonel Doğruluk (30 Puan)
1. **Ana İşlevler**: Ürün ekleme, listeleme, güncelleme ve silme işlemleri eksiksiz çalışmaktadır.
2. **Kullanıcı Yönetimi**: Kullanıcı ekleme, listeleme, güncelleme ve silme işlevleri tamamlanmıştır.
3. **Hatalı Giriş Yönetimi**: Üç hatalı giriş sonrası kilitleme ve yönetici tarafından kilit açma mekanizması çalışmaktadır.



