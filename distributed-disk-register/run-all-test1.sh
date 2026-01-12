#!/bin/bash

echo "=========================================="
echo "HaToKuSe - Test 1 Otomatik Başlatma"
echo "=========================================="
echo ""

# Tolerance ayarla
echo "tolerance=2" > tolerance.conf
echo "✓ Tolerance seviyesi 2 olarak ayarlandı"

# Temizlik
pkill -f "com.hatokuse" 2>/dev/null
sleep 2

# Derleme
echo ""
echo "Proje derleniyor..."
mvn clean compile -q
if [ $? -ne 0 ]; then
    echo "✗ Derleme başarısız!"
    exit 1
fi
echo "✓ Derleme tamamlandı"

# Lider başlat
echo ""
echo "Lider başlatılıyor..."
mvn exec:java -Dexec.mainClass="com.hatokuse.Leader" -Dexec.args="50051 8080" > leader.log 2>&1 &
LEADER_PID=$!
sleep 3
echo "✓ Lider başlatıldı (PID: $LEADER_PID)"

# Üyeleri başlat
echo ""
echo "Üyeler başlatılıyor..."
for i in {1..4}; do
    PORT=$((50051 + i))
    mvn exec:java -Dexec.mainClass="com.hatokuse.Member" -Dexec.args="$i $PORT" > member$i.log 2>&1 &
    echo "✓ Member-$i başlatıldı (Port: $PORT)"
    sleep 2
done

echo ""
echo "=========================================="
echo "Tüm sunucular hazır!"
echo "=========================================="
echo ""
echo "Logları görüntülemek için:"
echo "  tail -f leader.log"
echo "  tail -f member1.log"
echo ""
echo "Test istemcisini başlatmak için:"
echo "  mvn exec:java -Dexec.mainClass=\"com.hatokuse.Client\" -Dexec.args=\"localhost 8080 --test 1000\""
echo ""
echo "Tüm süreçleri durdurmak için:"
echo "  pkill -f \"com.hatokuse\""
echo ""
