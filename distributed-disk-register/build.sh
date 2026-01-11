#!/bin/bash

echo "=========================================="
echo "HaToKuSe Projesi Derleniyor..."
echo "=========================================="

# Maven ile projeyi derle
mvn clean compile

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Derleme başarılı!"
    echo "=========================================="
    echo ""
    echo "Kullanım:"
    echo "  1. Lideri başlat:   ./run-leader.sh"
    echo "  2. Üyeleri başlat:  ./run-member.sh <member_id> <port>"
    echo "  3. İstemci başlat:  ./run-client.sh"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "Derleme BAŞARISIZ!"
    echo "=========================================="
    exit 1
fi
