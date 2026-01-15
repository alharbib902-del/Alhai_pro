# R2 Setup Instructions

## 1. Create Cloudflare R2 Buckets

### Login to Cloudflare Dashboard
1. Go to https://dash.cloudflare.com
2. Navigate to R2 → Overview

### Create Public Bucket (for Product Images)
```
Name: alhai-public
Location: Automatic (closest to users)
Public Access: Enabled (Read Only)
```

**CORS Configuration**:
```json
[
  {
    "AllowedOrigins": [
      "https://alhai.sa",
      "https://*.alhai.sa",
      "app://alhai"
    ],
    "AllowedMethods": ["GET", "HEAD"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 3600
  }
]
```

### Create Private Bucket (for Invoice Images)
```
Name: alhai-private
Location: Automatic
Public Access: Disabled
```

**CORS Configuration**:
```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 300
  }
]
```

---

## 2. Configure Custom Domain

1. In R2 Dashboard → `alhai-public` → Settings → Public Access
2. Click "Connect Domain"
3. Enter: `cdn.alhai.sa`
4. Cloudflare will automatically:
   - Create CNAME record in DNS
   - Issue SSL certificate
   - Enable CDN caching

Verify:
```bash
curl https://cdn.alhai.sa
# Should return "Bucket not found" (expected - bucket is empty)
```

---

## 3. Generate R2 API Credentials

1. R2 Dashboard → Manage R2 API Tokens
2. Click "Create API Token"
3. Configuration:
   ```
   Token Name: alhai-supabase-edge
   Permissions: Object Read & Write
   Buckets: 
     - alhai-public
     - alhai-private
   TTL: Never expire
   ```
4. Save these credentials (you'll only see them once):
   ```
   Access Key ID: xxxxxxxxxxxxxxxxxxxxxxxx
   Secret Access Key: yyyyyyyyyyyyyyyyyyyyyyyy
   Endpoint: https://xxxxxxxxx.r2.cloudflarestorage.com
   ```

---

## 4. Configure Supabase Secrets

```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai

# Set secrets
npx supabase secrets set \
  R2_ENDPOINT=https://xxxxxxxxx.r2.cloudflarestorage.com \
  R2_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxxxxxxx \
  R2_SECRET_ACCESS_KEY=yyyyyyyyyyyyyyyyyyyyyyyy
```

Verify:
```bash
npx supabase secrets list
# Should show R2_ENDPOINT, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY
```

---

## 5. Deploy Edge Function

```bash
# Deploy
npx supabase functions deploy upload-product-images

# Test (optional)
npx supabase functions invoke upload-product-images --body '{
  "product_id": "test-123",
  "hash": "abc123",
  "images": {
    "thumb": "...",
    "medium": "...",
    "large": "..."
  }
}'
```

---

## 6. Run Database Migration

```bash
# Via Supabase CLI
npx supabase db push

# Or manually in Supabase Dashboard → SQL Editor
# Copy and paste content from:
# supabase/migrations/20260115_add_r2_images.sql
```

Verify:
```sql
-- In SQL Editor
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'products' 
AND column_name LIKE 'image%';

-- Should show:
-- image_url, image_thumbnail, image_medium, image_large, image_hash
```

---

## 7. Test Upload (Flutter)

Add to `pubspec.yaml`:
```yaml
dependencies:
  cached_network_image: ^3.3.0
  flutter_cache_manager: ^3.3.1
  image: ^4.1.0
  crypto: ^3.0.3
```

Then:
```bash
cd alhai_designer
flutter pub get
```

Test code:
```dart
import 'package:alhai_core/src/services/image_service.dart';

final service = ImageService();
final urls = await service.uploadProductImage(
  productId: 'test-product-id',
  imageFile: File('path/to/test.jpg'),
);

print('Uploaded successfully!');
print('Thumbnail: ${urls.thumbnail}');
```

---

## 8. Verify R2 Upload

1. Go to Cloudflare R2 Dashboard
2. Open `alhai-public` bucket
3. You should see:
   ```
   products/
     └── test-product-id_thumb_abc123.webp
     └── test-product-id_medium_abc123.webp
     └── test-product-id_large_abc123.webp
   ```

4. Open in browser:
   ```
   https://cdn.alhai.sa/products/test-product-id_thumb_abc123.webp
   ```
   Should display the image

---

## ✅ Setup Complete!

Your R2 + Supabase integration is ready. Images will now:
- Upload to R2 automatically
- Be served via CDN (fast!)
- Cache for 1 year (immutable)
- Cost $0-7/month

**Next**: Integrate `ProductImage` widget in your POS screens.
