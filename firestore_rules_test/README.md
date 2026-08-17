# Firestore Güvenlik Kuralları Testi

`../firestore.rules` dosyasını Firebase emülatörüne karşı test eder.
İki kullanıcı ("A" hesap sahibi, "B" saldırgan) senaryosuyla, kuralların
hassas veriyi (e-posta, sağlık durumu) ve gönderi bütünlüğünü koruduğunu doğrular.

## Kurulum (bir kez)

```bash
cd firestore_rules_test
npm install
```

Gereksinimler: Node, Java (emülatör için) ve `firebase-tools` (global CLI).

## Çalıştırma

```bash
npm test
```

Emülatörü başlatır, testleri çalıştırır, kapatır. Beklenen çıktı: `SONUÇ: 13 geçti, 0 kaldı`.

## Ne zaman çalıştırmalı

`firestore.rules` dosyasında **her değişiklikten sonra** — deploy etmeden önce.
Bir kuralı bozarsan test kırmızıya döner (regresyon koruması).

> Not: Loglardaki `PERMISSION_DENIED` satırları normaldir — bunlar saldırı
> denemelerinin *başarıyla engellendiğini* gösterir.
