#!/bin/bash

# CSV Dosyalarının Kontrolü
function check_csv_files() {
    for file in "depo.csv" "kullanici.csv" "log.csv"; do
        if [ ! -f "$file" ]; then
            touch "$file"
            echo "$file oluşturuldu."
        fi
    done
}

# Ürün Ekleme
function add_product() {
    local product_info=$(zenity --forms --title="Ürün Ekle" \
        --text="Ürün bilgilerini giriniz:" \
        --add-entry="Ürün Adı" \
        --add-entry="Stok Miktarı" \
        --add-entry="Birim Fiyatı" \
        --add-entry="Kategori")

    local name=$(echo "$product_info" | cut -d "|" -f1)
    local stock=$(echo "$product_info" | cut -d "|" -f2)
    local price=$(echo "$product_info" | cut -d "|" -f3)
    local category=$(echo "$product_info" | cut -d "|" -f4)

    if [[ -z "$name" || -z "$stock" || -z "$price" || -z "$category" ]]; then
        zenity --error --text="Tüm alanlar doldurulmalıdır."
        return
    fi

    if ! [[ "$stock" =~ ^[0-9]+$ ]] || ! [[ "$price" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        zenity --error --text="Geçersiz stok veya fiyat değeri."
        return
    fi

    if grep -q "^.*,${name}," depo.csv; then
        zenity --error --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz."
        log_error "Ürün adı zaten mevcut." "$name"
        return
    fi

    local id=$(($(tail -n 1 depo.csv | cut -d "," -f1) + 1))
    [ -z "$id" ] && id=1
    echo "$id,$name,$stock,$price,$category" >> depo.csv
    zenity --info --text="Ürün başarıyla eklendi."
}

# Ürün Listeleme
function list_products() {
    if [ ! -s depo.csv ]; then
        zenity --info --text="Hiç ürün bulunmamaktadır."
    else
        local products=$(awk -F"," '{print $1 " " $2 " " $3 " " $4 " " $5}' depo.csv)
        zenity --list --title="Ürünler" --column="ID" --column="Ürün" --column="Stok" --column="Fiyat" --column="Kategori" $(echo "$products" | tr " " "\n")
    fi
}

# Ürün Güncelleme
function update_product() {
    local product_name=$(zenity --entry --title="Ürün Güncelle" --text="Güncellemek istediğiniz ürünün adını giriniz:")
    local product_line=$(grep -n "^.*,${product_name}," depo.csv | cut -d":" -f1)

    if [ -z "$product_line" ]; then
        zenity --error --text="Ürün bulunamadı!"
    else
        local new_stock=$(zenity --entry --title="Stok Güncelle" --text="Yeni stok miktarını giriniz:")
        local new_price=$(zenity --entry --title="Fiyat Güncelle" --text="Yeni birim fiyatını giriniz:")
        local new_category=$(zenity --entry --title="Kategori Güncelle" --text="Yeni kategoriyi giriniz:")

        if [[ "$new_stock" =~ ^[0-9]+$ ]] && [[ "$new_price" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            sed -i "${product_line}s/.*/$(cut -d"," -f1-2 depo.csv | sed -n ${product_line}p),$new_stock,$new_price,$new_category/" depo.csv
            zenity --info --text="Ürün başarıyla güncellendi."
        else
            zenity --error --text="Geçersiz stok veya fiyat değeri."
        fi
    fi
}

# Ürün Silme
function delete_product() {
    local product_name=$(zenity --entry --title="Ürün Sil" --text="Silmek istediğiniz ürünün adını giriniz:")
    local product_line=$(grep -n "^.*,${product_name}," depo.csv | cut -d":" -f1)

    if [ -z "$product_line" ]; then
        zenity --error --text="Ürün bulunamadı!"
    else
        if zenity --question --text="Bu ürünü silmek istediğinize emin misiniz?"; then
            sed -i "${product_line}d" depo.csv
            zenity --info --text="Ürün başarıyla silindi."
        fi
    fi
}

# Raporlama: Stokta Azalan Ürünler
function low_stock_report() {
    local threshold=$(zenity --entry --title="Stokta Azalan Ürünler" --text="Eşik stok miktarını giriniz:")
    if [[ "$threshold" =~ ^[0-9]+$ ]]; then
        local low_stock=$(awk -F"," -v t="$threshold" '$3 < t {print $1 " " $2 " " $3 " " $4 " " $5}' depo.csv)
        if [ -z "$low_stock" ]; then
            zenity --info --text="Stokta azalan ürün yok."
        else
            zenity --list --title="Stokta Azalan Ürünler" --column="ID" --column="Ürün" --column="Stok" --column="Fiyat" --column="Kategori" $(echo "$low_stock" | tr " " "\n")
        fi
    else
        zenity --error --text="Geçersiz eşik değeri!"
    fi
}

# Raporlama: En Yüksek Stok Miktarına Sahip Ürünler
function high_stock_report() {
    local threshold=$(zenity --entry --title="En Yüksek Stok Raporu" --text="Gösterilecek ürün sayısını giriniz:")
    if [[ "$threshold" =~ ^[0-9]+$ ]]; then
        # En yüksek stok miktarına göre sıralama ve seçme
        local high_stock=$(sort -t"," -k3 -nr depo.csv | head -n "$threshold")
        
        if [ -z "$high_stock" ]; then
            zenity --info --text="Yeterli ürün verisi yok."
        else
            # Zenity için uygun formatta verileri hazırlayın
            local formatted_data=""
            while IFS=',' read -r id name stock price category; do
                formatted_data+="$id|$name|$stock|$price|$category\n"
            done <<< "$high_stock"

            # Zenity ile listeleme
            echo -e "$formatted_data" | zenity --list \
                --title="En Yüksek Stok Miktarına Sahip Ürünler" \
                --column="ID" --column="Ürün" --column="Stok" --column="Fiyat" --column="Kategori" \
                --separator="|"
        fi
    else
        zenity --error --text="Geçersiz giriş!"
    fi
}

# Program Yönetimi
function show_disk_usage() {
    local usage=$(df -h . | awk 'NR==2 {print $3 "/" $2}')
    zenity --info --title="Disk Kullanımı" --text="Diskte kullanılan alan: $usage"
}

function backup_files() {
    local backup_dir="yedek_$(date +%Y%m%d%H%M%S)"
    mkdir "$backup_dir"
    cp depo.csv kullanici.csv "$backup_dir"
    zenity --info --title="Yedekleme" --text="Dosyalar $backup_dir dizinine yedeklendi."
}

function view_logs() {
    if [ ! -s log.csv ]; then
        zenity --info --text="Hiç hata kaydı bulunmamaktadır."
    else
        zenity --text-info --title="Hata Kayıtları" --filename=log.csv
    fi
}

# Kullanıcı Yönetimi
function add_user() {
    local user_info=$(zenity --forms --title="Yeni Kullanıcı Ekle" \
        --text="Kullanıcı bilgilerini giriniz:" \
        --add-entry="Kullanıcı Adı" \
        --add-entry="Şifre" \
        --add-entry="Rol (Yönetici/Kullanıcı)")

    local username=$(echo "$user_info" | cut -d "|" -f1)
    local password=$(echo "$user_info" | cut -d "|" -f2 | md5sum | awk '{print $1}')
    local role=$(echo "$user_info" | cut -d "|" -f3)

    if grep -q "^$username," kullanici.csv; then
        zenity --error --text="Bu kullanıcı zaten mevcut."
    else
        local id=$(($(tail -n 1 kullanici.csv | cut -d "," -f1)+1))
        echo "$id,$username,$password,$role" >> kullanici.csv
        zenity --info --text="Kullanıcı başarıyla eklendi."
    fi
}

function list_users() {
    if [ ! -s kullanici.csv ]; then
        zenity --info --text="Hiç kullanıcı bulunmamaktadır."
    else
        local users=$(awk -F"," '{print $1 " " $2 " " $3 " " $4}' kullanici.csv)
# Kullanıcıyı kilitleme fonksiyonu
function lock_user() {
    local username=$1
    # Kilitli olduğunu log dosyasına kaydet
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Hata: Kullanıcı $username kilitlendi (3 hatalı giriş)" >> log.csv
    
    # Kullanıcıyı kilitle (kullanici.csv'ye ekle)
    sed -i "s/^$username,.*/&,(Kilitli)/" kullanici.csv
}
        zenity --list --title="Kullanıcılar" --column="ID" --column="Adı" --column="Şifre (MD5)" --column="Rol" $(echo "$users" | tr " " "\n")
    fi
}

# Kullanıcı giriş fonksiyonu
function user_login() {
    local username=$(zenity --entry --title="Giriş" --text="Kullanıcı Adı:")
    local password=$(zenity --password --title="Giriş")
    local stored_data=$(grep "^$username," kullanici.csv)

    if [ -z "$stored_data" ]; then
        zenity --error --text="Kullanıcı bulunamadı!"
        exit 1
    fi

    local stored_password=$(echo "$stored_data" | cut -d "," -f3)
    local role=$(echo "$stored_data" | cut -d "," -f4)
    local status=$(echo "$stored_data" | cut -d "," -f5)

    # Kullanıcı kilitli mi kontrolü
    if [[ "$status" == "Kilitli" ]]; then
        zenity --error --text="Hesabınız kilitlenmiştir. Lütfen yöneticinizle iletişime geçin."
        exit 1
    fi

    if [ "$stored_password" == "$(echo -n "$password" | md5sum | awk '{print $1}')" ]; then
        zenity --info --text="Giriş başarılı."
        if [ "$role" == "Yönetici" ]; then
            admin_menu
        else
            user_menu
        fi
    else
        zenity --error --text="Hatalı parola!"
        log_error "Hatalı parola." "$username"

 # Hatalı giriş sayısını kontrol et ve güncelle
        local failed_attempts=$(grep "^$username," log.csv | grep -c "Hatalı parola")
        if [ "$failed_attempts" -ge 3 ]; then
            lock_user "$username"
            zenity --error --text="Hesabınız 3 hatalı giriş sonrası kilitlenmiştir."
            exit 1
        fi
    fi
}
# Şifre Sıfırlama
function reset_password() {
    local username=$(zenity --entry --title="Şifre Sıfırlama" --text="Şifresi sıfırlanacak kullanıcı adını giriniz:")
    local user_line=$(grep -n "^$username," kullanici.csv | cut -d":" -f1)

    if [ -z "$user_line" ]; then
        zenity --error --text="Kullanıcı bulunamadı!"
    else
        local new_password=$(zenity --password --title="Yeni Şifre" --text="Yeni şifreyi giriniz:")
        local hashed_password=$(echo -n "$new_password" | md5sum | awk '{print $1}')
        sed -i "${user_line}s/\(.*\),.*/\1,$hashed_password/" kullanici.csv
        zenity --info --text="Şifre başarıyla sıfırlandı."
    fi
}

# Kullanıcıyı Kilitleme
function lock_user() {
    local username=$1
    sed -i "s/^$username,\(.*\),\(.*\),\(.*\)\$/&Kilitli/" kullanici.csv
    log_error "Kullanıcı kilitlendi." "$username"
}

# Kilitli Kullanıcı Açma
function unlock_user() {
    local username=$(zenity --entry --title="Kilit Açma" --text="Kilitini açmak istediğiniz kullanıcı adını giriniz:")
    local user_line=$(grep -n "^$username," kullanici.csv | cut -d":" -f1)

    if [ -z "$user_line" ]; then
        zenity --error --text="Kullanıcı bulunamadı!"
    else
        sed -i "${user_line}s/,(Kilitli)//" kullanici.csv
        zenity --info --text="Kullanıcı kilidi başarıyla açıldı."
    fi
}

# Kullanıcı Silme
function delete_user() {
    local username=$(zenity --entry --title="Kullanıcı Sil" --text="Silmek istediğiniz kullanıcı adını giriniz:")
    local user_line=$(grep -n "^$username," kullanici.csv | cut -d":" -f1)

    if [ -z "$user_line" ]; then
        zenity --error --text="Kullanıcı bulunamadı!"
    else
        if zenity --question --text="Bu kullanıcıyı silmek istediğinize emin misiniz?"; then
            sed -i "${user_line}d" kullanici.csv
            zenity --info --text="Kullanıcı başarıyla silindi."
        fi
    fi
}


# Hata Kaydı
function log_error() {
    local error_message=$1
    local username=$2
    local product_info=$3
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local error_id=$(($(wc -l < log.csv) + 1))
    echo "$error_id,$timestamp,$username,$product_info,$error_message" >> log.csv
}

# Ana Menü
# Kullanıcı Menüleri ve Yönetici İşlevleri
function admin_menu() {
    local choice=$(zenity --list --title="Ana Menü" \
        --column="İşlem" --column="Açıklama" \
        1 "Ürün Ekle" \
        2 "Ürün Listele" \
        3 "Ürün Güncelle" \
        4 "Ürün Sil" \
        5 "Kullanıcı Ekle" \
        6 "Kullanıcı Listele" \
        7 "Kullanıcı Şifresini Sıfırla" \
        8 "Kilitli Kullanıcı Aç" \
        9 "Stokta Azalan Ürünler Raporu" \
        10 "En Yüksek Stok Raporu" \
        11 "Diskte Kapladığı Alanı Göster" \
        12 "Diske Yedek Al" \
        13 "Hata Kayıtlarını Görüntüle" \
        14 "Kullanıcı Sil" \
        15 "Çıkış")
        
   case $choice in
        1) add_product ;;
        2) list_products ;;
        3) update_product ;;
        4) delete_product ;;
        5) add_user ;;
        6) list_users ;;
        7) reset_password ;;
        8) unlock_user ;;
        9) low_stock_report ;;
        10) high_stock_report ;;
        11) show_disk_usage ;;
        12) backup_files ;;
        13) view_logs ;;
        14) delete_user ;;  # Yeni seçenek eklendi
        15) exit 0 ;;
        *) zenity --error --text="Geçersiz seçim." ;;
    esac
    admin_menu
}

function user_menu() {
    local choice=$(zenity --list --title="Ana Menü" \
        --column="İşlem" --column="Açıklama" \
        1 "Ürün Listele" \
        2 "Çıkış")

    case $choice in
        1) list_products ;;
        2) exit 0 ;;
        *) zenity --error --text="Geçersiz seçim." ;;
    esac
    user_menu
}

# Ana Program
check_csv_files
user_login

