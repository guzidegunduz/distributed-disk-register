# HaToKuSe - Hata-Tolere Kuyruk Servisi

Java ve gRPC kullanarak geliştirilmiş dağıtık, hata-tolere abonelik sistemi.

## 🎥 Proje Demo Videosu
> https://youtu.be/kMgGlRqPFMM
> *Bu video; sistemin ayağa kalkışını,istemci testindeki performansını ve bir üyenin çökmesi (crash) anında sistemin verdiği hata toleransı tepkisini içermektedir.*

## 🎯 Özellikler

- ✅ Lider-Üye mimarisinde dağıtık mesajlaşma
- ✅ gRPC ile üyeler arası iletişim
- ✅ Text-based istemci protokolü (SET/GET)
- ✅ Disk üzerinde kalıcı depolama
- ✅ Dinamik üye ekleme/çıkarma
- ✅ Hata toleransı ve yük dengeleme
- ✅ Otomatik heartbeat kontrolü
- ✅ Periyodik istatistik raporlama

## 🛠️ Teknik Uygulama Detayları

- **Hibrit Protokol Yapısı:** İstemci ile Lider arasında metin tabanlı **TCP/Socket**, Lider ile Üyeler arasında ise yüksek performanslı **gRPC/Protobuf** iletişimi sağlandı.
- **Hata Toleransı Mekanizması:** `tolerance.conf` dosyasındaki değer çalışma anında kontrol edilir. Üye sayısı bu değerin altına düşerse sistem veri bütünlüğü için yazma işlemlerini otomatik reddeder.
- **Replikasyon ve Yük Dengeleme:** Mesajlar, Round-Robin algoritması kullanılarak aktif üyeler arasında paylaştırılır ve her mesajın belirlenen tolerans kadar kopyası (replica) farklı üyelerde tutulur.
- **Veri Kalıcılığı:** Mesaj eşleşmeleri Lider üzerinde (`leader_storage`), asıl veriler ise Üyeler üzerinde diskte fiziksel olarak saklanır.

## 📋 Gereksinimler

- **Java 11** veya üzeri
- **Maven 3.6+**
- **Linux/MacOS** (Bu proje Java tabanlı olduğu için tüm işletim sistemlerinde çalışır. Aşağıdaki .sh scriptleri MacOS ve Linux içindir. Windows kullanıcıları bu scriptlerin içindeki mvn exec:java ... komutlarını doğrudan terminale yazarak veya Git Bash kullanarak çalıştırabilirler.)

## 🚀 Kurulum

### 1. Projeyi İndirin

\`\`\`bash
git clone <repository-url>
cd hatokuse-system
\`\`\`

### 2. Projeyi Derleyin

\`\`\`bash
chmod +x build.sh
./build.sh
\`\`\`

Bu komut:
- Maven bağımlılıklarını indirir
- Protocol Buffer dosyalarını derler
- Java sınıflarını derler

## 📖 Kullanım

### Temel Kullanım (4 Terminal)

#### Terminal 1: Lider Sunucusunu Başlatın

\`\`\`bash
chmod +x run-leader.sh
./run-leader.sh
\`\`\`

Varsayılan portlar: gRPC=50051, İstemci=6666

#### Terminal 2-3: Üye Sunucularını Başlatın

\`\`\`bash
chmod +x run-member.sh
./run-member.sh 1 50052
\`\`\`

Başka bir terminalde:
\`\`\`bash
./run-member.sh 2 50053
\`\`\`

#### Terminal 4: İstemciyi Başlatın

\`\`\`bash
chmod +x run-client.sh
./run-client.sh
\`\`\`

### İstemci Komutları

\`\`\`
> SET 1 Merhaba Dünya
Yanıt: OK

> SET 2 İkinci mesaj
Yanıt: OK

> GET 1
Yanıt: Merhaba Dünya

> GET 2
Yanıt: İkinci mesaj

> EXIT
\`\`\`

## 🧪 Test Senaryoları

### Test Senaryosu 1: Tolerance=2, 4 Üye, 1000 Mesaj

**1. tolerance.conf dosyasını ayarlayın:**
\`\`\`
tolerance=2
\`\`\`

**2. 5 terminal açın ve şu komutları çalıştırın:**

**Terminal 1 - Lider:**
\`\`\`bash
./run-leader.sh
\`\`\`

**Terminal 2-5 - Üyeler:**
\`\`\`bash
./run-member.sh 1 50052
./run-member.sh 2 50053
./run-member.sh 3 50054
./run-member.sh 4 50055
\`\`\`

**3. Otomatik test çalıştırın:**
\`\`\`bash
mvn exec:java -Dexec.mainClass="com.hatokuse.Client" -Dexec.args="localhost 6666 --test 1000"
\`\`\`

**4. Kontrol Edilecekler:**
- ✅ 1000 mesaj dengeli dağıtıldı mı? (Her çift ~500 mesaj)
- ✅ Lider her mesajın ID'sine karşılık üye listesi tutuyor mu?
- ✅ Bir üye çökerse (Ctrl+C), lider diğer üyeden mesajı alabiliyor mu?

### Test Senaryosu 2: Tolerance=3, 6 Üye, 9000 Mesaj

**1. tolerance.conf dosyasını güncelleyin:**
\`\`\`
tolerance=3
\`\`\`

**2. 7 terminal açın:**

**Terminal 1 - Lider:**
\`\`\`bash
./run-leader.sh
\`\`\`

**Terminal 2-7 - Üyeler:**
\`\`\`bash
./run-member.sh 1 50052
./run-member.sh 2 50053
./run-member.sh 3 50054
./run-member.sh 4 50055
./run-member.sh 5 50056
./run-member.sh 6 50057
\`\`\`

**3. Otomatik test çalıştırın:**
\`\`\`bash
mvn exec:java -Dexec.mainClass="com.hatokuse.Client" -Dexec.args="localhost 6666 --test 9000"
\`\`\`

**4. Kontrol Edilecekler:**
- ✅ 9000 mesaj dengeli dağıtıldı mı? (Her üçlü grup ~4500 mesaj)
- ✅ Lider mesaj eşlemelerini doğru tutuyor mu?
- ✅ 2 üye çökerse, lider mesajları hayatta kalan üyeden alabiliyor mu?

## 📊 İstatistikler ve İzleme

### Lider İstatistikleri (Her 15 saniyede)
\`\`\`
========== LİDER İSTATİSTİKLERİ ==========
Toplam kayıtlı mesaj: 1000
Kayıtlı üye sayısı: 4
  Member-1: 500 mesaj (Durum: Canlı)
  Member-2: 500 mesaj (Durum: Canlı)
  Member-3: 500 mesaj (Durum: Canlı)
  Member-4: 500 mesaj (Durum: Canlı)
==========================================
\`\`\`

### Üye İstatistikleri (Her 10 saniyede)
\`\`\`
[Member-1] Toplam mesaj sayısı: 500
\`\`\`

## 🏗️ Proje Yapısı

\`\`\`
hatokuse-system/
├── src/
│   └── main/
│       ├── java/com/hatokuse/
│       │   ├── Leader.java          # Lider sunucu
│       │   ├── Member.java          # Üye sunucu
│       │   └── Client.java          # İstemci
│       └── proto/
│           └── hatokuse.proto       # gRPC tanımları
├── pom.xml                          # Maven yapılandırması
├── tolerance.conf                   # Hata tolerans ayarları
├── build.sh                         # Derleme script
├── run-leader.sh                    # Lider başlatma script
├── run-member.sh                    # Üye başlatma script
├── run-client.sh                    # İstemci başlatma script
└── README.md                        # Bu dosya
\`\`\`

## 🔧 Yapılandırma

### tolerance.conf
```properties
tolerance=2
